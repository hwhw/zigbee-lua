local U = require"lib.util"

local ctx = {
  config = require"config",
  tasks_waiting = {}
}

ctx.srv = require(ctx.config.srv_implementation)

function ctx:run()
  return self.srv:loop()
end

-- event handlers

local function handlersel(acc, tlist, event, depth)
  for _, handler in ipairs(tlist) do
      table.insert(acc, handler)
  end
  local e = event[depth]
  if not e then return end
  local l = tlist[e]
  if not l then return end
  return handlersel(acc, l, event, depth+1)
end
function ctx:fire(event, eventparams)
  local handlers = {}
  handlersel(handlers, self.tasks_waiting, event, 1)
  for _, handler in ipairs(handlers) do
    if not handler.cond or handler.cond(eventparams) then
      handler.callback(event, eventparams)
    end
  end
end

function ctx:on(event, cond, callback)
  local tlist = self.tasks_waiting
  for _, e in ipairs(event) do
    if not tlist[e] then tlist[e] = {} end
    tlist = tlist[e]
  end
  local handler = {cond=cond, callback=callback}
  table.insert(tlist, handler)
  return handler
end

function ctx:drop(event, handler)
  local tlist = self.tasks_waiting
  for _, e in ipairs(event) do
    if not tlist[e] then return end
    tlist = tlist[e]
  end
  for k, h in ipairs(tlist) do
    if h == handler then
      table.remove(tlist, k)
      return
    end
  end
end

-- coroutine based tasks

function ctx:task(func, ...)
  local t = coroutine.create(func)
  U.DEBUG("ctx/task", "task %s starting", tostring(t))
  self:task_continue(t, ...)
  return t
end

local ev_tfinished = {"task", "finished"}
function ctx:task_continue(t, ...)
  local result = coroutine.resume(t, ...)
  if coroutine.status(t) == "dead" then
    U.DEBUG("ctx/task", "task %s finished", tostring(t))
    self:fire(ev_tfinished, {task=t, result=result})
  end
end

function ctx:wait(event, cond, timeout)
  local cr = coroutine.running()
  local timer = timeout and self.srv:timer(timeout, function()
    self:task_continue(cr, false, "timeout")
  end)

  local handler = event and self:on(event, cond, function(e, ep)
    if timer then ctx.srv:timer_del(timer) end
    self:task_continue(cr, e, ep)
  end)

  U.DEBUG("ctx/task", "task %s waiting", tostring(cr))
  local ret = {coroutine.yield(true)}
  U.DEBUG("ctx/task", "task %s resuming", tostring(cr))

  if handler then self:drop(event, handler) end

  return unpack(ret)
end

function ctx:sleep(timeout)
  return self:wait(nil, nil, timeout)
end

return ctx
