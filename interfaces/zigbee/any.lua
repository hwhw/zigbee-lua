local ctx = require"lib.ctx"
local U = require"lib.util"

local any = U.object:new{
  id = nil,
}

function any:send_af(cluster, data, global, waitreply)
  local txseq = (self.txseq or 0) + 1
  self.txseq = txseq

  data.FrameControl = { global and "FrameTypeGlobal" or "FrameTypeLocal", "DirectionToServer" }
  if not waitreply then table.insert(data.FrameControl, "DisableDefaultResponse") end
  data.TransactionSequenceNumber = txseq

  ctx:fire({"Zigbee", "ZCL", "to"}, {
    dst = self.id,
    cluster = cluster,
    data = data
  })

  if waitreply then
    local filter = function(msg)
      return msg.cluster == cluster
        and msg.data.TransactionSequenceNumber == txseq
    end
    local ok, msg = ctx:wait({"Zigbee", "ZCL", "from", self.id}, filter, waitreply)
    return ok, msg
  else
    return txseq
  end
end

function any:get_attribute_list(cluster)
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
      }, true, 5)
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
  --U.DEBUG("any", "cluster %04x, attributes: %s", cluster, U.dump(attributes))
  return attributes
end
function any:get_attributes(cluster, attributes, at_once)
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
      }, true, 5)
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

function any:identify(time)
  self:send_af(0x0003, {
    IdentifyClusterFrame = { CommandIdentifier = "Identify", Identify = { IdentifyTime = time or 4 } }
  })
end

function any:switch(cmd)
  self:send_af(0x0006, {
    OnOffClusterFrame = { CommandIdentifier = cmd }
  }, false, 2)
end

function any:hue_sat(hue, sat, transition_time)
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "EnhancedMoveToHueAndSaturation",
      EnhancedMoveToHueAndSaturation = {
        EnhancedHue = (hue or 0.0) * 0xFFFE,
        Saturation = (sat or 1.0) * 0xFE,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, 2)
end

function any:ctemp(mireds, transition_time)
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "MoveToColorTemperature",
      MoveToColorTemperature = {
        ColorTemperatureMireds = mireds or 3000,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, 2)
end

function any:level(level, transition_time)
  self:send_af(0x0008, {
    LevelControlClusterFrame = {
      CommandIdentifier = "MoveToLevelWithOnOff",
      MoveToLevelWithOnOff = {
        Level = (level or 1.0) * 0xFF,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  }, false, 2)
end

function any:on_button_press(cb)
  ctx.task{name=string.format("%s/on_button_press", self.id),function()
    local filter = function(msg)
      return msg.cluster == 6 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes
    end
    while true do
      local ok, msg = ctx:wait({"Zigbee", "ZCL", "from", self.id}, filter)
      if not ok then
        U.ERR("Zigbee_any/on_button_press", "error while waiting for event")
      else
        U.DEBUG("Zigbee_any", "got event: %s", U.dump(msg))
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
    end
  end}
end

function any:on_occupancy(cb)
  ctx.task{name=string.format("%s/on_occupancy", self.id),function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", "ZCL", "from", self.id}
      if not ok then
        U.ERR("Zigbee_any/on_occupancy", "error while waiting for event")
      else
        U.DEBUG("Zigbee_any", "got event: %s", U.dump(msg))
        if msg.cluster == 0x406 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes then
          local btn = msg.ep
          for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
            if r.AttributeIdentifier == 0 and r.Attribute.Value[0] then
              cb()
              break
            end
          end
        end
      end
    end
  end}
end

return any
