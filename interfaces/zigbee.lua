local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zigbee"
local ZCL=require"interfaces.zigbee.zcl"
local zigbee = U.object:new{ev = {}, ZCL=ZCL, dongle=nil}

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
function devdb:dump_list(writer)
  writer(string.format("%16s | %04s | %04s | %16s | %s", "IEEE Addr", "NWK", "Manu", "Name", "EPs"))
  for ieeeaddr, v in pairs(self.devs) do
    local eps = {}
    for _, ep in ipairs(v.eps) do
      table.insert(eps, string.format("%d (in: %s, out: %s)", ep.Endpoint, table.concat(ep.InClusterList, ","), table.concat(ep.OutClusterList, ",")))
    end
    writer(string.format("%10s | %04x | %04x | %16s | %s", ieeeaddr, v.nwkaddr, v.nodedesc.ManufacturerCode, v.name or "-", table.concat(eps, "; ")))
  end
end

local provisioning = {}
function zigbee:provision_device(ieeeaddr, nwkaddr)
  if not provisioning[ieeeaddr] then
    U.INFO(z, "new device %s, starting provisioning", ieeeaddr)
    provisioning[ieeeaddr] = true
    ctx.task{name="zigbee_provisioning", function()
      local d, err = self.dongle:provision_device(nwkaddr)
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

function zigbee:unknown_dev(nwkaddr)
  U.INFO(z, "unknown device with NWK addr: %04x", nwkaddr)
  local ieeeaddr = self.dongle:get_ieeeaddr(nwkaddr)
  if ieeeaddr then
    U.INFO(z, "device has IEEEAddr %s, provisioning device", ieeeaddr)
    self:provision_device(ieeeaddr, nwkaddr)
    return ieeeaddr
  end
end

function zigbee:init()
  self.devices = devdb:open(self.device_database)
  self.dongle = require("interfaces.zigbee.devices."..self.device.class):new(self.device):init()

  ctx.task{name="initialize", function()
    if not self.dongle:initialize_coordinator(true) then
      U.ERR("main", "could not start coordinator")
      -- TODO: exit from another thread, better just send an event
      os.exit(1)
    end
  end}
  -- provisioning for newly announced devices
  ctx.task{name="zigbee_announce_listener", function()
    while true do
      local ok, data = ctx:wait{"Zigbee", self.dongle, "device_announce"}
      if not ok then return U.ERR(z, "error waiting for device announcements") end
      local dev = self.devices:ieee(data.ieeeaddr)
      if not dev then
        self:provision_device(data.ieeeaddr, data.nwkaddr)
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
  ctx.task{name="zigbee_rx_handler", function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", self.dongle, "af_message"}
      if not ok then
        U.ERR(z, "error waiting for AF message receive")
        -- TODO: reasoning whether to end task here
      else
        local dev, ieeeaddr = self.devices:nwk(msg.src)
        if not dev then
          self:unknown_dev(msg.src)
        else
          local ok, data = ZCL"Frame":safe_decode(msg.data,{ClusterId=msg.clusterid})
          if ok then
            U.DEBUG(z, "parsed: %s", U.dump(data))
            ctx:fire({"Zigbee", "ZCL", "from", dev.name or ieeeaddr}, {cluster = msg.clusterid, srcep = msg.srcendpoint, data = data})
          else
            U.INFO(z, "error decoding ZCL message: %s", data)
          end
        end
      end
    end
  end}
  -- handling of outgoing data
  ctx.task{name="zigbee_tx_handler", function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", "ZCL", "to"}
      if not ok then
        U.ERR(z, "error waiting for AF message transmit")
      else
        local dev, ieeeaddr = self.devices:find(msg.dst)
        if dev then
          if not dev.eps then
            U.ERR(z, "no endpoint information for device %s", msg.dst)
          else
            local dst_ep
            for _, ep in ipairs(dev.eps) do
              if U.contains(ep.InClusterList, {msg.cluster}) then
                dst_ep = ep.Endpoint
              end
            end
            if not dst_ep then
              U.ERR(z, "no endpoint on device %s for cluster %04x", msg.dst, msg.cluster)
            else
              self.dongle:sreq("AF_DATA_REQUEST", {
                DstAddr = dev.nwkaddr,
                DstEndpoint = dst_ep,
                SrcEndpoint = 1, -- TODO: make this flexible
                ClusterId = msg.cluster,
                TransId = 1,
                Options = {},
                Radius = dev.defaultradius or 3,
                Data = ZCL"Frame":encode(msg.data, {ClusterId = msg.cluster})
              })
            end
          end
        end
      end
    end
  end}
  -- handling of device naming and suchlike
  ctx.task{name="zigbee_device_attribute", function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", "device_attibute"}
      if not ok then
        U.ERR(z, "error waiting for device_attribute message")
      else
        local dev = self.devices:find(msg.id)
        if dev then
          if msg.key then
            dev[msg.key] = dev[msg.value]
          end
          self.devices:save()
        end
      end
    end
  end}
  return self
end

return zigbee
