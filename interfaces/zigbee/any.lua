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

function any:on_button_press(cb)
  ctx.task{name=string.format("%s/on_button_press", self.id),function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", "ZCL", "from", self.id}
      if not ok then
        U.ERR("Zigbee_any/on_button_press", "error while waiting for event")
      else
        U.DEBUG("Zigbee_any", "got event: %s", U.dump(msg))
        if msg.cluster == 6 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes then
          local btn = msg.srcep
          for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
            if r.AttributeIdentifier == 0x8000 then
              --TODO: add more checks for device?
              -- assuming Aqara touch button
              cb(btn, r.Attribute.Value)
              break
            elseif r.AttributeIdentifier == 0 and r.Attribute.Value then
              cb(btn, 1)
              break
            end
          end
        end
      end
    end
  end}
end

function any:on_occupancy(cb)
  ctx.task{name=string.format("%s/on_occupancy", self.id),function()
    while true do
      local ok, msg = ctx:wait{"Zigbee", "ZCL", "from", self.id}
      if not ok then
        U.ERR("Zigbee_any/on_occupancy", "error while waiting for event")
      else
        U.DEBUG("Zigbee_any", "got event: %s", U.dump(msg))
        if msg.cluster == 0x406 and msg.data.GeneralCommandFrame and msg.data.GeneralCommandFrame.ReportAttributes then
          local btn = msg.ep
          for _, r in ipairs(msg.data.GeneralCommandFrame.ReportAttributes.AttributeReports) do
            if r.AttributeIdentifier == 0 and r.Attribute.Value[0] then
              cb()
              break
            end
          end
        end
      end
    end
  end}
end

return any
