--
-- Main file connecting all the mappings
--

local sourceDirectory = debug.getinfo(1).source:match("@?(.*[/\\])") or ""

dofile(sourceDirectory .. "lua/strict.lua")
dofile(sourceDirectory .. "lua/GHubDefs.lua")
dofile(sourceDirectory .. "lua/BaseHandlerTable.lua")
dofile(sourceDirectory .. "lua/ModifierState.lua")
dofile(sourceDirectory .. "lua/DeviceEventHandler.lua")
dofile(sourceDirectory .. "lua/DirectKeyMap.lua")
dofile(sourceDirectory .. "lua/DirectKeyMapOverride.lua")
dofile(sourceDirectory .. "lua/DirectMouseButtonMap.lua")
dofile(sourceDirectory .. "lua/OneShotKeyCombinationMap.lua")
dofile(sourceDirectory .. "lua/DirectMacroMap.lua")
dofile(sourceDirectory .. "lua/OneShotMacroMap.lua")
dofile(sourceDirectory .. "lua/TabNavigationSequence.lua")

local G_Shift_Button			  = GHubDefs.GShiftButton
local Second_Shift_Button		  = GHubDefs.RightButton
local Pseudo_Tab_Button_for_Alt_Tab	  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.BackColumn]
local Pseudo_Tab_Button_for_Control_Tab   = GHubDefs.KeyPad[GHubDefs.MiddleRow][GHubDefs.MiddleFrontColumn]
local Volume_Down_and_Page_Down_Button    = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.MiddleFrontColumn]
local Volume_Up_and_End_Button		  = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.MiddleBackColumn]
local Redo_and_Page_Up_Button		  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.MiddleFrontColumn]
local Undo_and_Home_Button		  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.MiddleBackColumn]
local Back_and_Control_Tab_Button	  = Pseudo_Tab_Button_for_Control_Tab
local Minimize_Maximize_Button		  = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.FrontColumn]
local Delete_Backspace_Button		  = GHubDefs.KeyPad[GHubDefs.UpperRow ][GHubDefs.FrontColumn]
local Wheel_Click_Button		  = GHubDefs.MiddleButton
local Tab_Space_Button			  = GHubDefs.KeyPad[GHubDefs.MiddleRow][GHubDefs.FrontColumn]
local Playback_Control_Button		  = GHubDefs.KeyPad[GHubDefs.MiddleRow][GHubDefs.MiddleBackColumn]
local Scroll_Left_and_App_Tab_Button	  = GHubDefs.KeyPad[GHubDefs.LowerRow ][GHubDefs.BackColumn]
local Scroll_Right_and_App_Tab_Button	  = GHubDefs.KeyPad[GHubDefs.MiddleRow][GHubDefs.BackColumn]

local GShiftState        = ModifierState:new()
local SecondShiftState   = ModifierState:new()
local GShiftF24Map	 = DirectKeyMapOverride:new(GHubDefs.ScanCodes.F24)
local RightButtonF23Map  = DirectKeyMapOverride:new(GHubDefs.ScanCodes.F23)
local RaiseVolumeMap     = DirectMacroMap:new("Raise Volume")
local LowerVolumeMap     = DirectMacroMap:new("Lower Volume")
local SecondShiftMap	 = DirectMouseButtonMap:new(GHubDefs.MouseButtonLocation.Right)
local EndKeyMap		 = DirectKeyMap:new(GHubDefs.ScanCodes.End)
local HomeKeyMap	 = DirectKeyMap:new(GHubDefs.ScanCodes.Home)
local CtrlEndMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.End)
local CtrlHomeMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.Home)
local CutMap		 = OneShotMacroMap:new("Cut 1")
local UndoMap	         = OneShotMacroMap:new("Ctrl+Z")
local RedoMap	         = OneShotMacroMap:new("Ctrl+Y")
local AltTabSequence     = TabNavigationSequence:new(GHubDefs.ScanCodes.LeftAlt,     GHubDefs.ScanCodes.LeftShift, GHubDefs.ScanCodes.Tab)
local ControlTabSequence = TabNavigationSequence:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.LeftShift, GHubDefs.ScanCodes.Tab)
local App2TabSequence	 = TabNavigationSequence:new(GHubDefs.ScanCodes.LeftGui,     GHubDefs.ScanCodes.LeftShift, GHubDefs.ScanCodes.Digit2)
local GoBackKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftAlt,  GHubDefs.ScanCodes.Left)
local MinimizeMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftGui,  GHubDefs.ScanCodes.Down)
local MaximizeMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftGui,  GHubDefs.ScanCodes.Up)
local DeleteKeyMap	 = DirectKeyMap:new(GHubDefs.ScanCodes.Delete)
local BackspaceKeyMap	 = DirectKeyMap:new(GHubDefs.ScanCodes.Backspace)
local GoUpKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftAlt,	GHubDefs.ScanCodes.Up)
local SaveKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.S)
local OpenKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.O)
local NewTabKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl, GHubDefs.ScanCodes.T)
local TabKeyMap		 = DirectKeyMap:new(GHubDefs.ScanCodes.Tab)
local SpaceKeyMap	 = DirectKeyMap:new(GHubDefs.ScanCodes.Spacebar)
local PlaybackControlMap = DirectMacroMap:new("Play Pause")
local ScrollLeftMap	 = DirectMacroMap:new("Scroll Left")
local ScrollRightMap	 = DirectMacroMap:new("Scroll Right")

GShiftState:registerWith(DeviceEventHandler, DeviceEventHandler, G_Shift_Button)
GShiftF24Map:registerWith(G_Shift_Button)
RightButtonF23Map:registerWith(GHubDefs.RightButton)
SecondShiftMap:registerWith(DeviceEventHandler, Second_Shift_Button)
SecondShiftState:registerWith(DeviceEventHandler, GShiftState, Second_Shift_Button)
DirectKeyMapOverride:registerOverrides(DeviceEventHandler)

GoBackKeyMap:registerWith(DeviceEventHandler, Back_and_Control_Tab_Button)
CtrlEndMap:registerWith(SecondShiftState, Volume_Down_and_Page_Down_Button)
CtrlHomeMap:registerWith(SecondShiftState, Redo_and_Page_Up_Button)
EndKeyMap:registerWith(SecondShiftState, Volume_Up_and_End_Button)
HomeKeyMap:registerWith(SecondShiftState, Undo_and_Home_Button)
LowerVolumeMap:registerWith(GShiftState, Volume_Down_and_Page_Down_Button)
RaiseVolumeMap:registerWith(GShiftState, Volume_Up_and_End_Button)
CutMap:registerWith(SecondShiftState, Back_and_Control_Tab_Button)
UndoMap:registerWith(GShiftState, Undo_and_Home_Button)
RedoMap:registerWith(GShiftState, Redo_and_Page_Up_Button)
AltTabSequence:registerWith(DeviceEventHandler, GShiftState, Pseudo_Tab_Button_for_Alt_Tab, Pseudo_Tab_Button_for_Control_Tab)
ControlTabSequence:registerWith(GShiftState, Pseudo_Tab_Button_for_Control_Tab, Pseudo_Tab_Button_for_Alt_Tab)
App2TabSequence:registerWith(SecondShiftState, Scroll_Left_and_App_Tab_Button, Scroll_Right_and_App_Tab_Button)
MinimizeMap:registerWith(GShiftState, Minimize_Maximize_Button)
MaximizeMap:registerWith(SecondShiftState, Minimize_Maximize_Button)
DeleteKeyMap:registerWith(GShiftState, Delete_Backspace_Button)
BackspaceKeyMap:registerWith(SecondShiftState, Delete_Backspace_Button)
GoUpKeyMap:registerWith(GShiftState, Wheel_Click_Button)
SaveKeyMap:registerWith(SecondShiftState, Wheel_Click_Button)
TabKeyMap:registerWith(GShiftState, Tab_Space_Button)
SpaceKeyMap:registerWith(SecondShiftState, Tab_Space_Button)
PlaybackControlMap:registerWith(GShiftState, Playback_Control_Button)
OpenKeyMap:registerWith(SecondShiftState, Playback_Control_Button)
NewTabKeyMap:registerWith(DeviceEventHandler, GHubDefs.KeyPad[GHubDefs.UpperRow][GHubDefs.MiddleBackColumn])
ScrollLeftMap:registerWith(GShiftState, Scroll_Left_and_App_Tab_Button)
ScrollRightMap:registerWith(GShiftState, Scroll_Right_and_App_Tab_Button)
