local mod = { }

-- Implements a modifier key (Shift key) on the HID device. This will override previous handlers from DeviceEventHandler,
-- so when a button is pressed with the modififer, it is detected and triggered before the ususal button handlers.
--
-- Exposes the following 3 handler tables that can be used to register new combinations with this modifier:
--	- buttonDownEventTable
--	- buttonDownEventTable
--	- transitionEventTable
--
-- Combination buttons with this modifier have two more events, other then the usual onButtonPressed and onButtonReleased.
-- The new events are:
--	- onModifierPressed
--	- onModifierReleased
-- This can be uzsed to handle the use case when the modifier is released before the more specific button. The mapping
-- for the button combination usually triggers the release sequence in this case, as if the specific button is released.
--
-- A modifier key can depend on another modifier key. Like saying Ctrl+Shift on a keyboard is a new modifier, that
-- depends on the Ctrl modifier. In this case releasing the outer (independent) modifier will cause the dependent
-- modifier to report a release event as well.

function mod:onShiftKeyPressed(buttonStateTable)
    -- exit if any registered button is alreaady down, except buttons in the sequence start table
    for buttonID, buttonHandlers in pairs(self.buttonDownEventTable)
    do
	if buttonHandlers.overrideMethod or buttonHandlers.mainMethod
	then
	    if buttonStateTable[buttonID] and not self.sequenceStartTable[buttonID]
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
