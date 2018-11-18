local ffi=require"ffi"

ffi.cdef[[
int sd_notify(int unset_environment, const char *state);
]]

local libsystemd = ffi.load("libsystemd.so.0")
local SD = {
	notify = libsystemd.sd_notify,
}

return SD
