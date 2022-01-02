local mod = { }

function mod:onButtonPressed()
    PressKey(self.modifierScanCode)

    if self.nestedModifierScanCode
    then
	PressKey(self.nestedModifierScanCode)
    end

    PressAndReleaseKey(self.keyScanCode)

    if self.nestedModifierScanCode
    then
	ReleaseKey(self.nestedModifierScanCode)
    end

    ReleaseKey(self.modifierScanCode)
end

function mod:registerWith(buttonEventHandler, targetButton)
    buttonEventHandler.buttonDownEventTable:registerHandler(targetButton, self, self.onButtonPressed)
end

function mod:new(targetModifierScanCode, targetKeyScanCode, targetSecondScanCode)
    local object = { }

    if targetSecondScanCode == nil
    then
	object.modifierScanCode		= targetModifierScanCode
	object.nestedModifierScanCode	= nil
	object.keyScanCode		= targetKeyScanCode
    else
	object.modifierScanCode		= targetModifierScanCode
	object.nestedModifierScanCode   = targetKeyScanCode
	object.keyScanCode		= targetSecondScanCode
    end

    setmetatable(object, self)
    self.__index = self
    return object
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    OneShotKeyCombinationMap = mod
end

return mod

