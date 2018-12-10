local ctx = require"lib.ctx"
ctx.environment = require(arg[1])
ctx:run()
