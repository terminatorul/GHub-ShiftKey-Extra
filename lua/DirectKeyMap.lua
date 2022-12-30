local mod = { }

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

function mod:new(targetKeyScanCode, targetNestedModifierScanCode, targetModifierScanCode)
    local object = { keyScanCode = targetKeyScanCode, nestedModifierScanCode = targetNestedModifierScanCode, modifierScanCode = targetModifierScanCode, keyDown = false }
    setmetatable(object, self)
    self.__index = self
    return object
end

function mod:registerWith(buttonEventHandler, targetButton)
    buttonEventHandler.buttonDownEventTable:registerHandler(targetButton, self, self.onButtonPressed)
    buttonEventHandler.buttonUpEventTable:registerHandler(targetButton, self, self.onButtonReleased)

    if buttonEventHandler.transitionEventTable
    then
	buttonEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onControllingModifierReleased)
    end
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    DirectKeyMap = mod
end

return mod
