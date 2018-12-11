local ctx = require"lib.ctx"
local U = require"lib.util"

local ffi = require"ffi"
local S = require"lib.ljsyscall"

local tcp_server = U.object:new()

function tcp_server:init()
  local bufsize = 1024
  local buf = S.t.buffer(bufsize)

  -- TODO: move specifics into srv-epoll.lua
  return ctx.srv:tcp_server(self.host, self.port, {
    on_readable = function(this)
      local fd = this.socket:getfd()
      if fd < 0 then
        -- FD already closed?
        return
      end
      local n, err = this.socket:read(buf, bufsize)
      if n == 0 then
        ctx.srv:del(this.socket)
        this.socket:shutdown("rd")
        ctx.task{name="tcp_client", function()
          if this.data then
            local n, v
            local f, err = load(function()
              n, v = next(this.data, n)
              return v
            end, "remote Lua code")
            if f then
              f, err = xpcall(f, debug.traceback, ctx, this.socket)
            end
            if not f then
              U.DEBUG(string.format("tcp_server/%d", fd), "ERROR: %s\n", err)
            end
          end
        end}:next(function()
          this.socket:shutdown("rdwr")
          this.socket:close()
        end)
      elseif n then
        if not this.data then this.data = {} end
        local data = ffi.string(buf, n)
        table.insert(this.data, data)
        U.DEBUG(string.format("tcp_server/%d", fd), "data on socket, got %d bytes:\n%s", n, data)
      end
    end,
    on_error = function(this)
      U.INFO(string.format("tcp_server/%d", fd), "error or EOF for connection")
      ctx.srv:del(this.socket)
      this.socket:close()
    end
  })
end

return tcp_server
