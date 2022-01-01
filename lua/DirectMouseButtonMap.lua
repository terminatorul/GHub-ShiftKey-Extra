local mod = { }

function mod:onButtonPressed()
    PressMouseButton(self.mouseButtonCode)
    self.buttonDown = true
end

function mod:onButtonReleased()
    if self.buttonDown
    then
	ReleaseMouseButton(self.mouseButtonCode)
	self.buttonDown = false
    end
end

function mod:onControllingModifierReleased()
    if self.buttonDown
    then
	ReleaseMouseButton(self.mouseButtonCode)
	self.buttonDown = false
    end
end

function mod:new(targetMouseButton)
    local object = { mouseButtonCode = targetMouseButton, buttonDown = false }
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
    DirectMouseButtonMap = mod
end

return mod

