local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zigbee"
local ZCL=require"interfaces.zigbee.proto-zcl"

-----------------------------------------------------------------------------
-- Zigbee device "object":
-----------------------------------------------------------------------------
local device_mt = {}
-- handling of outgoing data
local fcodec = ZCL"Frame"
function device_mt:tx_zcl(msg)
  U.DEBUG(z, "sending ZCL message to device %s, cluster %04x: %s", self.ieeeaddr, msg.cluster, U.dump(msg.data))
  local dst_ep = msg.dst_ep
  if not dst_ep and self.eps then
    for _, ep in ipairs(self.eps) do
      if U.contains(ep.InClusterList, {msg.cluster}) then
        dst_ep = ep.Endpoint
      end
    end
  end
  if not dst_ep then
    U.ERR(z, "no known endpoint on device %s for cluster %04x", msg.dst, msg.cluster)
  else
    local ok, frame = xpcall(fcodec.encode, debug.traceback, fcodec, msg.data, {ClusterId = msg.cluster})
    if not ok then
      U.ERR(z, "could not encode ZCL data, error: %s", frame)
    else
      local source_route
      if self.source_route then
        source_route = {}
        for _, d in ipairs(self.source_route) do
          local route_dev = self.interface.devices:find(d)
          if not route_dev then
            source_route = nil
            break
          end
          U.DEBUG(z, "source routing via %04X (%s)", route_dev.nwkaddr, route_dev.name)
          table.insert(source_route, route_dev.nwkaddr)
        end
      end
      local ok = self.interface.dongle:tx({
        dst = self.nwkaddr,
        source_route = source_route,
        dst_ep = dst_ep,
        src_ep = 1, -- TODO: make this flexible?
        clusterid = msg.cluster,
        data = frame
      }, msg.timeout or 2.0)
      return ok
    end
  end
  return false
end

local devdata_filter = {db=true, interface=true, ieeeaddr=true, zcl=true, zcl_ep=true}
function device_mt:get_data()
  local device = {}
  for k, v in pairs(self) do
    if not devdata_filter[k] then device[k]=v end
  end
  return device
end
function device_mt:set(data)
  for k, v in pairs(data) do
    self[k] = v
  end
  self.db:save()
end

-----------------------------------------------------------------------------
-- Zigbee device database "object":
-----------------------------------------------------------------------------
local devdb = U.object:new()
local zcl_interface = require"interfaces.zigbee.zcl"

function devdb:insert(ieeeaddr, data)
  if type(data) == "table" then
    local dev = setmetatable(data, {__index=device_mt})
    dev.db = self
    dev.interface = self.interface
    dev.ieeeaddr = ieeeaddr
    dev.zcl = zcl_interface:new{device=dev}
    dev.zcl_ep = {}
    if dev.eps then
      for k, v in ipairs(dev.eps) do
        dev.zcl_ep[v.Endpoint] = zcl_interface:new{device=dev, ep=v.Endpoint}
      end
    end
    self.devs[ieeeaddr] = dev
  end
end
function devdb:open()
  self.devs={}
  local file, err = io.open(self.filename, "r")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s - trying to start with an empty one", self.filename, err)
    return
  end
  local content = file:read("*a")
  file:close()
  local ok, t = pcall(json.decode, content)
  if not ok then
    U.ERR(z, "cannot decode database file %s, please repair or delete", self.filename)
    os.exit(1) -- exit for now to allow for manual repair
  end
  for ieeeaddr, data in pairs(t) do self:insert(ieeeaddr, data) end
end
function devdb:get_data()
  local devices = {}
  for id, dev in pairs(self.devs) do
    devices[id] = dev:get_data()
  end
  return devices
end
function devdb:save()
  -- TODO: make this a write to a temp new file and an atomic move
  local file, err = io.open(self.filename, "w")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return
  end
  file:write(json.encode(self:get_data()))
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
function devdb:delete(id)
  local dev, ieeeaddr = self:find(id)
  if dev and ieeeaddr then
    self.devs[ieeeaddr] = nil
    self:save()
    return true
  end
end
function devdb:names()
  local names = {}
  for ieeeaddr, d in pairs(self.devs) do
    if d.name then
      names[ieeeaddr] = d.name
    else
      names[ieeeaddr] = ieeeaddr
    end
  end
  return names
end
function devdb:dump_list(writer)
  writer(string.format("%16s | %04s | %04s | %16s | %s\n", "IEEE Addr", "NWK", "Manu", "Name", "EPs"))
  for ieeeaddr, v in pairs(self.devs) do
    local eps = {}
    for _, ep in ipairs(v.eps) do
      local in_clusters, out_clusters = {}, {}
      for _, c in ipairs(ep.InClusterList) do table.insert(in_clusters, string.format("%04x", c)) end
      for _, c in ipairs(ep.OutClusterList) do table.insert(out_clusters, string.format("%04x", c)) end
      table.insert(eps, string.format("%d (in: %s, out: %s)", ep.Endpoint, table.concat(in_clusters, ","), table.concat(out_clusters, ",")))
    end
    writer(string.format("%10s | %04x | %04x | %16s | %s\n", ieeeaddr, v.nwkaddr, v.nodedesc.ManufacturerCode, v.name or "-", table.concat(eps, "; ")))
  end
end

-----------------------------------------------------------------------------
-- Zigbee interface "object":
-----------------------------------------------------------------------------
local zigbee = U.object:new{
  ev = {},
  ZCL = ZCL,
  dongle = nil,
  learn_devices = true,
  provision_devices = true
}

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

function zigbee:unknown_nwkaddr(nwkaddr, ieeeaddr)
  U.INFO(z, "unknown device with NWK addr: %04x", nwkaddr)
  ieeeaddr = ieeeaddr or self.dongle:get_ieeeaddr(nwkaddr)
  if ieeeaddr then
    local dev = self.devices:ieee(ieeeaddr)
    if dev then
      U.INFO(z, "known under different NWK, update NWK addr for device %s", ieeeaddr)
      dev.nwkaddr = nwkaddr
      self.devices:save()
    elseif self.provision_devices then
      self:provision_device(ieeeaddr, nwkaddr)
    end
  end
end

function zigbee:get_txseq()
  local txseq = ((self.txseq or 0) + 1) % 256
  self.txseq = txseq
  return txseq
end
function zigbee:zll_commissioning_send(command, data, channel, target, req_ack)
  local frame = ZCL"Frame":encode({
    FrameControl = { "FrameTypeLocal", "DirectionToServer", "DisableDefaultResponse" },
    TransactionSequenceNumber = self:get_txseq(),
    ZLLCommissioningClusterFrame={
      CommandIdentifier=command,
      [command] = data
    }
  }, {ClusterId=0x1000})

  return self.dongle:tx{
    dst_pan_id = 0xFFFF,
    dst = target or 0xFFFF,
    dst_ep = 0xFE,
    skip_routing = true,
    interpan = true,
    channel = channel or 11,
    broadcast = not target,
    request_ack = req_ack,
    clusterid = 0x1000,
    data = frame
  }
end
function zigbee:touchlink(method)
  method = method or "identify"
  local learn = self.learn_devices
  self.learn_devices = false
  local transaction_identifier = math.random(0,0xFFFFFFFF)
  local scan_request={
    InterPANTransactionIdentifier=transaction_identifier,
    ZigBeeInformation={"LogicalTypeRouter", "RxOnWhenIdle"},
    ZLLInformation={}
  }
  local scan_channels = {
    11,11,11,11,11,
    15,20,25,
    12,13,14,16,17,18,19,21,22,23,24,26 }
  for try=1,#scan_channels do
    local channel = scan_channels[try]
    self:zll_commissioning_send("ScanRequest", scan_request, channel)
    local ok, msg = ctx:wait({"Zigbee", "ZCL", "from"}, function(msg)
      return msg.cluster == 0x1000 and
        type(msg.data) == "table" and
        msg.data.ZLLCommissioningClusterFrame and
        msg.data.ZLLCommissioningClusterFrame.ScanResponse and
        msg.data.ZLLCommissioningClusterFrame.ScanResponse.InterPANTransactionIdentifier == transaction_identifier
    end, 0.25)
    if ok then
      U.INFO(z, "got a ScanResponse from device %s", msg.from)
      if method == "identify" then
        local request = {
          InterPANTransactionIdentifier=transaction_identifier,
          IdentifyDuration = 5
        }
        self:zll_commissioning_send("IdentifyRequest", request, channel, msg.from)
      elseif method == "factory_reset" then
        local request = { InterPANTransactionIdentifier=transaction_identifier }
        self:zll_commissioning_send("ResetToFactoryNewRequest", request, channel, msg.from)
      end
      break
    end
  end
  self.learn_devices = learn
end

function zigbee:init()
  self.devices = devdb:new{interface=self, filename=self.device_database}
  self.devices:open()
  self.dongle = require("interfaces.zigbee.devices."..self.device.class):new(self.device):init()

  -- run this in a task to allow it to suspend
  ctx.task{name="initialize", function()
    if not self.dongle:initialize_coordinator(true) then
      U.ERR("main", "could not start coordinator")
      -- TODO: exit from another thread, better just send an event
      os.exit(1)
    end
  end}
  -- provisioning for newly announced devices
  ctx.task{name="zigbee_announce_listener", function()
    for ok, data in ctx:wait_all{"Zigbee", self.dongle, "device_announce"} do
      if not ok then return U.ERR(z, "error waiting for device announcements") end
      local dev = self.devices:nwk(data.nwkaddr)
      if not dev then
        self:unknown_nwkaddr(data.nwkaddr, data.ieeeaddr)
      else
        ctx:fire({"Zigbee", "announce", data.ieeeaddr}, {from = data.ieeeaddr})
      end
    end
  end}
  -- handling of incoming data
  local seq_numbers = {} -- to weed out duplicate packets
  ctx.task{name="zigbee_rx_handler", function()
    for ok, msg in ctx:wait_all{"Zigbee", self.dongle, "af_message"} do
      if not ok then
        U.ERR(z, "error waiting for AF message receive")
        -- TODO: reasoning whether to end task here
      else
        U.INFO(z, "got AF message")
        local ieeeaddr
        if type(msg.src) == "number" then
          if self.learn_devices then
            local dev
            dev, ieeeaddr = self.devices:nwk(msg.src)
            if not dev then
              self:unknown_nwkaddr(msg.src)
            end
          end
        elseif type(msg.src) == "string" then
          ieeeaddr = msg.src
        end
        if ieeeaddr then
          local ok, data = ZCL"Frame":safe_decode(msg.data,{ClusterId=msg.clusterid})
          if ok then
            if seq_numbers[ieeeaddr] and seq_numbers[ieeeaddr] == data.TransactionSequenceNumber then
              U.DEBUG(z, "duplicate packet received, ignoring")
            else
              seq_numbers[ieeeaddr] = data.TransactionSequenceNumber
              U.DEBUG(z, "parsed: %s", U.dump(data))
              ctx:fire({"Zigbee", "ZCL", "from", ieeeaddr}, {from = ieeeaddr, cluster = msg.clusterid, srcep = msg.srcendpoint, linkquality = msg.linkquality, data = data})
            end
          else
            U.INFO(z, "error decoding ZCL message: %s", data)
          end
        end
      end
    end
  end}
  return self
end

return zigbee
