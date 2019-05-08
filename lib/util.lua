local util = {}
local config = require"config"
local bit = require"bit"

-- assert wrapper for proper error messages - about the same as
-- the normal Lua assert, except that the normal one does not do
-- the tostring() step
function util.assert(cond, s, ...)
	if not cond then error(tostring(s)) end
	return cond, s, ...
end

-- logging:
util.logoutput = io.stderr
function util.log(level, subsys, ...)
  subsys = (type(subsys)=="table") and subsys or {subsys}
  config.log = config.log or {DBG={false}}
  local do_log = true
  local domain = config.log[level]
  local n = 1
  while domain ~= nil do
    if type(domain)=="table" then
      if domain[1]~=nil then do_log = domain[1] end
      domain = domain[subsys[n]]
      n = n+1
    else
      do_log = domain
      domain = nil
    end
  end
  if not do_log then return nil end

  local msg =
    os.date("[%Y-%m-%d %H:%M:%S] <") .. level .. "> " ..
    table.concat(subsys,"|") .. ": " .. string.format(...) .. "\n"

  util.logoutput:write(msg)
  return msg
end
function util.ERR(subsys, ...) return false, util.log("ERR", subsys, ...) end
function util.INFO(subsys, ...) return true, util.log("INF", subsys, ...) end
function util.DEBUG(subsys, ...) return true, util.log("DBG", subsys, ...) end

-- tools for tables:
function util.contains(search_in, search_for)
  local c=0
  for _, h in pairs(search_in) do
    for _, n in pairs(search_for) do
      if h==n then
        c = c+1
        break
      end
    end
  end
  return c>0 and c
end
function util.contains_all(search_in, search_for)
  local n = util.contains(search_in, search_for)
  return n and n == #search_for
end
function util.list_compare(search_in, search_for)
  local n = util.contains(search_in, search_for)
  return n and n == #search_for and n == #search_in
end
function util.reverse(t)
  local n={}
  for i=#t, 1, -1 do table.insert(n, t[i]) end
  return n
end
function util.hashify(t)
  local n={}
  for _, v in ipairs(t) do n[v] = true end
  return n
end
function util.filter(f)
  return function(t)
    for k, v in pairs(f) do
      if t[k] ~= v then return false end
    end
    return true
  end
end
function util.fromhex(v)
  local d={}
  for s in string.gmatch(v, "(%x%x)") do table.insert(d, tonumber(s,16)) end
  return d
end
function util.tohex(t)
  local hex={}
  for _, c in ipairs(t) do table.insert(hex, string.format("%02x", c)) end
  return table.concat(hex)
end

local inspect=require"lib.inspect-lua.inspect"
function util.dump(x)
  return inspect(x, {process=function(item, path) if path[#path]~=inspect.METATABLE then return item end end})
end

-- helper function to parse binary numbers
function util.B(bstr, pos, acc)
  pos=pos or 1
  acc=acc or 0
  if pos > #bstr then
    return acc
  end
  return util.B(bstr, pos+1, bit.bor(bit.lshift(acc, 1), string.byte(bstr, pos) == 0x31 and 1 or 0))
end

function util.copy(t)
  if type(t) ~= "table" then return t end
  local n = {}
  for k, v in pairs(t) do n[k] = util.copy(v) end
  return n
end

function util.hexdump(buffer)
  if not (type(buffer)=="string" or type(buffer)=="table") then return tostring(buffer) end
  local p = 1
  local acc = {}
  local clear = ""
  while p <= #buffer do
    local b = type(buffer)=="string" and string.byte(buffer, p) or buffer[p]
    table.insert(acc, string.format("%02X ", b))
    if b >= 0x20 and b < 0x7E then
      clear = clear .. string.char(b)
    else
      clear = clear .. "."
    end
    if p == #buffer then
      local mod = p % 16
      if mod > 0 then
        for _ = mod, 15 do table.insert(acc, "   ") end
      end
    end
    if p % 16 == 0 or p == #buffer then
      table.insert(acc, "  ")
      table.insert(acc, clear)
      table.insert(acc, "\n")
      clear = ""
    end
    p = p + 1
  end
  return table.concat(acc)
end

util.object = {}
function util.object:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return util
