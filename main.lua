local ctx = require"lib.ctx"
local U = require"lib.util"

for class, instances in pairs(ctx.config.interfaces) do
  for n, config in ipairs(instances) do
    ctx.interfaces = ctx.interfaces or {}
    ctx.interfaces[class] = ctx.interfaces[class] or {}
    ctx.interfaces[class][n] = require("interfaces."..class):new(config):init()
  end
end
ctx:run()
