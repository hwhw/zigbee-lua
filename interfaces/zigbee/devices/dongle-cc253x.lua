local ctx = require"lib.ctx"
local U = require"lib.util"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"
local serial = require"lib.serial"
local ccznp = require"interfaces.zigbee.cc-znp""ZNP"
local zigbee = require"interfaces.zigbee"

local dongle = U.object:new{
  subsys = "dongle-cc2530",
  handler = {}
}

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
  self.serial.fd:write(req)
  U.DEBUG({self.subsys,"znp"}, "sending request:\n%s", U.hexdump(req))
end

local function check_ok(ok, ret)
  return ok and ret.Status==0, ret
end

function dongle:areq(areqname, data)
  U.DEBUG({self.subsys,"areq"}, "sending AREQ %s, data: %s", areqname, U.dump(data))
  local req="AREQ_"..areqname
  print(U.dump{Cmd=req,[req]=(data or {})})
  self:sendpackage(ccznp:encode{Cmd=req,[req]=(data or {})})
end

function dongle:sreq(sreqname, data, timeout)
  U.DEBUG({self.subsys,"sreq"}, "sending SREQ %s, data: %s", sreqname, U.dump(data))
  local sreq, srsp = "SREQ_"..sreqname, "SRSP_"..sreqname
  self:sendpackage(ccznp:encode{Cmd=sreq,[sreq]=(data or {})})
  return ctx:wait({"CC-ZNP-MT", self, "SRSP_"..sreqname}, nil, timeout or 5.0)
end

function dongle:init()
  self.subsys = string.format("dongle-cc2530/%s", self.port)

  self.serial = serial.open(self.port)
  self.serial:set_baud(self.baud)

  local frame_reader = coroutine.wrap(function()
    local readbyte = coroutine.yield
    while true do
      -- wait for SOF
      while true do
        local b = readbyte()
        if b == 0xFE then
          U.DEBUG(self.subsys, "SOF found")
          break
        else
          U.INFO(self.subsys, "skipping non-SOF byte 0x%02X", b)
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
        U.DEBUG({self.subsys, "mt"},
          "got MT command: type %s (%d), subsystem %s (0x%02X), command id 0x%02X, data:\n%s",
          cmd_types[cmd_type] or "unknown", cmd_type,
          cmd_subsystems[cmd_subsys] or "unknown", cmd_subsys,
          cmd2, U.hexdump(data))
        local ok, o, remainder = ccznp:safe_decode(data)
        if not ok then
          U.ERR({self.subsys, "mt"}, "error parsing MT command. skipping.")
        elseif not o then
          U.DEBUG({self.subsys, "mt"}, "no matching parser found.")
        else
          U.DEBUG({self.subsys, "mt"}, "MT command %s, payload:\n%s", o.Cmd, U.dump(o[o.Cmd]))
          ctx:fire({"CC-ZNP-MT", self, o.Cmd}, o[o.Cmd])
          if remainder then
            local r={}
            while true do local c = remainder(); if not c then break end; table.insert(r, c); end
            U.DEBUG({self.subsys, "mt"}, "MT command %s, remaining data in package: %s",
              name, U.hexdump(r))
          end
        end
      else
        -- invalid frame
        U.ERR({self.subsys, "mt"}, "bad FCS, dismissing packet: cmd=%02X%02X, data:\n%s", cmd1, cmd2, U.hexdump(data))
      end
    end
  end)
  frame_reader() -- init

  ctx.srv:char_reader(self.serial.fd, frame_reader)

  self.on_state_change = ctx.task{name="cc253x_state_change", function()
    for _, state in ctx:wait_all{"CC-ZNP-MT", self, "AREQ_ZDO_STATE_CHANGE_IND"} do
      self.state = tonumber(state.State)
      U.INFO(self.subsys, "device state changed to %d", self.state)
      -- TODO: fire event (at least on relevant states)
    end
  end}

  self.on_end_device_announce = ctx.task{name="cc253x_end_device_announce", function()
    for _, enddevice in ctx:wait_all{"CC-ZNP-MT", self, "AREQ_ZDO_END_DEVICE_ANNCE_IND"} do
      U.INFO(self.subsys, "end device announce received, device is %s (short: 0x%04x)", enddevice.IEEEAddr, enddevice.NwkAddr)
      ctx:fire({"Zigbee", self, "device_announce"}, {ieeeaddr = enddevice.IEEEAddr, nwkaddr = enddevice.NwkAddr})
    end
  end}

  self.on_leave_network = ctx.task{name="cc253x_leave_network", function()
    for _, enddevice in ctx:wait_all{"CC-ZNP-MT", self, "AREQ_ZDO_LEAVE_IND"} do
      U.INFO(self.subsys, "device %s left the network, will %srejoin the network", enddevice.IEEEAddr, enddevice.Rejoin == 0 and "not " or "")
      ctx:fire({"Zigbee", self, "device_leave"}, {ieeeaddr = enddevice.IEEEAddr})
    end
  end}

  self.on_af_incoming_msg = ctx.task{name="cc253x_incoming_message", function()
    for _, msg in ctx:wait_all{"CC-ZNP-MT", self, "AREQ_AF_INCOMING_MSG"} do
      U.INFO(self.subsys.."/af", "incoming message from 0x%04x, clusterid 0x%04x, dst EP %d", msg.SrcAddr, msg.ClusterId, msg.DstEndpoint)
      local profile = false
      if msg.DstEndpoint == 1 then
        profile = 0x104
      end
      if profile then
        ctx:fire({"Zigbee", self, "af_message"}, {
          data = msg.Data,
          src = msg.SrcAddr,
          clusterid = msg.ClusterId,
          localendpoint = msg.DstEndpoint,
          srcendpoint = msg.SrcEndpoint,
          profile = profile,
          linkquality = msg.LinkQuality
        })
      end
    end
  end}

  self.on_permit_join = ctx.task{name="cc253x_permit_join", function()
    for ok, data in ctx:wait_all{"Zigbee", "permit_join"} do
      if not ok then
        U.ERR(self.subsys, "error waiting for permit_join event")
      elseif not data.pan_id or data.pan_id == self.pan_id then
        -- NOTE: to force joining via a specific router, you need to add the coordinator (0)
        -- to the list of excluded devices, even if it was not among the included devices
        data.include = data.include or { 0 }
        data.include = type(data.include) == "table" and data.include or {data.include}
        data.exclude = data.exclude or {}
        data.exclude = type(data.exclude) == "table" and data.exclude or {data.exclude}
        data.duration = data.duration or 0xFE

        for _, devaddr in ipairs(data.include) do
          local addrmode = (devaddr == 0xFFFF or devaddr == 0xFFFC) and 0xFF or 0x02
          local ok, _ = check_ok(self:sreq("ZDO_MGMT_PERMIT_JOIN_REQ", {AddrMode=addrmode,DstAddr=devaddr,Duration=data.duration,TCSignificance=1}))
          if not ok then
            U.ERR(self.subsys, "error sending ZDO_MGMT_PERMIT_JOIN_REQ to devaddr %04x", devaddr)
          end
        end
        for _, devaddr in ipairs(data.exclude) do
          local addrmode = (devaddr == 0xFFFF or devaddr == 0xFFFC) and 0xFF or 0x02
          local ok, _ = check_ok(self:sreq("ZDO_MGMT_PERMIT_JOIN_REQ", {AddrMode=addrmode,DstAddr=devaddr,Duration=0,TCSignificance=0}))
          if not ok then
            U.ERR(self.subsys, "error sending ZDO_MGMT_PERMIT_JOIN_REQ to devaddr %04x", devaddr)
          end
        end
      end
    end
  end}

  return self
end

function dongle:tx(p)
  return self:sreq("AF_DATA_REQUEST", {
    DstAddr = p.dst,
    DstEndpoint = p.dst_ep,
    SrcEndpoint = p.src_ep,
    ClusterId = p.clusterid,
    TransId = 1,
    Options = {},
    Radius = dev.defaultradius or 3,
    Data = p.data
  })
end

function dongle:get_ieeeaddr(nwk)
  U.INFO(self.subsys, "looking up IEEEAddr for NWK addr %04x", nwk)
  local ok, res = self:sreq("UTIL_ADDRMGR_NWK_ADDR_LOOKUP", {NwkAddr=nwk})
  if ok then return res.ExtAddr end
end

function dongle:provision_device(nwk)
  U.INFO(self.subsys, "querying node descriptor for device %04x", nwk)

  local devdata = {nwkaddr=nwk}
  local ok, res, nodedesc, endpoints, desc

  for try=5,1,-1 do
    ok, res = check_ok(self:sreq("ZDO_NODE_DESC_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk}))
    if not ok then
      return U.ERR(self.subsys, "error issuing node descriptor query, aborting")
    end

    ok, nodedesc = check_ok(ctx:wait({"CC-ZNP-MT", self, "AREQ_ZDO_NODE_DESC_RSP"}, U.filter{NwkAddrOfInterest=nwk}, 5+math.random(5)))
    if not ok then
      U.ERR(self.subsys, "no or bad node descriptor received for device %04x", nwk)
      if try==1 then
        return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
      end
    else
      break
    end
  end

  devdata.nodedesc = nodedesc

  U.INFO(self.subsys, "enumerate endpoints for device 0x%04x", nwk)
  for try=5,1,-1 do
    ok, res = check_ok(self:sreq("ZDO_ACTIVE_EP_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk}))
    if not ok then
      return U.ERR(self.subsys, "error issuing active endpoint query, aborting")
    end

    ok, endpoints = check_ok(ctx:wait({"CC-ZNP-MT", self, "AREQ_ZDO_ACTIVE_EP_RSP"}, U.filter{NwkAddr=nwk}, 5+math.random(5)))
    if not ok then
      U.ERR(self.subsys, "no or bad active endpoint info received for device %04x", nwk)
      if try==1 then
        return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
      end
    else
      break
    end
  end
  
  devdata.eps = {}

  for _, ep in ipairs(endpoints.ActiveEPList) do
    U.INFO(self.subsys, "querying simple descriptor for EP %d of device %04x", ep, nwk)
    for try=5,1,-1 do
      ok, res = check_ok(self:sreq("ZDO_SIMPLE_DESC_REQ", {DstAddr=nwk, NWKAddrOfInterest=nwk, Endpoint=ep}))
      if not ok then
        return U.ERR(self.subsys, "error issuing simple descriptor query, aborting")
      end

      ok, desc = check_ok(ctx:wait({"CC-ZNP-MT", self, "AREQ_ZDO_SIMPLE_DESC_RSP"}, U.filter{NwkAddr=nwk, Endpoint=ep}, 5+math.random(5)))
      if not ok then
        U.ERR(self.subsys, "no or bad simple descriptor received for EP %d of device %04x", ep, nwk)
        if try==1 then
          return U.ERR(self.subsys, "aborting provisioning of device %04x", nwk)
        end
      else
        break
      end
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
    local ok, r = ctx:wait({"CC-ZNP-MT", self, "AREQ_SYS_RESET_IND"}, nil, 60)
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
    or not self:conf_check(0x62, self.network_key, reset_conf) -- network key
  then
    return U.ERR(self.subsys, "error initializing")
  end

  local ok, extaddr = self:sreq("SYS_GET_EXTADDR")
  if not ok then
    return U.ERR(self.subsys, "cannot read external address")
  end
  local extaddr = extaddr.ExtAddress

  -- TODO: handle wrong extaddr

  local channelmask = bit.lshift(1, self.channel)
  if not self:conf_check(0x87, {0}, reset_conf) -- logical type: coordinator
    or not self:conf_check(0x83, 
      {bit.band(self.pan_id, 0xFF), bit.rshift(self.pan_id, 8)}, reset_conf) -- PAN ID
    or not self:conf_check(0x2D, 
      (self.ext_pan_id=="coordinator") and U.reverse(U.fromhex(extaddr))
      or U.reverse(U.fromhex(self.ext_pan_id)), reset_conf) -- extended PAN ID
    or not self:conf_check(0x84, {
      bit.band(channelmask, 0xFF),
      bit.band(bit.rshift(channelmask, 8), 0xFF),
      bit.band(bit.rshift(channelmask, 16), 0xFF),
      bit.band(bit.rshift(channelmask, 24), 0xFF)}, reset_conf)
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
  ctx:fire({"Zigbee", self, "coordinator_ready"}, {ieeeaddr = extaddr})
  return U.INFO(self.subsys, "initialized")
end

return dongle
