local mod = { }

function mod:onButtonPressed()
    if IsModifierPressed(self.contextModifierKey)
    then
	if not self.secondContextModifierKey or IsModifierPressed(self.secondContextModifierKey)
	then
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

	    return false
	end
    end

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

	return false
    end

    return true
end

function mod:onControllingModifierReleased()
    return self:onButtonReleased()
end

function mod:new(targetContextModifier, targetSecondContextModifier, targetKeyScanCode, targetNestedModifierScanCode, targetModifierScanCode)
    local object =
    {
	contextModifierKey	    = targetContextModifier,
	secondContextModifierKey    = targetSecondContextModifier,
	keyScanCode		    = targetKeyScanCode,
	nestedModifierScanCode	    = targetNestedModifierScanCode,
	modifierScanCode	    = targetModifierScanCode,
	keyDown			    = false
    }

    setmetatable(object, self)
    self.__index = self

    return object
end

function mod:registerWith(buttonEventHandlers, targetButton)
    buttonEventHandlers.buttonDownEventTable:registerHandlerOverride(targetButton, self, self.onButtonPressed)
    buttonEventHandlers.buttonUpEventTable:registerHandlerOverride(targetButton, self, self.onButtonReleased)

    if buttonEventHandlers.transitionEventTable
    then
	buttonEventHandlers.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onControllingModifierReleased)
    end
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    DirectKeyWithModifierMap = mod
end

return mod
