local ctx = require"lib.ctx":init()
ctx.environment = require(arg[1])
ctx:run()
