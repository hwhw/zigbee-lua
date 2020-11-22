local U = require"lib.util"

-- LuaJIT builtin libs:
local ffi = require"ffi"
local bit = require"bit"

-- LJSyscall
local S = require"lib.ljsyscall"

-- wrapper for epoll()
local maxevents = 1024
local timeout = 60000 -- 1 minute
local function nilf() return nil end
local poll = {
  new = function(this)
    local epollsrv = {
      default_timeout = timeout,
      fd = U.assert(S.epoll_create()),
      fds = {}
    }
    return setmetatable(epollsrv, {__index = this})
  end,
  event = S.t.epoll_event(),
  add = function(this, s, events, callbacks)
    local E = {
      socket = s,
      event = S.t.epoll_event(),
    }
    callbacks.__index = callbacks
    setmetatable(E, callbacks)
    E.event.events = events or S.c.EPOLL.IN
    E.event.data.fd = type(s)=="number" and s or s:getfd()
    U.assert(this.fd:epoll_ctl("add", s, E.event))
    U.DEBUG("srv", "added FD %d to epoll group", E.event.data.fd)
    if E.worker then E:worker() end
    this.fds[E.event.data.fd] = E
  end,
  del = function(this, s)
    local fd = type(s)=="number" and s or s:getfd()
    local E = this.fds[fd]
    if E then
      U.assert(this.fd:epoll_ctl("del", s, E.event))
      this.fds[fd] = nil
      U.DEBUG("srv", "removed FD %d from epoll group", fd)
    else
      U.ERR("srv", "cannot remove socket %d from epoll group, no entry", fd)
    end
  end,
  events = S.t.epoll_events(maxevents),
  get = function(this, timeout)
    local f, a, r = this.fd:epoll_wait(this.events, timeout)
    if not f then
      U.ERR("srv", "error on fd: %s\n", a)
      return nilf
    else
      return f, a, r
    end
  end,
  register_before_wait = function(this, cb)
    this.before_wait = this.before_wait or {}
    this.before_wait[cb] = cb
  end,
  unregister_before_wait = function(this, cb)
    this.before_wait[cb] = nil
  end,
  set_max_timeout = function(this, max_timeout)
    this.timeout = math.min(this.timeout, max_timeout)
    U.DEBUG('srv', "timeout: %s, %s", max_timeout, this.timeout)
  end,
  loop = function(this)
    while true do
      this.timeout = this.default_timeout
      for _, c in pairs(this.before_wait or {}) do c(this) end
      U.DEBUG("srv", "waiting for epoll events")
      for i, ev in this:get(this.timeout) do
        U.DEBUG("srv", "got event on fd %d", ev.fd)
        local E = this.fds[ev.fd]
        if E then
          if ev.HUP or ev.ERR or ev.RDHUP then
            U.DEBUG("srv", "FD %d has error/HUP condition, cleaning up", ev.fd)
            if E.on_error then E:on_error() end
            this.del(this, E.socket)
            E.socket:close()
          elseif ev.IN and E.on_readable then E:on_readable()
          elseif ev.OUT and E.on_writable then E:on_writable()
          end
        end
      end
    end
  end
}

assert(S.signal("pipe", "ign"))

local srv = poll:new()

function srv:tcp_client(address, port, callbacks)
  local sock = U.assert(S.socket("inet", "stream"))
  local sockaddr = U.assert(S.t.sockaddr_in(port, address))
  U.assert(sock:connect(sockaddr))
  self:add(sock, S.c.EPOLL.IN, callbacks)
  return sock
end

function srv:udp_client(address, port)
  local sock = U.assert(S.socket("inet", "dgram"))
  local sockaddr = U.assert(S.t.sockaddr_in(port, address))
  U.assert(sock:connect(sockaddr))
  return sock
end

function srv:tcp_server(address, port, callbacks)
  local sock = U.assert(S.socket("inet", "stream, nonblock"))
  sock:setsockopt("socket", "reuseaddr", true)
  local sockaddr = U.assert(S.t.sockaddr_in(port, address))
  U.assert(sock:bind(sockaddr))
  U.assert(sock:listen(128))
  local ss = S.t.sockaddr_storage()
  local addrlen = S.t.socklen1(S.t.sockaddr_storage)
  self:add(sock, S.c.EPOLL.IN, {
    on_error = function(this)
      U.ERR("srv", "error on TCP server FD, shutting down socket")
      -- TODO: remove all child FDs? maybe not needed, should fail themselves?
    end,
    on_readable = function(this)
      repeat
        local client, err = this.socket:accept("nonblock", ss, addrlen)
        if client then
          self:add(client, S.c.EPOLL.IN, callbacks)
        end
      until not a
    end
  })
end

function srv:sock_server(fd, event_callbacks)
  self:add(fd, S.c.EPOLL.IN, event_callbacks)
end

function srv:char_reader(fd, char_reader)
  local bufsize = 1024
  local buf = ffi.new("uint8_t[?]", bufsize)
  self:add(fd, nil, {
    on_readable = function(this)
      local fd = this.socket:getfd()
      if fd < 0 then return end
      local n, err = this.socket:read(buf, bufsize)
      assert(n>=0 and not err, "reading from socket")
      for i=0,n-1 do char_reader(buf[i]) end
    end,
    on_error = function(this)
      U.ERR("srv", "error reading from fd, exiting.")
      os.exit(1)
    end
  })
end

function srv:timer(t, callback, ...)
  local sock = U.assert(S.timerfd_create("monotonic", "cloexec, nonblock"))
  local p = {...}
  U.assert(sock:timerfd_settime(nil, type(t)=="number" and {0, t} or t))
  self:add(sock, S.c.EPOLL.IN, {
    on_readable = function(this)
      callback(unpack(p))
    end
  })
  return sock
end

function srv:timer_del(sock)
  self:del(sock)
  sock:close()
end

return srv
