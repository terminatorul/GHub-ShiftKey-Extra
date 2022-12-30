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
    G11 = 11,
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

mod.MouseButtonLocation =
{
    Left    = 1,
    Middle  = 2,
    Right   = 3,
    X1	    = 4,
    X2	    = 5
}

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
    Escape       = 0x01,

    F1		 = 0x3b,
    F2		 = 0x3c,
    F3		 = 0x3d,
    F4		 = 0x3e,
    F5		 = 0x3f,
    F6		 = 0x40,
    F7		 = 0x41,
    F8		 = 0x42,
    F9		 = 0x43,
    F10		 = 0x44,
    F11		 = 0x57,
    F12		 = 0x58,

    F13		 = 0x64,
    F14		 = 0x65,
    F15		 = 0x66,
    F16		 = 0x67,
    F17		 = 0x68,
    F18		 = 0x69,
    F19		 = 0x6a,
    F20		 = 0x6b,
    F21		 = 0x6c,
    F22		 = 0x6d,
    F23		 = 0x6e,
    F24		 = 0x76,

    PrintScreen  = 0x137,
    ScrollLock	 = 0x46,
    Pause	 = 0x146,
    Tilde	 = 0x29,
    Digit1	 = 0x02,
    Digit2	 = 0x03,
    Digit3	 = 0x04,
    Digit4	 = 0x05,
    Digit5	 = 0x06,
    Digit6	 = 0x07,
    Digit7	 = 0x08,
    Digit8	 = 0x09,
    Digit8	 = 0x0a,
    Digit0	 = 0x0b,
    Minus	 = 0x0c,
    Equal	 = 0x0d,
    Backspace    = 0x0e,
    Enter	 = 0x1c,
    LeftAlt	 = 0x38,
    Spacebar	 = 0x39,
    LeftControl  = 0x1d,
    LeftShift	 = 0x2a,
    LeftGui	 = 0x15b,
    Tab		 = 0x0f,
    PageUp	 = 0x149,
    PageDown	 = 0x151,
    Insert	 = 0x152,
    Delete	 = 0x153,
    End		 = 0x14f,
    Home	 = 0x147,
    Up		 = 0x148,
    Left	 = 0x14b,
    Down	 = 0x150,
    Right	 = 0x14d,

    Q		 = 0x10,
    W		 = 0x11,
    E		 = 0x12,
    R		 = 0x13,
    T		 = 0x14,
    Y		 = 0x15,
    U		 = 0x16,
    I		 = 0x17,
    O		 = 0x18,
    P		 = 0x19,
    LeftBracket  = 0x1a,
    RightBracket = 0x1b,
    BackSlash	 = 0x2b,
    CapsLock	 = 0x3a,
    A		 = 0x1e,
    S		 = 0x1f,
    D		 = 0x20,
    F		 = 0x21,
    G		 = 0x22,
    H		 = 0x23,
    J		 = 0x24,
    K		 = 0x25,
    L		 = 0x26,
    SemiColon	 = 0x27,
    Quote	 = 0x28,
    NonUSSlash	 = 0x56,
    Z		 = 0x2c,
    X		 = 0x2d,
    C		 = 0x2e,
    V		 = 0x2f,
    B		 = 0x30,
    N		 = 0x31,
    M		 = 0x32,
    Comma	 = 0x33,
    Period	 = 0x34,
    Slash	 = 0x35,
    RightShift	 = 0x36,
    RightAlt	 = 0x138,
    RightGui	 = 0x15c,
    AppKey	 = 0x15d,
    RightControl = 0x11d,
    NumLock	 = 0x45,
    Numeric7	 = 0x47,
    Numeric8	 = 0x48,
    Numeric9	 = 0x49,
    NumericSlash = 0x135,
    NumericMinus = 0x4a,
    NumericPlus	 = 0x4e,
    Numeric4	 = 0x4b,
    Numeric5     = 0x4c,
    Numeric6	 = 0x4d,
    Numeric1	 = 0x4f,
    Numeric2	 = 0x50,
    Nuemric3	 = 0x51,
    NumericEnter = 0x11c,
    Numeric0	 = 0x52,
    NumericPeriod = 0x53
}

if _REQUIREDNAME
then
    _G[_REQUIREDNAME] = mod
else
    GHubDefs = mod
end

return mod
