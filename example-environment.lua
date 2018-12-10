local ctx = require"lib.ctx"
local U = require"lib.util"
local D = require"interfaces.zigbee.any"

local E = U.object:new{
  lamp1 = D:new{id="Gaestebett"},
  sw1 = D:new{id="1SW_Gaeste"}
}

E.sw1:on_button_press(function(btn, presses)
  E.lamp1:switch"Toggle"
end)

return E
