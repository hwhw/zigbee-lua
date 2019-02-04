-- example environment that will forward any received zigbee packet
-- to an MQTT broker
--
-- you may want to adapt this to extract the information (and packets)
-- you are really interested in...

local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"
local aqaracodec=require"interfaces.zigbee.xiaomi-aqara""AqaraReport"

local M = ctx.interfaces.mqtt_client[1]
if not M then error("no mqtt_client interface found") end

-- MQTT publishing: Just pass on any ZCL data we receive
ctx.task{name="mqtt_outgoing",function()
  for ok, msg in ctx:wait_all{"Zigbee", "ZCL", "from"} do
    -- TODO: you will probably want to process the data before converting the whole
    -- ZCL data structure into JSON. Well, maybe you don't. But if you do and implement
    -- it, I will be happily accept a pull request!
    if msg.cluster == 0
      and msg.data
      and msg.data.ManufacturerCode==4447
      and msg.data.GeneralCommandFrame
      and msg.data.GeneralCommandFrame.ReportAttributes
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1]
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].AttributeIdentifier==65281
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Type=="string"
      and msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Value
    then
      -- e.g. this is a special handling for Aqara proprietary data
      local data = aqaracodec:decode({string.byte(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports[1].Attribute.Value,1,-1)})
      if data then
        local ok, msg_json = pcall(json.encode, data)
        if ok then
          M:publish(string.format("/zigbee-lua/%s/aqarareport", msg.from), msg_json)
        else
          U.ERR("mqtt_environment", "error converting message to JSON, skipping.")
        end
      end
    else
      local ok, msg_json = pcall(json.encode, msg.data)
      if ok then
        M:publish(string.format("/zigbee-lua/%s/%d/%d", msg.from, msg.cluster, msg.srcep), msg_json)
      else
        U.ERR("mqtt_environment", "error converting message to JSON, skipping.")
      end
    end
  end
end}

-- MQTT subscribing: We use this to open the network for joining
M:subscribe("/zigbee-lua/permit_join")
ctx.task{name="mqtt_permit_join",function()
  for ok, msg in ctx:wait_all({"mqtt_client", "message"}, function(msg) return msg.topic == "/zigbee-lua/permit_join" end) do
    U.DEBUG("mqtt_environment", "got permit_join message via MQTT, opening network for devices")
    -- TODO: timeout handling etc
    ctx:fire({"Zigbee","permit_join"},{include={0xfffc}})
  end
end}
