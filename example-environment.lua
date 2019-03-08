local ctx = require"lib.ctx"
local U = require"lib.util"
local D = require"interfaces.zigbee.any"
local json = require"lib.json-lua.json"
local M = ctx.interfaces.mqtt_client[1]

local E = U.object:new()

local devices = ctx.interfaces.zigbee[1].devices:names()
for _, d in ipairs(devices) do E[d] = D:new{id=d} end

local lastdev = nil
local cur_sets = {}
local function set_lastdev(dev)
  lastdev = dev
end
local function get_cube_handler(dev)
  return function(event, p1, p2)
    U.DEBUG("env", "cube action: %s %s %s", event, p1 or "", p2 or "")
    local ok, msg_json = pcall(json.encode, {type="cube", event=event, p1=p1, p2=p2})
    if ok then M:publish(string.format("/zigbee-lua/event/%s", dev.id), msg_json) end

    cur_sets[dev] = cur_sets[dev] or {}
    local sets = cur_sets[dev]
    if sets.valid and os.time() > sets.valid then
      sets.dev = nil
    end
    if event == "shake" then
      if not lastdev then return end
      local newdev = (type(lastdev) == "table") and lastdev[1] or lastdev
      sets.colors = newdev:check_colors()
      sets.level = newdev:check_level()
      if sets.colors and sets.level then
        sets.dev = newdev
      else
        sets.dev = nil
        return
      end
      sets.what = "level"
      sets.valid = os.time() + 60*2
      sets.dev:identify(2)
      U.DEBUG("env", "locked new dev, level: %s, colors: %s", sets.level or "falsy", U.dump(sets.colors))
    elseif type(lastdev) == "table" and event == "slide" then
      local new
      for i, d in ipairs(lastdev) do
        if d == sets.dev then new = lastdev[(i+1 > #lastdev) and 1 or (i+1)] end
      end
      if not new then return end
      sets.colors = new:check_colors()
      sets.level = new:check_level()
      if sets.colors and sets.level then
        sets.dev = new
      else
        sets.dev = nil
        return
      end
      sets.what = "level"
      sets.valid = os.time() + 60*2
      sets.dev:identify(2)
      U.DEBUG("env", "locked new dev, level: %s, colors: %s", sets.level or "falsy", U.dump(sets.colors))
    elseif sets.dev and event == "roll" then
      if sets.what == "level" then
        sets.what = sets.colors.capabilities[4] and "ctemp" or sets.colors.capabilities[1] and "eh" or sets.colors.capabilities[0] and "h" or "level"
      elseif sets.what == "ctemp" then
        sets.what = sets.colors.capabilities[1] and "eh" or sets.colors.capabilities[0] and "h" or "level"
      elseif sets.what == "eh" or sets.what == "h" then sets.what = "s"
      elseif sets.what == "s" then sets.what = "level"
      end
    elseif sets.dev and event == "turn" then
      if sets.what == "level" and sets.level then
        local level = sets.level + (p1/180)*50
        level = (level < 1) and 1 or (level > 0xFE) and 0xFE or level
        sets.dev:level(level, 0)
        sets.level = level
      elseif sets.what == "ctemp" then
        local ctemp = sets.colors.ctemp + (p1/180)*30
        ctemp = (ctemp < sets.colors.ctemp_min) and sets.colors.ctemp_min or (ctemp > sets.colors.ctemp_max) and sets.colors.ctemp_max or ctemp
        sets.dev:ctemp(ctemp, 0)
        sets.colors.ctemp = ctemp
      elseif sets.what == "eh" then
        local eh = (sets.colors.eh + (p1/180) * 12000) % 0x10000
        sets.dev:ehue_sat(eh, sets.colors.s, 0)
        sets.colors.eh = eh
      elseif sets.what == "h" then
        local h = (sets.colors.h + (p1/180) * 50) % 0x100
        sets.dev:hue_sat(h, sets.colors.s, 0)
        sets.colors.h = h
      elseif sets.what == "s" then
        local s = (sets.colors.s + (p1/180) * 50)
        s = (s < 0) and 0 or (s > 0xFE) and 0xFE or s
        if sets.colors.capabilities[1] then
          sets.dev:ehue_sat(sets.colors.eh, s, 0)
        else
          sets.dev:hue_sat(sets.colors.h, s, 0)
        end
        sets.colors.s = s
      end
    end
  end
end
E.cube_1:on_cube_action(get_cube_handler(E.cube_1))
E.cube_2:on_cube_action(get_cube_handler(E.cube_2))

E.b_kueche:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_kueche"), msg_json) end
  local this = E.b_kueche
  if not this.state then
    local so = E.l_kueche_so:check_on_off()
    local no = E.l_kueche_no:check_on_off()
    local sw = E.l_kueche_sw:check_on_off()
    local nw = E.l_kueche_nw:check_on_off()
    this.state = 0
    if so then
      if no then
        this.state = 1
      else
        this.state = 2
      end
    end
  end
  if presses == 1 then
    if this.state == 0 then
      E.l_kueche_so:switch"On"
      E.l_kueche_no:switch"On"
      E.l_kueche_sw:switch"On"
      E.l_kueche_nw:switch"On"
      set_lastdev({E.l_kueche_so,E.l_kueche_no,E.l_kueche_sw,E.l_kueche_nw})
    elseif this.state == 1 then
      E.l_kueche_so:switch"On"
      E.l_kueche_no:switch"Off"
      E.l_kueche_sw:switch"Off"
      E.l_kueche_nw:switch"Off"
      set_lastdev(E.l_kueche_so)
    elseif this.state == 2 then
      E.l_kueche_so:switch"Off"
      E.l_kueche_no:switch"Off"
      E.l_kueche_sw:switch"Off"
      E.l_kueche_nw:switch"Off"
      set_lastdev()
    end
    this.state = (this.state + 1) % 3
  end
end)

E.s_kueche:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "s_kueche"), msg_json) end
  if btn == 1 then
    E.l_kueche_wand:switch"Toggle"
    set_lastdev(E.l_kueche_wand)
  else
    E.l_kueche_eingang:switch"Toggle"
    set_lastdev(E.l_kueche_eingang)
  end
end)

E.s_og:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "s_og"), msg_json) end
  if btn == 1 then
    E.l_gaeste:switch"Toggle"
    set_lastdev(E.l_gaeste)
  else
    E.l_treppe:switch"Toggle"
    set_lastdev(E.l_treppe)
  end
end)

E.b_gaeste:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_gaeste"), msg_json) end
  E.l_gaeste:switch"Toggle"
  set_lastdev(E.l_gaeste)
end)

E.b_bad:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_bad"), msg_json) end
  E.l_bad:switch"Toggle"
  set_lastdev(E.l_bad)
end)

E.p_bad:on_occupancy(function()
  local ok, msg_json = pcall(json.encode, {type="occupancy", event="trigger"})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "p_bad"), msg_json) end
  ctx.task(function()
    ctx:fire{"Env", E.p_bad}
    E.l_bad:switch"On"
    local ok = ctx:wait({"Env", E.p_bad}, nil, 300)
    if not ok then
      E.l_bad:switch"Off"
    end
  end)
end)

E.s_schlaf:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "s_schlaf"), msg_json) end
  if btn == 1 then
    E.l_schlaf_fluter:switch"Toggle"
    set_lastdev(E.l_schlaf_fluter)
  else
    E.l_schlaf_decke:switch"Toggle"
    set_lastdev(E.l_schlaf_decke)
  end
end)

E.b_schlaf:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_schlaf"), msg_json) end
  if presses == 1 then
    E.l_schlaf_lesen:switch"Toggle"
    set_lastdev(E.l_schlaf_lesen)
  elseif presses == 2 then
    E.l_schlaf_decke:switch"Toggle"
    set_lastdev(E.l_schlaf_decke)
  elseif presses == 3 then
    E.l_schlaf_fluter:switch"Toggle"
    set_lastdev(E.l_schlaf_fluter)
  end
end)

E.b_couch:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_couch"), msg_json) end
  if presses == 1 then
    E.l_couch_fluter:switch"Toggle"
    set_lastdev(E.l_couch_fluter)
  elseif presses == 2 then
    E.l_couch_lesen:switch"Toggle"
    set_lastdev(E.l_couch_lesen)
  elseif presses == 3 then
    E.l_couch_steh:switch"Toggle"
    set_lastdev(E.l_couch_steh)
  end
end)

E.s_eingang:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "s_eingang"), msg_json) end
  local this = E.s_eingang
  if not this.state then
    local n = E.l_eingang_n:check_on_off()
    local m = E.l_eingang_m:check_on_off()
    local s = E.l_eingang_s:check_on_off()
    this.state = 0
    if n then
      if s then
        this.state = 1
      else
        this.state = 2
      end
    end
  end
  if btn == 1 then
    E.l_treppe:switch"Toggle"
    set_lastdev(E.l_treppe)
  else
    if this.state == 0 then
      E.l_eingang_s:switch"On"
      E.l_eingang_m:switch"On"
      E.l_eingang_n:switch"On"
      set_lastdev({E.l_eingang_s,E.l_eingang_m,E.l_eingang_n})
    elseif this.state == 1 then
      E.l_eingang_s:switch"Off"
      E.l_eingang_m:switch"On"
      E.l_eingang_n:switch"On"
      set_lastdev({E.l_eingang_m,E.l_eingang_n})
    elseif this.state == 2 then
      E.l_eingang_s:switch"Off"
      E.l_eingang_m:switch"Off"
      E.l_eingang_n:switch"Off"
      set_lastdev()
    end
    this.state = (this.state + 1) % 3
  end
end)

local function color_rnd()
  local hue = math.random(0,0xFE)
  local sat = math.random(0xD0,0xFE)
  return "hue_sat", hue, sat
end
local scenes={
  {
    l_eingang_s={{"switch","Off"}},
    l_eingang_m={{"switch","Off"}},
    l_eingang_n={{"switch","Off"}},
    l_treppe={{"switch","Off"}},
    l_gaeste={{"switch","Off"}},
    l_bad={{"switch","Off"}},
    l_schlaf_decke={{"switch","Off"}},
    l_schlaf_fluter={{"switch","Off"}},
    l_schlaf_lesen={{"switch","Off"}},
    l_couch_fluter={{"switch","Off"}},
    l_couch_lesen={{"switch","Off"}},
    l_couch_steh={{"switch","Off"}},
    l_kueche_eingang={{"switch","Off"}},
    l_kueche_wand={{"switch","Off"}},
    l_kueche_so={{"switch","Off"}},
    l_kueche_sw={{"switch","Off"}},
    l_kueche_no={{"switch","Off"}},
    l_kueche_nw={{"switch","Off"}}
  },
  {
    l_eingang_s={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_eingang_m={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_eingang_n={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_treppe={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_gaeste={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","Off"}},
    l_schlaf_decke={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","Off"}},
    l_schlaf_fluter={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","Off"}},
    l_schlaf_lesen={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","Off"}},
    l_couch_fluter={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","Off"}},
    l_couch_lesen={{"switch","On"},{"level", 40},{"ctemp", 400},{"switch","On"}},
    l_couch_steh={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","On"}},
    l_kueche_eingang={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_kueche_wand={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_kueche_so={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_kueche_sw={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}},
    l_kueche_no={{"switch","On"},{"level", 1},{"ctemp", 400},{"switch","On"}},
    l_kueche_nw={{"switch","On"},{"level", 0.2},{"ctemp", 400},{"switch","Off"}}
  },
  {
    l_eingang_s={{"switch","Off"}},
    l_eingang_m={{"switch","On"},{"level",1},color_rnd},
    l_eingang_n={{"switch","On"},{"level",1},color_rnd},
    l_treppe={{"switch","Off"}},
    l_gaeste={{"switch","Off"}},
    l_couch_fluter={{"switch","On"},{"level",5},color_rnd},
    l_couch_steh={{"switch","On"},{"level",5},color_rnd},
    l_couch_lesen={{"switch","Off"}},
    l_kueche_so={{"switch","On"},{"level",1},color_rnd},
    l_kueche_sw={{"switch","Off"}},
    l_kueche_no={{"switch","Off"}},
    l_kueche_nw={{"switch","Off"}},
    l_treppe={{"switch","On"},{"level",1},color_rnd},
  },
  {
    l_eingang_s={{"switch","Off"}},
    l_eingang_m={{"switch","On"},{"level",1},{"hue_sat",0x0a,0xF0}},
    l_eingang_n={{"switch","On"},{"level",1},{"hue_sat",0x0a,0xF0}},
    l_treppe={{"switch","Off"}},
    l_gaeste={{"switch","Off"}},
    l_couch_fluter={{"switch","On"},{"level",5},{"hue_sat",0xb0,0xFE}},
    l_couch_steh={{"switch","On"},{"level",5},{"hue_sat",0xfe,0xFE}},
    l_couch_lesen={{"switch","Off"}},
    l_kueche_so={{"switch","On"},{"level",1},{"hue_sat",0x30,0xFE}},
    l_kueche_sw={{"switch","Off"}},
    l_kueche_no={{"switch","Off"}},
    l_kueche_nw={{"switch","Off"}},
    l_treppe={{"switch","On"},{"level",1},{"hue_sat",0x30,0xFE}},
  }
}
E.b_switcher:on_button_press(function(btn, presses)
  local ok, msg_json = pcall(json.encode, {type="button", event="press", btn=btn, presses=presses})
  if ok then M:publish(string.format("/zigbee-lua/event/%s", "b_switcher"), msg_json) end
  if scenes[presses] then
    for id, scene in pairs(scenes[presses]) do
      for _, action in ipairs(scene) do
        local d = E[id]
        if type(action)=='function' then
          action = {action()}
        end
        if action[1] then
          d[action[1]](d, select(2,unpack(action)))
        end
      end
    end
  end
end)

for _,v in ipairs{"cube_1","cube_2", "b_gaeste","s_og","b_couch","t_eg","b_bad","b_schlaf","s_kueche","p_bad","t_various","s_schlaf","b_kueche","t_schlaf","p_schlaf","s_eingang","b_switcher"} do
  E[v]:on_aqara_report(function (d)
    if d.ReportAttributes then
      for _, r in ipairs(d.ReportAttributes) do
        if r.AttributeIdentifier == 1 then
          -- battery voltage in mV
          U.DEBUG("env", "battery voltage of <%s>: %d mV", v, r.Attribute.Value)
          local ok, msg_json = pcall(json.encode, {type="battery", event="report", value=r.Attribute.Value})
          if ok then M:publish(string.format("/zigbee-lua/event/%s", v), msg_json) end
        end
      end
    end
  end)
end

for _,v in ipairs{"t_eg", "t_schlaf", "t_various"} do
  E[v]:on_measurement(0x402, 0, function(d)
    U.DEBUG("env", "temperature at sensor <%s>: %f degrees celsius", v, d/100)
    local ok, msg_json = pcall(json.encode, {type="temperature", event="report", value=d/100})
    if ok then M:publish(string.format("/zigbee-lua/event/%s", v), msg_json) end
  end)
  E[v]:on_measurement(0x403, 16, function(d)
    U.DEBUG("env", "pressure at sensor <%s>: %f kPa", v, d/10)
    local ok, msg_json = pcall(json.encode, {type="pressure", event="report", value=d/10})
    if ok then M:publish(string.format("/zigbee-lua/event/%s", v), msg_json) end
  end)
  E[v]:on_measurement(0x405, 0, function(d)
    U.DEBUG("env", "relative humidity at sensor <%s>: %f %%rel", v, d/100)
    local ok, msg_json = pcall(json.encode, {type="relhumidity", event="report", value=d/100})
    if ok then M:publish(string.format("/zigbee-lua/event/%s", v), msg_json) end
  end)
end

-- MQTT subscribing: We use this to open the network for joining
M:subscribe("/zigbee-lua/permit_join")
ctx.task{name="mqtt_permit_join",function()
  for ok, msg in ctx:wait_all({"mqtt_client", "message"}, function(msg) return msg.topic == "/zigbee-lua/permit_join" end) do
    U.DEBUG("mqtt_environment", "got permit_join message via MQTT, opening network for devices")
    -- TODO: timeout handling etc
    ctx:fire({"Zigbee","permit_join"},{include={0xfffc}})
  end
end}

return E
