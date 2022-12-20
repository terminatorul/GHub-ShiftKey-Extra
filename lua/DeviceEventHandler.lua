local buttonStateTable = { }
local mod = BaseHandlerTable:new(buttonStateTable)

-- DeviceEventHandler is used to implement the global OnEvent() function, and receives all possible input events from the HID device (mouse / keyboard).
-- Maintains the global buttonStateTable, that is shared by all the handlers throughout the code as the first argument in their invocation.
-- Pre-registers handlers for button pressed and released events (for all buttons), that dispatch the two events to per-button handlers.

mod.buttonDownEventTable = BaseHandlerTable:new(buttonStateTable)
mod.buttonUpEventTable   = BaseHandlerTable:new(buttonStateTable)

function mod:onButtonPressedEvent(buttonStateTable, button)
    self.buttonDownEventTable:invokeHandler(button)
end

function mod:onButtonReleasedEvent(buttonStateTable, button)
    self.buttonUpEventTable:invokeHandler(button)
end

function mod:invokeHandler(index, arg1, arg2, arg3, arg4, arg5)
    if index == GHubDefs.MOUSE_BUTTON_PRESSED
    then
	buttonStateTable[arg1] = true
    else
	if index == GHubDefs.MOUSE_BUTTON_RELEASED
	then
	    buttonStateTable[arg1] = false
	end
    end

    return BaseHandlerTable.invokeHandler(self, index, arg1, arg2, arg3, arg4, arg5)
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
