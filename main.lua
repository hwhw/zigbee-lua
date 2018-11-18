local C = require"config"
local U = require"lib.util"
local ffi = require"ffi"

local ctx = {srv=require"lib.srv"}
local tcp_server = require"interfaces.tcp-server"
tcp_server:new(ctx, '127.0.0.1', arg[1] or 16580)

local cc2530 = require"interfaces.zigbee.devices.dongle-cc253x"
ctx.dongle = cc2530:new(ctx, arg[2] or C.port, C.baud)

----------------------------------------------------------------------

ctx.dongle:task_create(function(t)
  while true do
    local state = t:waitmsg("AREQ_ZDO_STATE_CHANGE_IND", false)
    t.dongle.state = state.State
    U.INFO("task/state", "device state changed to %d", tonumber(t.dongle.state))
  end
end):run()

local devs = {}
ctx.dongle:task_create(function(t)
  while true do
    local enddevice = t:waitmsg("AREQ_ZDO_END_DEVICE_ANNCE_IND", false)

    local dev = enddevice.IEEEAddr
    local nwk = enddevice.NwkAddr
    local devdata = {NwkAddr=nwk, querying=true}

    U.INFO("task/newdev", "new end device announce received, device is %s (short: 0x%04x)", dev, nwk)
    if devs[dev] and devs[dev].querying then
      U.INFO("task/newdev", "device is currently being examined")
    elseif devs[dev] and devs[dev].NwkAddr == nwk then
      U.INFO("task/newdev", "device is already known")
    else
      U.INFO("task/newdev", "new device or new NWK address, examining")
      devs[dev] = devdata

      ctx.dongle:task_create(function(t)
        U.INFO("task/newdev/nodedesc", "querying node descriptor for device 0x%04x", nwk)
        local ok = t:sreq("ZDO_NODE_DESC_REQ",{DstAddr=nwk, NWKAddrOfInterest=nwk})
        if not ok or ok.Status ~= 0 then
          U.ERR("task/newdev/nodedesc", "error issuing node descriptor query, aborting")
          devs[dev] = nil
          return
        end

        local nodedesc = t:waitmsg("AREQ_ZDO_NODE_DESC_RSP", 1, U.filter{NwkAddrOfInterest=nwk})
        if not nodedesc or nodedesc.Status ~= 0 then
          U.ERR("task/newdev/nodedesc", "no or bad node descriptor received for device 0x%04x, aborting", nwk)
          devs[dev] = nil
          return
        end

        -- TODO: store some desc data?

        ctx.dongle:task_create(function(t)
          U.INFO("task/newdev/enumerate_eps", "enumerate endpoints for device 0x%04x", nwk)
          local ok = t:sreq("ZDO_ACTIVE_EP_REQ",{DstAddr=nwk, NWKAddrOfInterest=nwk})
          if not ok or ok.Status ~= 0 then
            U.ERR("task/newdev/enumerate_eps", "error issuing active endpoint query, aborting")
            devs[dev] = nil
            return
          end

          local endpoints = t:waitmsg("AREQ_ZDO_ACTIVE_EP_RSP", 1, U.filter{NwkAddr=nwk})
          if not endpoints or endpoints.Status ~= 0 then
            U.ERR("task/newdev/enumerate_eps", "no or bad active endpoint info received for device 0x%04x, aborting", nwk)
            devs[dev] = nil
            return
          end
          
          devdata.eps = {}

          ctx.dongle:task_create(function(t)
            for _, ep in ipairs(endpoints.ActiveEPList) do
              U.INFO("task/newdev/simple_desc", "querying simple descriptor for EP %d of device 0x%04x", ep, nwk)
              local ok = t:sreq("ZDO_SIMPLE_DESC_REQ",{DstAddr=nwk, NWKAddrOfInterest=nwk, Endpoint=ep})
              if not ok or ok.Status ~= 0 then
                U.ERR("task/newdev/simple_desc", "error issuing simple descriptor query, aborting")
                devs[dev] = nil
                return
              end

              local desc = t:waitmsg("AREQ_ZDO_SIMPLE_DESC_RSP", 1, U.filter{NwkAddr=nwk, Endpoint=ep})
              if not desc or desc.Status ~= 0 then
                U.ERR("task/newdev/simple_desc", "no or bad simple descriptor received for EP %d of device 0x%04x, aborting", ep, nwk)
                devs[dev] = nil
                return
              end

              devdata.eps[ep] = {DeviceId=desc.DeviceId, DeviceVersion=desc.DeviceVersion, ProfileId=desc.ProfileId, InClusterList=desc.InClusterList, OutClusterList=desc.OutClusterList}
              devdata.querying = nil
            end
          end):run()
        end):run()
      end):run()
    end
  end
end):run()

ctx.dongle:task_create(function(t)
  while true do
    local enddevice = t:waitmsg("AREQ_ZDO_LEAVE_IND", false)
    U.INFO("task/newdev", "device %s left the network, will %srejoin the network", enddevice.IEEEAddr, enddevice.Rejoin == 0 and "not " or "")
    -- TODO: remove from dev list?
  end
end):run()

ctx.dongle:task_create(function(t)
  local function reset()
    while true do
      t:areq("SYS_RESET_REQ")
      local r = t:waitmsg("AREQ_SYS_RESET_IND", 60)
      if r then
        U.DEBUG("task/init", "reset successful")
        break
      end
    end
  end

  local function version_check()
    local info = t:sreq"SYS_PING"
    return info and U.contains_all(info.Capabilities, {"MT_CAP_SYS", "MT_CAP_AF", "MT_CAP_ZDO", "MT_CAP_SAPI", "MT_CAP_UTIL"})
  end

  local function check_ok(r)
    return r and r.Status==0, r
  end

  local function conf_check(id, value)
    local ok, d = check_ok(t:sreq("ZB_READ_CONFIGURATION",{ConfigId=id}))
    if not ok then
      U.ERR("task/init", "error reading config id %04x", id)
      return false
    end
    if type(value)=="table" then value=string.char(unpack(value)) end
    local current = string.char(unpack(d.Value))
    if current~=value then
      U.DEBUG("task/init", "config mismatch on id %04x, current:\n%sdesired:\n%s", id, U.hexdump(current), U.hexdump(value))
      if not check_ok(t:sreq("ZB_WRITE_CONFIGURATION",{ConfigId=id, Value=value})) then
        U.ERR("task/init", "config id %04x could not be set.", id)
        return false
      end
    end
    return true
  end

  local function subscribe(subsys, enable)
    if not check_ok(t:sreq("UTIL_CALLBACK_SUB_CMD", {Subsystem={subsys}, Action=enable and {"Enable"} or {"Disable"}})) then
      U.ERR("task/init", "error (un-)subscribing to events for subsystem %s", subsys)
    end
  end
  
  reset()
  if not version_check() then
    U.ERR("task/init", "firmware does not support needed features, aborting")
    return
  end
  conf_check(0x62, {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13}) -- network key

  reset()
  local d = t:sreq("SYS_GET_EXTADDR")
  if not d then
    U.ERR("task/init", "cannot read external address")
    return
  end
  local extaddr = d.ExtAddress
  -- TODO: handle wrong extaddr
  conf_check(0x87, {0}) -- logical type: coordinator
  conf_check(0x83, {0x62, 0x1A}) -- PAN ID
  conf_check(0x2D, extaddr) -- extended PAN ID
  --conf_check(0x84, {0x00, 0x00, 0x08, 0x00}) -- Channel 0x800 = 1<<11 = channel 11
  conf_check(0x84, {0x00, 0x08, 0x00, 0x00}) -- Channel 0x800 = 1<<11 = channel 11
  conf_check(0x8F, {1}) -- ZDO direct cb
  
  subscribe("MT_AF", true)
  subscribe("MT_UTIL", true)
  subscribe("MT_ZDO", true)
  subscribe("MT_SAPI", true)
  subscribe("MT_SYS", true)
  subscribe("MT_DEBUG", true)

  if not check_ok(t:sreq("ZDO_STARTUP_FROM_APP",nil,30)) then
    U.ERR("task/init", "error on startup")
  end

  conf_check(0x64, {1}) -- enable security

  -- does this make any sense?:
  t:sreq("ZDO_END_DEVICE_ANNCE", {NwkAddr=0, IEEEAddr=extaddr, Capabilities={"ZigbeeRouter","MainPowered","ReceiverOnWhenIdle","AllocateShortAddress"}})

  if not check_ok(t:sreq("AF_REGISTER", {EndPoint=1, AppProfId=0x104, AppDeviceId=5, AddDevVer=0, LatencyReq={"NoLatency"}, AppInClusterList={6}, AppOutClusterList={6}})) then
    U.ERR("task/init", "error registering ZHA endpoint")
  end
end):run()

----------------------------------------------------------------------
ctx.srv:loop()
