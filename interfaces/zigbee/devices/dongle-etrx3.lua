local ctx = require"lib.ctx"
local U = require"lib.util"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"
local serial = require"lib.serial"
local zigbee = require"interfaces.zigbee"
local APS=require"interfaces.zigbee.aps"

local dongle = U.object:new{
  subsys = "dongle-etrx3",
  handler = {}
}

local function wait_reply()
  return coroutine.wrap
end

function dongle:command(data, throw_error, timeout, binary)
  self.serial.fd:write((type(data)=="table" and string.char(unpack(data)) or data).."\r")
  self.replybuf = nil
  U.DEBUG(self.subsys, "data written: %s", binary and U.hexdump(data) or data)
  if timeout==false then return true end
  local ok, msg = ctx:wait({"ETRX", self, "Result"}, nil, timeout or 5.0)
  if not ok and throw_error then error("error waiting for command response") end
  if ok and msg.err then ok=false end
  if not ok and throw_error then error(string.format("error response by ETRX module: %s", msg.err)) end
  return ok, msg
end

function dongle:setup(id,data,...)
  id = tostring(id)
  data = string.format(tostring(data),...)
  local ok, msg = self:command(string.format("ATS%s=%s", id, data))
  U.DEBUG(self.subsys, "set S-register %s to value %s: %s", id, data, ok and "success" or "error")
  if not ok then error("could not set S-register") end
  return true
end

function dongle:tsseq()
  self.tsseq_counter = ((self.tsseq_counter or 0xFF) + 1) % 0x100
  return self.tsseq_counter
end

local known_prompts = U.hashify{
  "ACK", "NACK", "POLLED", "SR", "BCAST", "MCAST", "UCAST", "INTERPAN", "RAW", "SDATA",
  "FN130", "FFD", "SED", "MED", "ZED", "NEWNODE", "LeftPAN", "LostPAN", "JPAN",
  "NODELEFT", "ADSK", "SREAD", "SWRITE", "Bind", "Unbind", "End Device Bind",
  "DataMODE", "OPEN", "CLOSED", "TRACK", "TRACK2", "PWRCHANGE", "AddrResp", "RX",
  "NM:ES REPORT WARNING", "ENTERING BLOAD"}
function dongle:init()
  self.subsys = string.format("dongle-etrx357/%s", self.port)

  self.serial = serial.open(self.port)
  self.serial:set_baud(self.baud or 19200)

  local linebuf = {}
  ctx.srv:char_reader(self.serial.fd, function(b)
    if b == 0x0a then
      local line = string.char(unpack(linebuf))
      U.DEBUG(self.subsys, "line read: %s", line)
      linebuf = {}
      local prefix, data = string.match(line, "^([%a%d ]+):(.+)$")
      if line == "OK" or prefix == "ERROR" then
        ctx:fire({"ETRX", self, "Result"}, {status=line=="OK" and line or prefix, err=data, data=self.replybuf})
      elseif known_prompts[line] then
        ctx:fire({"ETRX", self, "Prompt", line}, {prompt=line})
      elseif known_prompts[prefix] then
        ctx:fire({"ETRX", self, "Prompt", prefix}, {prompt=prefix, data=data})
      elseif line ~= "" then
        if not self.replybuf then self.replybuf = {} end
        table.insert(self.replybuf, line)
      end
    elseif b == 0x0d then
      -- skip
    else
      table.insert(linebuf, b)
    end
  end)

  ctx.task{name="etrx_debug", function()
    for _, msg in ctx:wait_all{"ETRX", self, "Prompt"} do U.DEBUG(self.subsys, "event: %s", U.dump(msg)) end
  end}

  self.on_rx_msg = ctx.task{name="etrx_rx_message", function()
    for _, msg in ctx:wait_all{"ETRX", self, "Prompt", "RX"} do
      local eui64, nwk, profile, dstep, srcep, clusterid, length, data, rssi, lqi = string.match(msg.data, "^(%x+),(%x+),(%x+),(%x+),(%x+),(%x+),(%x+):(%x+),([-%x]+),(%x+)$")
      if not eui64 then
        nwk, profile, dstep, srcep, clusterid, length, data, rssi, lqi = string.match(msg.data, "^(%x+),(%x+),(%x+),(%x+),(%x+),(%x+):(%x+),([-%x]+),(%x+)$")
      end
      if nwk then
        nwk = tonumber(nwk, 16)
        profile = tonumber(profile, 16)
        dstep = tonumber(dstep, 16)
        srcep = tonumber(srcep, 16)
        clusterid = tonumber(clusterid, 16)
        length = tonumber(length, 16)
        data = U.fromhex(data)
        lqi = tonumber(lqi, 16)
        U.INFO(self.subsys.."/rx", "incoming message from 0x%04x, src EP %d, profile 0x%04x, clusterid 0x%04x, dst EP %d", nwk, srcep, profile, clusterid, dstep)
        ctx:fire({"Zigbee", self, "af_message"}, {
          data = data,
          src = nwk,
          clusterid = clusterid,
          localendpoint = dstep,
          srcendpoint = srcep,
          profile = profile,
          linkquality = lqi
        })
      end
    end
  end}

  self.on_newdev = ctx.task{name="etrx_newdev", function()
    local prompts = U.hashify{"FFD","SED","MED","ZED"}
    for _, msg in ctx:wait_all({"ETRX", self, "Prompt"}, function(data) return prompts[data.prompt] end) do
      local ieeeaddr, nwkaddr = string.match(msg.data, "^(%x+),(%x+)$")
      if ieeeaddr then
        U.INFO(self.subsys.."/newdev", "new %s device: NWK addr %s, IEEE address %s", msg.prompt, nwkaddr, ieeeaddr)
        ctx:fire({"Zigbee", self, "device_announce"}, {nwkaddr = tonumber(nwkaddr, 16), ieeeaddr = ieeeaddr})
      end
    end
  end}

  -- this should probably go to the general Zigbee layer as soon as all dongle devices work with this:
  self.on_desc = ctx.task{name="aps", function()
    for _, msg in ctx:wait_all({"Zigbee", self, "af_message"}, function(data) return data.profile==0 and data.localendpoint==0 end) do
      local ok, data = APS"Frame":safe_decode(msg.data,{ClusterId=msg.clusterid})
      if ok then
        U.INFO(self.subsys.."/aps", "got APS message: %s", U.dump(data))
        ctx:fire({"Zigbee", self, "APS"}, {src=msg.src, data=data})
      else
        U.INFO(self.sybsys.."/aps", "error decoding APS message: %s", data)
      end
    end
  end}
  self.on_permit_join = ctx.task{name="aps_permit_join", function()
    for ok, data in ctx:wait_all{"Zigbee", "permit_join"} do
      if ok then
        -- NOTE: to force joining via a specific router, you need to add the coordinator (0)
        -- to the list of excluded devices, even if it was not among the included devices
        data.include = data.include or { 0 }
        data.include = type(data.include) == "table" and data.include or {data.include}
        data.exclude = data.exclude or {}
        data.exclude = type(data.exclude) == "table" and data.exclude or {data.exclude}
        data.duration = data.duration or 0xFE

        for _, devaddr in ipairs(data.include) do
          self:permit_joining(devaddr, data.duration, 1)
        end
        for _, devaddr in ipairs(data.exclude) do
          self:permit_joining(devaddr, 0, 0)
        end
      end
    end
  end}

  return self
end

function dongle:tx(p)
  if p.broadcast then
    self:command(string.format("AT+SENDMCASTB:%02X,%02X,%04X,%02X,%02X,%04X,%04X", #p.data, p.radius or 3, p.dst, p.src_ep, p.dst_ep, p.profileid or 0x0104, p.clusterid), false, false)
  elseif p.multicast then
    self:command(string.format("AT+SENDMCASTB:%02X,%02X,%04X,%02X,%02X,%04X,%04X", #p.data, p.radius or 3, p.dst, p.src_ep, p.profileid or 0x0104, p.clusterid), false, false)
  else
    self:command(string.format("AT+SENDUCASTB:%02X,%04X,%02X,%02X,%04X,%04X", #p.data, p.dst, p.src_ep, p.dst_ep, p.profileid or 0x0104, p.clusterid), false, false)
  end
  return self:command(p.data, true, 5.0, true)
end

function dongle:send_aps(nwk, clusterid, data, reply_handler, timeout)
  data.TransactionSequenceNumber = data.TransactionSequenceNumber or self:tsseq()
  local tsseq = data.TransactionSequenceNumber
  local frame=APS"Frame":encode(data, {ClusterId=clusterid})
  U.DEBUG(self.subsys.."/aps", "sending APS message for cluster %04x:\n%s\n%s", clusterid, U.dump(data), U.hexdump(frame))
  local reply_wait
  if reply_handler then
    reply_wait = ctx.task{function()
      local ok, msg = ctx:wait({"Zigbee", self, "APS"}, function(msg) return msg.data.TransactionSequenceNumber == tsseq end, timeout or 5.0)
      if ok then
        return reply_handler(msg.data)
      end
    end}
  end
  local ok_req, msg = self:tx{dst=nwk, src_ep=0, dst_ep=0, profileid=0, clusterid=clusterid, data=frame, broadcast=(nwk==0xFFFC or nwk==0xFFFD or nwk==0xFFFF)}
  if not reply_wait then return ok_req, msg end
  local ok_rsp, msg = reply_wait:finish()
  return ok_req and ok_rsp, msg
end

function dongle:send_aps_req(nwk, clusterid, data, replyname)
  local reply
  local ok, msg = self:send_aps(nwk, clusterid, data, function(msg)
    if msg[replyname] and msg[replyname].Status == "SUCCESS" then
      reply = msg[replyname]
    end
  end)
  return reply
end

function dongle:get_ieeeaddr(nwk)
  U.INFO(self.subsys, "looking up IEEEAddr for NWK addr %04X", nwk)
  local ieeeaddr = self:send_aps_req(nwk, 1, {IEEE_addr_req={ShortAddr=nwk, ReqType="Single"}}, "IEEE_addr_rsp")
  if ieeeaddr then
    U.INFO(self.subsys, "IEEEAddr for NWK addr %04X: %s", nwk, ieeeaddr.IEEEAddrRemoteDev)
  else
    U.INFO(self.subsys, "error retrieving IEEEAddr for NWK addr %04X", nwk)
  end
  return ieeeaddr.IEEEAddrRemoteDev
end

function dongle:get_node_descriptor(nwk)
  U.INFO(self.subsys, "get node descriptor for NWK addr %04X", nwk)
  local nodedesc = self:send_aps_req(nwk, 2, {Node_Desc_req={NWKAddrOfInterest=nwk}}, "Node_Desc_rsp")
  return nodedesc and nodedesc.NodeDescriptor
end

function dongle:get_power_descriptor(nwk)
  U.INFO(self.subsys, "get power descriptor for NWK addr %04X", nwk, endpoint)
  local powerdesc = self:send_aps_req(nwk, 3, {Power_Desc_req={NWKAddrOfInterest=nwk}}, "Power_Desc_rsp")
  return powerdesc and powerdesc.PowerDescriptor
end

function dongle:get_simple_descriptor(nwk, endpoint)
  U.INFO(self.subsys, "get simple descriptor for NWK addr %04X, EP %d", nwk, endpoint)
  local simpledesc = self:send_aps_req(nwk, 4, {Simple_Desc_req={NWKAddrOfInterest=nwk, Endpoint=endpoint}}, "Simple_Desc_rsp")
  return simpledesc and simpledesc.SimpleDescriptor
end

function dongle:get_active_ep_list(nwk)
  U.INFO(self.subsys, "get active endpoints for NWK addr %04X", nwk)
  local active_eps = self:send_aps_req(nwk, 5, {Active_EP_req={NWKAddrOfInterest=nwk}}, "Active_EP_rsp")
  return active_eps and active_eps.ActiveEPList
end

function dongle:permit_joining(nwk, duration, tcsignificance)
  duration = duration or 0xFE
  tcsignificance = tcsignificance or 1
  U.INFO(self.subsys, "permit joining for NWK addr %04X, duration %d, tcsignificance %d", nwk, duration, tcsignificance)
  return self:send_aps_req(nwk, 0x0036, {Mgmt_Permit_Joining_req={PermitDuration=duration, TC_Significance=tcsignificance}}, "Mgmt_Permit_Joining_rsp")
end

function dongle:provision_device(nwk)
  U.INFO(self.subsys, "provisioning NWK addr %04X", nwk)

  local devdata = {nwkaddr=nwk, eps={}}

  for try=5,1,-1 do
    devdata.nodedesc = self:get_node_descriptor(nwk)
    if devdata.nodedesc then
      break
    else
      U.ERR(self.subsys, "no or bad node descriptor received for device %04x", nwk)
      if try==1 then
        return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
      end
    end
  end

  local endpoints
  for try=5,1,-1 do
    endpoints = self:get_active_ep_list(nwk)
    if endpoints then
      break
    else
      U.ERR(self.subsys, "no or bad active endpoint info received for device %04x", nwk)
      if try==1 then
        return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
      end
    end
  end

  for _, ep in ipairs(endpoints) do
    local desc
    for try=5,1,-1 do
      desc = self:get_simple_descriptor(nwk, ep)
      if desc then
        break
      else
        U.ERR(self.subsys, "no or bad simple descriptor received for EP %d of device %04x", ep, nwk)
        if try==1 then
          return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
        end
      end
    end

    table.insert(devdata.eps, {
      Endpoint=ep,
      DeviceId=desc.ApplicationDeviceIdentifier,
      DeviceVersion=desc.ApplicationDeviceVersion,
      ProfileId=desc.ApplicationProfileIdentifier,
      InClusterList=desc.ApplicationInputClusterList,
      OutClusterList=desc.ApplicationOutputClusterList})
  end

  return devdata
end

function dongle:initialize_coordinator(reset_conf)
  -- disable command echo:
  self:setup("124", "1")

  local ok, msg = self:command"ATI"
  if ok then
    U.DEBUG(self.subsys, "Firmware info: %s", U.dump(msg))
  else
    error(U.ERR(self.subsys, "Error getting firmware info"))
  end

  if self.factory_reset then
    self:command("AT&F")
    error(U.ERR(self.subsys, "Issued factory reset, now remove factory_reset from config"))
  end

  self.password = self.password or "password"
  local ok, msg = self:command"AT+N"
  if ok then
    U.DEBUG(self.subsys, "Network info: %s", U.dump(msg))
    if msg.data[1] == "+N=NoPAN" then
      U.DEBUG(self.subsys, "No PAN currently configured, setting up coordinator")
      local channelmask = bit.lshift(1, self.channel-11)
      self:setup("00", "%04X", channelmask)
      if self.pan_id then self:setup("02", "%04X", self.pan_id) end
      if self.eui64 then self:setup("04", self.eui64) end
      local ok, msg = self:command("ATS04?", true)
      self.eui64 = msg.data[1]
      if self.ext_pan_id then
        if self.ext_pan_id=="coordinator" then
          self:setup("03", self.eui64)
        else
          self:setup("03", self.ext_pan_id)
        end
      end
      if self.network_key then
        self:setup("08", "%s:%s", U.tohex(self.network_key), self.password)
      end
      -- for now this is hardcoded for the HA profile:
      self:setup("09", "%s:%s", "5A6967426565416C6C69616E63653039", self.password)
      -- JPAN prompt may (or will?) arrive before OK result of enable command
      local jpan_waiter = ctx.task{name="etrx_init_coord_wait", function()
        local ok, msg = ctx:wait({"ETRX", self, "Prompt", "JPAN"}, nil, timeout or 10.0)
        if not ok then error("network not established") end
        local channel, pan_id, ext_pan_id = string.match(msg.data, "([^,]+),([^,]+),(.*)")
        U.INFO(self.subsys, "module created PAN on channel %s with PAN id %s (ExtPAN id %s)", channel, pan_id, ext_pan_id)
      end}
      self:command("AT+EN", true, 10.0)
      jpan_waiter:finish()
    end
  else
    error(U.ERR(self.subsys, "Error getting network info"))
  end

  if self.power then self:setup("01", self.power) end
  local ok, msg = self:command("AT+N", true)
  local devtype, channel, power, pan_id, ext_pan_id = string.match(msg.data[1], "%+N=([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$")
  if devtype and channel and power and pan_id and ext_pan_id then
    U.DEBUG(self.subsys, "got network info: devtype=%s, channel=%s, power=%s, PAN id=%s, ExtPAN id=%s", devtype, channel, power, pan_id, ext_pan_id)
    if devtype ~= "COO" then
      error(U.ERR(self.subsys, "is not set to coordinator mode, aborting"))
    end
  else
    error(U.ERR(self.subsys, "cannot determine current operation mode"))
  end
  self:setup("0A", "%04X:%s",
      0x0100 -- use configured TC key
    + 0x0040 -- append RSSI and LQI to RX prompts
    + 0x0010 -- send network key encrypted with TC key to nodes joining
    + 0x0004 -- send network key encrypted with TC key to nodes rejoining unsecured
    + 0x0001 -- disallow joining
    ,self.password)
  self:setup("0F", "%04X",
      0x4000 -- Show RSSI & LQI for received packets
    + 0x2000 -- Display incoming ZDO messages by RX prompt rather than preparsed (because that is harder to parse here)
    + 0x1000 -- hex encode received messages
    + 0x0800 -- show NODELEFT msg
    + 0x0400 -- show EP & NWK with ACK/NACK
    + 0x0100 -- show unhandled messages for EPs >= 1
    + 0x0004 -- hide proprietary Sink msgs
  )
  ctx:fire({"Zigbee", self, "coordinator_ready"}, {ieeeaddr = self.eui64})
  return U.INFO(self.subsys, "initialized")
end

return dongle
