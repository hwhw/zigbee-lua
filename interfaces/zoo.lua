local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zoo"
local zoo = {ev={}}

-- declare events
local function ev(eventname) zoo.ev[eventname] = {z, eventname} end
ev"value_report"

function zoo:handle()
  ctx.task(function()
    while true do
      local ok, data = ctx:wait(self.ev.value_report)
      if not ok then return U.ERR(z, "error waiting for value reports") end
      U.INFO(z, "value report: %s", U.dump(data))
    end
  end)
end

return zoo
