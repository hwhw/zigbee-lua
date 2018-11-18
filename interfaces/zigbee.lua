local ctx = require"lib.ctx"
local U = require"lib.util"
local json = require"lib.json-lua.json"

local z = "Zigbee"
local zigbee = {ev = {}}

-- declare events
local function ev(eventname) zigbee.ev[eventname] = {z, eventname} end
ev"coordinator_ready"
ev"device_announce"
ev"device_leave"
ev"af_message"

local devdb = U.object:new()
function devdb:open(filename)
  local file, err = io.open(filename, "r")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return self:new{devs={}, filename=filename}
  end
  local content = file:read("*a")
  file:close()
  local ok, t = pcall(json.decode, content)
  if not ok then
    U.ERR(z, "cannot decode database file %s", filename)
    return self:new{devs={}, filename=filename}
  end
  return self:new{devs=t, filename=filename}
end
function devdb:save()
  -- TODO: make this a write to a temp new file and an atomic move
  local file, err = io.open(self.filename, "w")
  if not file then
    U.ERR(z, "cannot open database file %s, error: %s", filename, err)
    return
  end
  file:write(json.encode(self.devs))
  file:close()
end
function devdb:ieee(ieeeaddr)
  return self.devs[ieeeaddr]
end
function devdb:nwk(nwkaddr)
  for ieeeaddr, v in pairs(self.devs) do
    if v.nwkaddr == nwkaddr then
      return self:ieee(ieeeaddr)
    end
  end
end
function devdb:set(ieeeaddr, data)
  self.devs[ieeeaddr] = data
end

zigbee.devices = devdb:open(ctx.config.device_database)

function zigbee:handle()
  ctx:task(function()
    local provisioning = {}
    while true do
      local ok, data = ctx:wait(self.ev.device_announce)
      if not ok then return U.ERR(z, "error waiting for device announcements") end
      local dev = self.devices:ieee(data.ieeeaddr)
      if not dev then
        if not provisioning[data.ieeeaddr] then
          U.INFO(z, "new device %s, starting provisioning", data.ieeeaddr)
          provisioning[data.ieeeaddr] = true
          ctx:task(function()
            local d, err = data.dongle:provision_device(data.nwkaddr)
            if d then
              self.devices:set(data.ieeeaddr, d)
              self.devices:save()
            end
            provisioning[data.ieeeaddr] = nil
          end)
        else
          U.INFO(z, "already provisioning device %s", data.ieeeaddr)
        end
      end
    end
  end)
  ctx:task(function()
    while true do
      local ok, msg = ctx:wait(self.ev.af_message)
      if not ok then return U.ERR(z, "error waiting for AF messages") end
      U.INFO(z, "got AF message: %s", U.dump(msg))
    end
  end)
end

return zigbee
