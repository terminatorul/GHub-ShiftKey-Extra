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
local GoBackKeyMap	 = OneShotKeyCombinationMap:new(GHubDefs.ScanCodes.LeftControl,  GHubDefs.ScanCodes.Minus)

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
