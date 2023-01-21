local mod = { buttonUpEventTable = BaseHandlerTable:new(), buttonDownEventTable = BaseHandlerTable:new() }

-- Override eventCategoryHandlers and directly map a key to a given button, after which the previous handlers are processed
-- as usual. To override the category handlers call:
--	- DirectKeyMapOverride:registerOverrides(eventCategoryHandlers)
--
-- at the right time, as the new handlers take priority over the existing handlers. To specify the button to override, call
-- the :new() constructor with the key to be sent (triggered), and call :registerWith() to specify the underlaying button.

function mod:onButtonPressed()
    if self.modifierScanCode
    then
	PressKey(self.modifierScanCode)
    end

    if self.nestedModifierScanCode
    then
	PressKey(self.nestedModifierScanCode)
    end

    PressKey(self.keyScanCode)
    self.keyDown = true

    return true
end

function mod:onButtonReleased()
    if self.keyDown
    then
	ReleaseKey(self.keyScanCode)
	self.keyDown = false

	if self.nestedModifierScanCode
	then
	    ReleaseKey(self.nestedModifierScanCode)
	end

	if self.modifierScanCode
	then
	    ReleaseKey(self.modifierScanCode)
	end
    end

    return true
end

function mod:onControllingModifierReleased()
    if self.keyDown
    then
	ReleaseKey(self.keyScanCode)
	self.keyDown = false

	if self.nestedModifierScanCode
	then
	    ReleaseKey(self.nestedModifierScanCode)
	end

	if self.modifierScanCode
	then
	    ReleaseKey(self.modifierScanCode)
	end
    end
end

function mod:onButtonPressedEventOverride(buttonStateTable, buttonID, arg1, arg2, arg3, arg4)
    self.buttonDownEventTable:invokeHandler(buttonID, arg1, arg2, arg3, arg4)
    return true
end

function mod:onButtonReleasedEventOverride(buttonStateTable, buttonID, arg1, arg2, arg3, arg4)
    self.buttonUpEventTable:invokeHandler(buttonID, arg1, arg2, arg3, arg4)
    return true
end

function mod:registerOverrides(eventCategoryHandlers)
    eventCategoryHandlers:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_PRESSED,  self, self.onButtonPressedEventOverride)
    eventCategoryHandlers:registerHandlerOverride(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onButtonReleasedEventOverride)
end

function mod:new(targetKeyScanCode, targetNestedModifierScanCode, targetModifierScanCode)
    local object = { keyScanCode = targetKeyScanCode, nestedModifierScanCode = targetNestedModifierScanCode, modifierScanCode = targetModifierScanCode, keyDown = false }

    setmetatable(object, self)
    self.__index = self

    return object
end

function mod:registerWith(targetButton)
    mod.buttonDownEventTable:registerHandlerOverride(targetButton, self, self.onButtonPressed)
    mod.buttonUpEventTable:registerHandlerOverride(targetButton, self, self.onButtonReleased)

    if mod.transitionEventTable
    then
	mod.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onControllingModifierReleased)
    end
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    DirectKeyMapOverride = mod
end

return mod
