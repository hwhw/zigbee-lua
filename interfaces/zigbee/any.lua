local ctx = require"lib.ctx"
local U = require"lib.util"

local any = U.object:new{
  id = nil,
}

function any:send_af(cluster, data, global)
  local txseq = (self.txseq or 0) + 1
  self.txseq = txseq

  data.FrameControl = { global and "FrameTypeGlobal" or "FrameTypeLocal", "DirectionToServer", "DisableDefaultResponse" }
  data.TransactionSequenceNumber = txseq

  ctx:fire({"Zigbee", "ZCL", "to"}, {
    dst = self.id,
    cluster = cluster,
    data = data
  })

  return txseq
end

function any:identify(time)
  self:send_af(0x0003, {
    IdentifyClusterFrame = { CommandIdentifier = "Identify", Identify = { IdentifyTime = time or 4 } }
  })
end

function any:switch(cmd)
  self:send_af(0x0006, {
    OnOffClusterFrame = { CommandIdentifier = cmd }
  })
end

function any:hue_sat(hue, sat, transition_time)
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "EnhancedMoveToHueAndSaturation",
      EnhancedMoveToHueAndSaturation = {
        EnhancedHue = (hue or 0.0) * 0xFFFE,
        Saturation = (sat or 1.0) * 0xFE,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  })
end

function any:ctemp(mireds, transition_time)
  self:send_af(0x0300, {
    ColorControlClusterFrame = {
      CommandIdentifier = "MoveToColorTemperature",
      MoveToColorTemperature = {
        ColorTemperatureMireds = mireds or 3000,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  })
end

function any:level(level, transition_time)
  self:send_af(0x0008, {
    LevelControlClusterFrame = {
      CommandIdentifier = "MoveToLevelWithOnOff",
      MoveToLevelWithOnOff = {
        Level = (level or 1.0) * 0xFF,
        TransitionTime = (transition_time or 1) * 10
      }
    }
  })
end

return any
