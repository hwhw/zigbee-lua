local ctx = require"lib.ctx"
local U = require"lib.util"

local M = require"lib.ffi_libmicrohttpd.libmicrohttpd"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"

local httpd = U.object:new()

local function testclient(cls, connection, url, method, version, upload_data, upload_data_size, ptr)
  U.INFO({"httpd","request"}, "%s %s %s", ffi.string(method), ffi.string(url), ffi.string(version))

  local resp = "<html>Hello World</html>"
  local r = M.MHD_create_response_from_buffer(#resp, ffi.cast("uint8_t*", resp), M.MHD_RESPMEM_MUST_COPY);
  return M.MHD_queue_response(connection, 200, r)
end

local fd_mask_size = ffi.sizeof("fd_mask")*8
local function get_fds(fd_set, max_fd)
  local w = 0
  local b = 0
  local fds = {}
  for i=0,max_fd do
    local bmask = bit.lshift(1, b)
    if bit.band(fd_set.fds_bits[w], bmask) ~= 0 then
      fds[i] = true
    end
    b = b + 1
    if b == fd_mask_size then
      b = 0
      w = w + 1
    end
  end
  return fds
end

function httpd:sync_fdsets()
  local read_fds = ffi.new("fd_set[1]")
  local write_fds = ffi.new("fd_set[1]")
  local except_fds = ffi.new("fd_set[1]")
  local max_fd = ffi.new("int[1]")

  if M.MHD_get_fdset(self.mhd, read_fds, write_fds, except_fds, max_fd) ~= 0 then
    local read = get_fds(read_fds[0], max_fd[0])
    local write = get_fds(read_fds[0], max_fd[0])
    local except = get_fds(read_fds[0], max_fd[0])
    self.fds = self.fds or {}
    local newfds = {}
    for fd=0,max_fd[0] do
      local new_events = bit.bor(
        read[fd] and S.c.EPOLL.IN or 0,
        write[fd] and S.c.EPOLL.OUT or 0,
        except[fd] and S.c.EPOLL.PRI or 0)
      if new_events ~= 0 then newfds[fd] = new_events end
      local old_events = self.fds[fd] or 0
      if old_events ~= new_events then
        U.DEBUG("httpd", "change for FD %d: %x -> %x", fd, old_events, new_events)
        ctx.srv:del(fd)
        ctx.srv:add(fd, new_events, self)
      end
    end
    for fd, events in pairs(self.fds) do
      if not newfds[fd] then
        ctx.srv:del(fd)
      end
    end
    self.fds = newfds
  end
end

function httpd:init()
  self.on_readable = function()
    if self.mhd then M.MHD_run(self.mhd) end
    self:sync_fdsets()
  end
  self.on_writable = self.on_readable
  self.on_error = self.on_error
  self.mhd = M.MHD_start_daemon(
    bit.bor(M.MHD_USE_EPOLL, M.MHD_USE_DEBUG),
    --bit.bor(M.MHD_USE_INTERNAL_POLLING_THREAD, M.MHD_USE_EPOLL, M.MHD_USE_DEBUG),
    self.port,
    nil, nil,
    testclient, nil,
    ffi.new("int", M.MHD_OPTION_CONNECTION_TIMEOUT), ffi.new("int", 120),
    ffi.new("int", M.MHD_OPTION_END))

  if self.mhd==nil then
    return U.ERR("httpd", "cannot start httpd daemon")
  end

  self:sync_fdsets()
  return self
end

return httpd
