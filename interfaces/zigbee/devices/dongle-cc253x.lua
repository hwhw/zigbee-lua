local ctx = require"lib.ctx"
local U = require"lib.util"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"
local serial = require"lib.serial"
local ZNP = require"lib.codec""interfaces.zigbee.cc-znp"
local zigbee = require"interfaces.zigbee"

local dongle = {}

local cmd_types = {
  [0] = "POLL",
  [1] = "SREQ",
  [2] = "AREQ",
  [3] = "SRSP"
}

local cmd_subsystems = {
  [0]  = "RPC Error",
  [1]  = "SYS",
  [2]  = "MAC",        -- no ZNP
  [3]  = "NWK",        -- no ZNP
  [4]  = "AF",
  [5]  = "ZDO",
  [6]  = "SAPI",
  [7]  = "UTIL",
  [8]  = "DEBUG",      -- no ZNP
  [9]  = "APP interface",
  [15] = "APP config", -- no ZNP
  [21] = "GreenPower"  -- no ZNP
}

function dongle:sendpackage(data)
  local l = #data - 2
  assert(l >= 0)
  local fcs = bit.bxor(l, unpack(data))
  local req = string.char(0xFE, l, unpack(data))..string.char(fcs)
  self.port.fd:write(req)
  U.DEBUG(self.subsys.."/znp", "sending request:\n%s", U.hexdump(req))
end

function dongle:new(port, baud)
  local d = {
    ZNP = ZNP,
    subsys = string.format("dongle-cc2530/%s", port),
    handler = {},
  }

  d.port = serial.open(port)
  d.port:set_baud(baud)

  setmetatable(d, {__index = self})

  local frame_reader = coroutine.wrap(function()
    local readbyte = coroutine.yield
    while true do
      -- wait for SOF
      while true do
        local b = readbyte()
        if b == 0xFE then
          U.DEBUG(d.subsys, "SOF found")
          break
        else
          U.INFO(d.subsys, "skipping non-SOF byte 0x%02X", b)
        end
      end
      -- read data len
      local datalen = readbyte()
      -- read command (16 bit)
      local cmd1 = readbyte()
      local cmd2 = readbyte()
      -- read data
      local data = {cmd1, cmd2}
      for d = 1, datalen do table.insert(data, readbyte()) end
      -- calculate and check checksum
      if bit.bxor(datalen, unpack(data)) == readbyte() then
        -- success, we have a valid frame
        local cmd_type = bit.rshift(cmd1, 5)
        local cmd_subsys = bit.band(cmd1, 0x1F)
        U.DEBUG(d.subsys,
          "got MT command: type %s (%d), subsystem %s (0x%02X), command id 0x%02X, data:\n%s",
          cmd_types[cmd_type] or "unknown", cmd_type,
          cmd_subsystems[cmd_subsys] or "unknown", cmd_subsys,
          cmd2, U.hexdump(data))
        local o, name, remainder = ZNP:match(data)
        if not o then
          U.DEBUG(d.subsys, "no matching parser found.")
        else
          U.DEBUG(d.subsys, "MT command %s, payload:\n%s", name, U.dump(o))
          ctx:fire({"CC-ZNP-MT", d, name}, o)
          if remainder then
            local r={}
            while true do local c = remainder(); if not c then break end; table.insert(r, c); end
            U.DEBUG(d.subsys, "MT command %s, remaining data in package: %s",
              name, U.hexdump(r))
          end
        end
      else
        -- invalid frame
        U.ERR(d.subsys, "bad FCS, dismissing packet: cmd=%02X%02X, data:\n%s", cmd1, cmd2, U.hexdump(data))
      end
    end
  end)
  frame_reader() -- init

  ctx.srv:char_reader(d.port.fd, frame_reader)

  -- TODO: no need to have these running in their own tasks?
  d.on_state_change = ctx:task(function()
    while true do
      local _, state = d:waitreq("AREQ_ZDO_STATE_CHANGE_IND")
      d.state = tonumber(state.State)
      U.INFO(d.subsys, "device state changed to %d", d.state)
      -- TODO: fire event (at least on relevant states)
    end
  end)

  d.on_end_device_announce = ctx:task(function()
    while true do
      local _, enddevice = d:waitreq("AREQ_ZDO_END_DEVICE_ANNCE_IND")
      U.INFO(d.subsys, "end device announce received, device is %s (short: 0x%04x)", enddevice.IEEEAddr, enddevice.NwkAddr)
      ctx:fire(zigbee.ev.device_announce, {dongle = d, ieeeaddr = enddevice.IEEEAddr, nwkaddr = enddevice.NwkAddr})
    end
  end)

  d.on_leave_network = ctx:task(function()
    while true do
      local _, enddevice = d:waitreq(t, "AREQ_ZDO_LEAVE_IND")
      U.INFO(d.subsys, "device %s left the network, will %srejoin the network", enddevice.IEEEAddr, enddevice.Rejoin == 0 and "not " or "")
      ctx:fire(zigbee.ev.device_leave, {dongle = d, ieeeaddr = enddevice.IEEEAddr})
    end
  end)

  return d
end

function dongle:areq(areqname, data)
  U.DEBUG(self.subsys.."/areq", "sending AREQ %s, data: %s", areqname, U.dump(data))
  self:sendpackage(ZNP("AREQ_"..areqname):encode(data))
end

function dongle:waitreq(reqname, timeout, cond)
  return ctx:wait({"CC-ZNP-MT", self, reqname}, cond, timeout)
end

function dongle:sreq(sreqname, data, timeout)
  U.DEBUG(self.subsys.."/sreq", "sending SREQ %s, data: %s", sreqname, U.dump(data))
  self:sendpackage(ZNP("SREQ_"..sreqname):encode(data))
  return self:waitreq("SRSP_"..sreqname, timeout or 5.0)
end

local function check_ok(ok, ret)
  return ok and ret.Status==0, ret
end

function dongle:provision_device(nwk)
  U.INFO(self.subsys, "querying node descriptor for device 0x%04x", nwk)

  local devdata = {nwkaddr=nwk}

  local ok, res = check_ok(self:sreq("ZDO_NODE_DESC_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk}))
  if not ok then
    return U.ERR(self.subsys, "error issuing node descriptor query, aborting")
  end

  local ok, nodedesc = check_ok(self:waitreq("AREQ_ZDO_NODE_DESC_RSP", 1, U.filter{NwkAddrOfInterest=nwk}))
  if not ok then
    return U.ERR(self.subsys, "no or bad node descriptor received for device 0x%04x, aborting", nwk)
  end

  devdata.nodedesc = nodedesc

  U.INFO(self.subsys, "enumerate endpoints for device 0x%04x", nwk)
  local ok, res = check_ok(self:sreq("ZDO_ACTIVE_EP_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk}))
  if not ok then
    return U.ERR(self.subsys, "error issuing active endpoint query, aborting")
  end

  local ok, endpoints = check_ok(self:waitreq("AREQ_ZDO_ACTIVE_EP_RSP", 1, U.filter{NwkAddr=nwk}))
  if not ok then
    return U.ERR(self.subsys, "no or bad active endpoint info received for device 0x%04x, aborting", nwk)
  end
  
  devdata.eps = {}

  for _, ep in ipairs(endpoints.ActiveEPList) do
    U.INFO(self.subsys, "querying simple descriptor for EP %d of device 0x%04x", ep, nwk)
    local ok, res = check_ok(self:sreq("ZDO_SIMPLE_DESC_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk, Endpoint=ep}))
    if not ok then
      return U.ERR(self.subsys, "error issuing simple descriptor query, aborting")
    end

    local ok, desc = check_ok(self:waitreq("AREQ_ZDO_SIMPLE_DESC_RSP", 1, U.filter{NwkAddr=nwk, Endpoint=ep}))
    if not ok then
      return U.ERR(self.subsys, "no or bad simple descriptor received for EP %d of device 0x%04x, aborting", ep, nwk)
    end

    table.insert(devdata.eps, {
      Endpoint=ep,
      DeviceId=desc.DeviceId,
      DeviceVersion=desc.DeviceVersion,
      ProfileId=desc.ProfileId,
      InClusterList=desc.InClusterList,
      OutClusterList=desc.OutClusterList})
  end

  return devdata
end

function dongle:reset(retries)
  for i = 1, retries or 3 do
    U.INFO(self.subsys, "resetting device")
    self:areq("SYS_RESET_REQ")
    local ok, r = self:waitreq("AREQ_SYS_RESET_IND", 60)
    if ok then
      return U.INFO(self.subsys, "reset successful")
    end
  end
  return U.ERR(self.subsys, "could not reset dongle")
end

function dongle:conf_check(id, value, update)
  local ok, d = check_ok(self:sreq("ZB_READ_CONFIGURATION", {ConfigId=id}))
  if not ok then
    return U.ERR(self.subsys, "error reading config id %04x", id)
  end
  if type(value)=="table" then value=string.char(unpack(value)) end
  local current = string.char(unpack(d.Value))
  if current~=value then
    local _, msg = U.INFO(self.subsys, "config mismatch on id %04x, current:\n%sdesired:\n%s", id, U.hexdump(current), U.hexdump(value))
    if not update then return false, msg end
    if not check_ok(self:sreq("ZB_WRITE_CONFIGURATION", {ConfigId=id, Value=value})) then
      return U.ERR(self.subsys, "config id %04x could not be set.", id)
    end
  end
  return true
end

function dongle:version_check()
  local ok, info = self:sreq"SYS_PING"
  if not ok then
    return U.ERR(self.subsys, "error waiting for ping reply")
  end
  if not U.contains_all(info.Capabilities, {"MT_CAP_SYS", "MT_CAP_AF", "MT_CAP_ZDO", "MT_CAP_SAPI", "MT_CAP_UTIL"}) then
    return U.ERR(self.subsys, "firmware does not support needed features")
  end
  return U.INFO(self.subsys, "firmware supports all needed features")
end

function dongle:subscribe(subsys, enable)
  if not check_ok(self:sreq("UTIL_CALLBACK_SUB_CMD", {Subsystem={subsys}, Action=enable and {"Enable"} or {"Disable"}})) then
    return U.ERR(self.subsys, "error (un-)subscribing to events for subsystem %s", subsys)
  end
  return U.INFO(self.subsys, "%s to %s events", enable and "subscribed" or "unsubscribed", subsys)
end

function dongle:initialize_coordinator(reset_conf)
  if not self:reset()
    or not self:version_check()
    or not self:conf_check(0x62, {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13}, reset_conf) -- network key
  then
    return U.ERR(self.subsys, "error initializing")
  end

  local ok, extaddr = self:sreq("SYS_GET_EXTADDR")
  if not ok then
    return U.ERR(self.subsys, "cannot read external address")
  end
  local extaddr = extaddr.ExtAddress

  -- TODO: handle wrong extaddr

  if not self:conf_check(0x87, {0}, reset_conf) -- logical type: coordinator
    or not self:conf_check(0x83, U.reverse(U.fromhex"1a62"), reset_conf) -- PAN ID
    or not self:conf_check(0x2D, U.reverse(U.fromhex(extaddr)), reset_conf) -- extended PAN ID
    or not self:conf_check(0x84, U.reverse(U.fromhex"00000800"), reset_conf) -- Channel 0x800 = 1<<11 = channel 11
    or not self:conf_check(0x8F, {1}, reset_conf) -- ZDO direct cb
    or not self:conf_check(0x64, {1}, reset_conf) -- enable security
    or not self:reset()
    or not self:subscribe("MT_AF", true)
    or not self:subscribe("MT_UTIL", true)
    or not self:subscribe("MT_ZDO", true)
    or not self:subscribe("MT_SAPI", true)
    or not self:subscribe("MT_SYS", true)
    or not self:subscribe("MT_DEBUG", true)
    or not check_ok(self:sreq("ZDO_STARTUP_FROM_APP",nil,30))
    -- does this make any sense?:
    or not check_ok(self:sreq("ZDO_END_DEVICE_ANNCE", {NwkAddr=0, IEEEAddr=extaddr, Capabilities={"ZigbeeRouter","MainPowered","ReceiverOnWhenIdle","AllocateShortAddress"}}))
    or not check_ok(self:sreq("AF_REGISTER", {EndPoint=1, AppProfId=0x104, AppDeviceId=5, AddDevVer=0, LatencyReq={"NoLatency"}, AppInClusterList={6}, AppOutClusterList={6}}))
  then
    return U.ERR(self.subsys, "error initializing")
  end
  ctx:fire(zigbee.ev.coordinator_ready, {dongle = self, ieeeaddr = extaddr})
  return U.INFO(self.subsys, "initialized")
end

return dongle
