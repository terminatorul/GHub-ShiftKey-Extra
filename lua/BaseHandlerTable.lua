local mod = { }

-- A HandlerTable identifies groups of handlers by the group index. Within the group two ordered lists of handlers are maintained:
--	- main handlers are invoked in the order they are registered, and their result is ignored
--	- override handlers are invoked in the reverse order of registration (last handler has highest precedence), are always invoked before the main
--	  handlers, and they can return false to prevent invocation of any remaining handlers
--
-- A handler is defined as a pair of an object and an associated method. The first argument to any handler invocation is given at the table construction time
-- (as the buttonStateTable argument).
--
-- Invoking the registered handlers in a group is done by the group index, and all invocation arguments are passed to all groupp handlers, after the
-- first argument given at construction time. Invocation of a handlers group (by index) returns true if any handlers were found and invoked in the group.

function mod:registerHandler(index, handlerObject, handlerMethod)
    if self[index]
    then
	if (self[index].mainMethod)
	then
	    table.insert(self[index].mainMethod, handlerMethod)
	    table.insert(self[index].mainObject, handlerObject)
	else
	    self[index].mainMethod = { [1] = handlerMethod }
	    self[index].mainObject = { [1] = handlerObject }
	end
    else
	self[index] =
	{
	    mainMethod = { [1] = handlerMethod },
	    mainObject = { [1] = handlerObject }
	}
    end
end

function mod:registerHandlerOverride(index, handlerObject, handlerMethod)
    if self[index]
    then
	if self[index].overrideMethod
	then
	    table.insert(self[index].overrideMethod, 1, handlerMethod)
	    table.insert(self[index].overrideObject, 1, handlerObject)
	else
	    self[index].overrideMethod = { [1] = handlerMethod }
	    self[index].overrideObject = { [1] = handlerObject }
	end
    else
	self[index] =
	{
	    overrideMethod = { [1] = handlerMethod },
	    overrideObject = { [1] = handlerObject }
	}
    end
end

function getTableSize(table)
    local i = 1

    while table[i]
    do
	i = i + 1
    end

    return i - 1
end

function mod:invokeHandler(index, arg1, arg2, arg3, arg4, arg5)
    local handler = self[index]
    if handler
    then
	local nextOverride = true

	if handler.overrideMethod
	then
	    local i = 1

	    while handler.overrideMethod[i] and handler.overrideMethod[i](handler.overrideObject[i], self.buttonStateTable, arg1, arg2, arg3, arg4, arg5)
	    do
		i = i + 1
	    end

	    nextOverride = not handler.overrideMethod[i]
	end

	if nextOverride
	then
	    if handler.mainMethod
	    then
		local i = 1

		while handler.mainMethod[i]
		do
		    handler.mainMethod[i](handler.mainObject[i], self.buttonStateTable, arg1, arg2, arg3, arg4, arg5)
		    i = i + 1
		end
	    end
	end
	return handler.overrideMethod or handler.mainMethod
    else
	return false
    end
end

function mod:new(buttonStateTable, obj)
    obj = obj or { }
    setmetatable(obj, self)
    obj.buttonStateTable = buttonStateTable
    self.__index = self
    return obj
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    BaseHandlerTable = mod
end

return mod
