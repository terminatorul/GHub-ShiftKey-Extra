--
-- These values match a G600 mouse from Logitech
--

local mod =
{
    G1  =  1,
    G2  =  2,
    G3  =  3,
    G4  =  4,
    G5  =  5,
    G6  =  6,
    G7  =  7,
    G8  =  8,
    G9  =  9,
    G10 = 10,
    G12 = 12,
    G13 = 13,
    G14 = 14,
    G15 = 15,
    G16 = 16,
    G17 = 17,
    G18 = 18,
    G19 = 19,
    G20 = 20
}

mod.LeftButton   = mod.G1
mod.RightButton  = mod.G2
mod.MiddleButton = mod.G3
mod.ScrollLeft   = mod.G4
mod.ScrollRight  = mod.G5
mod.GShiftButton = mod.G6
mod.DPICycle	 = mod.G7
mod.ProfileCycle = mod.G8

mod.LowerRow  = 1
mod.MiddleRow = 2
mod.UpperRow  = 3

mod.FrontColumn	      = 1
mod.MiddleFrontColumn = 2
mod.MiddleBackColumn  = 3
mod.BackColumn	      = 4

mod.KeyPad =
{
    [mod.UpperRow]  = { [mod.FrontColumn] = mod.G11, [mod.MiddleFrontColumn] = mod.G14, [mod.MiddleBackColumn] = mod.G17, [mod.BackColumn] = mod.G20 },
    [mod.MiddleRow] = { [mod.FrontColumn] = mod.G10, [mod.MiddleFrontColumn] = mod.G13, [mod.MiddleBackColumn] = mod.G16, [mod.BackColumn] = mod.G19 },
    [mod.LowerRow]  = { [mod.FrontColumn] = mod.G9,  [mod.MiddleFrontColumn] = mod.G12, [mod.MiddleBackColumn] = mod.G15, [mod.BackColumn] = mod.G18 }
}

mod.MOUSE_BUTTON_PRESSED  = "MOUSE_BUTTON_PRESSED"
mod.MOUSE_BUTTON_RELEASED = "MOUSE_BUTTON_RELEASED"

-- See Scripting API document from G Hub mouse software (G-series Lua API.pdf) for the complete list
--
mod.ScanCodes =
{
    Escape      = 0x01,

    F1		= 0x3b,
 -- ...
 -- ...
 -- ...
    F10		= 0x44,

    F11		= 0x57,
    F12		= 0x58,

    F13		= 0x64,
 -- ...
 -- ...
 -- ...
    F23		= 0x6e,

    F24		= 0x76,

    PrintScreen = 0x76,
    Digit1	= 0x02,
 -- ...
 -- ...
 -- ...
    Digit0	= 0x0b,
    Backspace   = 0x0e,
    Enter	= 0x1c,
    LeftAlt	= 0x38,
    Spacebar	= 0x39,
    LeftControl = 0x1d,
    LeftShift	= 0x2a,
    LGui	= 0x15b,
    Tab		= 0x0f,
    PageUp	= 0x149,
    PageDown	= 0x151,
    Insert	= 0x152,
    Delete	= 0x153,
    End		= 0x14f,
    Home	= 0x147,
    Up		= 0x148,
    Left	= 0x14b,
    Down	= 0x150,
    Right	= 0x14d
}

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    GHubDefs = mod
end

return mod
