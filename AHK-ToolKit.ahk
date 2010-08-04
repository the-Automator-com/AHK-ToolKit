/*
Author:         RaptorX	<graptorx@gmail.com>
Script Name:    AHK-ToolKit
Script Version: 0.3.1
Homepage:

Creation Date: July 11, 2010 | Modification Date: August 04, 2010

[GUI Number Index]

GUI 01 - Main [AHK-ToolKit]
GUI 99 - PasteBin Popup
GUI 98 - Send to PasteBin
GUI 97 - Pastebin Success Popup
GUI 96 - Add Hotkey
GUI 50 - First Run
*/

;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
SetBatchLines -1
; --
SendMode Input
SetWorkingDir %A_ScriptDir%
onExit, Clean
;-

;+--> ; ---------[Basic Info]---------
s_name      := "AutoHotkey ToolKit"     ; Script Name
s_version   := "0.3.1"                  ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
;-

;+--> ; ---------[General Variables]---------
sec         :=  1000                    ; 1 second
min         :=  sec * 60                ; 1 minute
hour        :=  min * 60                ; 1 hour
; --
SysGet, mon, Monitor                    ; Get the boundaries of the current screen
SysGet, wa_, MonitorWorkArea            ; Get the working area of the current screen
mid_scrw    :=  a_screenwidth / 2       ; Middle of the screen (width)
mid_scrh    :=  a_screenheight / 2      ; Middle of the screen (heigth)
; --
s_ini       := ; Optional ini file
s_xml       := "res\ahk_tk.xml"         ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
Clipboard :=
FileRead, ahk_keywords, res\key.lst     ; Used for the PasteBin routines
reg_run := "Software\Microsoft\Windows\CurrentVersion\Run"
mod_list := "mod_ctrl|mod_alt|mod_shift|mod_win"
hs_optlist := "hs_iscommand|hs_dnd|hs_trigger|hs_raw"
exc := "ScrollLock|CapsLock|NumLock|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft"
. "|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel|LWin|RWin|LControl"
. "|RControl|LShift|RShift|LAlt|RAlt|CtrlBreak|Control|Alt|Shift|AppsKey"
keylist := "None||" . klist(2,0,1, exc)
hsloc := "res\tools\hslauncher.ahk"

; Live Code Scripts
;{
live_code =
(
; **************************************************************************
; * All live scripts start with the following default options:             *
; * #NoEnv, #Persistent, SendMode Input, SetbatchLines -1 and Esc::ExitApp *
; *                                                                        *
; * You can enable change them  at any time using the normal options       *
; * (e.g.'SendMode Play' to override the SendMode)                         *
; **************************************************************************`n`n
)

TimedShutdown_s =
(
; ********************************************************************************
; All Live Code scripts can use the variables 'sec' 'min' and 'hour'
;
; The following script schedules a shutdown on the specified time.
; Note that we need to divide by 1000 because the shutown command
; only accepts seconds while our variables return milliseconds.
;
; Also as we are dividing, time would return a decimal number
; so we need to get rid of the '.000000' before passing it to the shutdown command
; ********************************************************************************

time := RegexReplace(time:=(1*hour + 30*min + 15*sec)/1000,"\.\d+","")
Run, Shutdown -s -t `%time`% -f
)

SaveXYCoords_s =
(
; ********************************************************************************
; This script saves X and Y coordinates in a file every time you click.
; Very useful for quickly determining positions on the screen or to record several
; x y positions to be parsed later on by a macro which would click those positions
; automatically.
;
; Use the Right Mouse button or the Esc key to exit the application.
; ********************************************************************************

CoordMode, Mouse, Screen
s_file := a_desktop . "\xy-coords.txt"		; Change as desired

Loop
{
	MouseGetPos, X, Y
	ToolTip, x`%X`% - y`%Y`%					; Tooltip to make everything easier
	Sleep 10
}

LButton::FileAppend, `%X`%``,`%Y`%``n, `%s_file`%   ; Save coords to parse e.g. 300,400
RButton::
Esc::ExitApp
)

TextControlsRefs_s =
(
; ********************************************************************************
; This Script is just a demostration of the styles that you can apply to
; Text controls.
;
; To apply a style just write the code like this:
; Gui, add, Text, [options] [style]
; Ex. Gui, add, Text, w50 h50 x20 y25 0x4
;
; As you can see this opens tons of posibilities in your Gui Creation and with
; enough creativity you can create cool interfaces!
; Dont limit yourself to the defaults!
;
; Created by RaptorX
; **Press Esc to close the Aplication
; ********************************************************************************

; --[Main]------------------------------------------------------------------------

0x4=
(
Specifies a rectangle filled with the current *window frame* color.
This color is BLACK in the default color scheme.
`)
0x5=
`(
Specifies a rectangle filled with the current *screen background* color.
This color is GRAY in the default color scheme.
`)
0x6=
`(
Specifies a rectangle filled with the current *window background* color.
This color is WHITE in the default color scheme.
`)
0x7=
`(
Specifies a box with a frame drawn in the same color as the
*window frames*. This color is BLACK in the default color scheme.
`)
0x8=
`(
Specifies a box with a frame drawn with the same color as the *screen
background* (desktop). This color is GRAY in the default color scheme.
`)
0x9=
`(
Specifies a box with a frame drawn with the same color as the *window
background*. This color is WHITE in the default color scheme.
`)
0x10=
`(
Draws the top and bottom edges of the static control using the
EDGE_ETCHED edge style.
`)
0x11=
`(
Draws the left and right edges of the static control using the
EDGE_ETCHED edge style.
`)
0x12=
`(
Draws the frame of the static control using the
EDGE_ETCHED edge style.
`)
0x1000=
`(
Draws a half-sunken border around a static control.
`)

Desc=
`(
This Script is just a demostration of the styles that you can apply to Text controls.

To apply a style just write the code like this: Gui, add, Text, [options] [style]
Ex. Gui, add, Text, w50 h50 x20 y25 0x4

As you can see this opens tons of posibilities in your Gui Creation and with enough creativity you can create cool interfaces!
Dont limit yourself to the defaults!

**Press Esc to close the Aplication
`)

Gui, add, Text, w50 h50 x20 y25 0x4
Gui, add, Text, wp hp y+32 0x5
Gui, add, Text, wp hp y+32 0x6
Gui, add, Text, wp hp y+32 0x7
Gui, add, Text, wp hp y+32 0x8
Gui, add, Text, x450 y25 wp hp 0x9
Gui, add, Text, wp hp y+52 0x10
Gui, add, Text, wp hp xp+20 y+12 0x11
Gui, add, Text, wp hp xp-20 y+32 0x12
Gui, add, Text, wp hp y+32 0x1000

Gui, add, Groupbox, w420 h75 x10 y10,0x4
Gui, add, Groupbox, wp hp,0x5
Gui, add, Groupbox, wp hp,0x6
Gui, add, Groupbox, wp hp,0x7
Gui, add, Groupbox, wp hp,0x8
Gui, add, Groupbox, x440 y10 wp hp,0x9
Gui, add, Groupbox, wp hp,0x10
Gui, add, Groupbox, wp hp,0x11
Gui, add, Groupbox, wp hp,0x12
Gui, add, Groupbox, wp hp,0x1000

Gui, add, Text, x80 y35, `%0x4`%
Gui, add, Text,y+60, `%0x5`%
Gui, add, Text,y+55, `%0x6`%
Gui, add, Text,y+55, `%0x7`%
Gui, add, Text,y+55, `%0x8`%
Gui, add, Text,x510 y35, `%0x9`%
Gui, add, Text,y+60, `%0x10`%
Gui, add, Text,y+55, `%0x11`%
Gui, add, Text,y+55, `%0x12`%
Gui, add, Text,y+60, `%0x1000`%
; --[Description]-----------------------------------------------------------------
Gui, add, Text, w750 x60 0x10
Gui, add, Text, w850 h150 xp-50 yp+7 0x7
Gui, add, Text, w840 hp-10 xp+5 yp+5 0x8
Gui, add, Text, w800 xp+5 yp+5, `%desc`%
Gui, add, Text, w50 h50 x+-150 yp+10 0x4
Gui, add, Text, w50 h50 x+5 0x5
Gui, add, Text, w50 h50 x670 y+5 0x7
Gui, add, Text, w50 h50 x+5 0x6

Gui show

GuiClose:
~*Esc::ExitApp
)

;}

; Resources folder
if !FileExist("res")
{
    FileCreateDir, res\tools
    FileInstall, res\key.lst, res\key.lst, 1
    FileInstall, res\tools\rh.exe, res\tools\rh.exe, 1
}

;First Run GUI
if !load := xpath_load(xml, s_xml)
{
    Gui, 50: add, Text,x10, % "This is the first time that you run AHK-Toolkit.`n"
                            . "Please Take a few seconds to setup some initial options.`n"
    Gui, 50: Font, cBlue
    Gui, 50: add, Text,x10, % "Startup Options"
    Gui, 50: add, Text, w265 x+10 yp+7 0x10
    Gui, 50: Font
    Gui, 50: add, CheckBox, x10 Checked vsww, % "Start with Windows"
    Gui, 50: add, CheckBox, x10 vaus, % "AutoUpload copied scripts to:"
    Gui, 50: add, DropDownList, x+20 yp-2 vdef_aus, % "AutoHotkey.net||Pastebin.com|Paste2.org"
    Gui, 50: Font, cBlue
    Gui, 50: add, Text,x10 y+10, % "Main Gui Hotkey"
    Gui, 50: add, Text, w260 x+10 yp+7 0x10
    Gui, 50: Font
    Gui, 50: add, DropDownList, w160 x10 vddl_mainhkey,  % keylist
    Gui, 50: add, CheckBox, x+10 yp+3 vcb_mainctrl, % "Ctrl"
    Gui, 50: add, CheckBox, x+10 vcb_mainalt, % "Alt"
    Gui, 50: add, CheckBox, x+10 vcb_mainshift, % "Shift"
    Gui, 50: add, CheckBox, x+10 vcb_mainwin, % "Win"
    Gui, 50: Font, s7
    Gui, 50: add, Text,x10, % "Notes:`nIf no hotkey is selected the default `nwill be Win + ``  (Back Tic)`n`n"
                            . "If AutoUpload is selected the link for `nthe uploaded script will be copied to the "
                            . "clipboard"
    Gui, 50: add, Text, w370 x0 y+20 0x10
    Gui, 50: add, Button, w100 x260 yp+10 gFR_Save, Save
    Gui, 50: Show, w365, % "First Run"
    Pause
}

; Use ahk.exe if AutoHotkey is not installed
if !ahkexist
{
    FileCreateDir, res\ahk
    FileInstall, res\ahk\ahk.exe, res\ahk\ahk.exe, 1
}
;-

;+--> ; ---------[Main]---------
Gosub, ReadXML

; Hotkey Maker GUI[Main]
;{
Gui, add, Tab2, w620 h340 x0 y0, % "Hotkeys|Hotstrings|Live Code|Options"
Gui, add, StatusBar,, % "Add new hotkeys / hotstrings"

Gui, Tab, Hotkeys
Gui, add, ListView, w600 r15 Sort Grid AltSubmit gLV_Sub vLV_hklist, % "Type|Program Name|Hotkey|Program Path"
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x400 yp+10 Default gAddHotkey, % "&Add"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Tab, Hotstrings
Gui, add, ListView, w600 r9 Grid AltSubmit gLV_Sub vLV_hslist, % "Options|Abreviation|Expand To"
Gui, add, Text, y+10, % "Expand:"
Gui, add, Edit, w150 x+10 yp-3 vhs_expand
Gui, add, Text, x+10 yp+3, % "To:"
Gui, add, Edit, w250 x+10 yp-3 vhs_expandto
Gui, add, Checkbox, x510 yp+5 vhs_iscommand, % "Run Command"
Gui, add, CheckBox, x12 y+15 Checked vhs_autoexpand, % "AutoExpand"
Gui, add, CheckBox, x250 yp vhs_dnd, % "Do not delete typed abreviation"
Gui, add, CheckBox, x12 y+10 vhs_trigger, % "Trigger inside other words"
Gui, add, CheckBox, x250 yp vhs_raw, % "Send Raw (do not translate {Enter} or {key})"
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x400 yp+10 gAddHotstring, % "&Add"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Tab, Live Code
Gui, Font, s8, Courier New
Gui, add, Edit, w600 h215 WantTab T14 vlive_code, % live_code
Gui, Font
Gui, add, Text, y+5, % "Some small tools:"
Gui, add, Text, x+10 gTimedShutdown, % "Timed Shutdown"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Text, x+10 yp+2.5 gSaveXYCoords, % "Save X,Y coord list"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Text, x+10 yp+2.5 gTextControlsRefs, % "Text Controls Style Refs"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x195 yp+10 gLiveRun, % "&Run"
Gui, add, Button, w100 x+5 yp gLiveSavetoFile, % "&Save to File"
Gui, add, Button, w100 x+5 yp gLiveClear, % "Cl&ear"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Show, Hide ;w619 h341
SB_SetParts(150,150)
;}

; PasteBin Popup GUI
;{
Gui, 99: -Caption +Border +AlwaysOnTop +ToolWindow
Gui, 99: Font, s10 w600, Verdana
Gui, 99: add, Text, w250 x0 Center, % "AHK Code Detected"
Gui, 99: add, Text, w260 x0 0x10
Gui, 99: Font, s8 normal
Gui, 99: add, Text, w250 x5 yp+5, % "You have copied text that contains some AutoHotkey Keywords. `n`n"
                                  . "Do you want to upload it to a pastebin service?"
Gui, 99: add, Text, w260 x0 0x10
Gui, 99: add, Button, w60 h25 x10 yp+10 gPopYes, % "&Yes"
Gui, 99: add, Button, w60 h25 x+10 gPopNo, % "&No"
Gui, 99: add, CheckBox, x+10 yp+6 Checked%pastepop_ena% gDisablePopup vpastepop_ena, % "Enable Popup"
Gui, 99: Show, NoActivate w250 h150 x%monRight% y%monBottom%
WinGet, 99Hwnd, ID,, % "AHK Code Detected"

Gui, 99: Show, Hide ; w250 h150
;}

; Send To PasteBin GUI
;{
Gui, 98: Font, s8, Courier New
Gui, 98: add, Edit, w620 h400 WantTab T14 vahk_code
Gui, 98: Font
Gui, 98: add, Text, w650 x0 0x10
Gui, 98: add, GroupBox, w620 h80 x10 yp+5, % "Options"
Gui, 98: add, Text, xp+10 yp+20, % "Upload  to:"
Gui, 98: add, Text, x+83, % "Description / Post Title:"
Gui, 98: add, Text, x+25, % "Nick / Subdomain:"
Gui, 98: add, Text, x+45, % "Privacy:"
Gui, 98: add, Text, x+42, % "Expiration:"
Gui, 98: add, DropDownList, w125 x20 y+10 gDDL_Pastebin vddl_pastebin, % "AutoHotkey.net||Pastebin.com|Paste2.org"
Gui, 98: add, Edit, w125 x+10 vpb_name
Gui, 98: add, Edit, w125 x+10 vpb_subdomain
Gui, 98: add, DropDownList, w70 x+10 vpb_exposure Disabled, % "Public||Private"
Gui, 98: add, DropDownList, w115 x+10 vpb_expiration Disabled, % "Never|10 Minutes||1 Hour|1 Day|1 Month"
Gui, 98: add, Text, w650 x0 0x10
Gui, 98: add, Button, w100 h25 x315 yp+10 gPasteUpload, % "&Upload"
Gui, 98: add, Button, w100 h25 x+5 yp gPasteSavetoFile, % "&Save to File"
Gui, 98: add, Button, w100 h25 x+10 yp gGuiCancel, % "&Cancel"

Gui, 98: Show, Hide ; w640 h550
;}

; PasteBin Success Popup GUI
;{
Gui, 97: -Caption +Border +AlwaysOnTop +ToolWindow
Gui, 97: Font, s10 w600, Verdana
Gui, 97: add, Text, w250 x0 Center, % "Code Uploaded Succesfully"
Gui, 97: add, Text, w260 x0 0x10
Gui, 97: Font, s8 normal
Gui, 97: add, Text, w250 x5 yp+5, % "The code has been uploaded correctly.`n"
                                  . "The link has been copied to the clipboard"
Gui, 97: add, Text, w260 x0 0x10
Gui, 97: Show, NoActivate w250 h90 x1024 y768
WinGet, 97Hwnd, ID,, % "Code Uploaded Succesfully"

Gui, 97: Show, Hide ; w250 h90
;}

; Add Hotkey GUI
;{
Gui, 96: add, GroupBox, w400 h70, % "Select Program"
Gui, 96: add, Edit, w270 xp+10 yp+20 ve_progpath, %a_programfiles%
Gui, 96: add, Button, w100 x+10 Default gProgBrowse vBrowse, % "&Browse..."
Gui, 96: add, Radio, x110 y+5 Checked vr_selfof, % "Select a File"
Gui, 96: add, Radio,x+10, % "Select a Folder"
Gui, 96: add, GroupBox, w400 h70 x10, % "Select Hotkey"
Gui, 96: add, DropDownList, w200 xp+10 yp+30 vddl_key , % keylist
Gui, 96: add, CheckBox, x+10 yp+3 vmod_ctrl, % "Ctrl"
Gui, 96: add, CheckBox, x+10 vmod_alt, % "Alt"
Gui, 96: add, CheckBox, x+10 vmod_shift, % "Shift"
Gui, 96: add, CheckBox, x+10 vmod_win, % "Win"
Gui, 96: add, Text, w425 x0 y+35 0x10
Gui, 96: add, Button, w100 h25 x200 yp+10 gAddHotkey, % "&Add"
Gui, 96: add, Button, w100 h25 x+10 yp gGuiCancel, % "&Cancel"

Gui, 96: Show, Hide ; w420 h210
;}

Gosub, LVHK_Load
Gosub, LVHS_Load
Return ; End of autoexecute area
;-

;+--> ; ---------[Labels]---------
FR_Save:                                                            ; First Run Save
;{
 Gui, 50: Submit

 if cb_mainctrl
    mainctrl := "^"
 if cb_mainalt
    mainalt := "!"
 if cb_mainshift
    mainshift := "+"
 if cb_mainwin
    mainwin := "#"
 else if ddl_mainhkey = None
 {
    ddl_mainhkey := "``"
    mainwin := "#"
 }

 RegRead, ahkexist, HKLM, SOFTWARE\AutoHotkey, InstallDir
 Gosub, SWW                 ; Start with windows
 Gosub, AUInfo              ; Auto upload default info
 xpath(xml, "/root[+1]/@ahkexist/text()", ahkexist)
 xpath(xml, "/root/hotkeys[+1]")
 xpath(xml, "/root/hotstrings[+1]")
 xpath(xml, "/root/options[+1]")
 xpath(xml, "/root/options/AUS[+1]/@value/text()", aus)
 xpath(xml, "/root/options/AUS/@default/text()", def_aus)
 xpath(xml, "/root/options/SWW[+1]/@value/text()", sww)
 xpath(xml, "/root/options/MHK[+1]/@value/text()", mainctrl . mainalt . mainshift . mainwin . ddl_mainhkey)

 if def_aus = AutoHotkey.net
 {
    xpath(xml, "/root/options/AUS/AutoHotkey[+1]/@autoirc/text()", airc)
    xpath(xml, "/root/options/AUS/AutoHotkey/@nick/text()", def_ircnick)
 }
 else if def_aus = Pastebin.com
 {
    Loop, Parse, optionlst, |
    {
        if a_index = 1
            xpath(xml, "/root/options/AUS/Pastebin[+1]/@" . a_loopfield . "/text()", option%a_index%)
        else
            xpath(xml, "/root/options/AUS/Pastebin/@" . a_loopfield . "/text()", option%a_index%)
    }
 }
 xpath_save(xml, s_xml)
 Pause                                                      ; Unpause Script

 Gui, 50: Destroy
return
;}

AUInfo:                                                             ; Default AutoUpload Options
;{
 airc := 0
 if (aus && def_aus = "AutoHotkey.net")
 {
    Msgbox, 4, Auto announce options, % "Do you want your code to be auto announced on the AHK IRC Channel?"
    IfMsgbox, Yes
    {
        airc := 1
        InputBox, def_ircnick, % "Default Nick", % "Please enter your default nickname for AutoHotkey's IRC Channel"
                             ,, 230, 140
    }
 }
 else if (aus && def_aus = "Pastebin.com")
 {
    optionlst := "name|subdomain|exposure|expiration"
    InputBox, defaus_P_lst, % "Pastebin Default Options"
                          , % "Please enter a Paste Title, Subdomain, Exposure and Expiration separated by comas.`n"
                            . "You can omit a parameter by leaving its space blank.`n`n"
                            . "Examples: PasteName,,0,1D`n"
                            . "`t    PasteName,mysubdomain,0,N`n`n"
                            . "N = Never, 10M = 10 Minutes, 1H = 1 Hour, 1D = 1 Day, 1M = 1 Month"
                          ,, 520, 220
    StringSplit, option, defaus_P_lst,`,
 }
return
;}

ReadXML:                                                            ; Read options from XML file
;{
 if !load := xpath_load(xml, s_xml)
    return
 ahkexist := xpath(xml, "/root/@ahkexist/text()", ahkexist)
 pastepop_ena := !aus                                               ; Pastebin Popup if Autoupload is off
 aus := xpath(xml, "/root/options/AUS/@value/text()")               ; AutoUpload copied scripts
 sww := xpath(xml, "/root/options/SWW/@value/text()")               ; Start with Windows
 mhk := xpath(xml, "/root/options/MHK/@value/text()")               ; Main Hotkey
 ddl_pastebin := xpath(xml, "/root/options/AUS/@default/text()")    ; Default upload site
 hkcount := xpath(xml, "/root/hotkeys/hk/count()")                  ; Hotkey Count
 hscount := xpath(xml, "/root/hotstrings/hs/count()")               ; Hotstring Count
 Gosub, SWW
 Hotkey, %mhk%, MasterHotkey
return
;}

SWW:                                                                ; Start With Windows subroutine
;{
 if (sww && ahkexist != a_scriptfullpath)
    RegWrite, REG_SZ, HKCU, %reg_run%, ahk-tk, %a_scriptfullpath%
 else
 {
    RegRead, sww_exist, HKCU, %reg_run%, ahk-tk
    if sww_exist
        RegDelete, HKCU, %reg_run%, ahk-tk
 }
return
;}

LVHK_Load:
;{
 Gui, 1: Default
 Gui, ListView, LV_hklist
 Loop, % hkcount
 {
    load_type := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@type/text()")
    load_name := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@name/text()")
    load_keyL := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@key/text()")
    load_keyS := hkSwap(load_keyL, "short") ; convert to short hotkey for creating hotkeys
    load_dir := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@dir/text()")

    Hotkey, %load_keyS%, Hotkeyit
    LV_Add("", load_type, load_name, load_keyL, load_dir)
    LV_Organize("LV_hklist")
 }
return
;}

LVHS_Load:
;{
 Gosub, ReadXML
 Gui, 1: Default
 Gui, ListView, LV_hslist
 hsloading := True
 Gosub, CreateHSScript      ; If not exist Create file
 
 Loop, % hscount
 {
    load_opts := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@opts/text()")
    load_expand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expand/text()")
    load_expandto := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expandto/text()")
    load_iscommand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@iscommand/text()")
    LV_Add("", load_opts, load_expand, load_expandto)
    LV_Organize("LV_hslist")
    Gosub, CreateHSScript   ; Append strings 
 }
 Run, %hsloc%,,, hslPID
return
;}

CreateHSScript:
;{
 if !FileExist(hsloc)
 {
    hsfileopts =
    (Ltrim
        #NoEnv
        #SingleInstance Force
        #NoTrayIcon
        ; --
        SetBatchLines -1`n`n
    )
 FileAppend, %hsfileopts%, %hsloc%
 return
 }
 
 if hsloading
 {
    if load_iscommand
        script := "`n:" . load_opts . ":" . load_expand . "::`n" . load_expandto . "`nreturn`n`n"
    else
        script := ":" . load_opts . ":" . load_expand . "::" . load_expandto . "`n"
 }
 else if !hsloading
 {
    if hs_iscommand
        script := "`n:" . hs_opts . ":" . hs_expand . "::`n" . hs_expandto . "`nreturn`n`n"
    else
        script := ":" . hs_opts . ":" . hs_expand . "::" . hs_expandto . "`n"
 } 
    FileAppend, %script%, %hsloc%
return
;}

Hotkeyit:
;{
 if !load := xpath_load(xml, s_xml)
 {
    Msgbox % "there was an error loading the hotkeys"
    return
 }
 key := a_thishotkey
 key := hkSwap(key, "long")
 name := xpath(xml, "/root/hotkeys/hk[@key=" . key . "]/@name/text()")
 type := xpath(xml, "/root/hotkeys/hk[@key=" . key . "]/@type/text()")
 if type = File
    Run % path := xpath(xml,"/root/hotkeys/hk[@key=" . key . "]/@dir/text()") . "\" . name
 else if type = Folder
    Run % path := xpath(xml,"/root/hotkeys/hk[@key=" . key . "]/@dir/text()")
return
;}

GuiDropFiles:
;{
 if a_guicontrol = LV_hklist
 {
    dropped := 1
    SplitPath, a_guievent,,prog_dir,,prog_name
    StringUpper, prog_name, prog_name, T
    if a_guievent contains .lnk             ; Resolve the link target instead of using the link's directory
    {
        FileGetShortcut, %a_guievent%, prog_target
        SplitPath, prog_target,,prog_dir,,prog_name
    }
    GuiControl, 96:, e_progpath, %prog_dir%
 }
 Gosub, AddHotkey
return
;}

LV_Sub:
;{
 if a_guicontrol = LV_hklist
{
    Gui, 1: Default
    Gui, ListView, LV_hklist
    if a_guievent = Normal
        sel_row := a_eventinfo                      ; Currently selected Row
    if (a_guievent = "K" && a_eventinfo = 46)
    {
        Loop, % LV_GetCount("S")
        {
            if !next := LV_GetNext("F")
                break
            LV_GetText(prog_name, next, 2)
            LV_GetText(prog_hkL, next, 3)
            LV_GetText(prog_dir, next, 4)
            DelxmlInstance("hk")
            CleanXML()
            LV_Delete(next)
        }
        LV_Organize("LV_hklist")
    }
    
    if a_guievent = DoubleClick
    {
        LV_GetText(prog_type, sel_row, 1)
        LV_GetText(prog_name, sel_row, 2)
        LV_GetText(prog_hkL, sel_row, 3)
        LV_GetText(prog_dir, sel_row, 4)
        prog_hkS := hkSwap(prog_hkL, "short")
        StringSplit, prog_hk, prog_hkS

        /*
         * Need to handle hotkeys that contain whole words like Enter or Space
         * Thats why if the array contains more than 5 letters (4 modifiers + 1 key)
         * the program needs to handle the hotkey in a different way.
         */
        if prog_hk0 <= 5
            GuiControl, 96: Choose, ddl_key, % prog_hk%prog_hk0%
        else
        {
            Loop, % prog_hk0
            {
                if (prog_hk%a_index% = "^" || prog_hk%a_index% = "!"
                ||  prog_hk%a_index% = "+" || prog_hk%a_index% = "#")
                    continue
                hk := hk . prog_hk%a_index%
            }
            GuiControl, 96: Choose, ddl_key, % hk
            hk :=                                    ; Empty for next use
        }
        GuiControl, 96:, e_progpath, %prog_dir%
        GuiControl, 96: Focus, ddl_key
        if prog_type = File
            GuiControl, 96:, Select a File, 1
        else if prog_type = Folder
            GuiControl, 96:, Select a Folder, 1

        Loop, % prog_hk0
        {
            if prog_hk%a_index% = ^
                GuiControl, 96:, mod_ctrl, 1
            if prog_hk%a_index% = !
                GuiControl, 96:, mod_alt, 1
            if prog_hk%a_index% = +
                GuiControl, 96:, mod_shift, 1
            if prog_hk%a_index% = #
                GuiControl, 96:, mod_win, 1
        }
        Gosub, AddHotkey
    }
}

 if a_guicontrol = LV_hslist
 {
    Gui, 1: Default
    Gui, ListView, LV_hslist
    ; if a_guievent = Normal
        ; sel_row := a_eventinfo                      ; Currently selected Row
    if (a_guievent = "K" && a_eventinfo = 46)
    {
        Loop, % LV_GetCount("S")
        {
            if !next := LV_GetNext("F")
                break
            LV_GetText(hs_expand, next, 2)
            LV_GetText(hs_expandto, next, 3)
            DelxmlInstance("hs")
            CleanXML()
            LV_Delete(next)
        }
        sleep 100
        FileDelete, %hsloc%
        LV_Delete()             ; Delete all rows to reload them from xml file with LVHS_Load
        Gosub, LVHS_Load
    }
 }
return
;}

OnClipboardChange:
;{
 Gosub, ReadXML
 kword_count:=
/*
* This checks if the clipboard contains keywords from ahk scripting
* if it contains more than x ammount of keywords it will fire up the pastebin
* routines. You can change this to suit you better.
*/
 Loop, parse, ahk_keywords, `n, `r
 {
    if RegexMatch(clipboard, "i)\b" . a_loopfield . "\b\(?")
        kword_count++
 }
 if kword_count >= 3
 {
    kword_count :=
    if aus
        Gosub, AUS
    else
        Gosub, Pastebin
 } ; Finish ahk code detection
return
;}

PasteBin:
;{
 Gui, 99: Show, NoActivate w250 h150 x%monRight% y%monBottom%
 Gui, 99: Submit, NoHide
 if pastepop_ena
 {
    WinGetPos,,,99Width,99Height,ahk_id %99Hwnd%                    ; Get Window width and Height
    WinMove, ahk_id %99Hwnd%,,,% wa_Bottom - 99Height               ; Move the window to correct position
    pop_Right := wa_Right - 5
    Loop, 5
    {
        pop_Right -= 99Width/5
        WinMove, ahk_id %99Hwnd%,,% pop_Right
    }
 Sleep, 5 * sec
 Gui, 99: Hide
 }
return
;}

AddHotkey:
;{
 if (dropped || a_gui = 1)
 {
    ActiveHwnd := WinExist("AutoHotkey ToolKit")
    Gui, 01: +Disabled
    Gui, 96: Show, w420 h210
 }
 if a_gui = 96
 {
    Gui, 96: Submit
    Gui, 01: Default
    Gui, -Disabled
    Gui, ListView, LV_hklist
    Gosub, VarSwap
    dropped :=
    prog_hkL := mod_ctrl . mod_alt . mod_shift . mod_win . ddl_key
    prog_hkS := hkSwap(prog_hkL, "short") ; convert to short for creating hotkey
    if CheckLV("LV_hklist")
    {
        LV_Add("", r_selfof, prog_name, prog_hkL, prog_dir)
        xpath(xml, "/root/hotkeys/hk[+1]/@type/text()", r_selfof)
        xpath(xml, "/root/hotkeys/hk[last()]/@name/text()", prog_name)
        xpath(xml, "/root/hotkeys/hk[last()]/@key/text()", prog_hkL)
        xpath(xml, "/root/hotkeys/hk[last()]/@dir/text()", prog_dir)
        Sleep, 100              ; Give it little time before saving since we are using SetBatchLines -1
                                ; this fixes some problems of xpath appending instead of overwriting the file
        xpath_save(xml,s_xml)
        LV_Organize("LV_hklist")    ; Sort the LV and set the status messages
        CleanXML()
        Hotkey, %prog_hkS%, Hotkeyit
        GuiReset(96)
    }
 }
return
;}

AddHotstring:
;{
 Gui, Submit, NoHide
 Gui, ListView, LV_hslist
 Gosub, VarSwap
 hsloading := False
 hs_opts :=  hs_autoexpand . hs_dnd . hs_trigger . hs_raw
 
 if CheckLV("LV_hslist")
 {
    LV_Add("", hs_opts, hs_expand, hs_expandto)
    xpath(xml, "/root/hotstrings/hs[+1]/@opts/text()", hs_opts)
    xpath(xml, "/root/hotstrings/hs[last()]/@expand/text()", hs_expand)
    xpath(xml, "/root/hotstrings/hs[last()]/@expandto/text()", hs_expandto)
    xpath(xml, "/root/hotstrings/hs[last()]/@iscommand/text()", hs_iscommand)
    Sleep, 100
    xpath_save(xml, s_xml)
    LV_Organize("LV_hslist")    ; Sort the LV and set the status messages
    CleanXML()
    Gosub, CreateHSScript
    Run, %hsloc%,,, hslPID
    GuiReset(1)
 }
return
;}

ProgBrowse:
;{
 Gui, 96: +OwnDialogs
 Gui, 96: Submit, NoHide

 ; File or Folder?
 if r_selfof = 1
    FileSelectFile, sel_prog, 3, %a_programfiles%, % "Select the program to be launched"
    , Executable files (*.exe)
 else if r_selfof = 2
    FileSelectFolder, sel_prog, *%a_programfiles%, 3, % "Select the folder to be launched"

 SplitPath, sel_prog,,prog_dir,,prog_name
 if r_selfof = 2
    prog_dir := prog_dir . "\" . prog_name          ; Needed to have the complete dir since prog_dir would not have
                                                    ; the last folder name included in this case.
 StringUpper, prog_name, prog_name, T

 if !sel_prog
    GuiControl, 96:, e_progpath, %a_programfiles%
 else
 {
    GuiControl, 96:, e_progpath, %sel_prog%
    GuiControl, 96: Focus, ddl_key
 }
return
;}

PopYes:                                                             ; Popup YES
;{
 Gui, Hide                                                          ; Hide Popup
AUS:
 /*
  * This will replace the includes for the actual files to avoid
  * the issues of missing includes on pasted code
  */
 Loop, parse, clipboard, `n, `r
 {
    if a_loopfield contains #Include
    {
        inc_file := RegexReplace(a_loopfield, "i)^#include\s|\*i\s|\s;.*")
        if inc_file contains .ahk
            FileRead, inc_%a_index%, %inc_file%
        else
            SetWorkingDir, %inc_file%
        Stringreplace, clipboard, clipboard, %a_loopfield%, % inc_%a_index%
    }
 } ; Finish Replacing
 SetWorkingDir %A_ScriptDir%
 /*
  * The following code replaces signs that might provoke issues
  * when sending the httpQUERY. They are automatically converted back
  * by the HTTP request, so no need to worry there.
  */
 StringReplace, clipboard, clipboard,`%, `%25, 1
 StringReplace, clipboard, clipboard, &, `%26, 1
 StringReplace, clipboard, clipboard, +, `%2B, 1
 ; Finish Replacing
 if aus
{
    ; Some default values
    xpath_load(xml, s_xml)
    autoirc  := xpath(xml, "/root/options/AUS/AutoHotkey/@autoirc/text()")
    ahk_code := clipboard
    pb_name  := "Code auto uploaded with AHK-toolkit v" . s_version
    if (autoirc && ddl_pastebin = "AutoHotkey.net")
        pb_subdomain    := xpath(xml, "/root/options/AUS/AutoHotkey/@nick/text()")
    else if ddl_pastebin = Pastebin.com
    {
        pb_name         := xpath(xml, "/root/options/AUS/Pastebin/@name/text()")
        pb_subdomain    := xpath(xml, "/root/options/AUS/Pastebin/@subdomain/text()")
        pb_exposure     := xpath(xml, "/root/options/AUS/Pastebin/@exposure/text()")
        pb_expiration   := xpath(xml, "/root/options/AUS/Pastebin/@expiration/text()")
    }

    Goto, SendAUS
}
 GuiControl, 98:, ahk_code, %clipboard%
 Gui, 98: Show, w640 h550, % "Send To Pastebin"
 Gui, 98: Submit, NoHide
return
;}

PopNo:                                                              ; Popup No
;{
 Gui, Hide
return
;}

PasteUpload:                                                        ; Send to Pastebin Upload
;{
 Gui, 98: Submit
SendAUS:
 if ddl_pastebin = Autohotkey.net
 {
    if pb_subdomain
        irc_stat = 1
    else
        irc_stat = 0

    URL  := "http://www.autohotkey.net/paste/"
    POST := "text="             . ahk_code
         . "&irc="              . irc_stat
         . "&ircnick="          . pb_subdomain
         . "&ircdescr="         . pb_name
         . "&submit=submit"

    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    RegexMatch(paste_url, "Paste\s(#(.*?)<)", Match)
    if !Match2
    {
        Msgbox, % "Your code is probably too long (max ~110 lines), try again or pick another pastebin service"
        return
    }
    paste_url := "http://www.autohotkey.net/paste/" . Match2
    pasted()
 }
 else if ddl_pastebin = Pastebin.com
 {
    if pb_exposure = Public
        pb_exposure = 0
    else if pb_exposure = Private
        pb_exposure = 1

    if pb_expiration = Never
        pb_expiration = N
    else if pb_expiration = 10 Minutes
        pb_expiration = 10M
    else if pb_expiration = 1 Hour
        pb_expiration = 1H
    else if pb_expiration = 1 Day
        pb_expiration = 1D
    else if pb_expiration = 1 Month
        pb_expiration = 1M

    URL  := "http://pastebin.com/api_public.php"
    POST := "paste_code="           . ahk_code
         . "&paste_name="           . pb_name
         . "&paste_subdomain="      . pb_subdomain
         . "&paste_private="        . pb_exposure
         . "&paste_expire_date="    . pb_expiration


    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    pasted()
 }
 else if ddl_pastebin = Paste2.org
 {
    URL  := "http://paste2.org/new-paste"
    POST := "lang=text"
         . "&description="   . pb_name
         . "&code="          . ahk_code
         . "&parent=0"

    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)

    RegexMatch(paste_url, "Paste\s(\b\d+)", Match)
    paste_url := "http://paste2.org/p/" . Match1
    pasted()
 }
return
;}

PasteSavetoFile:                                                    ; Send to Pastebin Save To File
;{
 Gui, 98: +OwnDialogs
 FileSelectFile, f_saved, S24, %a_desktop%, Save script as..., AutoHotkey (*.ahk)
 if !f_saved
    return
 /*
  * The following fixes back the code replacement done earlier to prevent
  * issues with httpQUERY.
  */
 StringReplace, ahk_code, ahk_code, `%25,`%, 1
 StringReplace, ahk_code, ahk_code, `%26, &, 1
 StringReplace, ahk_code, ahk_code, `%2B, +, 1
 ; Finish Replacing

 /*
  * The following piece of code fixes the issue with saving a file without adding the extension while the file
  * existed as "file.ahk", which caused the file to be saved as "file.ahk.ahk" and added a msgbox if the user
  * is overwriting an existing file
  */
 if f_saved contains .ahk               ; Check whether the user added the file extension or not
 {
    if FileExist(f_saved)
        FileDelete, %f_saved%
    FileAppend, %ahk_code%, %f_saved%   ; If added just save the file as the user specified
 }
 else
 {
    if FileExist(f_saved . ".ahk")
        Msgbox, 4, Replace file...?,  % f_saved . " already exist.`nDo you want to replace it?"
    ifMsgbox, No
        return
    FileDelete, %f_saved%.ahk
    FileAppend, %ahk_code%, %f_saved%.ahk
 }
 Gui, Hide
return
;}

TimedShutdown:
;{
 GuiControl,, live_code, %TimedShutdown_s%
return
;}

SaveXYCoords:
;{
 GuiControl,, live_code, %SaveXYCoords_s%
return
;}

TextControlsRefs:
;{
 GuiControl,, live_code, %TextControlsRefs_s%
return
;}

LiveRun:
;{
 Gui, Submit, NoHide

 if lcf_name := a_temp . "\" . randomName(8,"ahk")        ; Random Live Code Path
 {
    live_code =
    (Ltrim
        #NoEnv
        #Persistent
        ; --
        SendMode Input
        SetBatchLines -1
        ; --
        sec         :=  1000               ; 1 second
        min         :=  sec * 60           ; 1 minute
        hour        :=  min * 60           ; 1 hour

        %live_code%
        
        Esc::ExitApp
    )
    FileAppend, %live_code%, %lcf_name%
 }
 else
    Msgbox % "There was a problem while creating the file name"
 if FileExist(lcf_name)
 {
    if ahkexist
        Run, %lcf_name%
    else
        Run, res\ahk\ahk.exe "%lcf_name%"
    Sleep, 500
    FileDelete, %lcf_name%
 }
 else
    Goto, LiveRun   ; Try again (I dont accept failure)
return
;}

LiveSavetoFile:                                                     ; Live Code Save To File
;{
 Gui, Submit, NoHide
 Gui, +OwnDialogs
 FileSelectFile, f_saved, S24, %a_desktop%, Save script as..., AutoHotkey (*.ahk)
 if !f_saved
    return
 /*
  * The following piece of code fixes the issue with saving a file without adding the extension while the file
  * existed as "file.ahk", which caused the file to be saved as "file.ahk.ahk" and added a msgbox if the user
  * is overwriting an existing file
  */
 if f_saved contains .ahk               ; Check whether the user added the file extension or not
 {
    if FileExist(f_saved)
        FileDelete, %f_saved%
    FileAppend, %live_code%, %f_saved%   ; If added just save the file as the user specified
 }
 else
 {
    if FileExist(f_saved . ".ahk")
        Msgbox, 4, Replace file...?,  % f_saved . " already exist.`nDo you want to replace it?"
    ifMsgbox, No
        return
    FileDelete, %f_saved%.ahk
    FileAppend, %live_code%, %f_saved%.ahk
 }
return
;}

LiveClear:
;{
 GuiControl,,live_code,
return
;}

GuiCancel:
96GuiClose:
96GuiEscape:
;{
 Gui, Hide
 if a_gui = 96
 {
     Gui, 01: Default
     Gui, -Disabled
     GuiReset(96)
 }
return
;}

DisablePopup:
;{
 Gui, 99: Submit, NoHide
 Msgbox, % "You have chosen to disable the Pastebin Alert, to enable it again go to the options tab"
 xpath(xml, "/root/options/AUS/@value/text()", !pastepop_ena)
 xpath_save(xml, s_xml)
return
;}

DDL_Pastebin:
;{
 Gui, 98: Submit, NoHide
 if ddl_pastebin = AutoHotkey.net
    ena_control(1,1,0,0)
 else if ddl_pastebin = Pastebin.com
    ena_control(1,1,1,1)
 else if ddl_pastebin = Paste2.org
    ena_control(1,0,0,0)
return
;}

MasterHotkey:
ButtonClose:
GuiClose:
GuiEscape:
;{
 main_toggle := !main_toggle
 if main_toggle
    Gui, Show, w619 h341, AutoHotkey ToolKit
 else
    Gui, Hide
return
;}

VarSwap:
;{
; Hotkey vars
 if mod_ctrl
    mod_ctrl := "Ctrl + "
 else
    mod_ctrl :=
 if mod_alt
    mod_alt := "Alt + "
 else
    mod_alt :=
 if mod_shift
    mod_shift := "Shift + "
 else
    mod_shift :=
 if mod_win
    mod_win := "Win + "
 else
    mod_win :=

 if r_selfof = 1
    r_selfof := "File"
 else if r_selfof = 2
    r_selfof := "Folder"

; Hotstring vars
 if hs_autoexpand
    hs_autoexpand := "*"
 else
    hs_autoexpand :=
 if hs_dnd
    hs_dnd := "B0"
 else
    hs_dnd :=
 if hs_trigger
    hs_trigger := "?"
 else
    hs_trigger :=
 if hs_raw
    hs_raw := "R"
 else
    hs_raw :=
return
;}

50GuiClose:
50GuiEscape:
;{
 ExitApp
;}

Clean:
;{
WinClose, ahk_pid %hslPID%
FileDelete, %hsloc%
ExitApp
;}
;-

;+--> ; ---------[Functions]---------
ena_control(name = "", subdomain = "", exposure = "", expiration = ""){
    _var_list  := "name|subdomain|exposure|expiration"

    Loop, parse, _var_list, |
    {
        if %a_loopfield% = 1
            GuiControl, 98:  Enable, pb_%a_loopfield%
        else if %a_loopfield% = 0
            GuiControl, 98: Disable, pb_%a_loopfield%
    }
}
pasted(){
    Global
    FormatTime,cur_time,,[MMM/dd/yyyy - HH:mm:ss]
    code_preview :=
    xpos := wa_Right - 250 - 5
    ypos := wa_Bottom - 90
    clipboard := paste_url
    Gui, 97: Show, x%xpos% y%ypos%
    Loop, parse, ahk_code, `n, `r
    {
        if a_index = 20
            break
        if !code_preview
            code_preview := a_loopfield
        else
            code_preview := code_preview . "`n" . a_loopfield
    }
    FileAppend,
    (
--> %cur_time% %paste_url% :
----------------------------------------------------------------------
%code_preview%
----------------------------------------------------------------------`n`n
    ), res\pastebin-log.dat
    Sleep, 3 * sec
    Gui, 97: Hide
}
GuiReset(guinum){
    Global
    if guinum = 1
    {
        GuiControl,, hs_expand,
        GuiControl,, hs_expandto,
        Loop, Parse, hs_optlist, |
            GuiControl,, %a_loopfield%, 0
    }
    if guinum = 96
    {
        GuiControl, 96: Focus, Browse
        GuiControl, 96:, e_progpath, %a_programfiles%
        GuiControl, 96:, ddl_key,|%keylist%
        GuiControl, 96:, r_selfof, 1
        Loop, Parse, mod_list, |
            GuiControl, 96:, %a_loopfield%, 0
        WinActivate, ahk_id %ActiveHwnd%
    }
}
CheckLV(lvName){
    Global
    if LV_GetCount()
        lvcount := LV_GetCount()
    else
        lvcount := 1                ; The loop must run at least once

    if lvName = LV_hklist
    {
        Loop % lvcount
        {
            LV_GetText(cname, a_index, 2)
            LV_GetText(chk, a_index, 3)
            LV_GetText(cdir, a_index, 4)

            if (cname != prog_name && chk != prog_hkL && cdir != prog_dir)
            {
                isNew := True
                continue
            }
            else if (cname = prog_name || chk = prog_hkL || cdir = prog_dir)
            {
                Msgbox,36,% "Duplicate Found"
                , % "The hotkey or program that you are trying to set up was already found.`n"
                  . "Do you want to teplace the existing one for this one?"
                IfMsgBox, Yes
                {
                    /*
                     * Need to repeat the process twice for cases where you want to replace
                     * more than one existing cases.
                     * e.g. Winamp has Win + w and Ccleaner has Win + c
                     * but you want to assign Win + w to Ccleaner. By repeating the process we delete
                     * both existing hotkeys and create a new one with the desired hotkey.
                     */
                    LV_Delete(a_index)
                    Loop % lvcount
                    {
                        LV_GetText(cname, a_index, 2)
                        LV_GetText(chk, a_index, 3)
                        LV_GetText(cdir, a_index, 4)
                        if (cname = prog_name || chk = prog_hkL || cdir = prog_dir)
                            LV_Delete(a_index) ; repeating
                    }
                    DelxmlInstance("hk") ; Delete XML instances of this hotkey.
                    isNew := True    ; We already deleted the existing one, so it IS new :)
                }
                IfMsgBox, No
                {
                    GuiReset(96)
                    return isNew := False
                }
                xpath_save(xml, s_xml)
                GuiReset(96)
            }
        }
        return isNew
    }
    if lvName = LV_hslist
    {
        Loop, % lvcount
        {
            LV_GetText(chs_expand, a_index, 2)
            LV_GetText(chs_expandto, a_index, 3)

            if (chs_expand != hs_expand && chs_expandto != hs_expandto)
            {
                isNew := True
                continue
            }
            else if (chs_expand = hs_expand || chs_expandto = hs_expandto)
            {
                Msgbox,36,% "Duplicate Found"
                , % "The hotsring that you are trying to set up was already found.`n"
                  . "Do you want to teplace the existing one for this one?"
                IfMsgBox, Yes
                {
                    LV_Delete(a_index)
                    Loop % lvcount
                    {
                        LV_GetText(chs_expand, a_index, 2)
                        LV_GetText(chs_expandto, a_index, 3)
                        if (chs_expand = hs_expand || chs_expandto = hs_expandto)
                            LV_Delete(a_index) ; Repeating
                    }
                    DelxmlInstance("hs") ; Delete XML instances of this hotstring.
                    isNew := True
                }
                IfMsgBox, No
                {
                    GuiReset(1)
                    return isNew := False
                }
                xpath_save(xml, s_xml)
                GuiReset(1)
            }
        }
        return isNew
    }
}
DelxmlInstance(type){
    /*
     * Need to repeat the process twice for cases where you want to replace
     * more than one existing cases.
     * e.g. Winamp has Win + w and Ccleaner has Win + c
     * but you want to assign Win + w to Ccleaner. By repeating the process we delete
     * both existing hotkeys and create a new one with the desired hotkey.
     */
    Global
    xpath_load(xml, s_xml)
    if type = hk
    {
        Loop, % xpath(xml, "/root/hotkeys/hk/count()")
        {
            load_name := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@name/text()")
            load_keyL := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@key/text()")
            load_dir := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@dir/text()")

            if (load_name = prog_name || load_keyL = prog_hkL || load_dir = prog_dir)
            {
                xpath(xml, "/root/hotkeys/hk[" . a_index . "]/remove()")
                Loop, % xpath(xml, "/root/hotkeys/hk/count()")
                {
                    load_name := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@name/text()")
                    load_keyL := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@key/text()")
                    load_dir := xpath(xml, "/root/hotkeys/hk[" . a_index . "]/@dir/text()")

                    if (load_name = prog_name || load_keyL = prog_hkL || load_dir = prog_dir)
                        xpath(xml, "/root/hotkeys/hk[" . a_index . "]/remove()") ; repeating
                }
            }
        xpath_save(xml, s_xml)
        }
    }
    if type = hs
    {
        Loop, % xpath(xml, "/root/hotstrings/hs/count()")
        {
            load_expand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expand/text()")
            load_expandto := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expandto/text()")

            if (load_expand = hs_expand || load_expandto = hs_expandto)
            {
                xpath(xml, "/root/hotstrings/hs[" . a_index . "]/remove()")
                Loop, % xpath(xml, "/root/hotstrings/hs/count()")
                {
                    load_expand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expand/text()")
                    load_expandto := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expandto/text()")

                    if (load_expand = hs_expand || load_expandto = hs_expandto)
                        xpath(xml, "/root/hotstrings/hs[" . a_index . "]/remove()")
                }
            }
        xpath_save(xml, s_xml)
        }
    }
}
CleanXML(){
    Global
    FileRead, rxml, %s_xml%         ; Read xml file
    FileDelete, %s_xml%             ; Delete the file because we dont want to append
    FileAppend, % rxml := RegexReplace(rxml, "\s+\/", "/"), %s_xml% ; Clean and save
}
LV_Organize(lvName){
    Global
    Gosub, ReadXML
    if lvName = LV_hklist
    {
        Gui, ListView, LV_hklist
        Loop, 4
        {
            if a_index = 4
                LV_ModifyCol(a_index, "AutoHdr")
            else
                LV_ModifyCol(a_index, "Center AutoHdr")
        }
        if hkcount = 1
            SB_SetText("`t" . hkcount . " Hotkey currently active")
        else
            SB_SetText("`t" . hkcount . " Hotkeys currently active")
    }
    if lvName = LV_hslist
    {
        Gui, ListView, LV_hslist
        Loop, 3
        {
            if a_index = 1
                LV_ModifyCol(a_index, "Center AutoHdr")
            else
                LV_ModifyCol(a_index, "AutoHdr")
        }
        if hscount = 1
            SB_SetText("`t" . hscount . " Hotstrings currently active", 2)
        else
            SB_SetText("`t" . hscount . " Hotstrings currently active", 2)
    }
}
randomName(length = "", filext = ""){
    Loop, % length
    {
        Assign:
        Random, rand%a_index%, 33, 126
        if (rand%a_index% = 95 || rand%a_index% = 47 || rand%a_index% = 58
        || rand%a_index% = 42 || rand%a_index% = 63 || rand%a_index% = 34
        || rand%a_index% = 60 || rand%a_index% = 62 || rand%a_index% = 124)
            Goto, Assign
        rand%a_index% := chr(rand%a_index%)
        RName := RName . rand%a_index%
    }
    return RName . "." . filext
}
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
!Esc::ExitApp
Pause::Reload
;+> ; [Ctrl + F5] Send Current Date
^F5::Send, % a_mmmm " "a_dd ", " a_yyyy
;-
;+> ; [Ctrl + Shift + A/Z] BW ally
#IfWinActive ahk_class SWarClass
^+a::
 if !nick
    Inputbox, nick, % "Set your ally", % "Pease enter the nick of your ally",,210,120, % mid_scrw - (210/2)
    , % mid_scrh - (120/2)
 else
    Send, /ally %nick% {Enter}

 IfWinNotActive ahk_class SWarClass
    WinActivate
 else
    WinMaximize
return
^+z::
 nick :=
 Gosub, ^+a
return
#IfWinActive
;-
;-

;+--> ; ---------[Includes]---------
#Include *i C:\Documents and Settings\RaptorX\My Documents\AutoHotkey ; Current Library
#Include lib\httpQuery.ahk
#Include lib\klist.ahk
#Include lib\xpath.ahk
#Include lib\hkSwap.ahk
;-

/*
 *==================================================================================
 *                          		END OF FILE
 *==================================================================================
 */
