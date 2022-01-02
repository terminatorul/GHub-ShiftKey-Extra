local mod = { sequenceInProgress = false }

-- Release both Tab and Alt keys at the end of the Alt+Tab (or similar) sequence
function mod:stopSequence()
    if self.sequenceInProgress
    then
	if self.isAdvanceKeyDown
	then
	    ReleaseKey(self.advanceKey)
	end
	if self.isReverseKeyDown
	then
	    ReleaseKey(self.reverseKey)
	end
	ReleaseKey(self.modifierKey)
	self.sequenceInProgress = false
	mod.sequenceInProgress = false
    end
end

-- Trigger the first Alt and Tab key press in the Alt+Tab (or similar) sequence
function mod:startSequence(oneShotAdvance)
    if not self.sequenceInProgres and not mod.sequenceInProgress
    then
	PressKey(self.modifierKey)

	if oneShotAdvance
	then
	    PressAndReleaseKey(self.advanceKey)
	    self.isAdvanceKeyDown   = false
	else
	    PressKey(self.advanceKey)
	    self.isAdvanceKeyDown = true
	end

	self.isNavigatingReverse = false
	self.isReverseKeyDown   = false
	self.sequenceInProgress = true

	mod.sequenceInProgress  = true

	return true
    end
end

function mod:onDirectAdvanceKeyPress()
    self:startSequence(true)
end

function mod:OnDirectAdvanceKeyRelease()
    self:stopSequence()
end

function mod:onDirectReverseKeyRelease()
    self:stopSequence()
end

-- The equivalent for Tab in the Alt+Tab mapping was pressed, while the Alt modifier equivalent was
-- already held down
function mod:onModifiedAdvanceKeyPress()
    if self.sequenceInProgress
    then
	if not self.isAdvanceKeyDown
	then
	    PressKey(self.advanceKey)
	    self.isAdvanceKeyDown = true
	end
    else
	self:startSequence(false)
    end
end

-- The equivalent for Tab in the Alt+Tab mapping was released, while the Alt modifier equivalent was
-- already held down
function mod:onModifiedAdvanceKeyRelease()
    if self.sequenceInProgress
    then
	if self.isAdvanceKeyDown
	then
	    ReleaseKey(self.advanceKey)
	    self.isAdvanceKeyDown = false
	end
    end
end

-- The equivalent for Shift+Tab in the Alt+Tab mapping was pressed, while the Alt modifier equivalent
-- was already held down
function mod:onModifiedReverseKeyPress()
    if self.sequenceInProgress
    then
	if not self.isReverseKeyDown
	then
	    PressKey(self.reverseKey)
	    self.isReverseKeyDown = true

	    if self.reverseModifier and not self.isAdvanceKeyDown
	    then
		PressKey(self.advanceKey)
		self.isAdvanceKeyDown = true
	    end
	end
	self.isNavigatingReverse = true
    end
end
--
-- The equivalent for Shift+Tab in the Alt+Tab mapping was released, while the Alt modifier equivalent
-- was held down
function mod:onModifiedReverseKeyRelease()
    if self.sequenceInProgress
    then
	if self.isReverseKeyDown
	then
	    if self.reverseModifier and self.isAdvanceKeyDown
	    then
		ReleaseKey(self.advanceKey)
		self.isAdvanceKeyDown = false
	    end

	    ReleaseKey(self.reverseKey)
	    self.isReverseKeyDown = false
	end
	self.isNavigatingReverse = false
    end
end

-- Special case equivalent to pressing Alt while Alt+Tab sequence is already in progress. This happens
-- because of the special requirement of starting the sequence with a direct key press as well (without a
-- modifier key). In this case, eventually pressing the modifier will advance the sequence (will press
-- Tab again).
function mod:onModifierPress()
    if self.sequenceInProgress
    then
	if self.isNavigatingReverse
	then
	    if not self.isReverseKeyDown
	    then
		PressKey(self.reverseKey)
		self.isReverseKeyDown = true
	    end

	    if self.reverseModifier and not self.isAdvanceKeyDown
	    then
		PressKey(self.advanceKey)
		self.isAdvanceKeyDown = true;
	    end
	else
	    if not self.isAdvanceKeyDown
	    then
		PressKey(self.advanceKey)
		self.isAdvanceKeyDown = true
	    end
	end
    end
end

-- The equivalent of Alt in the Alt+Tab mapping was released. As a special case if Tab is also being
-- held down at the same time, the Tab is released but Alt is not, so the Alt+Tab sequence is not terminated.
--
-- This allows using the modifier key to advance (or reverse) the sequence, effectively switching roles
-- with the actual advance key (or reverse key).
function mod:onModifierRelease()
    if self.sequenceInProgress
    then
	if not self.requireModifierButton and (self.isReverseKeyDown or self.isAdvanceKeyDown)
	then
	    if self.isReverseKeyDown
	    then
		if self.reverseModifier and self.isNavigatingReverse
		then
		    if self.isAdvanceKeyDown
		    then
			ReleaseKey(self.advanceKey)
			self.isAdvanceKeyDown = false
		    end
		else
		    ReleaseKey(self.reverseKey)
		    self.isReverseKeyDown = false
		end
	    else
		if self.isAdvanceKeyDown
		then
		    ReleaseKey(self.advanceKey)
		    self.isAdvanceKeyDown = false
		end
	    end
	else
	    self:stopSequence()
	end
    end
end

function mod:registerWithModifierMappings(buttonEventHandler, advanceButton, reverseButton)
    buttonEventHandler.buttonDownEventTable:registerHandler(advanceButton, self, self.onModifiedAdvanceKeyPress)
    buttonEventHandler.buttonUpEventTable:registerHandler(advanceButton, self, self.onModifiedAdvanceKeyRelease)

    if reverseButton
    then
	buttonEventHandler.buttonDownEventTable:registerHandler(reverseButton, self, self.onModifiedReverseKeyPress)
	buttonEventHandler.buttonUpEventTable:registerHandler(reverseButton, self, self.onModifiedReverseKeyRelease)
    end

    if buttonEventHandler.transitionEventTable
    then
	buttonEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onModifierRelease)
    end

    self.requireModifierButton = true
end

function mod:registerWithDirectMappings(directEventHandler, buttonEventHandler, advanceButton, reverseButton)
    self:registerWithModifierMappings(buttonEventHandler, advanceButton, reverseButton)

    directEventHandler.buttonDownEventTable:registerHandler(advanceButton, self, self.onDirectAdvanceKeyPress)
    directEventHandler.buttonUpEventTable:registerHandler(advanceButton, self, self.onDirectAdvanceKeyRelease)

    buttonEventHandler.sequenceStartTable[advanceButton] = true

    if reverseButton
    then
	directEventHandler.buttonUpEventTable:registerHandler(advanceButton, self, self.onDirectReverseKeyRelease)
    end

    if directEventHandler.transitionEventTable
    then
	directEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onDirectAdvanceKeyRelease)

	if reverseButton
	then
	    directEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_RELEASED, self, self.onDirectReverseKeyRelease)
	end
    end

    if buttonEventHandler.transitionEventTable
    then
	buttonEventHandler.transitionEventTable:registerHandler(GHubDefs.MOUSE_BUTTON_PRESSED, self, self.onModifierPress)
    end

    self.requireModifierButton = false
end

function mod:registerWith(eventHandler, eventHandlerOrButton, targetButton, optionalTargetButton)
    if optionalTargetButton == nil
    then
	self:registerWithModifierMappings(eventHandler, eventHandlerOrButton, targetButton)
    else
	self:registerWithDirectMappings(eventHandler, eventHandlerOrButton, targetButton, optionalTargetButton)
    end
end

function mod:new(modifierScanCode, backwardScanCode, forewardScanCode, isBackwardKeyModifier)

    if isBackwardKeyModifier == nil
    then
	isBackwardKeyModifier = true
    end

    local object =
    {
	modifierKey	= modifierScanCode,
	advanceKey	= forewardScanCode,
	reverseKey	= backwardScanCode,
	reverseModifier	= isBackwardKeyModifier,

	requireModifierButton = true,
	sequenceInProgress    = false
    }
    setmetatable(object, self);
    self.__index = self
    return object
end

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    TabNavigationSequence = mod
end

return mod
