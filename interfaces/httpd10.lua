local ctx = require"lib.ctx"
local U = require"lib.util"

local ffi = require"ffi"
local S = require"lib.ljsyscall"

local httpd_connection = U.object:new()

local httpd = U.object:new()

local bufsize = 1024
local buf = S.t.buffer(bufsize)

function httpd:init()
  self.host = self.host or "127.0.0.1"
  self.port = self.port or 80
  self.handler = self.handler or {}

  local connection = httpd_connection:new{httpd=self}

  self.srv = ctx.srv:tcp_server(self.host, self.port, connection)
  return self
end

function httpd:add_handler(method_match, url_match, callback)
  local id = tostring(callback)
  table.insert(self.handler, {
    id = id,
    method_match = method_match,
    url_match = url_match,
    callback = callback
  })
  return id
end

function httpd:remove_handler(id)
  for k, v in ipairs(self.handler) do
    if v.id == id then
      table.remove(self.handler, k)
      return true
    end
  end
  return false
end

function httpd_connection:on_readable()
  print("XXX")
  local fd = self.socket:getfd()
  if fd < 0 then return end
  local n, err = self.socket:read(buf, bufsize)
  if n == 0 then
    U.INFO(self.id, "connection closed")
    ctx.srv:del(self.socket)
    self.socket:shutdown("rd")
    ctx:fire(self.id, nil)
  elseif n then
    U.DEBUG(self.id, "read data")
    ctx:fire(self.id, ffi.string(buf, n))
  end
end

function httpd_connection:write(data)
  local fd = self.socket:getfd()
  if fd < 0 then return end
  self.socket:write(data)
end

function httpd_connection:shutdown()
  self.socket:shutdown("rdwr")
  self.socket:close()
end

function httpd_connection:send_error(statuscode, message)
  U.ERR(self.id, "HTTP Error, status code %s: %s", statuscode, message)
  self:write(string.format("HTTP/1.0 %s %s\r\nContent-Type: text/plain\r\n\r\n%s %s\r\n", statuscode, message, statuscode, message))
  self:shutdown()
end

function httpd_connection:err_bad_request()
  return self:send_error(400, "Bad Request")
end

function httpd_connection:on_error()
  U.ERR(self.id, "error or EOF for connection")
  ctx.srv:del(this.socket)
  this.socket:close()
  ctx:fire(self.id, nil)
end

local http_methods = { GET = true, POST = true, HEAD = true }
local http_reason = {
  [200] = "OK",
  [201] = "Created",
  [202] = "Accepted",
  [204] = "No Content",
  [301] = "Moved Permanently",
  [302] = "Moved Temporarily",
  [304] = "Not Modified",
  [400] = "Bad Request",
  [401] = "Unauthorized",
  [403] = "Forbidden",
  [404] = "Not Found",
  [500] = "Internal Server Error",
  [501] = "Not Implemented",
  [502] = "Bad Gateway",
  [503] = "Service Unavailable"
}
local function decode_url_params(str)
  local p = {}
  for k, v in string.gmatch(str, "([^=]+)=([^&]*)[&]?") do
    p[k] = string.gsub(v, "%%([0-9a-fA-F]{2})", function(hex) return string.char(tonumber(hex, 16)) end)
  end
  return p
end
function httpd_connection:worker()
  self.id = {"httpd_connection", tostring(self)}
  U.INFO(self.id, "new connection")
  ctx.task{name="httpd_worker", function()
    local L = U.line_reader(function() local ok, data = ctx:wait(self.id); return data end)
    local request = L()
    if not request then self:shutdown() return end
    local uri09 = string.match(request, "^GET ([^ ]+)$")
    if uri09 then
      U.ERR(self.id, "got HTTP/0.9 request for URI %s, not yet implemented", uri)
      return self:shutdown()
    end
    local method, uri, http_version_major, http_version_minor = string.match(request, "^([^ ]+) ([^ ]+) HTTP/([0-9]+).([0-9]+)$")
    if not method or not http_methods[method] then
      U.ERR(self.id, "not a HTTP request, closing connection")
      return self:shutdown()
    else
      U.DEBUG(self.id, "HTTP request: %s | %s | %s.%s", method, uri, http_version_major, http_version_minor)
    end
    if http_version_major ~= "1" then
      return self:send_error(505, "HTTP Version not supported")
    end
    local http_headers = {}
    local request_complete = false
    for line in L do
      if line == "" then request_complete = true; break end
      local name, value = string.match(line, "^([^: ]+) *: *(.*)$")
      if name then
        U.DEBUG(self.id, "request header: %s = %s", name, value)
        http_headers[name] = value
      end
    end

    if not request_complete then return self:shutdown() end

    local get_arguments, post_arguments

    local short_uri, query = string.match(uri, "([^?]+)?(.*)")
    if(short_uri) then
      uri = short_uri
      get_arguments = decode_url_params(query)
    else
      get_arguments = {}
    end

    if method == "POST" then
      if not string.match(http_headers["Content-Length"] or "", "^[0-9]+$") then return self:bad_request() end
      local post_length = tonumber(http_headers["Content-Length"])
      local post_body = ""
      if post_length > 0 then
        while true do
          local chunk = L(true)
          if not chunk then self:bad_request() end
          post_body = post_body .. chunk
          if #post_body >= post_length then
            post_body = string.sub(post_body, 1, post_length)
            break
          end
        end
      end
      U.DEBUG(self.id, "read POST body of %d bytes", post_length)
      if http_headers["Content-Type"] == "application/x-www-form-urlencoded" then
        post_arguments = decode_url_params(post_body)
      else
        post_arguments = { __unparsed = post_body }
      end
    end

    for _, h in pairs(self.httpd.handler) do
      if method == h.method_match then
        local params = {string.match(uri, h.url_match)}
        if params[1] then
          local ok, msg = xpcall(h.callback, debug.traceback, params, get_arguments, post_arguments, http_headers, uri, method)
          if not ok then
            U.ERR(self.id, "error while handling request: %s", tostring(msg))
            self:send_error(500, "Internal Server Error")
          else
            if type(msg) == "string" then msg = {data = msg} end
            if type(msg) ~= "table" then return self:send_error(500, "Internal Server Error") end
            msg.code = msg.code or 200
            msg.reason = msg.reason or http_reason[msg.code] or "Unknown Reason"
            msg.headers = msg.headers or {}
            msg.headers["Content-Type"] = msg.headers["Content-Type"] or "text/html"

            self:write(string.format("HTTP/1.0 %s %s\r\n", msg.code, msg.reason))
            for k, v in pairs(msg.headers) do
              self:write(string.format("%s: %s\r\n", k, v))
            end
            self:write("\r\n")
            if(msg.data) then self:write(msg.data) end
            return self:shutdown()
          end
        end
      end
    end
    self:send_error(404, "Not Found")
  end}
end

return httpd
