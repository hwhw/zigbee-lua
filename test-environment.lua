#!/usr/bin/env -S luajit
require"lib.ctx"(require"config", function(ctx)
local U = require"lib.util"

local E = U.object:new()

local Z = ctx.interfaces.zigbee[1]
local devices = Z.devices:names()
for ieeeaddr, d in pairs(devices) do
  local dev = Z.devices:ieee(ieeeaddr)
  E[d] = dev.zcl
end

local lastdev = nil
local cur_sets = {}
local function set_lastdev(dev)
  lastdev = dev
end

return E
end)
