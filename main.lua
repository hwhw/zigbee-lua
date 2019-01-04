local ctx = require"lib.ctx":init()
if arg[1] then ctx.environment = require(arg[1]) end
ctx:run()
