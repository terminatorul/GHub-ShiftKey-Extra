local mod = { }

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

function mod:invokeHandler(index, arg1, arg2, arg3, arg4, arg5)
    local handler = self[index]
    if handler
    then
	local nextOverride = true

	if handler.overrideMethod
	then
	    local i = 1

	    while handler.overrideMethod[i] and handler.overrideMethod[i](handler.overrideObject[i], arg1, arg2, arg3, arg4, arg5)
	    do
		i = i + 1;
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
		    handler.mainMethod[i](handler.mainObject[i], arg1, arg2, arg3, arg4, arg5)
		    i = i + 1
		end
	    end
	end
	return handler.overrideMethod or handler.mainMethod
    else
	return false
    end
end

function mod:new(obj)
    obj = obj or { }
    setmetatable(obj, self)
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
