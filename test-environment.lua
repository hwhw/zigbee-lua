local ctx = require"lib.ctx"
local U = require"lib.util"
local D = require"interfaces.zigbee.any"

local E = U.object:new()

local devices = ctx.interfaces.zigbee[1].devices:names()
for _, d in ipairs(devices) do E[d] = D:new{id=d} end

local lastdev = nil
local cur_sets = {}
local function set_lastdev(dev)
  lastdev = dev
end

return E
