local mod = BaseHandlerTable:new()

mod.buttonDownEventTable = BaseHandlerTable:new()
mod.buttonUpEventTable   = BaseHandlerTable:new()

function mod:onButtonPressedEvent(button)
    -- OutputLogMessage("Button " .. button .. " pressed\n")
    self.buttonDownEventTable:invokeHandler(button)
end

function mod:onButtonReleasedEvent(button)
    self.buttonUpEventTable:invokeHandler(button)
end

mod:registerHandler(GHubDefs.MOUSE_BUTTON_PRESSED,  mod, mod.onButtonPressedEvent)
mod:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, mod, mod.onButtonReleasedEvent)

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    DeviceEventHandler = mod
end

return mod
