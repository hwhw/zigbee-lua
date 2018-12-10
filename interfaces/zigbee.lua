local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zigbee"
local ZCL=require"interfaces.zigbee.zcl"
local zigbee = {ev = {}, ZCL=ZCL}

-- declare events
local function ev(eventname) zigbee.ev[eventname] = {z, eventname} end
ev"coordinator_ready"
ev"device_announce"
ev"device_leave"
ev"af_message"

local devdb = U.object:new()
function devdb:open(filename)
  local file, err = io.open(filename, "r")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return self:new{devs={}, filename=filename}
  end
  local content = file:read("*a")
  file:close()
  local ok, t = pcall(json.decode, content)
  if not ok then
    U.ERR(z, "cannot decode database file %s", filename)
    return self:new{devs={}, filename=filename}
  end
  return self:new{devs=t, filename=filename}
end
function devdb:save()
  -- TODO: make this a write to a temp new file and an atomic move
  local file, err = io.open(self.filename, "w")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return
  end
  file:write(json.encode(self.devs))
  file:close()
  U.INFO(z, "device database written to file")
end
function devdb:ieee(ieeeaddr)
  return self.devs[ieeeaddr]
end
function devdb:nwk(nwkaddr)
  for ieeeaddr, v in pairs(self.devs) do
    if v.nwkaddr == nwkaddr then
      return self:ieee(ieeeaddr), ieeeaddr
    end
  end
end
function devdb:name(name)
  for ieeeaddr, v in pairs(self.devs) do
    if v.name == name then
      return self:ieee(ieeeaddr), ieeeaddr
    end
  end
end
function devdb:find(id)
  local dev, ieeeaddr = self:nwk(id)
  if not dev then
    dev, ieeeaddr = self:name(id)
  end
  if not dev then
    dev = self:ieee(id)
    if dev then ieeeaddr = id end
  end
  return dev, ieeeaddr
end
function devdb:set(ieeeaddr, data)
  local old = self:ieee(ieeeaddr)
  if old then
    for k, v in pairs(old) do
      data[k] = data[k] or v
    end
  end
  self.devs[ieeeaddr] = data
end
function devdb:setname(id, name)
  local dev = self:find(id)
  if dev then
    dev.name = name
    self:save()
  end
end
function devdb:dump_list()
  U.INFO(z, "%16s | %04s | %04s | %16s | %s", "IEEE Addr", "NWK", "Manu", "Name", "EPs")
  for ieeeaddr, v in pairs(self.devs) do
    local eps = {}
    for _, ep in ipairs(v.eps) do
      table.insert(eps, string.format("%d (in: %s, out: %s)", ep.Endpoint, table.concat(ep.InClusterList, ","), table.concat(ep.OutClusterList, ",")))
    end
    U.INFO(z, "%10s | %04x | %04x | %16s | %s", ieeeaddr, v.nwkaddr, v.nodedesc.ManufacturerCode, v.name or "-", table.concat(eps, "; "))
  end
end

zigbee.devices = devdb:open(ctx.config.zigbee_device_database)

local provisioning = {}
function zigbee:provision_device(dongle, ieeeaddr, nwkaddr)
  if not provisioning[ieeeaddr] then
    U.INFO(z, "new device %s, starting provisioning", ieeeaddr)
    provisioning[ieeeaddr] = true
    ctx.task{name="zigbee_provisioning", function()
      local d, err = dongle:provision_device(nwkaddr)
      if d then
        self.devices:set(ieeeaddr, d)
        self.devices:save()
      end
      provisioning[ieeeaddr] = nil
    end}
  else
    U.INFO(z, "already provisioning device %s", ieeeaddr)
  end
end

function zigbee:unknown_dev(dongle, nwkaddr)
  U.INFO(z, "unknown device with NWK addr: %04x", nwkaddr)
  local ieeeaddr = dongle:get_ieeeaddr(nwkaddr)
  if ieeeaddr then
    U.INFO(z, "device has IEEEAddr %s, provisioning device", ieeeaddr)
    self:provision_device(dongle, ieeeaddr, nwkaddr)
    return ieeeaddr
  end
end

function zigbee:handle()
  -- provisioning for newly announced devices
  ctx.task{name="zigbee_announce_listener", function()
    while true do
      local ok, data = ctx:wait(self.ev.device_announce)
      if not ok then return U.ERR(z, "error waiting for device announcements") end
      local dev = self.devices:ieee(data.ieeeaddr)
      if not dev then
        self:provision_device(data.dongle, data.ieeeaddr, data.nwkaddr)
      else
        if dev.nwkaddr ~= data.nwkaddr then
          U.INFO(z, "update NWK addr for device %s", data.ieeeaddr)
          dev.nwkaddr = data.nwkaddr
          self.devices:save()
        end
      end
    end
  end}
  -- handling of incoming data
  ctx.task{name="zigbee_data_handler", function()
    while true do
      local ok, msg = ctx:wait(self.ev.af_message)
      if not ok then
        U.ERR(z, "error waiting for AF messages")
        -- TODO: reasoning whether to end task here
      else
        local dev, ieeeaddr = self.devices:nwk(msg.src)
        if not dev then
          self:unknown_dev(msg.dongle, msg.src)
        else
          --U.INFO(z, "got AF message: %s", U.dump(msg))
          local ok, data = ZCL"Frame":safe_decode(msg.data,{ClusterId=msg.clusterid})
          if ok then
            U.DEBUG(z, "parsed: %s", U.dump(data))
            local clusternames = {
              [0x0006] = "OnOff",
              [0x0012] = "MultistateInput",
              [0x0400] = "IlluminanceMeasurement",
              [0x0401] = "IlluminanceLevelSensing",
              [0x0402] = "TemperatureMeasurement",
              [0x0403] = "PressureMeasurement",
              [0x0404] = "FlowMeasurement",
              [0x0405] = "RelativeHumidityMeasurement",
              [0x0406] = "OccupancySensing",
              [0x0b04] = "ElectricalMeasurement",
            }
            local cluster = clusternames[msg.clusterid]
            if cluster
              and data.GeneralCommandFrame
              and data.GeneralCommandFrame.CommandIdentifier == "ReportAttributes" then

              if data.GeneralCommandFrame.ReportAttributes.AttributeReports then
                for _, report in ipairs(data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
                  local id = report.AttributeIdentifier
                  local value = report.Attribute.Value
                  ctx:fire(ctx.zoo.ev.value_report, {source={"Zigbee", dev.name or ieeeaddr, msg.srcendpoint}, cluster=cluster, id=id, value=value})
                end
              end
            else
              U.INFO(z, "got attribute record for unhandled cluster %04x", msg.clusterid)
            end
          else
            U.INFO(z, "error decoding ZCL message: %s", data)
          end
        end
      end
    end
  end}
end

function zigbee:get_dev_ep(id, inclusters, outclusters)
  inclusters = inclusters or {}
  outclusters = outclusters or {}
  local dev, ieeeaddr = self.devices:find(id)
  if not dev then
    U.ERR(z, "unknown device %s", ieeeaddr)
    return
  end
  if not dev.eps then
    U.ERR(z, "no endpoint information for device %s", ieeeaddr)
    return
  end
  local matching_eps = {}
  for _, ep in ipairs(dev.eps) do
    if U.contains(ep.InClusterList, inclusters) or U.contains(ep.OutClusterList, outclusters) then
      table.insert(matching_eps, ep.Endpoint)
    end
  end
  if #matching_eps > 0 then
    return dev, matching_eps[1], matching_eps
  end
  U.ERR(z, "no matching endpoints for device %s (in: %s, out: %s)", ieeeaddr, inclusters, outclusters)
end

function zigbee:send_af(id, cluster, data, global)
  local dev, ep = self:get_dev_ep(id, {cluster})
  if dev and ep then
    -- TODO: make this device agnostic
    local seqno = dev.seqno or 1
    dev.seqno = (seqno + 1) % 0x100
    data.FrameControl = {global and "FrameTypeGlobal" or "FrameTypeLocal", "DirectionToServer", "DisableDefaultResponse" }
    data.TransactionSequenceNumber = seqno
    local ok, ret = ctx.dongle:sreq("AF_DATA_REQUEST", {
      DstAddr = dev.nwkaddr,
      DstEndpoint = ep,
      SrcEndpoint = 1, -- TODO: make this flexible
      ClusterId = cluster,
      TransId = 1,
      Options = {},
      Radius = dev.defaultradius or 3,
      Data = ZCL"Frame":encode(data, {ClusterId = cluster})
    })
  end
end

function zigbee:identify(id, time)
  ctx.task{name="zigbee_idenfity", function()
    self:send_af(id, 0x0003, {
      IdentifyClusterFrame = { CommandIdentifier = "Identify", Identify = { IdentifyTime = time or 4 } }
    })
  end}
end

function zigbee:switch(id, cmd)
  ctx.task{name="zigbee_switch", function()
    self:send_af(id, 0x0006, {
      OnOffClusterFrame = { CommandIdentifier = cmd }
    })
  end}
end

function zigbee:hue_sat(id, hue, sat, transition_time)
  ctx.task{name="zigbee_hue_sat", function()
    self:send_af(id, 0x0300, {
      ColorControlClusterFrame = {
        CommandIdentifier = "EnhancedMoveToHueAndSaturation",
        EnhancedMoveToHueAndSaturation = {
          EnhancedHue = (hue or 0.0) * 0xFFFE,
          Saturation = (sat or 1.0) * 0xFE,
          TransitionTime = (transition_time or 1) * 10
        }
      }
    })
  end}
end

function zigbee:ctemp(id, mireds, transition_time)
  ctx.task{name="zigbee_ctemp", function()
    self:send_af(id, 0x0300, {
      ColorControlClusterFrame = {
        CommandIdentifier = "MoveToColorTemperature",
        MoveToColorTemperature = {
          ColorTemperatureMireds = mireds or 3000,
          TransitionTime = (transition_time or 1) * 10
        }
      }
    })
  end}
end

function zigbee:level(id, level, transition_time)
  ctx.task{name="zigbee_level", function()
    self:send_af(id, 0x0008, {
      LevelControlClusterFrame = {
        CommandIdentifier = "MoveToLevelWithOnOff",
        MoveToLevelWithOnOff = {
          Level = (level or 1.0) * 0xFF,
          TransitionTime = (transition_time or 1) * 10
        }
      }
    })
  end}
end

return zigbee
