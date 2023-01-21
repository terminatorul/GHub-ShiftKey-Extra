
; Page Up and Peage Down with:
;	F24 + Scroll Wheel
;
; Change volume with:
;	F24 + F23 + Scroll Wheel

; Configure the Logitech G600 to:
;   - send F24 on G-Shift key press
;   - send F23 on right-click (button 2) press

global GShiftKeyPressed := GetKeyState("F24")
global RightButtonPressed := GetKeyState("F23")

$F23::
{
    global RightButtonPressed

    if RightButtonPressed
	return

    RightButtonPressed := true
}

$F23 UP::
{
    global RightButtonPressed

    if RightButtonPressed
	RightButtonPressed := false
}

$F24::
{
    global GShiftKeyPressed

    if GShiftKeyPressed
	return

    GShiftKeyPressed := true
}

$F24 UP::
{
    global GShiftKeyPressed

    if GShiftKeyPressed
	GShiftKeyPressed := false
}

*WheelUp::
{
    global GShiftKeyPressed
    global RightButtonPressed

    if GShiftKeyPressed
	if RightButtonPressed
	    SendEvent "{Volume_Up}"
	else
	    SendEvent "{PgUp}"
    else
	SendEvent "{WheelUp}"
}

*WheelDown::
{
    global GShiftKeyPressed
    global RightButtonPressed

    if GShiftKeyPressed
	if RightButtonPressed
	    SendEvent "{Volume_Down}"
	else
	    SendEvent "{PgDn}"
    else
	SendEvent "{WheelDown}"
}

