local ffi = require"ffi"
local bit = require"bit"
local U = require"lib.util"
local object = U.object

-- base object: a definition
local def = object:new()
function def:create(childs)
  if type(childs) == "table" then
    -- the name of the definition element is always the first member of the definition table if not given
    childs.name = childs.name or table.remove(childs, 1)
    -- just a reference to a definition elsewhere
    if childs.ref then
      assert(self._registry, "try to reference definition without a registry")
      return self:new{_ref=childs.ref, _registry=self._registry, name=childs.name, when=childs.when}
    end
    local d = self:new(childs)
    if self._registry and childs.name and childs.register then self._registry[childs.name] = d end
    return d
  elseif type(childs) == "string" then
    assert(self._registry, "try to access definition without a registry")
    return self._registry[childs]
  end
end
function def:match(data, ctx)
  for n, d in pairs(self._registry) do
    local ok, ret, remain = pcall(d.decode, d, data, ctx)
    if ok then return ret, n, remain end
  end
  return false
end
function def:deref_iter()
  return function(t, i)
    i = i + 1
    local v = t[i]
    if v then
      if v._ref then
        if not v._registry[v._ref] then return end
        v = v._registry[v._ref]:new(v)
        t[i] = v
      end
      return i, v
    end
  end, self, 0
end
function def:encode(o, ctx, putc, root)
  o = o or {}
  root = root or o
  local ret
  if not putc then
    ret = {}
    putc = function(byte) table.insert(ret, byte) end
  end
  if not self.when or self.when(o, nil, ctx, root) then
    local this = self.name and type(o)=="table" and o[self.name] or o
    for _, s in self:deref_iter() do
      s:encode(this, ctx, putc, root)
    end
  end
  return ret
end
function def:decode(getc, ctx, o, root)
  if type(getc)~="function" then
    local data=getc
    local dptr=data[0] and 0 or 1
    getc = function(peek) local v=data[dptr]; if not peek then dptr=dptr+1 end; return v; end
  end
  local this = {}
  if not self.when or self.when(o, getc, ctx, root) then
    if o then
      if self.name then
        o[self.name] = this
      else
        this = o
      end
    end
    root = root or this
    for _, s in self:deref_iter() do
      s:decode(getc, ctx, this, root)
    end
  end
  return this, getc(true) and getc
end

local t_msg = def:new{__call=def.create,register=true}

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
function t_map:encode(o, ctx, putc, root)
  local values = assert(o[self.name], "no value for "..self.name)
  values = type(values)=="table" and values or {values}
  local ret = 0
  for _, v in ipairs(values) do
    for name, value, mask in self:iter() do
      if name==v then ret = bit.bor(ret, value) end
    end
  end
  self.type:put(ret, putc)
end
function t_map:decode(getc, ctx, o, root)
  local v = self.type:get(getc)
  local ret = {}
  for name, value, mask in self:iter() do
    if bit.band(v, mask)==value then table.insert(ret, name) end
  end
  o[self.name] = (#ret == 1) and ret[1] or ret
end

local t_arr = def:new()
function t_arr:encode(o, ctx, putc, root)
  local v=assert(o[self.name], "no value for "..self.name)
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
    if self.type then
      self.type:put(e, putc)
    else
      def.encode(self, e, ctx, putc, root)
    end
  end
end
function t_arr:decode(getc, ctx, o, root)
  local v = {}
  local count = self.counter and self.counter:get(getc) or self.length
  while true do
    if not count and getc(true)==nil then
      break
    elseif count then
      if count==0 then break end
      count = count - 1
    end
    local item
    if self.type then
      item = self.type:get(getc)
    else
      item = def.decode(self, getc, ctx, item, root)
    end
    if type(item)=="table" and #item==1 then item=item[1] end
    table.insert(v, item)
  end
  if self.reverse then
    v=U.reverse(v)
  end
  o[self.name] = self.asstring and string.char(unpack(v))
    or self.ashex and U.tohex(v)
    or v
end

local t_opt = def:new()

local t_bool = def:new()
function t_bool:encode(o, ctx, putc, root)
  o[self.name]=o[self.name] or self.default or self.const
  assert(not self.const or o[self.name]==self.const, "value not according to constant define")
  putc(assert(o[self.name], "no value for "..self.name) and 1 or 0)
end
function t_bool:decode(getc, ctx, o, root)
  local v = getc() == 1 and true or false
  assert(not self.const or v==self.const, "value not according to constant define")
  o[self.name] = v
end

local t_bmap = def:new()
function t_bmap:encode(o, ctx, putc, root)
  -- TODO: implement default
  -- TODO: equality check for const
  for i=0,self.bytes-1 do
    local v = 0
    for b=0,7 do
      if o[self.name][i*8+b+1] then v = bit.bor(v, bit.lshift(1, b)) end
    end
    putc(v)
  end
end
function t_bmap:decode(getc, ctx, o, root)
  for i=0,self.bytes-1 do
    local v = getc()
    for b=0,7 do
      o[self.name][i*8+b+1] = bit.band(v, bit.lshift(1, b)) ~= 0
    end
  end
end

local t_primitive = def:new()
function t_primitive:encode(o, ctx, putc, root)
  local v = o
  if self.name and type(v)=="table" then v=v[self.name] end
  v = v or self.default or self.const
  self:put(v, putc)
end
function t_primitive:decode(getc, ctx, o, root)
  local v = self:get(getc)
  assert(not self.const or v==self.const, "value not according to constant define")
  if self.name then
    o[self.name] = v
  else
    table.insert(o, v)
  end
end

local t_genint = t_primitive:new()
function t_genint:put(v, putc)
  local p = ffi.cast("uint8_t*", ffi.new(self.signed and "int64_t[1]" or "uint64_t[1]", v))
  for i=0,self.bytes-1 do putc(p[i]) end
end
function t_genint:get(getc)
  local ret = ffi.new(self.signed and "int64_t[1]" or "uint64_t[1]", 0)
  local p = ffi.cast("uint8_t*", ret)
  local v
  for i=0,self.bytes-1 do v=getc() p[i]=v end
  if self.signed and v>0x7F then for i=self.bytes,7 do p[i]=0xFF end end
  return tonumber(ret[0])
end

local t_int = t_genint:new{signed=true}
local t_uint = t_genint:new{signed=false}

local t_I8 = t_int:new{bytes=1}
local t_I16 = t_int:new{bytes=2}
local t_I24 = t_int:new{bytes=3}
local t_I32 = t_int:new{bytes=4}
local t_I40 = t_int:new{bytes=5}
local t_I48 = t_int:new{bytes=6}
local t_I56 = t_int:new{bytes=7}
local t_I64 = t_int:new{bytes=8}
local t_U8 = t_uint:new{bytes=1}
local t_U16 = t_uint:new{bytes=2}
local t_U24 = t_uint:new{bytes=3}
local t_U32 = t_uint:new{bytes=4}
local t_U40 = t_uint:new{bytes=5}
local t_U48 = t_uint:new{bytes=6}
local t_U56 = t_uint:new{bytes=7}
local t_U64 = t_uint:new{bytes=8}

local t_float = t_primitive:new{size=4,type="float"}
function t_float:put(v, putc)
  local p = ffi.cast("uint8_t*", ffi.new(self.type.."[1]", v))
  for i=0,self.size-1 do putc(p[i]) end
end
function t_float:get(getc)
  local ret = ffi.new(self.type.."[1]", 0)
  local p = ffi.cast("uint8_t*", ret)
  for i=0,self.size-1 do p[i] = getc() end
  return ret[0]
end
local t_double = t_float:new{size=8,type="double"}

-- parse codec definition
local function create(typeobj) return function(...) return typeobj:create(...) end end
local function parse(deffun)
  local t_msg_i = t_msg:new{_registry={}}
  local t_map_i = t_map:new{_registry={}}

  local ctx = {
    -- typerefs
    t_U8 = t_U8, t_U16 = t_U16, t_U32 = t_U32, t_U40 = t_U40, t_U48 = t_U48, t_U56 = t_U56, t_U64 = t_U64,
    t_I8 = t_I8, t_I16 = t_I16, t_I32 = t_I32, t_I40 = t_I40, t_I48 = t_I48, t_I56 = t_I56, t_I64 = t_I64,
    -- utility functions
    B = U.B, contains = U.contains, contains_all = U.contains_all,
    U = U, print=print,
    -- definition directives
    msg = create(t_msg_i),
    map = create(t_map_i),
    arr = create(t_arr),
    opt = create(t_opt),
    bool = create(t_bool),
    bmap = create(t_bmap),
    float = create(t_float),
    double = create(t_double),
    U8 = create(t_U8), U16 = create(t_U16), U24 = create(t_U24), U32 = create(t_U32),
    U40 = create(t_U40), U48 = create(t_U48), U56 = create(t_U56), U64 = create(t_U64),
    I8 = create(t_I8), I16 = create(t_I16), I24 = create(t_I24), I32 = create(t_I32),
    I40 = create(t_I40), I48 = create(t_I48), I56 = create(t_I56), I64 = create(t_I64),
  }

  setfenv(deffun, ctx)()

  return t_msg_i
end

return parse
