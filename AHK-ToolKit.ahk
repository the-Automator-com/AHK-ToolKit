/*
 * Author:          RaptorX	<graptorx@gmail.com>
 * Script Name:     AutoHotkey ToolKit
 * Script Version:  0.4.10
 * Homepage:        http://www.autohotkey.com/forum/topic61379.html#376087
 *
 * Creation Date: July 11, 2010 | Modification Date: September 06, 2010
 * 
 * [GUI Number Index]
 *
 * GUI 01 - Main [AutoHotkey ToolKit]
 * GUI 02 - Advanced Hotstring Setup
 * GUI 03 - Selection Box
 * GUI 99 - PasteBin Popup
 * GUI 98 - Send to PasteBin
 * GUI 97 - Pastebin Success Popup
 * GUI 96 - Add Hotkey
 * GUI 50 - First Run
 */

;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
; --
SetBatchLines -1
SendMode Input
SetTitleMatchMode, Regex
CoordMode, Tooltip, Screen
SetWorkingDir %A_ScriptDir%
onExit, Clean
;-

;+--> ; ---------[Basic Info]---------
s_name      := "AutoHotkey ToolKit"     ; Script Name
s_version   := "0.4.10"                 ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
GoSub, CheckUpdate
;-

;+--> ; ---------[General Variables]---------
sec       :=  1000                      ; 1 second
min       :=  sec * 60                  ; 1 minute
hour      :=  min * 60                  ; 1 hour
; --
SysGet, mon, Monitor                    ; Get the boundaries of the current screen
SysGet, wa_, MonitorWorkArea            ; Get the working area of the current screen
WinGet, DeskHwnd, ID, Program Manager   ; Get the current Hwnd of the Destop
mid_scrw  :=  a_screenwidth / 2         ; Middle of the screen (width)
mid_scrh  :=  a_screenheight / 2        ; Middle of the screen (heigth)
; --
s_ini     :=                            ; Optional ini file
s_xml     := "res\ahk_tk.xml"           ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
Clipboard :=
GroupAdd, Ahk_Tk, % "AutoHotkey ToolKit"
GroupAdd, Ahk_Tk, % "Advanced Hotstring Setup"
GroupAdd, Ahk_Tk, % "Send To Pastebin"
FileRead, ahk_keywords, % "res\key.lst" ; Used for the PasteBin routines
reg_SMWCVR:= "Software\Microsoft\Windows\CurrentVersion\Run"
mod_list  := "mod_ctrl|mod_alt|mod_shift|mod_win"
hs_optlist:= "hs_iscommand|hs_dnd|hs_trigger|hs_raw"
exc       := "ScrollLock|CapsLock|NumLock|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft"
. "|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel|LWin|RWin|LControl"
. "|RControl|LShift|RShift|LAlt|RAlt|CtrlBreak|Control|Alt|Shift|AppsKey"
keylist   := "None||" . klist(2,0,1, exc)
resahk    := "res\tools\ahk\ahk.exe"
rescurl   := "res\tools\curl\cu.exe"
resrehash := "res\tools\rehash\rh.exe"
hsloc     := a_temp . "\hslauncher.ahk"

; Live Code Scripts
;{
s_livecode =
(
; **************************************************************************
; * All live scripts start with the following default options:             *
; * #NoEnv, #SingleInstance Force, SendMode Input, SetbatchLines -1        *
; * and Esc::ExitApp                                                       *
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
ExitApp
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
	ToolTip, x(`%X`%)``, y(`%Y`%)				; Tooltip to make everything easier
	Sleep 10
}

~LButton::FileAppend, `%X`%`,`%Y`%``n, `%s_file`%  ; Save coords to parse e.g. 300,400
RButton::ExitApp
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
return

GuiClose:
ExitApp
)
;}

; Resources folder
if !FileExist("res")
{
    FileCreateDir, % "res\tools"
    FileCreateDir, % regexreplace(rescurl, "\\\w+\.exe", "")
    FileCreateDir, % regexreplace(resrehash, "\\\w+\.exe", "")
    FileInstall, res\key.lst, res\key.lst, 1
    FileInstall, res\tools\rehash\rh.exe, res\tools\rehash\rh.exe, 1
    FileInstall, res\tools\curl\cu.exe, res\tools\curl\cu.exe, 1
    FileRead, ahk_keywords, % "res\key.lst" ; First Time Read.
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
                            . "Clipboard"
    Gui, 50: add, Text, w370 x0 y+20 0x10
    Gui, 50: add, Button, w100 x260 yp+10 gFR_Save, Save
    
    Gui, 50: Show, w365, % "First Run"
    Suspend
    Pause
}

;-

;+--> ; ---------[Main]---------

onMessage(0x203, "WM_LBUTTONDBLCLK")
Gosub, ReadXML
Gosub, SWW
; Use ahk.exe if AutoHotkey is not installed
if !ahkexist
{
    if !FileExist("res\tools\ahk")
        FileCreateDir, % regexreplace(resahk, "\\\w+\.exe", "")
    if !FileExist("res\tools\ahk\ahk.exe")
        FileInstall, res\tools\ahk\ahk.exe, %resahk%, 1
}

; Tray Menu
;{
Menu, Tray, NoStandard
Menu, Tray, Click, 1
Menu, Tray, add, % "Show Main Gui", MasterHotkey
Menu, Tray, Default, % "Show Main Gui"
Menu, Tray, add
Menu, Tray, Standard
;}

; Hotkey Maker GUI[Main]
;{
Gui, add, Tab2, w620 h340 x0 y0, % "Hotkeys|Hotstrings|Live Code|Options"
Gui, add, StatusBar,, % "Add new hotkeys / hotstrings"

Gui, Tab, Hotkeys
Gui, add, ListView, w600 h234 Sort Grid AltSubmit gLV_Sub vLV_hklist, % "Type|Program Name|Hotkey|Program Path"
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x400 yp+10 Default gAddHotkey, % "&Add"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Tab, Hotstrings
Gui, add, ListView, w600 h150 Grid AltSubmit gLV_Sub vLV_hslist, % "Options|Abbreviation|Expand To"
Gui, add, Text, y+10, % "Expand:"
Gui, add, Edit, w150 x+10 yp-3 vhs_expand
Gui, add, Text, x+10 yp+3, % "To:"
Gui, add, Edit, w250 x+10 yp-3 gLV_Sub vhs_expandto
Gui, add, Checkbox, x510 yp+5 vhs_iscommand, % "Run Command"
Gui, add, CheckBox, x12 y+15 Checked vhs_autoexpand, % "AutoExpand"
Gui, add, CheckBox, x250 yp vhs_dnd, % "Do not delete typed abbreviation"
Gui, add, CheckBox, x12 y+10 vhs_trigger, % "Trigger inside other words"
Gui, add, CheckBox, x250 yp vhs_raw, % "Send Raw (do not translate {Enter} or {key})"
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x400 yp+10 gAddHotstring, % "&Add"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Tab, Live Code
Gui, Font, s8, Courier New
Gui, add, Edit, w600 h215 WantTab T14 vlive_code, % s_livecode
Gui, Font
Gui, add, Text, y+5, % "Some small tools:"
Gui, add, Radio, x+10 gTimedShutdown vTimedShutdown, % "Timed Shutdown"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Radio, x+10 yp+2.5 gSaveXYCoords vSaveXYCoords, % "Save X,Y coord list"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Radio, x+10 yp+2.5 gTextControlsRefs vTextControlsRefs, % "Text Controls Style Refs"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Text, x515 yp+2.5 gRetrieveLC vRetrieveLC, % "Retrieve Live Code"
Gui, add, Text, wp+10 hp+5 xp-4 yp-2.5 0x8
Gui, add, Text, w630 x0 y272 0x10
Gui, add, Button, w100 x190 yp+10 gLiveRun, % "&Run"
Gui, add, Button, w100 x+5 yp gLiveSavetoFile, % "&Save to File"
Gui, add, Button, w100 x+5 yp gLiveClear, % "Cl&ear"
Gui, add, Button, w100 x+10 yp, % "&Close"

Gui, Tab, Options
FileInstall, res\img\UnderConstruction.png, % a_temp . "\" . "UC.png"
Gui, add, Picture, w600 h280, % a_temp . "\" . "UC.png"

Gui, Show, Hide ;w619 h341
SB_SetParts(150,150)
;}

; Advanced Hotstring Setup GUI
;{
Gui, 2: add, Text,, % "Options:`n(You can add any supported hotstring option)"
Gui, 2: add, Edit, vahs_opts
Gui, 2: add, Text,, % "Expand:"
Gui, 2: add, Edit, vahs_expand
Gui, 2: add, Text,, % "Expand To:"
Gui, 2: add, Checkbox, x+260 gahsIsCommand vahs_iscommand, % "Run Command"
Gui, 2: add, Edit, w400 h150 x10 WantTab T14 vahs_expandto
Gui, 2: add, Text, w430 x0 y290 0x10
Gui, 2: add, Button, w100 x95 yp+10 gAdvHotstring, % "Save"
Gui, 2: add, Button, w100 x+5 yp gLiveRun, % "Test Code"
Gui, 2: add, Button, w100 x+10 yp gGuiCancel, % "Cancel"

Gui, 2: Show, Hide ;w420 h335
;}

; Selection Box GUI
;{
Gui, 3: -Caption +ToolWindow
Gui, 3: Show, Hide
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
                                  . "The link has been copied to the Clipboard"
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
 Suspend

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

CheckUpdate:
;{
 URL := "http://github.com/RaptorX/AHK-ToolKit/raw/master/Changelog.txt"
 Httpquery(update := "", URL)
 VarSetCapacity(update, -1)
 Loop, Parse, update, `n,`r
 {
    if a_index = 5
    {
        RegexMatch(a_loopfield, "v(.+)", Match)
        u_version := Match1
        if s_version != %u_version%
            MsgBox, 4, % "New update available"
            , % "A new update has been found.`nDo you want to update AutoHotkey Toolkit to " . Match
              . "`n`n Current Version: v" s_version, 10
        IfMsgBox, No
            return
        IfMsgBox, Timeout
            return
        break
    }
 }
 if s_version != %u_version%
 {
    if a_iscompiled
        URL := "http://www.autohotkey.net/~RaptorX/AHK-TK/AHK-Toolkit-" . Match . "-Compiled.zip"
    else
        URL := "http://www.autohotkey.net/~RaptorX/AHK-TK/AHK-ToolKit-" . Match . ".zip"   

    FileSelectFile, updatezip, S16, %a_workingdir%\AutoHotkey Toolkit.zip
    , % "Please selecte where to download the file.", Zip Files (*.zip)
    SetTimer, dlCheck, 10
    VarSEtCapacity(f_update, 5242880)
    length := HttpQuery(f_update := "", URL)
    WriteBin(f_update, updatezip, length)
    SetTimer, dlCheck, Off
    Tooltip
    Msgbox, % "Download Completed"
    Run, % updatezip
    VarSEtCapacity(f_update, 0)
    ExitApp
 }
return
;}

dlCheck:
;{
 httpQueryOps := "updateSize"
 u_csize := RegexReplace(t := HttpQueryCurrentSize/1048576, "\d{4}$", "")
 Tooltip, % "Downloaded: " . u_csize . "MB/" 
 . u_tsize := RegexReplace(c := HttpQueryFullSize/1048576, "\d{4}$", "") . "MB"
return
;}
 
ReadXML:                                                            ; Read options from XML file
;{
 RegRead, sww_exist, HKCU, %reg_SMWCVR%, ahk-tk
 if !load := xpath_load(xml, s_xml)
    return
 ahkexist := xpath(xml, "/root/@ahkexist/text()", ahkexist)
 aus := xpath(xml, "/root/options/AUS/@value/text()")               ; AutoUpload copied scripts
 sww := xpath(xml, "/root/options/SWW/@value/text()")               ; Start with Windows
 mhk := xpath(xml, "/root/options/MHK/@value/text()")               ; Main Hotkey
 ddl_pastebin := xpath(xml, "/root/options/AUS/@default/text()")    ; Default upload site
 hkcount := xpath(xml, "/root/hotkeys/hk/count()")                  ; Hotkey Count
 hscount := xpath(xml, "/root/hotstrings/hs/count()")               ; Hotstring Count
 pastepop_ena := !aus                                               ; Pastebin Popup if Autoupload is off
 Hotkey, %mhk%, MasterHotkey
return
;}

SWW:                                                                ; Start With Windows subroutine
;{
 if sww
    RegWrite, REG_SZ, HKCU, %reg_SMWCVR%, ahk-tk, %a_scriptfullpath%
 else if (!sww && sww_exist)
	RegDelete, HKCU, %reg_SMWCVR%, ahk-tk
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
 if !hkcount
    SB_SetText("`t" . hkcount . " Hotkeys currently active")
return
;}

LVHS_Load:
;{
 Gosub, ReadXML
 Gui, 1: Default
 Gui, ListView, LV_hslist
 hs_loading := True
 Gosub, CreateHSScript      ; If not exist Create file
 
 Loop, % hscount
 {
    load_opts := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@opts/text()")
    load_expand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expand/text()")
    load_iscommand := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@iscommand/text()")
    if !load_expandto := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/@expandto/text()")
    {
        loadIsMultiline := True
        load_expandto := xpath(xml, "/root/hotstrings/hs[" . a_index . "]/text()")
    }
    
    load_expand := uriSwap(load_expand, 2)
    load_expandto := uriSwap(load_expandto , 2)
    
    if loadIsMultiline
    {
        old_expandto := load_expandto
        LV_Add("", load_opts, load_expand, load_expandto := "Multiline (Double Click to see the whole text)")
        load_expandto := old_expandto
    }
    else
        LV_Add("", load_opts, load_expand, load_expandto)

    LV_Organize("LV_hslist")
    Gosub, CreateHSScript   ; Append strings
 }
 if !hscount
    SB_SetText("`t" . hscount . " Hotstrings currently active", 2)
 
 if ahkexist && FileExist(hsloc)
    Run, %ahkexist%\AutoHotkey.exe %hsloc%,,, hslPID
 else
    Run, %resahk% %hsloc%,,, hslPID
return
;}

CreateHSScript:
;{
 hs_expand := uriSwap(hs_expand, 2)
 hs_expandto := uriSwap(hs_expandto , 2)
 load_expand := uriSwap(load_expand, 2)
 load_expandto := uriSwap(load_expandto , 2)

 if !FileExist(hsloc)
 {
    hsfileopts =
    (Ltrim
        #NoEnv
        #SingleInstance Force
        #NoTrayIcon
        ; --
        SetBatchLines -1
        F11::Suspend`n`n
    )
 FileAppend, %hsfileopts%, %hsloc%
 return
 }
  
 if (hs_loading && hs_isadv)         ; This is because im using the AdvHotstring subroutine which sets hs_loading
 {
    if loadisMultiline
    {
        loadisMultiline :=
        if load_iscommand
            script := "`n:" . load_opts . ":" . load_expand . "::`n" . load_expandto . "`nreturn`n`n"
        else
            script := "`n:" . load_opts . ":" . load_expand . "::`n(`n" . load_expandto . "`n)`nreturn`n`n"
    }
    
    else if !loadisMultiline
    {
        if load_iscommand
            script := "`n:" . load_opts . ":" . load_expand . "::`n" . load_expandto . "`nreturn`n`n"
        else
            script := ":" . load_opts . ":" . load_expand . "::" . load_expandto . "`n"
    }
 }
 
  if (hs_loading && !hs_isadv)
 {
    if (!load_opts || !load_expand || !load_expandto)
        return
    if load_iscommand
        script := "`n:" . load_opts . ":" . load_expand . "::`n" . load_expandto . "`nreturn`n`n"
    else
    {
        if loadIsMultiline
        {
            loadIsMultiline :=
            script := "`n:" . load_opts . ":" . load_expand . "::`n(`n" . load_expandto . "`n)`nreturn`n`n"
        }
        else
            script := ":" . load_opts . ":" . load_expand . "::" . load_expandto . "`n"
    }
 }
 
 if (!hs_loading && !hs_isadv)
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
 exec := xpath(xml, "/root/hotkeys/hk[@key=" . key . "]/@exec/text()")
 type := xpath(xml, "/root/hotkeys/hk[@key=" . key . "]/@type/text()")
 if type = File
    Run % path := xpath(xml,"/root/hotkeys/hk[@key=" . key . "]/@dir/text()") . "\" . exec
 else if type = Folder
    Run % path := xpath(xml,"/root/hotkeys/hk[@key=" . key . "]/@dir/text()")
return
;}

GuiDropFiles:
;{
 if a_guicontrol = LV_hklist
 {
    dropped := 1
    SplitPath, a_guievent,prog_exec, prog_dir,, prog_name
    if a_guievent contains .lnk             ; Resolve the link target instead of using the link's directory
    {
        FileGetShortcut, %a_guievent%, prog_target
        SplitPath, prog_target,prog_exec, prog_dir,, prog_name
        GuiControl, 96:, e_progpath, % prog_target
    }
    else
        GuiControl, 96:, e_progpath, % a_guievent
 }
 StringUpper, prog_name, prog_name, T
 GuiControl, 96: Focus, ddl_key
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
            prog_hkS := hkSwap(prog_hkL, "short")
            Hotkey, %prog_hkS%, Off
            DelxmlInstance("hk")
            CleanXML()
            LV_Delete(next)
        }
        LV_Organize("LV_hklist")
    }

    if a_guievent = DoubleClick
    {
        if sel_row = 0
        {
            Gosub, AddHotkey
            return
        }
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
        GuiControl, 96:, e_progpath, % prog_dir
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
    if a_guievent = Normal
        sel_row := a_eventinfo                      ; Currently selected Row
    
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
        LV_Organize("LV_hslist")
        sleep 100
        FileDelete, %hsloc%
        LV_Delete()             ; Delete all rows to reload them from xml file with LVHS_Load
        Gosub, LVHS_Load
    }

    if a_guievent = DoubleClick
    {
        if sel_row = 0
        {
            Gui, 2: Show, w420 h335, % "Advanced Hotstring Setup"
            return
        }
        Gui, 1: Default
        Gui, Submit, NoHide
        Gui, ListView, LV_hslist
        xpath_load(xml, s_xml)
        LV_GetText(hs_opts, sel_row, 1)
        LV_GetText(hs_expand, sel_row, 2)
        LV_GetText(hs_expandto, sel_row, 3)
        hs_expand := uriSwap(hs_expand,1)
        hs_iscommand := xpath(xml, "/root/hotstrings/hs[@expand=" . hs_expand . "]/@iscommand/text()")
        
        if (hs_expandto = "Multiline (Double Click to see the whole text)")
            hs_expandto := xpath(xml, "/root/hotstrings/hs[@expand=" . hs_expand . "]/text()")
        
        hs_expandto := uriSwap(hs_expandto, 2)
        hs_expand := uriSwap(hs_expand,2)
        GuiControl, 2:, ahs_opts, % hs_opts
        GuiControl, 2:, ahs_expand, % hs_expand
        GuiControl, 2:, ahs_expandto, % hs_expandto
        if !hs_iscommand
            GuiControl, 2:, ahs_iscommand, 0
        else
            GuiControl, 2:, ahs_iscommand, % hs_iscommand
            
        if hs_iscommand
            GuiControl, 2: Enable, % "Test Code"
        else if !hs_iscommand
            GuiControl, 2: Disable, % "Test Code"
            
        Gui, 2: Show, w420 h335, % "Advanced Hotstring Setup"
    }
 }
return
;}

OnClipboardChange:
;{
 if autoCode
 {
    Gosub, LiveRun
    autoCode := False
    return
 }
 if (Clipboard = oldScript || clipold)
   return
 oldScript := Clipboard
 kword_count :=
 Gosub, ReadXML
 
/*
* This checks if the Clipboard contains keywords from ahk scripting
* if it contains more than x ammount of keywords it will fire up the pastebin
* routines. You can change this to suit you better.
*/
 Loop, parse, ahk_keywords, `n, `r
 {
    if RegexMatch(Clipboard, "i)\b" . a_loopfield . "\b\(?")
        kword_count++
 }
 if kword_count >= 5
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
 if (!autoCode && pastepop_ena)
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

PopYes:                                                             ; Popup YES
;{
 Gui, Hide                                                          ; Hide Popup
AUS:
 /*
  * This will replace the includes for the actual files to avoid
  * the issues of missing includes on Pasted code
  */
 Loop, parse, Clipboard, `n, `r
 {
    if a_loopfield contains #Include
    {
        inc_file := RegexReplace(a_loopfield, "i)^#include\s|\*i\s|\s;.*")
        if inc_file contains .ahk
            FileRead, inc_%a_index%, %inc_file%
        else
            SetWorkingDir, %inc_file%
        Stringreplace, Clipboard, Clipboard, %a_loopfield%, % inc_%a_index%
    }
 } ; Finish Replacing
 SetWorkingDir %A_ScriptDir%
 
 if aus
{
    ; Some default values
    xpath_load(xml, s_xml)
    autoirc  := xpath(xml, "/root/options/AUS/AutoHotkey/@autoirc/text()")
    ahk_code := Clipboard
    pb_name  := "Code auto uploaded with " . s_name . " v" . s_version
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
 GuiControl, 98:, ahk_code, %Clipboard%
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
    
    uriSwap(POST, 3)
    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    RegexMatch(paste_url, "Paste\s(#(.*?)<)", Match)
    if !Match2
    {
        Msgbox, % "There was a problem while uploading, try again or pick another pastebin service"
        return
    }
    paste_url := "http://www.autohotkey.net/paste/" . Match2
    Pasted()
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
    
    uriSwap(POST, 3)
    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    Pasted()
 }
 else if ddl_pastebin = Paste2.org
 {
    URL  := "http://paste2.org/new-paste"
    POST := "lang=text"
         . "&description="   . pb_name
         . "&code="          . ahk_code
         . "&parent=0"
    
    uriSwap(POST, 3)
    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)

    RegexMatch(paste_url, "Paste\s(\b\d+)", Match)
    if !Match1
    {
        Msgbox, % "There was a problem while uploading, try again or pick another pastebin service"
        return
    }
    paste_url := "http://paste2.org/p/" . Match1
    Pasted()
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

ImageUpload:
;{
 if FileExist(scWin)
    image := scWin
 else if FileExist(scRect)
    image := scRect

 iunick := "AHK-TK_" . a_computername
    
 RunWait %comspec% /c "%rescurl% -i -F nickname=`"%iunick%`" -F image=@`"%image%;type=image/png`" -F disclaimer_agree=Y -F Submit=Submit -F mode=add http://www.imagebin.org/index.php  > `"%a_temp%`"\url",, Hide
 FileRead, url, %a_temp%\url
 FileDelete, %a_temp%\url
 RegexMatch(url,"\w+:\s(\d+)", Match)
 clipold := Clipboard
 if !Match1
 {
    Tooltip, % "There was an error uploading the picture, try again.", 5, 5
    Sleep, 5 * sec
    Tooltip
    return
 }
 Tooltip, % Clipboard := "http://www.imagebin.org/" . Match1, 5, 5
 SetTimer, CheckCtrlV, 30
return
;}

CheckCtrlV:
;{
 if (GetKeyState("Ctrl", "p") && GetKeyState("v", "p") || GetKeyState("Escape", "p"))
 {
    Clipboard := clipold
    clipold :=
    SetTimer, CheckCtrlV, off
    Tooltip, % "Your Clipboard has been restored", 5, 5
    Sleep, 5 * sec
    Tooltip
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
    if !br_prog
    {
        SplitPath, e_progpath,prog_exec, prog_dir,, prog_name
        StringUpper, prog_name, prog_name, T
    }
    if (prog_hkS = "None")
    {
       prog_hkS := 
       MsgBox, % "Please select a hotkey"
       Gui, 96: Show, w420 h210
       return
    }
    if CheckLV("LV_hklist")
    {
        br_prog := False
        LV_Add("", r_selfof, prog_name, prog_hkL, prog_dir)
        xpath(xml, "/root/hotkeys/hk[+1]/@type/text()", r_selfof)
        xpath(xml, "/root/hotkeys/hk[last()]/@name/text()", prog_name)
        xpath(xml, "/root/hotkeys/hk[last()]/@exec/text()", prog_exec)
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
 hs_loading := False
 hs_isadv := False
 hs_opts :=  hs_autoexpand . hs_dnd . hs_trigger . hs_raw

 if  !hs_expand
 {
    MsgBox, % "Please specify a hotstring"
    GuiReset(1)
    GuiReset(2)
    return
 }
 if CheckLV("LV_hslist")
 {
    LV_Add("", hs_opts, hs_expand, hs_expandto)
    hs_expand := uriSwap(hs_expand , 1)
    hs_expandto := uriSwap(hs_expandto , 1)
    xpath(xml, "/root/hotstrings/hs[+1]/@opts/text()", hs_opts)
    xpath(xml, "/root/hotstrings/hs[last()]/@expand/text()", hs_expand)
    xpath(xml, "/root/hotstrings/hs[last()]/@expandto/text()", hs_expandto)
    xpath(xml, "/root/hotstrings/hs[last()]/@iscommand/text()", hs_iscommand)
    Sleep, 100
    xpath_save(xml, s_xml)
    LV_Organize("LV_hslist")    ; Sort the LV and set the status messages
    CleanXML()
    Gosub, CreateHSScript
    
    If ahkexist && FileExist(hsloc)
        Run, %ahkexist%\AutoHotkey.exe %hsloc%,,, hslPID
    else
        Run, %resahk% %hsloc%,,, hslPID
    GuiReset(1)
 }
return
;}

AdvHotstring:
;{
 Gui, 2: Submit
 Gui, 1: Default
 Gui, ListView, LV_hslist
 
 hs_loading := False
 hs_isadv := True
 hs_opts := ahs_opts
 hs_expand := ahs_expand
 hs_expandto := ahs_expandto
 
 if  !hs_expand
 {
    MsgBox, % "Please specify a hotstring"
    GuiReset(1)
    GuiReset(2)
    return
 }
 if CheckLV("LV_hslist")
 {
    Loop, Parse, hs_expandto, `n,`r
    {
        if (a_index >= 2 && a_loopfield || InStr(a_loopfield, "0xa"))
            isMultiline := True            
    }
    if isMultiline
        hs_expandto := "Multiline (Double Click to see the whole text)"
    else
        hs_expandto := RegexReplace(hs_expandto, "\n", "")  ; Make sure there are no accidental "`n" laying around 
                                                            ; on a non multiline hotstring
    hs_expand := uriSwap(hs_expand, 1)
    hs_expandto := uriSwap(hs_expandto , 1)
    ahs_expandto := uriSwap(ahs_expandto, 1)
    
    xpath(xml, "/root/hotstrings/hs[+1]/@opts/text()", hs_opts)
    xpath(xml, "/root/hotstrings/hs[last()]/@expand/text()", hs_expand)
    if isMultiline
    {
        isMultiline :=
        xpath(xml, "/root/hotstrings/hs[last()]/text()", ahs_expandto)
    }
    else
        xpath(xml, "/root/hotstrings/hs[last()]/@expandto/text()", hs_expandto)    
    xpath(xml, "/root/hotstrings/hs[last()]/@iscommand/text()", ahs_iscommand)
    Sleep, 100
    xpath_save(xml, s_xml)
    LV_Organize("LV_hslist")    ; Sort the LV and set the status messages
    CleanXML()
    LV_Delete()
    FileDelete, %hsloc%
    Gosub, LVHS_Load
    GuiReset(1)
    GuiReset(2)
 }
return
;}

ahsIsCommand:
;{
 Gui, 2: Default
 Gui, 2: Submit, NoHide
 
 if ahs_iscommand
    GuiControl, 2: Enable, Test Code
 else if !ahs_iscommand
    GuiControl, 2: Disable, Test Code

return
;}

TimedShutdown:
;{
 savelivecode()
 GuiControl,, live_code, % TimedShutdown_s
 GuiControl,, SaveXYCoords, 0
 GuiControl,, TextControlsRefs, 0 
return
;}

SaveXYCoords:
;{
 savelivecode()
 GuiControl,, live_code, % SaveXYCoords_s
 GuiControl,, TimedShutdown, 0
 GuiControl,, TextControlsRefs, 0
return
;}

TextControlsRefs:
;{
 savelivecode()
 GuiControl,, live_code, % TextControlsRefs_s
 GuiControl,, TimedShutdown, 0
 GuiControl,, SaveXYCoords, 0
return
;}

RetrieveLC:
;{
 GuiControl,, TimedShutdown, 0
 GuiControl,, SaveXYCoords, 0
 GuiControl,, TextControlsRefs, 0
 
 if w_livecode
 {
    GuiControl,,live_code, % w_livecode
    w_livecode := 
 }
 else
    GuiControl,,live_code, % s_livecode
return
;}

LiveRun:
;{
 if a_gui = 2
    Gui, 2: Default
 Gui, Submit, NoHide

 if lcf_name := a_temp . "\" . RName(8, "ahk")        ; Random Live Code Path
 {
    if a_gui = 1
        append_code := live_code
    else if a_gui = 2
        append_code := ahs_expandto
    else 
        append_code := Clipboard
    
    if !InStr(append_code,"Gui")
        append_code .= "`n`nExitApp"
    else if !InStr(append_code,"GuiClose")
    {
        if !InStr(append_code,"return")
            append_code .= "`nreturn"
        append_code .= "`n`nGuiClose:`nExitApp"
    }
    live_code =
    (Ltrim
        #NoEnv
        #SingleInstance Force
        ; --
        SendMode Input
        SetBatchLines -1
        ; --
        sec         :=  1000               ; 1 second
        min         :=  sec * 60           ; 1 minute
        hour        :=  min * 60           ; 1 hour
        
        %append_code%
        
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
        Run, %resahk% %lcf_name%
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
 if InStr(f_saved, ".ahk")               ; Check whether the user added the file extension or not
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
 GuiControl,, TimedShutdown, 0
 GuiControl,, SaveXYCoords, 0
 GuiControl,, TextControlsRefs, 0
return
;}

ProgBrowse:
;{
 Gui, 96: +OwnDialogs
 Gui, 96: Submit, NoHide
 br_prog := True
 ; File or Folder?
 if r_selfof = 1
    FileSelectFile, sel_prog, 3, %a_programfiles%, % "Select the program to be launched"
 else if r_selfof = 2
    FileSelectFolder, sel_prog, *%a_programfiles%, 3, % "Select the folder to be launched"

 SplitPath, sel_prog,prog_exec, prog_dir,, prog_name
 if r_selfof = 2
    prog_dir := prog_dir . "\" . prog_name          ; Needed to have the complete dir since prog_dir would not have
                                                    ; the last folder name included in this case.
 StringUpper, prog_name, prog_name, T

 if !sel_prog
    GuiControl, 96:, e_progpath, %a_programfiles%
 else
 {
    GuiControl, 96:, e_progpath, % sel_prog
    GuiControl, 96: Focus, ddl_key
 }
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
    Ena_Control(1,1,0,0)
 else if ddl_pastebin = Pastebin.com
    Ena_Control(1,1,1,1)
 else if ddl_pastebin = Paste2.org
    Ena_Control(1,0,0,0)
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
 if a_gui = 2
 {
    GuiReset(1)
    GuiReset(2)
 }
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

GuiSize:
;{
 if a_eventinfo = 1
 {
    main_toggle := !main_toggle
    Gui, Hide
 }
return
;}

Clean:
;{
 Process,Close, %hslPID%
 FileDelete, %hsloc%
 if FileExist(hsloc)
    MsgBox, % "File could not be deleted"
 FileRemoveDir, %resahk%, 1
 FileDelete, % a_temp . "\" . "UC.png"
50GuiClose:
50GuiEscape:
ExitApp
;}
;-

;+--> ; ---------[Functions]---------
Ena_Control(name = "", subdomain = "", exposure = "", expiration = ""){
    _var_list  := "name|subdomain|exposure|expiration"

    Loop, parse, _var_list, |
    {
        if %a_loopfield% = 1
            GuiControl, 98:  Enable, pb_%a_loopfield%
        else if %a_loopfield% = 0
            GuiControl, 98: Disable, pb_%a_loopfield%
    }
}
Pasted(){
    Global
    FormatTime,cur_time,,[MMM/dd/yyyy - HH:mm:ss]
    code_preview :=
    xpos := wa_Right - 250 - 5
    ypos := wa_Bottom - 90
    ; clipold := Clipboard
    Tooltip, % Clipboard := paste_url, 5, 5
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
    ), % "res\pastebin-log.dat"
    Sleep, 3 * sec
    Gui, 97: Hide
    SetTimer, CheckCtrlV, 30
}
GuiReset(guinum){
    Global
    if guinum = 1
    {
        Gui, 1: Default
        GuiControl,, hs_expand,
        GuiControl,, hs_expandto,
        GuiControl,, hs_autoexpand, 1
        Loop, Parse, hs_optlist, |
            GuiControl,, %a_loopfield%, 0
    }

    if guinum = 96
    {
        Gui, 96: Default
        GuiControl, 96: Focus, Browse
        GuiControl, 96:, e_progpath, % a_programfiles
        GuiControl, 96:, ddl_key,|%keylist%
        GuiControl, 96:, r_selfof, 1
        Loop, Parse, mod_list, |
            GuiControl, 96:, %a_loopfield%, 0
        WinActivate, ahk_id %ActiveHwnd%
    }

    if guinum = 2
    {
        Gui, 2: Default
        GuiControl, 2:, ahs_opts,
        GuiControl, 2:, ahs_expand,
        GuiControl, 2:, ahs_expandto,
        GuiControl, 2:, ahs_iscommand, 0
    }
    Gui, 1: Default                         ; Go Back to the defaults
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

            if (cname != prog_name && chk != prog_hkL)
            {
                isNew := True
                continue
            }
            else if (cname = prog_name || chk = prog_hkL)
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
        xpath_load(xml, s_xml)
        Loop, % lvcount
        {
            LV_GetText(chs_expand, a_index, 2)
            LV_GetText(chs_expandto, a_index, 3)
            chs_expand := uriSwap(chs_expand, 1) ; encode
            if (chs_expandto = "Multiline (Double Click to see the whole text)")
            {
                chs_expandto := xpath(xml, "/root/hotstrings/hs[@expand=" . chs_expand . "]/text()")
                chs_expandto := uriSwap(chs_expandto, 2)
            }
            chs_expand := uriSwap(chs_expand, 2) ; decode back because we are working with plain text now.
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
            hs_expand := uriSwap(hs_expand, 1)
            hs_expandto := uriSwap(hs_expandto, 1)
            
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
uriSwap(str, action){
    if action = 1
    {
        oldformat := a_formatinteger
        SetFormat, integer, hex
        loop, parse, str
            e_str := hx_str .= regexreplace(a_loopfield, "[^\w]", asc(a_loopfield))
        SetFormat, integer, % oldformat
        return e_str
    }
    else if action = 2
    {
        Loop
        {
            if !RegExMatch(str, "((?<=0x)[a-f]|(?<=0x)[\da-f]{1,2})", hex)
                break
            str := regexreplace(str,"0x" . hex, chr("0x" . hex))
        }
        return d_str := str
    }
    else if action = 3
    {
        oldformat := a_formatinteger
        SetFormat, integer, hex
        loop, parse, str
            e_str := regexreplace(e_str := hx_str .= RegexReplace(a_loopfield, "[^\w]", asc(a_loopfield))
            , "0x", "%")
        SetFormat, integer, % oldformat
        return e_str
    }
    else if action = 4
    {
        Loop
        {
            if !RegExMatch(str, "((?<=%)[a-f]|(?<=%)[\da-f]{1,2})", hex)
                break
            str := regexreplace(str,"%" . hex, chr("0x" . hex))
        }
        return d_str := str
    }
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
            else if a_index = 2
                LV_ModifyCol(a_index, "Sort AutoHdr")
            else if a_index = 3
                LV_ModifyCol(a_index, "AutoHdr")
        }
        if hscount = 1
            SB_SetText("`t" . hscount . " Hotstrings currently active", 2)
        else
            SB_SetText("`t" . hscount . " Hotstrings currently active", 2)
    }
}
RName(length = "", filext = ""){
	if !length
		Random, length, 8, 15
	Loop,26
	{
		n .= chr(64+a_index)
		n .= chr(96+a_index)
	}
	n .= "0123456789"
	Loop,% length {
		Random,rnd,1,% StrLen(n)
		Random,UL,0,1
		RName .= RegExReplace(SubStr(n,rnd,1),".$","$" (round(UL)? "U":"L") "0")
	}
	if !filext
		return RName
	Else
		return RName . "." . filext
}
SaveLiveCode(){
    Global
    Gui, Submit, NoHide
    if live_code contains %TextControlsRefs_s%, %SaveXYCoords_s%, %TimedShutdown_s%
        live_code :=
    else
        w_livecode := live_code
}
MimeType(ByRef Binary) {
   MimeTypes:="424d image/bmp|4749463 image/gif|ffd8ffe image/jpeg|89504e4 image/png|4657530"
          . " application/x-shockwave-flash|49492a0 image/tiff"
   @:="0123456789abcdef"
   Loop,8
      hex .= substr(@,(*(a:=&Binary-1+a_index)>>4)+1,1) substr(@,((*a)&15)+1,1)
   Loop,Parse,MimeTypes,|
      if ((substr(hex,1,strlen(n:=RegExReplace(A_Loopfield,"\s.*"))))=n)
         Mime := RegExReplace(A_LoopField,".*?\s")
   Return (Mime!="") ? Mime : "application/octet-stream"
}
WM_LBUTTONDBLCLK(wParam, lParam){
    Global
    if a_guicontrol = hs_expandto
    {
        Gui, Submit, NoHide
        Gosub, VarSwap
        ahsIsNew := True
        hs_opts :=  hs_autoexpand . hs_dnd . hs_trigger . hs_raw
        ;cControl := a_guicontrol                            ; Control that called the Gui #2
        
        GuiControl, 2:, ahs_opts, % hs_opts
        GuiControl, 2:, ahs_expand, % hs_expand
        GuiControl, 2:, ahs_expandto, % hs_expandto
        if !hs_iscommand
            GuiControl, 2:, ahs_iscommand, 0
        else
            GuiControl, 2:, ahs_iscommand, % hs_iscommand

        if hs_iscommand
            GuiControl, 2: Enable, Test Code
        else if !hs_iscommand
            GuiControl, 2: Disable, Test Code

        Gui, 2: Show, w420 h335, % "Advanced Hotstring Setup"
    }
}
WriteBin(byref bin,filename,size){
   h := DllCall("CreateFile","str",filename,"Uint",0x40000000
            ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0)
   IfEqual h,-1, SetEnv, ErrorLevel, -1
   IfNotEqual ErrorLevel,0,ExitApp ; couldn't create the file
   r := DllCall("SetFilePointerEx","Uint",h,"Int64",0,"UInt *",p,"Int",0)
   IfEqual r,0, SetEnv, ErrorLevel, -3
   IfNotEqual ErrorLevel,0, {
      t = %ErrorLevel%              ; save ErrorLevel to be returned
      DllCall("CloseHandle", "Uint", h)
      ErrorLevel = %t%              ; return seek error
   }
   result := DllCall("WriteFile","UInt",h,"Str",bin,"UInt"
               ,size,"UInt *",Written,"UInt",0)
   h := DllCall("CloseHandle", "Uint", h)
   return, 1
}
matchclip(type){
	
    global fnct_name1
    clipold := Clipboard
	if type = var
		URL := "http://www.autohotkey.com/docs/Variables.htm"
	if type = fnct
		URL := "http://www.autohotkey.com/docs/Functions.htm"
    if type = cmd
		URL := "http://www.autohotkey.com/docs/Commands.htm"
    
	httpQuery(htm, URL)
	VarSetCapacity(htm, -1)
    
	if type = var
    {
        if !RegexMatch(htm, "i)" . Clipboard, Match)
            return 0
        if InStr(Clipboard, "screen")
            Match := URL . "#Screen"
        else if InStr(Clipboard, "caret")
            Match := URL . "#Caret"
        else if InStr(Clipboard, "guiheight")
            Match := URL . "#GuiWidth"
        else
            Match := URL . "#" . SubStr(Match, 3)
        return Match
    }
    if type = fnct
    {
        if !RegexMatch(htm, "i)" . fnct_name1, Match)
            return 0
        if (InStr(fnct_name1, "regex") || InStr(fnct_name1, "dllcall"))
            return Match := matchclip("cmd")
        else if InStr(fnct_name1, "asc")
            return Match := URL . "#Asc"
        else if InStr(fnct_name1, "abs")
            return Match := URL . "#Abs"
        else
            Match := URL . "#" . Match
        return Match
    }
    if type = cmd
    {
        if ((InStr(Clipboard, "clipboard") || InStr(Clipboard, "thread")) && !InStr(Clipboard, "regex"))
            URL := "http://www.autohotkey.com/docs/misc/"
        else
            URL := "http://www.autohotkey.com/docs/commands/"
        
        if !RegexMatch(htm, "i)>(" . RegexReplace(Clipboard, "\W.*", "") . ").*?<", Match)
            return 0
        if InStr(Clipboard, "#")
            Match := URL . RegexReplace(Clipboard, "#", "_") . ".htm"
        else if (InStr(Clipboard, "regex") || InStr(Clipboard, "dllcall"))
            Match := URL . RegexReplace(Clipboard, "\s?\(.*\).*", "") . ".htm"
        else
            Match := URL . Match1 . ".htm"
        return Match
    }
    if type = manual
    {
        Match := RegexReplace(Clipboard, "\(.*", "")
        if InStr(Match, "guiwidth")
            Match := "A_GuiWidth"
        ToolTip, % "Searching for """ . Match . """ on the documentation files"
        Sleep 2*sec
        URL := "http://www.autohotkey.com/search/search.php"
        POST := "site=4"
             . "&refine=1"
             . "&template_demo=phpdig.html"
             . "&result_page=search.php"
             . "&query_string=" . Match
             . "&search=Go+..."
             . "&option=start"
             . "&path=docs%2F%25"

        HttpQuery(html := "", URL, POST)
        VarSetCapacity(html, -1)
        if (Clipboard = "WinGet")
            RegexMatch(html, "99.80 %.+?(href=""(.+?)"")", Match)
        else if (Clipboard = "ErrorLevel")
            RegexMatch(html, "4.+82.92 %.+?(href=""(.+?)"")", Match)
        else
            RegexMatch(html, "100.00 %.+?(href=""(.+?)"")", Match)
        return Match2
    }
	return 0
}
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
!Esc::ExitApp
Pause::Reload
F12::Suspend
;+> ; [Ctrl + S] Save and Reload scripts
#IfWinActive .*\.ahk - .*pad
^s::
Send, ^s
Reload
return
#IfWinActive
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
;+> ; [Ctrl + Alt + LButton] Auto Run Selected Code
^!LButton::
 autoCode := True
 Send, ^c
return
;-
;+> ; [LButton + Shift] Command Detection
~LButton::
 stime := a_tickcount               ; Start Time
 KeyWait, LButton
 etime := a_tickcount - stime       ; End Time
 if etime >= 500                    ; The mouse was dragged
 {
    KeyWait, Shift, D T.5
    if ErrorLevel
        return
    clipold := Clipboard
    Send, ^c
    ClipWait
    Sleep 10
	Loop, Parse, Clipboard,`n,`r
		if a_index > 1
			return
    ToolTip, % Clipboard

	if RegexMatch(Clipboard, "i)a_\w+")
		Match := matchclip("var")
	else if RegexMatch(Clipboard, "i)\s?(\w+)\(.*", fnct_name)
		Match := matchclip("fnct")
	else
		Match := matchclip("cmd")
	
    httpQuery(htm, Match)
    VarSetCapacity(htm, -1)
    if (InStr(htm, "403") || InStr(htm, "404") || !Match)
    {
        ToolTip, % "Not found. `nTrying a manual search, results may be inaccurate"
        Sleep 3*sec
        Match := matchclip("manual")
        if !Match
            ToolTip, % "Not found in the documentation files"
    }
    
	if WinActive("i).*post.*")
		Send, {raw}[url=%Match%]%Clipboard%[/url]
	else
        Run, % Match
    Clipboard := clipold
    clipold :=
    Sleep, 2*sec
    ToolTip
 }
return
;-
;+> ; [Alt + LButton] Screen Capture Active Window/Area
#IfWinNotActive ahk_class SWarClass
!LButton::
 CoordMode, Mouse, Screen
 rect := False
 MouseGetPos, scXL, scYT, scWinHwnd
 WinMove, % "SelBox",, %scXL%, %scYT%        ; Move the "Selection Box window" to current mouse position
 Sleep, 150
 if GetKeyState("LButton", "P")
 {
    Gui, 3: Show, w1 h1 x%scXL% y%scYT%, % "SelBox"
    WinSet, Transparent, 120, % "SelBox"
    While GetKeyState("LButton", "P")
    {
        CoordMode, Mouse, Screen
        MouseGetPos, scXR, scYB             ; This must be relative to the screen for use with the ScreenCapture
        CoordMode, Mouse, Relative
        MouseGetPos, rel_scXR, rel_scYB     ; This is just for creating the selection window, it must be relative
        WinMove, % "SelBox",,,, %rel_scXR%, %rel_scYB%
        ToolTip, %rel_scXR%`, %rel_scYB%
        if GetKeyState("RButton", "P")
        {
            ToolTip
            Gui, 3: Show, w1 h1 x0 y0, % "SelBox"
            return
        }
    }
    ToolTip
    Gui, 3: Show, w1 h1 x0 y0, % "SelBox"
    CaptureScreen(scXL "," scYT "," scXR "," scYB, 0, scRect := a_temp . "\scRect_" . RName(0,"png"))
    rect := True
 }
 if (!rect && scWinHwnd != DeskHwnd)
    CaptureScreen(1, 0, scWin := a_temp . "\scWin_" . RName(0,"png"))
 Gosub, ImageUpload
 FileDelete, %scWin%
 FileDelete, %scRect%
return
#IfWinNotActive
;-
;+> ; [Hotkeys for Edit controls]
#IfWinActive, ahk_group Ahk_Tk
^d::                    ; [Ctrl + D] Duplicate Line
 clipold := Clipboard
 Send, {Home}+{End}^c{End}{Enter}^v
 Clipboard := clipold
 clipold :=
return

^+Up::                  ; [Ctrl + Shift + Up] Move Up Current Line
 clipold := Clipboard
 Send, {Home}+{End}^x{Delete}{Up}{Enter}{Up}^v{Home}
 Clipboard := clipold
 clipold :=
return

^+Down::                ; [Ctrl + Shift + Up] Move Down Current Line
 clipold := Clipboard
 Send, {Home}+{End}^x{Delete}{End}{Enter}^v{Home}
 Clipboard := clipold
 clipold :=
return

^+u::                   ; [Ctrl + Shift u] UPPERCASE
 clipold := Clipboard
 Send, ^x
 StringUpper, Clipboard, Clipboard
 Send, ^v
 Clipboard := clipold
 clipold :=
return

^u::                    ; [Ctrl + u] lowercase
 clipold := Clipboard
 Send, ^x
 StringLower, Clipboard, Clipboard
 Send, ^v
 Clipboard := clipold
 clipold :=
return

^q::                    ; [Ctrl + q] Comment one Line
 clipold := Clipboard
 Clipboard :=
 Send, ^x
 if !Clipboard
 {
    Send, {Home}+{Right}^c
    if Clipboard contains `;
        Send, {Home}{Delete 2}{Home}
    else
        Send, {Home}; {Home}
 }
 else
 {
    Loop, Parse, Clipboard, `n, `r
    {
        if !a_loopfield
        {
            ctext .= "`n"
            continue
        }
        if a_loopfield contains `;
            ctext .= RegexReplace(a_loopfield, ";\s?", "") . "`n"
        else
            ctext .= "; " . a_loopfield . "`n"
    }
    SendRaw %ctext%
    Send, {BackSpace}
 }
 ctext :=
 Clipboard := clipold
 clipold :=
return
+Tab::BackSpace         ; [Shift + Tab] delete Tab
#IfWinActive
;-
;-

;+--> ; ---------[Includes]---------
#Include *i %a_scriptdir%\extlib ; Current Library
#Include httpQuery.ahk
#Include klist.ahk
#Include xpath.ahk
#Include hkSwap.ahk
#Include sc.ahk
;-

/*
 *==================================================================================
 *                          		END OF FILE
 *==================================================================================
 */
 