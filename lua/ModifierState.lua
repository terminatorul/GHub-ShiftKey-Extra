local mod = { }

function mod:onShiftKeyPressed(buttonStateTable)
    -- exit if any registered button is alreaady down, except buttons in the sequence start table
    for k, v in pairs(self.buttonDownEventTable)
    do
	if self.buttonDownEventTable[k].overrideMethod or self.buttonDownEventTable[k].mainMethod
	then
	    if buttonStateTable[k] and not self.sequenceStartTable[k]
	    then
		return
	    end
	end
    end

    self.shifted = true
    self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_PRESSED)
end

function mod:onShiftKeyReleased()
    if self.shifted
    then
	self.shifted = false
	self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_RELEASED)
    end
end

function mod:onControllingModifierReleased()
    if self.shifted
    then
	self.shifted = false
	self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_RELEASED)
    end
end

function mod:onButtonPressedEventOverride(buttonStateTable, button)
    local invokeBaseHandler = true

    if self.shifted
    then
	invokeBaseHandler = not self.buttonDownEventTable:invokeHandler(button)
    end

    return invokeBaseHandler
end

function mod:onButtonReleasedEventOverride(buttonStateTable, button)
    local invokeBaseHandler = true

    if self.shifted
    then
	invokeBaseHandler = not self.buttonUpEventTable:invokeHandler(button)
    end

    return invokeBaseHandler
end

function mod:registerWith(eventCategoryHandler, buttonEventHandler, modifierButton)
    self.buttonUpEventTable.buttonStateTable   = eventCategoryHandler.buttonStateTable
    self.buttonDownEventTable.buttonStateTable = eventCategoryHandler.buttonStateTable
    self.transitionEventTable.buttonStateTable = eventCategoryHandler.buttonStateTable

    eventCategoryHandler:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_PRESSED,  self, self.onButtonPressedEventOverride)
    eventCategoryHandler:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onButtonReleasedEventOverride)

    buttonEventHandler.buttonDownEventTable:registerHandler(modifierButton, self, self.onShiftKeyPressed)
    buttonEventHandler.buttonUpEventTable:registerHandler(modifierButton, self, self.onShiftKeyReleased)

    if buttonEventHandler.transitionEventTable
    then
	buttonEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onControllingModifierReleased)
    end
end

function mod:new(obj)
    local object = obj or { }

    object.shifted = false
    object.buttonUpEventTable   = BaseHandlerTable:new()
    object.buttonDownEventTable = BaseHandlerTable:new()
    object.transitionEventTable = BaseHandlerTable:new()
    object.sequenceStartTable	= { }

    setmetatable(object, self)
    self.__index = self

    return object
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    ModifierState = mod
end

return mod
