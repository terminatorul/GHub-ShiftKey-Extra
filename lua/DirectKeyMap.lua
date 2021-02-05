local mod = { }

function mod:onButtonPressed()
    PressKey(self.keyScanCode)
    self.keyDown = true
end

function mod:onButtonReleased()
    if self.keyDown
    then
	ReleaseKey(self.keyScanCode)
	self.keyDown = false
    end
end

function mod:onControllingModifierReleased()
    if self.keyDown
    then
	ReleaseKey(self.keyScanCode)
	self.keyDown = false
    end
end

function mod:new(targetKeyScanCode)
    local object = { keyScanCode = targetKeyScanCode, keyDown = false }
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
