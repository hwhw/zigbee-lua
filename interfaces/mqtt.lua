local ctx = require"lib.ctx"
local U = require"lib.util"

local M = require"lib.ffi_libmosquitto.mosquitto"
local ffi = require"ffi"
local bit = require"bit"
local S = require"lib.ljsyscall"

local mqtt = U.object:new()

function mqtt:init()
end

return mqtt
