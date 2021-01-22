local mod = { }

function mod:onButtonPressed()
    PressKey(self.modifierScanCode)
    PressAndReleaseKey(self.keyScanCode)
    ReleaseKey(self.modifierScanCode)
end

function mod:new(targetModifierScanCode, targetKeyScanCode)
    local object = { modifierScanCode = targetModifierScanCode, keyScanCode = targetKeyScanCode }
    setmetatable(object, self)
    self.__index = self
    return object
end

function mod:registerWith(buttonEventHandler, targetButton)
    buttonEventHandler.buttonDownEventTable:registerHandler(targetButton, self, self.onButtonPressed)
end

if (_REQUIREDNAME)
then
    _G[_REQUIREDNAME] = mod
else
    OneShotModifiedKeyMap = mod
end

return mod

