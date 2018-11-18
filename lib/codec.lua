local ffi = require"ffi"
local bit = require"bit"
local U = require"lib.util"
local object = U.object

local def = object:new()
function def:create(childs, newname)
  childs = childs or {}
  if type(childs) == "table" then
    childs._name = table.remove(childs, 1)
    local i = self:new(childs)
    if self._registry and childs._name then self._registry[childs._name] = i end
    return i
  else
    --return self._registry and self._registry[childs]:new{_name=newname or childs._name}
    return self._registry and self._registry[childs]
  end
end
function def:match(data)
  for n, d in pairs(self._registry) do
    local ok, ret, remain = pcall(d.decode, d, data)
    if ok then return ret, n, remain end
  end
  return false
end
function def:encode(o, putc)
  local ret
  o = o or {}
  if not putc then
    ret = {}
    putc = function(byte) table.insert(ret, byte) end
  end
  for _, s in ipairs(self) do
    s:encode(o, putc)
  end
  return ret
end
function def:decode(getc, o)
  if type(getc)~="function" then
    local data=getc
    local dptr=data[0] and 0 or 1
    getc = function(peek) local v=data[dptr]; if not peek then dptr=dptr+1 end; return v; end
  end
  local this = {}
  for _, s in ipairs(self) do
    s:decode(getc, this)
  end
  if o then o[self._name] = this end
  return this, getc(true) and getc
end

local t_msg = def:new{__call=def.create}

local t_map = def:new()
function t_map:iter()
  local i=0
  local n=table.getn(self.values)
  return function()
    i = i+1
    if i<=n then
      local v=self.values[i]
      if type(v)=="table" then
        return v[1], v[2] or (i-1), v[3] or v[2] or 0xFFFFFFFF
      else
        return v, i-1, 0xFFFFFFFF
      end
    end
  end
end
function t_map:encode(o, putc)
  local values = o[self._name]
  values = type(values)=="table" and values or {values}
  local ret = 0
  for _, v in ipairs(values) do
    for name, value, mask in self:iter() do
      if name==v then ret = bit.bor(ret, value) end
    end
  end
  self.type:put(ret, putc)
end
function t_map:decode(getc, o)
  local v = self.type:get(getc)
  local ret = {}
  for name, value, mask in self:iter() do
    if bit.band(v, mask)==value then table.insert(ret, name) end
  end
  o[self._name] = (#ret == 1) and ret[1] or ret
end

local t_arr = def:new()
function t_arr:encode(o, putc)
  local v=o[self._name]
  if type(v)=="string" then
    v = self.ashex and U.fromhex(v) or {string.byte(v,1,#v)}
  end
  if self.length then
    for i=#v+1, self.length do table.insert(v, 0) end
  end
  if self.reverse then
    v=U.reverse(v)
  end
  if self.counter then
    self.counter:put(#v, putc)
  end
  for _, e in ipairs(v) do
    self.type:put(e, putc)
  end
end
function t_arr:decode(getc, o)
  assert(self.counter or self.length)
  local v = {}
  local count = self.counter and self.counter:get(getc) or self.length
  for c=1,count do
    local item = self.type:get(getc)
    table.insert(v, item)
  end
  if self.reverse then
    v=U.reverse(v)
  end
  o[self._name] = self.asstring and string.char(unpack(v))
    or self.ashex and U.tohex(v)
    or v
end

local t_opt = def:new()
function t_opt:encode(o, putc)
  assert(self.when)
  if self.when(o) then
    for _, s in ipairs(self) do
      s:encode(o, putc)
    end
  end
end
function t_opt:decode(getc, o)
  assert(self.when)
  if self.when(o) then
    for _, s in ipairs(self) do
      s:decode(getc, o)
    end
  end
end

local t_rst = def:new()
function t_rst:decode(getc, o)
  local v = {}
  while true do
    local input=getc()
    if not input then return v end
    table.insert(v, input)
  end
  o[self._name] = v
end

local t_primitive = def:new()
function t_primitive:encode(o, putc)
  local v = self.const or o[self._name] or self.default
  self:put(assert(v), putc)
end
function t_primitive:decode(getc, o)
  local v = self:get(getc)
  assert(not self.const or v==self.const)
  o[self._name] = v
end

local t_U8 = t_primitive:new()
function t_U8:put(v, putc) putc(v) end
function t_U8:get(getc) return assert(getc()) end

local t_U16 = t_primitive:new()
function t_U16:put(v, putc) putc(bit.band(v,0xFF)) putc(bit.rshift(v,8)) end
function t_U16:get(getc) return bit.bor(assert(getc()), bit.lshift(assert(getc()), 8)) end

local t_U32 = t_primitive:new()
function t_U32:put(v, putc) putc(bit.band(v,0xFF)) putc(bit.band(bit.rshift(v,8),0xFF)) putc(bit.band(bit.rshift(v,16),0xFF)) putc(bit.rshift(v,24)) end
function t_U32:get(getc) return bit.bor(assert(getc()), bit.lshift(assert(getc()), 8), bit.lshift(assert(getc()), 16), bit.lshift(assert(getc()), 24)) end

-- parse codec definition
local function parse(luadef)
  local t_msg_i = t_msg:new{_registry={}}
  local t_map_i = t_map:new{_registry={}}

  local ctx = {
    -- typerefs
    t_U8 = t_U8, t_U16 = t_U16, t_U32 = t_U32,
    -- utility functions
    B = U.B, contains = U.contains, contains_all = U.contains_all,
    -- definition directives
    msg = function(...) return t_msg_i:create(...) end,
    map = function(...) return t_map_i:create(...) end,
    arr = function(...) return t_arr:create(...) end,
    rst = function(...) return t_rst:create(...) end,
    opt = function(...) return t_opt:create(...) end,
    U8 = function(...) return t_U8:create(...) end,
    U16 = function(...) return t_U16:create(...) end,
    U32 = function(...) return t_U32:create(...) end,
  }

  setfenv(require(luadef), ctx)()

  return t_msg_i
end

return parse
