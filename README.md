# GHub-ShiftKey-Extra
 Use scripting to add a second Shift (Modifier) Key to G600 mouse in G Hub software, use a Shift key for Alt+Tab navigation with the mouse

## About
 This Lua script can be loaded in the G600 mouse software -- Logitech G Hub -- to implement a second Shift Key (modifier key) on the mouse, to be used together with the default GShift key on the mouse, to create even more mappings on the mouse for the side pad.

## Installation
 - Clone this repository and get the resulting directory, in my case `C:\Local\Projects\GHub-ShiftKey-Extra\`
 - Open Logitech G Hub software as usual and select the profile from the top of the first screen.
 - Click on the little round "scripting" icon underneath the tiles representing existing profiles in the group.
 - Enter a name and description for the script, like `Work -- Extra Mappings`
 - Copy the following lines to load the script files from the repository:
```lua

dofile("C:\\Local\\Projects\\GHub-ShiftKey-Extra\\DeviceMapping.lua")

function OnEvent(event, arg)
    -- OutputLogMessage("Event: "..event.." Arg: "..arg.."\n")

    DeviceEventHandler:invokeHandler(event, arg)
end

```
 - Update the directory name above to match your location. Save the script with Ctrl+S and watch for output messages in the script window, to make sure the directory is found.
 - For mappings for macOS (which I use in a virtual machine), replace `DeviceMapping.lua` above with `DeviceMappingsMacOS.lua`.

## Configuration
Open this top-level script file `DeviceMapping.lua`. Although it is a script file in lua, it also works as the mouse configuration file. In here all mappings are created and connected to the mouse buttons. Mouse button IDs for Logitech G600, plus standard keyboard scan codes, are found in file `lua/GHubDefs.lua`. The pre-defined configuration looks like:

```lua
local G_Shift_Button			  = GHubDefs.GShiftButton
local Second_Shift_Button		  = GHubDefs.RightButton
local Pseudo_Tab_Button_for_Alt_Tab	  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.BackColumn]
local Pseudo_Tab_Button_for_Control_Tab   = GHubDefs.KeyPad[GHubDefs.MiddleRow][GHubDefs.MiddleFrontColumn]
local Volume_Down_and_Page_Down_Button    = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.MiddleFrontColumn]
local Volume_Up_and_End_Button		  = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.MiddleBackColumn]
local Redo_and_Page_Up_Button		  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.MiddleFrontColumn]
local Undo_and_Home_Button		  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.MiddleBackColumn]
local Back_and_Control_Tab_Button	  = Pseudo_Tab_Button_for_Control_Tab

local GShiftState        = ModifierState:new()
local SecondShiftState   = ModifierState:new()
local PageDownKeyMap     = DirectKeyMap:new(GHubDefs.ScanCodes.PageDown)
local PageUpKeyMap       = DirectKeyMap:new(GHubDefs.ScanCodes.PageUp)
local RaiseVolumeMap     = DirectMacroMap:new("Raise Volume")
local LowerVolumeMap     = DirectMacroMap:new("Lower Volume")
local EndKeyMap		 = DirectKeyMap:new(GHubDefs.ScanCodes.End)
local HomeKeyMap	 = DirectKeyMap:new(GHubDefs.ScanCodes.Home)
local CutMap		 = OneShotMacroMap:new("Cut 1")
local UndoMap	         = OneShotMacroMap:new("Ctrl+Z")
local RedoMap	         = OneShotMacroMap:new("Ctrl+Y")
local AltTabSequence     = TabNavigationSequence:new(GHubDefs.ScanCodes.LeftAlt,     GHubDefs.ScanCodes.LeftShift, GHubDefs.ScanCodes.Tab)
local ControlTabSequence = TabNavigationSequence:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.LeftShift, GHubDefs.ScanCodes.Tab)
local GoBackKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftAlt,  GHubDefs.ScanCodes.Left)

GShiftState:registerWith(DeviceEventHandler, DeviceEventHandler, GHubDefs.GShiftButton)
SecondShiftState:registerWith(DeviceEventHandler, GShiftState, GHubDefs.RightButton)

GoBackKeyMap:registerWith(DeviceEventHandler, Back_and_Control_Tab_Button)
PageDownKeyMap:registerWith(SecondShiftState, Volume_Down_and_Page_Down_Button)
PageUpKeyMap:registerWith(SecondShiftState, Redo_and_Page_Up_Button)
EndKeyMap:registerWith(SecondShiftState, Volume_Up_and_End_Button)
HomeKeyMap:registerWith(SecondShiftState, Undo_and_Home_Button)
LowerVolumeMap:registerWith(GShiftState, Volume_Down_and_Page_Down_Button)
RaiseVolumeMap:registerWith(GShiftState, Volume_Up_and_End_Button)
CutMap:registerWith(SecondShiftState, Back_and_Control_Tab_Button)
UndoMap:registerWith(GShiftState, Undo_and_Home_Button)
RedoMap:registerWith(GShiftState, Redo_and_Page_Up_Button)
AltTabSequence:registerWith(DeviceEventHandler, GShiftState, Pseudo_Tab_Button_for_Alt_Tab, Pseudo_Tab_Button_for_Control_Tab)
ControlTabSequence:registerWith(GShiftState, Pseudo_Tab_Button_for_Control_Tab, Pseudo_Tab_Button_for_Alt_Tab)
```

Create a new modifier key by following 2 steps:
 - declare an object of type ModifierKey, for example: `local SecondShiftState = ModifierState:new()`
 - register the object with either the `DeviceEventHandler`, either a previously declared ModifierKey object, and name one of the mouse buttons to act as the new shift key. For example:

```lua
GShiftState:registerWith(DeviceEventHandler, DeviceEventHandler, GHubDefs.GShiftButton)
SecondShiftState:registerWith(DeviceEventHandler, GShiftState, GHubDefs.RightButton)
```

Adding a new mappings by following 3 steps:
 - declare a mouse key (or keys) that will be mapped to the new function, for example
    `GHubDefs.KeyPad[GHubDefs.UpperRow][GHubDefs.BackColumn]`
 - declare one of the below mapping types, using the above key as the argument, for example `local GoBackKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftAlt, GHubDefs.ScanCodes.Left)`
 - register the mapping with either the `DeviceEventHandler`, either a previously declared ModifierState object

These mappings use keyboard scan codes to press and release keys from the keyboard, which are translated to characters by the operating system according to the current keyboard layout. Scancodes are declared here using the "name" of the corresponding keys on the English US keyboard layout. Other layouts may produces different characters then the standard scancode indicates.

You can see available classes to create new mappings are:

 - **ModifierState**
    - represents a Shift (modifier) button on the mouse, and holds key event handlers for mappings enabled by the sfhift key. You should declare a `ModifierState` object for the default `GShfit` key on the mouse as well
 - **DirectKeyMap**
     - maps a sigle key to one of the mouse buttons, that will be pressed when the button is pressed, and will be released when the button is released
 - **OneShotKeyCombinationMap**
     - maps as simple key combination with a single modifier key (Shift, Alt, ...) to a single button press on the mouse. The key is pressed once when the mouse button is pressed, and is not held down while the button is held down.
 - **DirectMacroMap**
     - maps a macro available in the G Hub software UI to one of the mouse buttons. The "On press" sequence of the macro runs when the mouse button is pressed, the "While Holding" sequence runs when the mouse button is held down, and the "On release" sequence runs when the button si released.

 - **OneShotMacroMap**
     - maps a macro available in the G Hub software UI to one of the mouse buttons. The macro runs only once when the button is pressed and will not keep running while the button is held down
- **TabNavigationSequence**
     - maps a combination of a modifier button with some other button, to a corresponding modifier key on the keyboard with another keyboard key. Used to implement on the mouse behavior very similiar to the `Alt+Tab` sequence on the keyboard, or `Contrl+Tab` sequence (used in Firefox, Visual Studio, IntelliJ IDEA or other multi-document applications).

All the mappings and `ModifierState` objects that are created have to be registered "with" either:
 - the single `DeviceEventHandler` object, for direct mappings on the mouse buttons without a modifier key
 - other `ModifierState` objects, for mappings that use mouse buttons with the modifier key

All macro names used (mapped) in the script (in the default example above these would be `Raise Volume`, `Lower Volume`, `Cut 1`, `Ctrl+Z` and `Ctrl+Y`) have to be (manually) created in G Hub softwate user interface, for the script to be able to run them.

Actions attached to mouse buttons in the script will execute at the same time with any actions mapped in the user interface. To avoid conflicting or duplicate actions, make sure you create and assign "empty" macros in the UI for buttons used in the script. To create an empy macro add a Delay with a value of 0ms. Give an appropriate name to the macro to reflect what the button really does in the script. This way you can have a visual images of all the button mappins in the UI even if ssimply ome mappings are "hidden" in the script file.

In this example we create a second Shift Key (modifier button), that is in our example `GShift + RightButton`. So now you can map:
 - `GShift + RightButton + G12` to `Page Up` key
 - `GShift + RightButton + G14` to `Page Down` key
 - `GShift + RightButton + G15` to `End` key
 - `GShift + RightButton + G27` to `Home` key
 - and so on...

This examples creates new mappings only for some of the mouse buttons, the others are mapped in the GHub Software UI and are not used in this script.

You can select your own keys and buttons used in the mapping by modifying the example top-level script file. Make sure to save the loader script excerpt in the G Hub scripting window, in order to activate (load) and validate the new script changes.

The `TabNavigationSequence` allow you to implement window list navigation and selection with `Alt+Tab` and `Alt+Shift+Tab` (and ``Alt+` ``for macOS) entirely on the mouse. The sequence uses one of the modifier keys, plus one of the other buttons. But unlike the keyboard usage, you can open the navigation pop-up with a single button press (without the modifier). This results in an immediate switch. Or you can hold the button and choose to use the modifier if you want to navigate the list. When you hold the "action" button (Tab equivalent) you can switch to holding the modifier button instead, if you can briefly press them both at the same time, then release the "action" button. Later you can switch back to holding the "action" button by briefly pressing again both of the buttons. That is, the `Alt+Tab` selection is only made if you release both the modifier and the navigation keys. You can use this to switch from the forward navigation button (Tab equivalent) to the reverse navigation button (Shift+Tab) equivalent, as well.

In this case you should register the `TabNavigationSequence` object with both the `DeviceEventHandler` for the direct key press, and one of the `ShiftState` objects for the modifier key. 

Or you can register the `TabNavigationSequence` object with a single `ShfitState` object only, and then Tab navigation can only be initiated and used with the modifier key (not by a direct key press). This way the navigation feels closer to the way it works on the keyboard.

You should make an effort not to enter errors in the script file, and test after every little change you make, as some errors are pretty difficult understand.
