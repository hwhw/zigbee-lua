-- example environment that will forward any received zigbee packet
-- to an MQTT broker
--
-- you may want to adapt this to extract the information (and packets)
-- you are really interested in...

local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local M = ctx.interfaces.mqtt_client[1]
if not M then error("no mqtt_client interface found") end

ctx.task{name="mqtt_outgoing",function()
  for ok, msg in ctx:wait_all{"Zigbee", "ZCL", "from"} do
    M:publish(string.format("/zigbee-lua/%s/%d/%d", msg.from, msg.cluster, msg.srcep), json.encode(msg.data))
  end
end}

M:subscribe("/zigbee-lua/permit_join")
ctx.task{name="mqtt_permit_join",function()
  for ok, msg in ctx:wait_all({"mqtt_client", "message"}, function(msg) return msg.topic == "/zigbee-lua/permit_join" end) do
    U.DEBUG("mqtt_environment", "got permit_join message via MQTT, opening network for devices")
    -- TODO: timeout handling etc
    ctx:fire({"Zigbee","permit_join"},{include={0xfffc}})
  end
end}
