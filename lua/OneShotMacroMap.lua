local mod = { }

function mod:onButtonPressed()
    PlayMacro(self.macroName)
end

function mod:registerWith(buttonEventHandler, targetButton)
    buttonEventHandler.buttonDownEventTable:registerHandler(targetButton, self, self.onButtonPressed)
end

function mod:new(targetMacroName)
    local object = { macroName = targetMacroName }
    setmetatable(object, self)
    self.__index = self
    return object
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    OneShotMacroMap = mod
end

return mod
