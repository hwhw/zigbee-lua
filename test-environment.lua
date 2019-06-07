#!/usr/bin/env -S luajit
require"lib.ctx"(require"config", function(ctx)
local U = require"lib.util"
local Z = ctx.interfaces.zigbee[1]

U.DEBUG("env", "test environment running.")

end)
