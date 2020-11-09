local ctx = require"lib.ctx"
local U = require"lib.util"

local zcl = U.object:new{
  device = nil,
  ep = nil,
}

local txseqs={}

function zcl:send_af(cluster, data, global, waitreply, retries)
  retries = retries or 1
  local ok, msg
  local txseq = ((txseqs[self.device] or 0) + 1) % 256
  txseqs[self.device] = txseq
  for retry=1,retries do
    data.FrameControl = { global and "FrameTypeGlobal" or "FrameTypeLocal", "DirectionToServer" }
    if not waitreply then table.insert(data.FrameControl, "DisableDefaultResponse") end
    data.TransactionSequenceNumber = txseq

    ok = self.device:tx_zcl{
      dst = self.device.ieeeaddr,
      dst_ep = self.ep,
      cluster = cluster,
      data = data
    }

    if ok then
      if waitreply then
        local filter = function(msg)
          return msg.cluster == cluster
            and msg.data.TransactionSequenceNumber == txseq
        end
        ok, msg = ctx:wait({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, filter, waitreply)
        if ok then break end
      else
        return txseq
      end
    end
  end
  return ok, msg
end

function zcl:get_attribute_list(cluster)
  local attributes = {}
  local done = false
  local start = 0
  while not done do
    local ok, msg = self:send_af(cluster, {
        GeneralCommandFrame = {
          CommandIdentifier = "DiscoverAttributes",
          DiscoverAttributes = {
            StartAttributeIdentifier = start,
            MaximumAttributeIdentifiers = 20
          }
        }
      }, true, 1, 3)
    if not ok then return end
    if not msg.data
      or not msg.data.GeneralCommandFrame
      or not msg.data.GeneralCommandFrame.DiscoverAttributesResponse
      or not msg.data.GeneralCommandFrame.DiscoverAttributesResponse.AttributeInformations then
      return
    end
    local lastattr = 0
    for _, attr in ipairs(msg.data.GeneralCommandFrame.DiscoverAttributesResponse.AttributeInformations) do
      lastattr = attr.AttributeIdentifier
      table.insert(attributes, lastattr)
    end
    if msg.data.GeneralCommandFrame.DiscoverAttributesResponse.DiscoveryComplete then
      done = true
    else
      start = lastattr + 1
    end
  end
  --U.DEBUG("zcl", "cluster %04x, attributes: %s", cluster, U.dump(attributes))
  return attributes
end
function zcl:get_attributes(cluster, attributes, at_once)
  at_once = at_once or 5
  local values = {}
  for i=0,#attributes,at_once do
    local attr_list = {}
    for j=i,i+at_once-1 do
      if attributes[j] then table.insert(attr_list, attributes[j]) end
    end
    local ok, msg = self:send_af(cluster, {
        GeneralCommandFrame = {
          CommandIdentifier = "ReadAttributes",
          ReadAttributes = {
            AttributeIdentifiers = attr_list
          }
        }
      }, true, 1.5, 3)
    if ok
      and msg.data
      and msg.data.GeneralCommandFrame
      and msg.data.GeneralCommandFrame.ReadAttributesResponse
      and msg.data.GeneralCommandFrame.ReadAttributesResponse.ReadAttributeStatusRecords
    then
      for _, r in ipairs(msg.data.GeneralCommandFrame.ReadAttributesResponse.ReadAttributeStatusRecords) do
        if r.Status == "SUCCESS" then
          values[r.AttributeIdentifier] = r.Attribute.Value
        end
      end
    end
  end
  return values
end
function zcl:set_attributes(cluster, attribs)
  local attrlist = {}
  for _, a in ipairs(attribs) do
    table.insert(attrlist, {
      AttributeIdentifier = a[1],
      Attribute = {
        Type = a[2],
        Value = a[3]
      }
    })
  end
  self:send_af(cluster, {
    GeneralCommandFrame = {
      CommandIdentifier = "WriteAttributes",
      WriteAttributes = {
        WriteAttributeRecords = attrlist
      }
    }
  }, true)
end

function zcl:identify(time)
  self:send_af(0x0003, {
    IdentifyClusterFrame = { CommandIdentifier = "Identify", Identify = { IdentifyTime = time or 4 } }
  })
end

function zcl:add_group(group_id, group_name)
  self:send_af(0x0004, {
    GroupsClusterFrame = { CommandIdentifier = "AddGroup", AddGroup = { GroupId = group_id, GroupName = group_name or "" } }
  })
end
function zcl:get_group_membership()
  local ok, msg = self:send_af(0x0004, {
    GroupsClusterFrame = { CommandIdentifier = "GetGroupMembership", GetGroupMembership = { Groups = {} } }
  }, false, 2)
  if ok
    and msg.data
    and msg.data.GroupsClusterFrame
    and msg.data.GroupsClusterFrame.GetGroupMembershipResponse
    and msg.data.GroupsClusterFrame.GetGroupMembershipResponse.Groups
  then
    return msg.data.GroupsClusterFrame.GetGroupMembershipResponse.Groups, msg.data.GroupsClusterFrame.GetGroupMembershipResponse.Capacity
  end
end
function zcl:remove_group(group_id)
  self:send_af(0x0004, {
    GroupsClusterFrame = { CommandIdentifier = "RemoveGroup", RemoveGroup = { GroupId = group_id } }
  })
end

function zcl:switch(cmd)
  self:send_af(0x0006, {
    OnOffClusterFrame = { CommandIdentifier = cmd }
  }, false, nil, 3)
end

function zcl:check_on_off()
  local is_on = self:get_attributes(0x0006, {0})
  return is_on and is_on[0]
end

function zcl:color(x, y, transition_time)
  x = x or 0.9999
  x = (x < 1.0) and (x * 0xFFFE) or x
  y = y or 0.9999
  y = (y < 1.0) and (y * 0xFFFE) or y
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "MoveToColor",
      MoveToColor = {
        ColorX = x,
        ColorY = y,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, nil, 3)
end
function zcl:hue_sat(hue, sat, transition_time)
  hue = hue or 0.9999
  hue = (hue < 1.0) and (hue * 0xFE) or hue
  sat = sat or 0.9999
  sat = (sat < 1.0) and (sat * 0xFE) or sat
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "MoveToHueAndSaturation",
      MoveToHueAndSaturation = {
        Hue = hue,
        Saturation = sat,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, nil, 3)
end
function zcl:ehue_sat(hue, sat, transition_time)
  hue = hue or 0.9999
  hue = (hue < 1.0) and (hue * 0xFFFE) or hue
  sat = sat or 0.9999
  sat = (sat < 1.0) and (sat * 0xFE) or sat
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "EnhancedMoveToHueAndSaturation",
      EnhancedMoveToHueAndSaturation = {
        EnhancedHue = hue,
        Saturation = sat,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, nil, 3)
end

function zcl:ctemp(mireds, transition_time)
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "MoveToColorTemperature",
      MoveToColorTemperature = {
        ColorTemperatureMireds = mireds or 3000,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, nil, 3)
end
function zcl:check_ctemp()
  local ctemp = self:get_attributes(0x0300, {7,0x400b,0x400c}) or {}
  return ctemp[7], ctemp[0x400b], ctemp[0x400c]
end
--[[
 returns capabilities (idx 0: hue/sat, 1: enhanced_hue, 2: color loop, 3: x/y, 4: ctemp),
   current mode (0: h/s, 1: x/y, 2: ctemp, 3: eh/s),
   hue (max: 0xFE),
   sat (max: 0xFE),
   enhanced_hue,
   ctemp,
   ctemp_min,
   ctemp_max
]]
local current_mode = {
  [0] = "h_s",
  [1] = "x_y",
  [2] = "ctemp",
  [3] = "eh_s"
}
function zcl:check_colors()
  local colors = self:get_attributes(0x0300, {0,1,7,8,0x4000,0x4001,0x400a,0x400b,0x400c}, 20) or {}
  if not colors[0x400a] or not colors[8] then return end
  local capabilities = {
    hue_sat = colors[0x400a][0],
    enhanced_hue = colors[0x400a][1],
    color_loop = colors[0x400a][2],
    x_y = colors[0x400a][3],
    ctemp = colors[0x400a][4]
  }
  return {
    capabilities = capabilities,
    current_e = current_mode[colors[0x4001] or -1],
    current = current_mode[colors[8] or -1],
    h = colors[0],
    s = colors[1],
    eh = colors[0x4000],
    ctemp = colors[7],
    ctemp_min = colors[0x400b],
    ctemp_max = colors[0x400c]
  }
end

function zcl:level(level, transition_time, withonoff)
  level = level or 0.9999
  level = (level < 1.0) and (level * 0xFE) or level
  local method = withonoff and "MoveToLevelWithOnOff" or "MoveToLevel"
  self:send_af(0x0008, {
    LevelControlClusterFrame = {
      CommandIdentifier = method,
      [method] = {
        Level = level,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, nil, 3)
end
function zcl:check_level()
  local level = self:get_attributes(0x0008, {0})
  return level and level[0]
end

function zcl:on_announce(cb)
  ctx.task{name=string.format("%s/on_announce", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all{"Zigbee", "announce", self.device.ieeeaddr} do
      U.DEBUG("Zigbee_zcl", "got announcement: %s", U.dump(msg))
      cb()
    end
  end}
end

function zcl:on_button_press(cb)
  ctx.task{name=string.format("%s/on_button_press", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, function(msg)
      return msg.cluster == 6 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes
      end) do

      U.DEBUG("Zigbee_zcl", "got event: %s", U.dump(msg))
      local btn = msg.srcep
      for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
        if r.AttributeIdentifier == 0x8000 then
          --TODO: add more checks for device?
          -- assuming Aqara touch button
          cb(btn, r.Attribute.Value)
          break
        elseif r.AttributeIdentifier == 0 and r.Attribute.Value then
          cb(btn, 1)
          break
        end
      end
    end
  end}
end

function zcl:on_measurement(cluster, id, cb)
  ctx.task{name=string.format("%s/on_measurement_temp", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, function(msg)
      return msg.cluster == cluster and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes
      end) do

      U.DEBUG("Zigbee_zcl", "got event: %s", U.dump(msg))
      for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
        if r.AttributeIdentifier == id then
          cb(r.Attribute.Value)
          break
        end
      end
    end
  end}
end

function zcl:on_occupancy(cb)
  ctx.task{name=string.format("%s/on_occupancy", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, function(msg)
      return msg.cluster == 0x406 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes
      end) do

      U.DEBUG("Zigbee_zcl", "got event: %s", U.dump(msg))
      local btn = msg.ep
      for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
        if r.AttributeIdentifier == 0 and r.Attribute.Value[0] then
          cb()
          break
        end
      end
    end
  end}
end

function zcl:on_aqara_report(cb)
  local aqaracodec=require"interfaces.zigbee.xiaomi-aqara""AqaraReport"
  ctx.task{name=string.format("%s/on_aqara_report", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, function(msg)
      return msg and msg.cluster == 0
        and msg.data
        -- not all Aqara devices claim the ZCL packet to be manufacturer specific, so we
        -- cannot check this reliably:
        --and msg.data.ManufacturerCode==4447
        and msg.data.GeneralCommandFrame
        and msg.data.GeneralCommandFrame.ReportAttributes
        and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports
        and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1]
        and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute
        and 
        (( msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].AttributeIdentifier==65281
          and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Type=="string"
          and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Value )
        or ( msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].AttributeIdentifier==65282
          and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Type=="struct"
        ))
      end) do
      if msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].AttributeIdentifier==65281 then
        local data = aqaracodec:decode({string.byte(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Value,1,-1)})
        if data then
          U.DEBUG("Zigbee_zcl", "got Xiaomi/Aqara attributes: %s", U.dump(data))
          if cb then cb(data) end
        else
          U.DEBUG("Zigbee_zcl", "error parsing Aqara data:\n%s", U.hexdump(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Value))
        end
      else
        local old = msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Members
          -- make a replica of the newer format
        local data = {ReportAttributes = {}}
        if old[2] then table.insert(data.ReportAttributes, {Attribute = old[2].Attribute, AttributeIdentifier = 1}) end
        if old[3] then table.insert(data.ReportAttributes, {Attribute = old[3].Attribute, AttributeIdentifier = 4}) end
        if old[4] then table.insert(data.ReportAttributes, {Attribute = old[4].Attribute, AttributeIdentifier = 6}) end
        U.DEBUG("Zigbee_zcl", "got old style Xiaomi/Aqara attributes: %s", U.dump(data))
        if cb then cb(data) end
      end
    end
  end}
end

function zcl:on_cube_action(cb)
  ctx.task{name=string.format("%s/on_cube_action", self.device.ieeeaddr),function()
    for ok, msg in ctx:wait_all({"Zigbee", "ZCL", "from", self.device.ieeeaddr}, function(msg)
      return (msg.cluster == 0x0c or msg.cluster == 0x12)
        and msg.data.GeneralCommandFrame
        and msg.data.GeneralCommandFrame.ReportAttributes
        and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports
      end) do
      U.DEBUG("Zigbee_zcl", "got cube event: %s", U.dump(msg))
      for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
        if r.AttributeIdentifier == 0x55 then
          local v = r.Attribute.Value
          if msg.cluster == 0x0c then
            -- this is a "turn", like with a potentiometer
            cb("turn", v)
          elseif msg.cluster == 0x12 then
            -- this is one of the other event types:
            if v == 0 then
              cb("shake")
            elseif v == 2 then
              cb("wakeup")
            elseif v == 3 then
              cb("fall")
            elseif v >= 512 then
              cb("tap", v-512)
            elseif v >= 256 then
              cb("slide", v-256)
            elseif v >= 128 then
              cb("flip", v-128)
            elseif v >= 64 then
              cb("roll", v % 8, math.floor((v-64)/8))
            end
          end
          break
        end
      end
    end
  end}
end

return zcl
