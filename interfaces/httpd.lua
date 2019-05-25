local ctx = require"lib.ctx"
local U = require"lib.util"

local M = require"lib.ffi_libmicrohttpd.libmicrohttpd"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"

local httpd = U.object:new{
  M = M
}

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

local value_kinds = bit.bor(M.MHD_HEADER_KIND, M.MHD_COOKIE_KIND, M.MHD_GET_ARGUMENT_KIND)
local post_data = {}
local unparsed_marker = ffi.cast("void*", 1)
local response = {}
local function send_response(connection, msg)
  if type(msg) == "string" then msg = {data = msg} end
  if type(msg) ~= "table" then
    msg = { code = 500, data = "Internal Server Error" }
  end
  msg.code = msg.code or 200
  msg.headers = msg.headers or {}
  msg.headers["Content-Type"] = msg.headers["Content-Type"] or "text/html"
  local r = M.MHD_create_response_from_buffer(#msg.data, ffi.cast("uint8_t*", msg.data), M.MHD_RESPMEM_MUST_COPY);
  for key, value in pairs(msg.headers) do
    M.MHD_add_response_header(r, tostring(key), tostring(value))
  end
  M.MHD_queue_response(connection, msg.code, r)
  M.MHD_queue_response(connection, msg.code, r)
  M.MHD_destroy_response(r)
end
function httpd:add_handler(method_match, url_match, callback)
  self.handler[callback] = {
    match = function(method, url)
      return (method==method_match or nil) and string.match(url, url_match)
    end,
    callback = function(connection, params, url, method, version, upload_data, upload_data_size, ptr)
      local conn_id = tostring(connection)
      -- check for asynchronously created response and send if it exists
      if response[conn_id] then
        send_response(connection, response[conn_id])
        response[conn_id] = nil
        return 1
      end
      -- POST handling
      local post_arguments = nil
      if method == "POST" then
        U.DEBUG("httpd", "POST: C:%s, P:%s, S:%s, D:%s", connection, ptr[0], upload_data_size[0], post_data[conn_id])
        if ptr[0] == nil then
          local pp = M.MHD_create_post_processor(connection, 4096,
            function(coninfo_cls, kind, key, filename, content_type, transfer_encoding, data, off, size)
              if size > 0 then
                key = key and ffi.string(key)
                data = data and ffi.string(data)
                post_data[conn_id][key] = data
                return 1
              else
                return 0
              end
            end, nil)
          if pp ~= nil then
            ptr[0] = pp
          else
            ptr[0] = unparsed_marker
          end
          post_data[conn_id] = {}
          return 1
        elseif upload_data_size[0] > 0 then
          if ptr[0] == unparsed_marker then
            table.insert(post_data[conn_id], ffi.string(upload_data, upload_data_size[0]))
          else
            M.MHD_post_process(ptr[0], upload_data, upload_data_size[0])
          end
          upload_data_size[0] = 0
          return 1
        else
          if not post_data[conn_id] then
            return 1
          end
          if ptr[0] == unparsed_marker then
            post_arguments = { _unparsed = table.concat(post_data[conn_id]) }
          else
            M.MHD_destroy_post_processor(ptr[0])
            post_arguments = post_data[conn_id]
          end
          post_data[conn_id] = nil
        end
      end
      -- handling of HTTP client headers, GET parameters:
      local headers = {}
      local get_arguments = {}
      local function fetchheaders(cls, kind, key, value)
        key = key and ffi.string(key)
        value = value and ffi.string(value)
        if key then
          --U.DEBUG("httpd", "Headers: %s: %s=%s", kind, key, value)
          if kind == M.MHD_HEADER_KIND then
            headers[key] = value
          elseif kind == M.MHD_GET_ARGUMENT_KIND then
            get_arguments[key] = value
          end -- TODO: other kinds?
        end
        return 1
      end
      M.MHD_get_connection_values(connection, value_kinds, fetchheaders, nil)
      -- handling of new requests
      local has_completed = false
      local is_suspended = false
      ctx.task{function()
        local ok, msg = xpcall(callback, debug.traceback, params, get_arguments, post_arguments, headers, url, method)
        has_completed = true
        if not ok then
          U.ERR({"httpd","requesthandler"}, "error while handling request: %s", tostring(msg))
          msg = 0
        end
        if is_suspended then
          response[conn_id] = msg
          U.DEBUG("httpd", "resume %s", connection)
          M.MHD_resume_connection(connection)
        else
          send_response(connection, msg)
        end
      end}
      if not has_completed then
        U.DEBUG("httpd", "suspend %s", connection)
        M.MHD_suspend_connection(connection)
        is_suspended = true
      end
      return 1
    end
  }
  return callback
end

function httpd:init()
  self.handler = {}

  self.client = function(cls, connection, url, method, version, upload_data, upload_data_size, ptr)
    local method = ffi.string(method)
    local url = ffi.string(url)
    U.INFO({"httpd","request"}, "%s %s %s %s %s %s", method, url, ffi.string(version), upload_data, upload_data_size and tonumber(upload_data_size[0]), ptr)
    for _, handler in pairs(self.handler) do
      local params = {handler.match(method, url)}
      if #params > 0 then return handler.callback(connection, params, url, method, version, upload_data, upload_data_size, ptr) end
    end
    local msg = "<html>NOT FOUND</html>"
    local r = M.MHD_create_response_from_buffer(#msg, ffi.cast("uint8_t*", msg), M.MHD_RESPMEM_MUST_COPY);
    local ret = M.MHD_queue_response(connection, 404, r)
    M.MHD_destroy_response(r)
    return ret
  end

  local timeout = ffi.new("MHD_UNSIGNED_LONG_LONG[1]")
  ctx.srv:register_before_wait(function()
    if self.mhd then
      -- we seem to need to do this every time (for now):
      M.MHD_run(self.mhd)
      if M.MHD_get_timeout(self.mhd, timeout) == 1 then
        ctx.srv:set_max_timeout(tonumber(timeout[0]))
      end
    end
  end)
  self.on_readable = function()
    -- not needed, we call MHD_run() indiscriminately (see above)
    --if self.mhd then M.MHD_run(self.mhd) end
  end
  self.on_writable = self.on_readable
  self.on_error = self.on_error
  self.mhd = M.MHD_start_daemon(
    bit.bor(M.MHD_USE_EPOLL, M.MHD_USE_DEBUG, M.MHD_ALLOW_SUSPEND_RESUME),
    self.port,
    nil, nil,
    self.client, nil,
    ffi.new("int", M.MHD_OPTION_CONNECTION_TIMEOUT), ffi.new("int", 120),
    ffi.new("int", M.MHD_OPTION_END))

  if self.mhd==nil then
    return U.ERR("httpd", "cannot start httpd daemon")
  end

  self:sync_fdsets()
  return self
end

return httpd
