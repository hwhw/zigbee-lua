local U = require"util"
local C = require"config"

-- LuaJIT builtin libs:
local ffi = require"ffi"
local bit = require"bit"

-- LJSyscall
local S = require"ljsyscall"

local watchdog = function() end
if C.systemd then
  -- for now, this means we send watchdog pings
  local sd = require"systemd"
  watchdog = function()
    sd.notify(0, "WATCHDOG=1")
  end
end

-- wrapper for epoll()
local maxevents = 1024
local timeout = 60000 -- 1 minute
local function nilf() return nil end
local poll = {
  new = function(this)
    local epollsrv = {
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
      cb = callbacks
    }
		E.event.events = events or S.c.EPOLL.IN
		E.event.data.fd = s:getfd()
		U.assert(this.fd:epoll_ctl("add", s, E.event))
    U.DEBUG("srv", "added FD %d to epoll group", E.event.data.fd)
    this.fds[E.event.data.fd] = E
	end,
	del = function(this, s)
		local E = this.fds[s:getfd()]
    if E then
      U.assert(this.fd:epoll_ctl("del", s, E.event))
      this.fds[E.event.data.fd] = nil
      U.DEBUG("srv", "removed FD %d from epoll group", s:getfd())
    else
      U.ERR("srv", "cannot remove socket %d from epoll group, no entry", s:getfd())
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
  loop = function(this)
    while true do
      U.DEBUG("srv", "waiting for epoll events")
      for i, ev in this:get(timeout) do
        U.DEBUG("srv", "got event on fd %d", ev.fd)
        local E = this.fds[ev.fd]
        if E then
          if ev.HUP or ev.ERR or ev.RDHUP then
            U.DEBUG("srv", "FD %d has error/HUP condition, cleaning up", ev.fd)
            if E.cb.on_error then E.cb.on_error(E) end
            this.del(this, E.socket)
            E.socket:close()
          elseif ev.IN and E.cb.on_readable then E.cb.on_readable(E)
          elseif ev.OUT and E.cb.on_writable then E.cb.on_writable(E)
          end
        end
        watchdog()
      end
      watchdog()
    end
  end
}

assert(S.signal("pipe", "ign"))

local srv = poll:new()

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
      U.ERR("srv", "error on TCP server FD, shutting down socket\n")
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

function srv:timer(t, callback, ...)
  local sock = U.assert(S.timerfd_create("monotonic", "cloexec, nonblock"))
  local p = {...}
  U.assert(sock:timerfd_settime(nil, type(t)=="number" and {0, t} or t))
  self:add(sock, S.c.EPOLL.IN, {
    on_readable = function(this)
      --local o=ffi.new("uint64_t[1]")
      --this.socket:read(o, 8)
      self:timer_del(this.socket)
      callback(unpack(p))
    end
  })
  return sock
end

function srv:timer_del(sock)
  self:del(sock)
  sock:close()
end

local task = U.object:new()
function task:sleep(timeout)
  srv:timer(timeout, task.continue, self)
  coroutine.yield(true)
end
function task:run(...)
  self:continue(self, ...)
end
function task:continue(...)
  U.DEBUG("srv/task", "task %s wakeup", tostring(self))
  local cont = self.cr(...)
  if not cont then
    U.DEBUG("srv/task", "task %s finished", tostring(self))
  end
end
function task:create(func)
  return self:new({cr = coroutine.wrap(func)})
end

srv.task = task

return srv
