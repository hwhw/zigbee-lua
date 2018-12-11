local U = require"lib.util"

local ctx = {
  config = require"config",
  tasks_waiting = {},
  interfaces = {}
}

ctx.srv = require(ctx.config.srv_implementation)

function ctx:run()
  for class, instances in pairs(self.config.interfaces) do
    for n, config in ipairs(instances) do
      self.interfaces[class] = self.interfaces[class] or {}
      self.interfaces[class][n] = require("interfaces."..class):new(config):init()
    end
  end

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

-- this sends an event to all tasks listening for it
--
-- an event is identified by a list (table) of values
-- a task is considered to be waiting for an event if
-- it registered for this event (identity of all list values)
-- or a parent event (identity of a rooted subset of list values)
function ctx:fire(event, eventparams)
  local handlers = {}
  handlersel(handlers, self.tasks_waiting, event, 1)
  --U.DEBUG("ctx/event", "event fired: %s", U.dump(event))
  for _, handler in ipairs(handlers) do
    if not handler.cond or handler.cond(eventparams) then
      handler.callback(event, eventparams)
    end
  end
end

-- register for an event (usually used through a task's wait() method)
--
-- aside from the event itself, a condition function can given
-- that is executed in order to allow for more fine grained
-- filtering. The condition function will be called with the event's
-- parameter value as argument and if it returns trueish, the condition
-- is supposed to be fulfilled.
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

-- remove an event from the register of event listeners
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

---------------------------------------------------------------------
-- coroutine based tasks

local task = U.object:new{root=true}
local taskregistry = {}

-- start a new task
--
-- this is basically a wrapper around a coroutine-based approach
-- to parallel states. tasks can stop waiting for events using their
-- wait() method.
--
-- Tasks can be enqueued to be run after the previous task is done
-- using the previous tasks' next() method. A completely new task to
-- be started immediately can be created with the ctx.task's next()
-- method, accessible also via direct call to ctx.task
--
-- taskfn can either be a function or a table with the function as
-- its element at index 1, giving additional task attributes as
-- named values (most prominently a name for debugging purposes)
function task:next(taskfn, ...)
  local next_task
  if type(taskfn) == "table" then
    next_task = task:new{cr=coroutine.create(taskfn[1]),
      ignore_errors=taskfn.ignore_errors,name=taskfn.name,
      next_task=false, root=false, parent=coroutine.running()}
  else
    next_task = task:new{cr=coroutine.create(taskfn), next_task=false, root=false, parent=coroutine.running()}
  end
  next_task.name = next_task.name or tostring(next_task)
  U.DEBUG("ctx/task", "registering follow up task: %s -> %s", self.name, next_task.name)
  taskregistry[next_task.cr] = next_task
  if self.root or not taskregistry[self.cr] then
    U.DEBUG("ctx/task", "starting next task %s immediately", next_task.name)
    if self.result then
      return next_task:continue(unpack(self.result))
    else
      return next_task:continue(true, ...)
    end
  elseif self.next_task == false then
    self.next_task = next_task
  end
  return next_task
end

task.__call = task.next

function task:finish()
  if taskregistry[self.cr] then
    U.DEBUG("ctx/task", "waiting for finish of task %s", self.name)
    local ev = {"task", "finish", self}
    local task = self:next(function(t, ...)
      ctx:fire(ev)
    end)
    taskregistry[coroutine.running()]:wait(ev)
  end
  return unpack(self.result)
end

-- this starts a list (table) of tasks in "parallel" mode
--
-- it stops tasks still running as soon as @max_successful tasks
-- returned (i.e. finished) without error or @max_errors tasks
-- returned with an error. Default is to wait for all given tasks
-- to complete successfully or abort as soon as one of them quits
-- due to an error
function task:parallel(tasks, max_successful, max_errors)
  max_successful = max_successful or #tasks
  max_errors = max_errors or 1
  return self:next(function(t, ok, ...)
    if not ok then error(...) end
    local running = {}
    local ev = {"task", "finish", t}
    local results = {}
    local no_ok = 0
    local no_error = 0
    local check = function(i, result)
      results[i] = result
      if result[1] then
        no_ok = no_ok + 1
      else
        no_error = no_error + 1
      end
      if no_ok >= max_successful or no_error >= max_errors then
        for ktask, _ in pairs(running) do
          ktask:kill()
        end
        return true
      end
      return false
    end
    for i, taskfn in ipairs(tasks) do
      local new = task:next(taskfn, ...)
      if taskregistry[new.cr] then
        running[new] = i
        new:next{function(t, ok, ...)
          running[new] = nil
          ctx:fire(ev, {i, {ok, ...}})
        end}
      else
        if check(i, new.result) then return results end
      end
    end
    for subtask, i in pairs(running) do
      local _, ep = t:wait(ev)
      if check(ep[1], ep[2]) then return results end
    end
    return results
  end)
end

-- the external calling vector to resume a task that is either
-- newly created and not yet running or in the state of waiting
-- for an event. Will also handle what to do next when the
-- task that has been resumed dies, either to it having finished
-- or due to an error
function task:continue(...)
  self.result = {coroutine.resume(self.cr, self, ...)}
  if coroutine.status(self.cr) == "dead" then
    U.DEBUG("ctx/task", "task %s finished", self.name)
    taskregistry[self.cr] = nil
    if not self.result[1] then
      U.ERR("ctx/task", "task %s aborted with error: %s, %s", self.name, tostring(self.result[2]), debug.traceback(self.cr))
      if not self.ignore_errors then error(tostring(self.result[2])) end
    end
    if self.next_task then
      return self.next_task:continue(unpack(self.result))
    end
  end
  return self
end

-- external calling vector to signal a task to die
-- The task that has been signalled this way will be resumed only
-- to be able to die with an error()
function task:kill()
  local cr = coroutine.running()
  assert(self.cr ~= cr, "a task is not supposed to kill itself")
  self.killed = true
  self:continue(false, "killed")
end

-- wait for an event
--
-- optionally, check the event parameter value against additional
-- conditions using a function that is passed as the cond argument
-- also, optionally honor a timeout (given in seconds, float values OK)
function task:wait(event, cond, timeout)
  local cr = coroutine.running()
  assert(self.cr == cr, "a task is supposed to call its own wait() method")

  self.timer = timeout and ctx.srv:timer(timeout, function()
    self:continue(false, "timeout")
  end)
  self.handler = event and ctx:on(event, cond, function(e, ep)
    self:continue(e, ep)
  end)

  U.DEBUG("ctx/task", "task %s waiting", self.name)
  local ret = {select(2, coroutine.yield(true))}

  if self.handler then
    ctx:drop(event, self.handler)
    self.handler = nil
  end
  if self.timer then
    ctx.srv:timer_del(self.timer)
    self.timer = nil
  end

  if self.killed then
    U.DEBUG("ctx/task", "task %s killed", self.name)
    -- the only way to reliably quit the execution of the
    -- coroutine (except from mandates to be honored by the
    -- upwards call stack) is exiting with an error
    error("killed")
  else
    U.DEBUG("ctx/task", "task %s resuming", self.name)
  end

  return unpack(ret)
end

-- convenience method that acts on the current task
function ctx:wait(...)
  assert(taskregistry[coroutine.running()], "wait() called outside a task context")
  return taskregistry[coroutine.running()]:wait(...)
end

-- convenience wrapper to simply sleep for a given number
-- of seconds (fractionally, if needed)
function task:sleep(timeout)
  return self:wait(nil, nil, timeout)
end

-- convenience method that acts on the current task
function ctx:sleep(...)
  assert(taskregistry[coroutine.running()], "wait() called outside a task context")
  return taskregistry[coroutine.running()]:sleep(...)
end

-- ctx.task is an instance so the __call metamethod works as
-- intended
ctx.task = task:new()

return ctx
