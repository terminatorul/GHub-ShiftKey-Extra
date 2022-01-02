local mod = { }

function mod:onButtonPressed()
    if not self.macroRunning
    then
	PressMacro(self.macroName)
	self.macroRunning = true
    end
end

function mod:onButtonReleased()
    if self.macroRunning
    then
	ReleaseMacro(self.macroName)
	self.macroRunning = false
    end
end

function mod:onControllingModifierReleased()
    if self.macroRunning
    then
	ReleaseMacro(self.macroName)
	self.macroRunning = false
    end
end

function mod:registerWith(buttonEventHandler, targetButton)
    DirectKeyMap.registerWith(self, buttonEventHandler, targetButton)
end

function mod:new(targetMacroName)
    local object = { macroName = targetMacroName, macroRunning = false }
    setmetatable(object, self)
    self.__index = self
    return object
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    DirectMacroMap = mod
end

return mod
