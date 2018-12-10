local ctx = require"lib.ctx"
local U = require"lib.util"

ctx.zoo = require"interfaces.zoo"
ctx.zoo:handle()
ctx.tcp_server = require"interfaces.tcp-server":new(ctx.config.tcp_server_host or '127.0.0.1', arg[1] or ctx.config.tcp_server_port)
ctx.dongle = require"interfaces.zigbee.devices.dongle-cc253x":new(arg[2] or ctx.config.port, ctx.config.baud)
ctx.zigbee = require"interfaces.zigbee"
ctx.zigbee:handle()
ctx.task{name="initialize", function()
  if not ctx.dongle:initialize_coordinator(true) then
    U.ERR("main", "could not start coordinator")
    os.exit(1)
  end
end}
ctx:run()
