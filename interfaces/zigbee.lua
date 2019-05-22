local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zigbee"
local ZCL=require"interfaces.zigbee.zcl"
local zigbee = U.object:new{
  ev = {},
  ZCL = ZCL,
  dongle = nil,
  ieeeaddrcache = {}
}

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
  local json = json.encode(self.devs)
  local file, err = io.open(self.filename, "w")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return
  end
  file:write(json)
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
    return true
  end
end
function devdb:names()
  local names = {}
  for _, d in pairs(self.devs) do
    if d.name then table.insert(names, d.name) end
  end
  return names
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
  local ieeeaddr = self.ieeeaddrcache[nwkaddr]
  if not ieeeaddr then
    ieeeaddr = self.dongle:get_ieeeaddr(nwkaddr)
    U.INFO(z, "got IEEE addr %s", ieeeaddr)
    self.ieeeaddrcache[nwkaddr] = ieeeaddr
  end
  if ieeeaddr then
    U.INFO(z, "device has IEEEAddr %s, provisioning device", ieeeaddr)
    self:provision_device(ieeeaddr, nwkaddr)
    return ieeeaddr
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
  --[[
  local scan_channels={11}
  --]]
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
  self.devices = devdb:open(self.device_database)
  self.learn_devices = true
  self.ieeeaddrcache = {}
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
    for ok, data in ctx:wait_all{"Zigbee", self.dongle, "device_announce"} do
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
        ctx:fire({"Zigbee", "announce", dev.name or data.ieeeaddr}, {from = data.ieeeaddr})
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
        if type(msg.src) == "number" and self.learn_devices then
          dev, ieeeaddr = self.devices:nwk(msg.src)
          if not dev then
            self:unknown_dev(msg.src)
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
              ctx:fire({"Zigbee", "ZCL", "from", (type(dev) == "table") and dev.name or ieeeaddr}, {from = ieeeaddr, cluster = msg.clusterid, srcep = msg.srcendpoint, linkquality = msg.linkquality, data = data})
            end
          else
            U.INFO(z, "error decoding ZCL message: %s", data)
          end
        end
      end
    end
  end}
  -- handling of outgoing data
  ctx.task{name="zigbee_tx_handler", function()
    local fcodec = ZCL"Frame"
    for ok, msg in ctx:wait_all{"Zigbee", "ZCL", "to"} do
      if not ok then
        U.ERR(z, "error waiting for AF message transmit")
      else
        local dev, ieeeaddr = self.devices:find(msg.dst)
        U.DEBUG(z, "sending ZCL message to device %s, cluster %04x: %s", ieeeaddr, msg.cluster, U.dump(msg.data))
        if dev then
          if not dev.eps then
            U.ERR(z, "no endpoint information for device %s", msg.dst)
          else
            local dst_ep = msg.dst_ep
            if not dst_ep then
              for _, ep in ipairs(dev.eps) do
                if U.contains(ep.InClusterList, {msg.cluster}) then
                  dst_ep = ep.Endpoint
                end
              end
            end
            if not dst_ep then
              U.ERR(z, "no endpoint on device %s for cluster %04x", msg.dst, msg.cluster)
            else
              local ok, frame = xpcall(fcodec.encode, debug.traceback, fcodec, msg.data, {ClusterId = msg.cluster})
              if not ok then
                U.ERR(z, "could not encode ZCL data, error: %s", frame)
              else
                self.dongle:tx{
                  dst = dev.nwkaddr,
                  dst_ep = dst_ep,
                  src_ep = 1, -- TODO: make this flexible?
                  clusterid = msg.cluster,
                  data = frame
                }
              end
            end
          end
        end
      end
    end
  end}
  -- handling of device naming and suchlike
  ctx.task{name="zigbee_device_attribute", function()
    for ok, msg in ctx:wait_all{"Zigbee", "device_attibute"} do
      if not ok then
        U.ERR(z, "error waiting for device_attribute message")
      else
        local dev = self.devices:find(msg.id)
        if dev then
          if msg.key then
            dev[msg.key] = msg.value
          end
          self.devices:save()
        end
      end
    end
  end}
  -- handling of device database operations
  ctx.task{name="zigbee_device_db", function()
    for ok, msg in ctx:wait_all{"Zigbee", "device_db"} do
      if not ok then
        U.ERR(z, "error waiting for device_attribute message")
      else
        if msg.cmd and msg.cmd=="copy" then
          local dev = self.devices:find(msg.id)
          if dev then
            local ndev = U.copy(dev)
            ndev.name = msg.name
            ndev.nwkaddr = msg.nwkaddr
            self.devices:set(msg.newid, ndev)
          end
          self.devices:save()
        elseif msg.cmd and msg.cmd=="delete" then
          if msg.id and self.devices:delete(msg.id) then
            self.devices:save()
          end
        end
      end
    end
  end}
  return self
end

return zigbee
