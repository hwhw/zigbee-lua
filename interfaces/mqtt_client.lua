local ctx = require"lib.ctx"
local U = require"lib.util"

local M = require"lib.ffi_libmosquitto.mosquitto"
local ffi = require"ffi"
local json = require"lib.json-lua.json"

local mqtt_client = U.object:new()

function mqtt_client:init()
  self.id = self.id or "zigbee-lua"
  if not self.running then
    U.DEBUG("mqtt_client", "using libmosquitto version %d.%d.%d", M.lib_version())
    -- the following will drop an error if it fails.
    -- TODO: better error handling
    self.client = M.new(self.id)
    if self.username and self.password then
      self.client:username_pw_set(self.username, self.password)
    end
    -- TODO: TLS setup
    self.client:connect(self.host, self.port, self.keepalive)
    self.socketfd = self.client:socket()
    ctx.srv:sock_server(self.socketfd, {
      on_readable = function() self.client:loop_read(1) end,
      on_error = function() --[[ TODO: error handling here? ]] end,
    })
    ctx.srv:register_before_wait(function()
      if self.client:want_write() then self.client:loop_write() end
    end)
    self.running = true
    U.INFO("mqtt_client", "MQTT client connection established to %s:%s, monitoring socket %s", self.host, self.port, self.socketfd)
  end
  return self
end

function mqtt_client:subscribe(sub, qos)
  U.INFO("mqtt_client", "subscribing to MQTT topic <%s>", sub)
  self.client:subscribe_message_callback(sub, qos or 0, function(message)
    local msg = {
      topic = ffi.string(message.topic),
      payload = ffi.string(message.payload, message.payloadlen)
    }
    U.DEBUG("mqtt_client", "got MQTT message: %s", U.dump(msg))
    ctx:fire({"mqtt_client", "message", self.id}, msg)
  end)
end

function mqtt_client:publish(topic, message, qos, retain)
  self.client:publish(topic, message, qos, retain)
end

return mqtt_client
