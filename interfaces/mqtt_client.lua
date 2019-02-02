local ctx = require"lib.ctx"
local U = require"lib.util"

local M = require"lib.ffi_libmosquitto.mosquitto"
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
    self.client:loop_start()
    self.running = true
    U.INFO("mqtt_client", "MQTT client connection established to %s:%s", self.host, self.port)
  end
  return self
end

function mqtt_client:subscribe(sub, qos)
  U.INFO("mqtt_client", "subscribing to MQTT topic <%s>", sub)
  self.client:subscribe_message_callback(sub, qos or 0, function(message)
    U.DEBUG("mqtt_client", "got MQTT message: %s", U.dump(message))
    ctx:fire({"mqtt_client", "message", self.id}, message)
  end)
end

function mqtt_client:publish(topic, message)
  self.client:publish(topic, message)
end

return mqtt_client
