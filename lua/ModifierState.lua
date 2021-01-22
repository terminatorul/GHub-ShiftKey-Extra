local mod = { }

function mod:onShiftKeyPressed()
    self.shifted = true
    self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_PRESSED)
end

function mod:onShiftKeyReleased()
    if (self.shifted)
    then
	self.shifted = false
	self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_RELEASED)
    end
end

function mod:onControllingModifierReleased()
    if (self.shifted)
    then
	self.shifted = false
	self.transitionEventTable:invokeHandler(GHubDefs.MOUSE_BUTTON_RELEASED)
    end
end

function mod:onButtonPressedEventOverride(button)
    local invokeBaseHandler = true

    if (self.shifted)
    then
	invokeBaseHandler = not self.buttonDownEventTable:invokeHandler(button)
    end

    return invokeBaseHandler
end

function mod:onButtonReleasedEventOverride(button)
    local invokeBaseHandler = true

    if (self.shifted)
    then
	invokeBaseHandler = not self.buttonUpEventTable:invokeHandler(button)
    end

    return invokeBaseHandler
end

function mod:registerWith(eventCategoryHandler, buttonEventHandler, modifierButton)
    eventCategoryHandler:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_PRESSED,  self, self.onButtonPressedEventOverride)
    eventCategoryHandler:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onButtonReleasedEventOverride)

    buttonEventHandler.buttonDownEventTable:registerHandler(modifierButton, self, self.onShiftKeyPressed)
    buttonEventHandler.buttonUpEventTable:registerHandler(modifierButton, self, self.onShiftKeyReleased)

    if (buttonEventHandler.transitionEventTable)
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

    setmetatable(object, self)
    self.__index = self

    return object
end

if (_REQUIREDNAME)
then
    _G[_REQUIREDNAME] = mod
else
    ModifierState = mod
end

return mod
