local C = require"config"
local U = require"util"
local ffi = require"ffi"
local bit = require"bit"
local S = require"ljsyscall"
local serial = require"serial"
local srv = require"srv"

local dongle = {_taskid=0}

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

local znp_status = {
  [0x00] = "ZSuccess",
  [0x01] = "Zfailure",
  [0x02] = "ZinvalidParameter",
  [0x09] = "NV_ITEM_UNINIT",
  [0x0a] = "NV_OPER_FAILED",
  [0x0c] = "NV_BAD_ITEM",
  [0x10] = "ZmemError",
  [0x11] = "ZbufferFull",
  [0x12] = "ZunsupportedMode",
  [0x13] = "ZmacMemError",
  [0x80] = "zdoInvalidRequestType",
  [0x82] = "zdoInvalidEndpoint",
  [0x84] = "zdoUnsupported",
  [0x85] = "zdoTimeout",
  [0x86] = "zdoNoMatch",
  [0x87] = "zdoTableFull",
  [0x88] = "zdoNoBindEntry",
  [0xa1] = "ZSecNoKey",
  [0xa3] = "ZSecMaxFrmCount",
  [0xb1] = "ZapsFail",
  [0xb2] = "ZapsTableFull",
  [0xb3] = "ZapsIllegalRequest",
  [0xb4] = "ZapsInvalidBinding",
  [0xb5] = "ZapsUnsupportedAttrib",
  [0xb6] = "ZapsNotSupported",
  [0xb7] = "ZapsNoAck",
  [0xb8] = "ZapsDuplicateEntry",
  [0xb9] = "ZapsNoBoundDevice",
  [0xc1] = "ZnwkInvalidParam",
  [0xc2] = "ZnwkInvalidRequest",
  [0xc3] = "ZnwkNotPermitted",
  [0xc4] = "ZnwkStartupFailure",
  [0xc7] = "ZnwkTableFull",
  [0xc8] = "ZnwkUnknownDevice",
  [0xc9] = "ZnwkUnsupportedAttribute",
  [0xca] = "ZnwkNoNetworks",
  [0xcb] = "ZnwkLeaveUnconfirmed",
  [0xcc] = "ZnwkNoAck",
  [0xcd] = "ZnwkNoRoute",
  [0xe9] = "ZMacNoACK"
}

local sreq_error_codes = {
  [0x01] = "Invalid subsystem",
  [0x02] = "Invalid command ID",
  [0x03] = "Invalid parameter",
  [0x04] = "Invalid length"
}

local ZNP=require"codec""znp"
function dongle:sendpackage(data)
  local l = #data - 2
  assert(l >= 0)
  local fcs = bit.bxor(l, unpack(data))
  local req = string.char(0xFE, l, unpack(data))..string.char(fcs)
  self.port.fd:write(req)
  U.DEBUG(self.subsys.."/znp", "sending request:\n%s", U.hexdump(req))
end

local task = srv.task:new()

function task:waitmsg(msg, timeout, cond)
  local t = self.dongle._taskid
  self.dongle._taskid = self.dongle._taskid + 1
  U.DEBUG(self.dongle.subsys.."/task/waitmsg", "task %d: waiting for message %s", t, msg)

  local handlers = self.dongle.handler[msg] or {}
  local timer = timeout and self.dongle.ctx.srv:timer(timeout, function()
    U.DEBUG(self.dongle.subsys.."/task/waitmsg", "task %d: timeout", t)
    if handlers[t] then
      handlers[t] = nil
      self:continue(false, "timeout")
    end
  end)
  handlers[t] = function(data)
    if (not cond) or cond(data) then
      U.DEBUG(self.dongle.subsys.."/task/waitmsg", "task %d: message received", t)
      handlers[t] = nil
      if timer then self.dongle.ctx.srv:timer_del(timer) end
      self:continue(data)
    end
  end
  self.dongle.handler[msg] = handlers
  return coroutine.yield(true)
end

function task:areq(areqname, data)
  U.DEBUG(self.dongle.subsys.."/areq", "sending AREQ %s, data: %s", areqname, U.dump(data))
  self.dongle:sendpackage(ZNP("AREQ_"..areqname):encode(data))
end

function task:sreq(sreqname, data, timeout)
  U.DEBUG(self.dongle.subsys.."/sreq", "sending SREQ %s, data: %s", sreqname, U.dump(data))
  self.dongle:sendpackage(ZNP("SREQ_"..sreqname):encode(data))
  return self:waitmsg("SRSP_"..sreqname, timeout or 5.0)
end

dongle.task = task

function dongle:task_create(func)
  local t = task:create(func)
  t.dongle = self
  return t
end

function dongle:handle_frame(cmd1, cmd_id, data)
  local cmd_type = bit.rshift(cmd1, 5)
  local cmd_subsys = bit.band(cmd1, 0x1F)
  U.DEBUG(self.subsys,
    "got MT command: type %s (%d), subsystem %s (0x%02X), command id 0x%02X, data:\n%s",
    cmd_types[cmd_type] or "unknown", cmd_type,
    cmd_subsystems[cmd_subsys] or "unknown", cmd_subsys,
    cmd_id, U.hexdump(data))
  local o, name, remainder = ZNP:match(data)
  if not o then
    U.DEBUG(self.subsys, "no matching parser found.")
  else
    U.DEBUG(self.subsys, "got MT command %s, payload:\n%s", name, U.dump(o))
    if self.handler[name] then
      for _, h in pairs(self.handler[name]) do
        h(o)
      end
    end
    if remainder then
      local r={}
      while true do local c = remainder(); if not c then break end; table.insert(r, c); end
      U.DEBUG(self.subsys, "got MT command %s, remaining data in package: %s",
        name, U.hexdump(r))
    end
  end
end

function dongle:new(ctx, port, baud)
  local d = {
    ctx = ctx,
    ZNP = ZNP,
    subsys = string.format("dongle-cc2530/%s", port),
    handler = {},
  }

  d.port = serial.open(port)
  d.port:set_baud(baud)

  local bufsize = 1024
  local buf = ffi.new("uint8_t[?]", bufsize) --S.t.buffer(bufsize)
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
        d:handle_frame(cmd1, cmd2, data)
      else
        U.ERR(d.subsys, "bad FCS, dismissing packet: cmd=%02X%02X, data:\n%s", cmd1, cmd2, U.hexdump(data))
      end
    end
  end)
  frame_reader() -- init

  ctx.srv:add(d.port.fd, nil, {
    on_readable = function(this)
      local fd = this.socket:getfd()
      if fd < 0 then return end
      local n, err = this.socket:read(buf, bufsize)
      assert(n>=0 and not err, "reading from socket")
      for i=0,n-1 do frame_reader(buf[i]) end
    end,
    on_error = function(this)
      U.ERR(d.subsys, "error reading from device, exiting.")
      os.exit(1)
    end
  })

  return setmetatable(d, {__index = self})
end

return dongle
