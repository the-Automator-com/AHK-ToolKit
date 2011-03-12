/*
 * =============================================================================================== *
 * Author           : RaptorX   <graptorx@gmail.com>
 * Script Name      : AutoHotkey ToolKit (AHK-ToolKit)
 * Script Version   : 0.5
 * Homepage         : http://www.autohotkey.com/forum/topic61379.html#376087
 *
 * Creation Date    : July 11, 2010
 * Modification Date: February 19, 2011
 *
 * Description      :
 * ------------------
 *
 * -----------------------------------------------------------------------------------------------
 * License          :           Copyright ©2011 RaptorX <GPLv3>
 *
 *          This program is free software: you can redistribute it and/or modify
 *          it under the terms of the GNU General Public License as published by
 *          the Free Software Foundation, either version 3 of  the  License,  or
 *          (at your option) any later version.
 *
 *          This program is distributed in the hope that it will be useful,
 *          but WITHOUT ANY WARRANTY; without even the implied warranty  of
 *          MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the
 *          GNU General Public License for more details.
 *
 *          You should have received a copy of the GNU General Public License
 *          along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * -----------------------------------------------------------------------------------------------
 *
 * [GUI Number Index]
 *
 * GUI 01 - AutoHotkey ToolKit [MAIN GUI]
 * GUI 02 - Add Hotkey
 * GUI 03 - Add Hotstring
 * GUI 04 - Import Hotkeys/Hotstrings
 * GUI 05 - Export Hotkeys/Hotstrings
 * GUI 06 - Preferences
 * GUI 07 - Add Snippet
 * GUI 08 - About
 * GUI 98 - General Preferences
 * GUI 99 - Splash Window
 *
 * =============================================================================================== *
 */

;[Includes]{
#include *i %a_scriptdir%
#include lib\attach.h.ahk
#include lib\hash.h.ahk
#include lib\SCI.h.ahk
;}

;[Directives]{
#NoEnv
#SingleInstance Force
; --
SetBatchLines, -1
SendMode, Input
SetWorkingDir, %a_scriptdir%
OnExit, Exit
; --
;}

;[Basic Script Info]{
script              := object()

script.getparams    := "getparams"
script.update       := "update"
script.splash       := "splash"
script.autostart    := "autostart"

script.name         := "AHK-ToolKit"                                            ; Script Name
script.version      := "0.5"                                                    ; Script Version
script.author       := "RaptorX"                                                ; Script Author
script.email        := "graptorx@gmail.com"                                     ; Author's contact email
script.homepage     := "http://www.autohotkey.com/forum/topic61379.html#376087" ; Script Homepage
script.crtdate      := "July 11, 2010"                                          ; Script Creation Date
script.moddate      := "February 24, 2011"                                      ; Script Modification Date
script.conf         := "conf.xml"                                               ; Configuration file

script.getparams()
;}

;[General Variables]{
null        := ""
sec         := 1000 	            ; 1 second
min         := 60*sec  	            ; 1 minute
hour        := 60*min  	            ; 1 hour
;}

;[User Configuration]{
system := object(), system.mon := object(), system.wa := object()

RegRead,defBrowser,HKCR,.html                               ; Get default browswer
RegRead,defBrowser,HKCR,%defBrowser%\Shell\Open\Command     ; Get path to default browser + options
SysGet, mon, Monitor                                        ; Get the boundaries of the current screen
SysGet, wa, MonitorWorkArea                                 ; Get the working area of the current screen

system.defBrowser := defBrowser
system.mon.left := monLEFT, system.mon.right := monRIGHT, system.mon.top := monTOP, system.mon.bottom := monBOTTOM
system.wa.left := waLEFT, system.wa.right := waRIGHT, system.wa.top := waTOP, system.wa.bottom := waBOTTOM
;--
; Cleaning
defBrowser := monLEFT := monRIGHT := monTOP := monBOTTOM := waLEFT := waRIGHT := waTOP := waBOTTOM := null  ; Set all to null
;--
; Configuration file objects
conf := ComObjCreate("MSXML2.DOMDocument"), xsl := ComObjCreate("MSXML2.DOMDocument")
style =
(
<!-- Extracted from: http://www.dpawson.co.uk/xsl/sect2/pretty.html (v2) -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" />

<xsl:template match="*">
   <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
   </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()">
   <xsl:copy />
</xsl:template>

</xsl:stylesheet>
)
xsl.loadXML(style), style := null
if !conf.load(script.conf)
{
    if FileExist(script.conf)
    {
        Msgbox, 0x14
              , % "Error while reading the configuration file."
              , % "The configuration file is corrupt.`n"
                . "Do you want to load the default configuration file?`n`n"
                . "Note: `n"
                . "You will lose any saved hotkeys/hotstrings and all other personal data by this operation.`n"
                . "Choose No to abort the operation and try to recover the file manually."

        IfMsgBox Yes
        {
            Msgbox, 0x40
                  , % "Operation Completed"
                  , % "The default configuration file was successfully created. The script will reload."
            defConf(script.conf)
            Reload
            Pause       ; Fixes the problem of the Main Gui flashing because of being created before
                        ; the Reload is really performed.
        }
        IfMsgBox No
            ExitApp
    }
    else
        FirstRun()
} root:=conf.documentElement,options:=root.firstChild,hotkeys:=options.nextSibling,hotstrings:=hotkeys.nextSibling
;}

;[Main]{
script.autostart(options.selectSingleNode("//@sww").text)

if options.selectSingleNode("//@cfu").text
    script.update(script.version)

if options.selectSingleNode("//@ssi").text
    script.splash("res\AHK-TK_Splash.png")

TrayMenu(), CreateGui()
Return                      ; [End of Auto-Execute area]
;}

;[Labels]{
GuiHandler:     ;{
    GuiHandler()
return
;}

MenuHandler:    ;{
    MenuHandler()
return
;}

ListHandler:    ;{
    ListHandler()
return
;}

GuiSize:        ;{ Gui Size Handler
4GuiSize:
    if a_gui = 1
    {
        _guiwidth := a_guiwidth, _guiheight:= a_guiheight
        SB_SetParts(150,150,a_guiwidth-370,50)
        Gui, ListView, hkList
        LV_ModifyCol(4, "AutoHdr")
        Gui, ListView, hsList
        LV_ModifyCol(3, "AutoHdr")
        if a_eventinfo = 1
        {
            main_toggle := !main_toggle
            Gui, 01: Hide
        }
    }
    if a_gui = 4
    {
        Gui, 04: ListView, imList
        LV_ModifyCol(5, "AutoHdr")
    }
return
;}

GeneralAdd:     ;{
    Gui, %a_gui%: Submit
    WinActivate, ahk_id %$hwnd1%
    Gui, 01: -Disabled

    GuiReset(a_gui) ; ,savePrefs(), lvAdd(tabLast)
return
;}

QSearch:        ;{ Thanks to Adabo
	LV_Delete()
	Gui, Submit, NoHide
	While (A_Index < (FileLine_0 + 1))
		IfInString, FileLine_%A_Index%, %UserEdit%
			LV_Add("", A_Index, FileLine_%A_Index%)
Return
;}

Exit:
    if FileExist(a_temp "\ahkl.bak")
        FileDelete, %a_temp%\ahkl.bak

    Loop, % a_temp "\*.code"
        FileDelete, %a_loopfilefullpath%

    ExitApp
;}

;[Functions]{
; Gui related functions
FirstRun(){
    global

    Gui, +DelimiterSpace
    Gui, add, GroupBox, y5 w345 h95, % "General Preferences"
    Gui, add, Text, xp+10 yp+20 w325, % "This is the first time you are running " script.name ".`n"
                                      . "Here you can set some general options for the program.`n`n"
                                      . "You can change them at any time later on by going to the `n""Settings >"
                                      . " Preferences"" Menu."
    Gui, add, GroupBox, x10 y+15 w345 h70, % "Startup"
    Gui, add, CheckBox, xp+25 yp+20 Checked v_ssi, % "Show splash image"
    Gui, add, CheckBox, x+70 Checked v_sww, % "Start with Windows"
    Gui, add, CheckBox, x35 y+10 Checked v_smm, % "Start minimized"
    Gui, add, CheckBox, x+91 Checked v_cfu, % "Check for updates"

    Gui, add, GroupBox, x10 y+20 w345 h55, % "Main GUI Hotkey"
    Gui, add, DropDownList, xp+10 yp+20 w140 HWND$hkddl v_hkddl, % lst:=klist("all^", "mods msb")" None  "
    SetHotkeys(lst,$hkddl, "First Run")
    Gui, add, CheckBox, x+10 yp+3 v_ctrl, % "Ctrl"
    Gui, add, CheckBox, x+10 v_alt, % "Alt"
    Gui, add, CheckBox, x+10 v_shift, % "Shift"
    Gui, add, CheckBox, x+10 v_win, % "Win"

    Gui, add, GroupBox, x10 y+26 w345 h70, % "Other Tools"
    Gui, add, CheckBox, xp+15 yp+20 Checked v_ecd, % "Enable Code Detection"
    Gui, add, CheckBox, x+60 Checked v_ech, % "Enable Command Helper"
    Gui, add, CheckBox, x25 y+10 Checked v_eft, % "Enable Forum Tag-AutoComplete"
    Gui, add, CheckBox, x+14 Checked v_est, % "Enable Screen Tools"
    Gui, add, Text, x20 y+30 w325
              , % "Note:`n"
                . "The default hotkey is Win + ``  (Win key + Back tic)"

    Gui, add, Text, x0 y+10 w370 0x10
    Gui, add, Button, xp+280 yp+10 w75 gGuiHandler, % "&Save"
    Gui, show, w365 h405, % "First Run"

    Pause
}
TrayMenu(){
    Menu, Tray, NoStandard
    Menu, Tray, Click, 1
    Menu, Tray, add, % "Show Main Gui", GuiClose
    Menu, Tray, Default, % "Show Main Gui"
    Menu, Tray, add
    Menu, Tray, Standard
}
MainMenu(){
    global conf, script

    conf.load(script.conf), root:=conf.documentElement,options:=root.firstChild
    Menu, iexport, add, Import Hotkeys/Hotstrings, MenuHandler
    Menu, iexport, add
    Menu, iexport, add, Export Hotkeys/Hotstrings, MenuHandler

    Menu, File, add, &New`t`tCtrl+N, MenuHandler
    Menu, File, add, &Open`t`tCtrl+O, MenuHandler
    Menu, File, disable, &Open`t`tCtrl+O
    Menu, File, add, &Save`t`tCtrl+S, MenuHandler
    Menu, File, disable, &Save`t`tCtrl+S
    Menu, File, add, Save As`t`tCtrl+Shift+S, MenuHandler
    Menu, File, disable, Save As`t`tCtrl+Shift+S
    Menu, File, add, Close`t`tCtrl+W, MenuHandler
    Menu, File, disable, Close`t`tCtrl+W
    Menu, File, add, Close All`t`tCtrl+Shift+W, MenuHandler
    Menu, File, disable, Close All`t`tCtrl+Shift+W
    Menu, File, add, Delete`t`tDEL, MenuHandler
    Menu, File, add
    Menu, File, add, Import/Export, :iexport
    Menu, File, add
    Menu, File, add, Exit, Exit

    Menu, LO, add, Duplicate Line`t`tCtrl+D, MenuHandler
    Menu, LO, add, Split Lines`t`tCtrl+I, MenuHandler
    Menu, LO, add, Join Lines`t`tCtrl+J, MenuHandler
    Menu, LO, add, Move up current Line`t`tCtrl+Shift+Up, MenuHandler
    Menu, LO, add, Move down current Line`t`tCtrl+Shift+Down, MenuHandler

    Menu, Convert Case,add, Convert to Lowercase`t`tCtrl+U, MenuHandler
    Menu, Convert Case,add, Convert to Uppercase`t`tCtrl+Shift+U, MenuHandler

    Menu, Edit, add, Undo`t`tCtrl+Z, MenuHandler
    Menu, Edit, disable, Undo`t`tCtrl+Z
    Menu, Edit, add, Redo`t`tCtrl+Y, MenuHandler
    Menu, Edit, disable, Redo`t`tCtrl+Y
    Menu, Edit, add
    Menu, Edit, add, Cut`t`tCtrl+X, MenuHandler
    Menu, Edit, add, Copy`t`tCtrl+C, MenuHandler
    Menu, Edit, add, Paste`t`tCtrl+V, MenuHandler
    Menu, Edit, add, Select All`t`tCtrl+A, MenuHandler
    Menu, Edit, add
    Menu, Edit, add, Convert Case, :Convert Case
    Menu, Edit, add, Line Operations, :LO
    Menu, Edit, add, Trim Trailing Space`t`tCtrl+Space, MenuHandler
    Menu, Edit, add
    Menu, Edit, add, Set Read Only, MenuHandler

    Menu, Search, add, Find...`t`tCtrl+F, MenuHandler
    Menu, Search, add, Find in Files...`t`tCtrl+Shift+F, MenuHandler
    Menu, Search, add, Find Next...`t`tF3, MenuHandler
    Menu, Search, add, Find Previous...`t`tShift+F3, MenuHandler
    Menu, Search, add, Find && Replace`t`tCtrl+H, MenuHandler
    Menu, Search, add, Go to Line`t`tCtrl+G, MenuHandler
    Menu, Search, add, Go to Matching Brace`t`tCtrl+B, MenuHandler
    Menu, Search, disable, Go to Matching Brace`t`tCtrl+B

    Menu, Symbols, add, Show Spaces and TAB, MenuHandler
    Menu, Symbols, add, Show End Of Line, MenuHandler
    Menu, Symbols, add, Show All Characters, MenuHandler

    Menu, Zoom, add, Zoom in`t`tCtrl+Numpad +, MenuHandler
    Menu, Zoom, add, Zoom out`t`tCtrl+Numpad -, MenuHandler
    Menu, Zoom, add, Default Zoom`t`tCtrl+=, MenuHandler

    Menu, View, add, Always On Top, MenuHandler
    Menu, View, add, Snippet Library, MenuHandler
    Menu, View, disable, Snippet Library
    Menu, View, add
    Menu, View, add, Show Symbols, :Symbols
    Menu, View, disable, Show Symbols
    Menu, View, add, Zoom, :Zoom
    Menu, View, disable, Zoom
    Menu, View, add, Line Wrap, MenuHandler
    Menu, View, disable, Line Wrap

    Menu, RCW, add, L-Ansi, MenuHandler
    Menu, RCW, add, L-Unicode, MenuHandler
    Menu, RCW, add, Basic, MenuHandler
    Menu, RCW, add, IronAHK, MenuHandler

    Menu, Settings, add, Run Code With, :RCW
    Menu, Settings, disable, Run Code With
    Menu, Settings, add, Enable Command Helper, MenuHandler
    Menu, Settings, disable, Enable Command Helper
    Menu, Settings, add, Context Menu Options, MenuHandler
    Menu, Settings, disable, Context Menu Options
    Menu, Settings, add
    Menu, Settings, add, &Preferences`t`tCtrl+P, MenuHandler

    Menu, Help, add, Help, MenuHandler
    Menu, Help, disable, Help
    Menu, Help, add, Documentation, MenuHandler
    Menu, Help, disable, Documentation
    Menu, Help, add, Check for Updates, MenuHandler
    Menu, Help, add
    Menu, Help, add, About, MenuHandler

    Menu, MainMenu, add, File, :File
    Menu, MainMenu, add, Edit, :Edit
    Menu, MainMenu, disable, Edit
    Menu, MainMenu, add, Search, :Search
    Menu, MainMenu, disable, Search
    Menu, MainMenu, add, View, :View
    Menu, MainMenu, add, Settings, :Settings
    Menu, MainMenu, add, Help, :Help


    if root.selectSingleNode("//@alwaysontop").text
        Menu, View, check, Always On Top

    if options.selectSingleNode("//@snplib").text
        Menu, View, check, Snippet Library

    if options.selectSingleNode("//@linewrap").text
        Menu, View, check, Line Wrap

    rcwSet()

    if options.selectSingleNode("//@sci").text
        Menu, Settings, check, Enable Command Helper

    return
}
SnippetMenu(){
    global

    Menu, Snippet, add, New, MenuHandler
    Menu, Snippet, add
    Menu, Snippet, add, Edit, MenuHandler
    Menu, Snippet, add, Rename, MenuHandler
    ; Menu, Snippet, add
    Menu, Snippet, add, Delete, MenuHandler
    return
}
CreateGui(){
    global conf, $hwnd1

    MainGui(), AddHKGui(), AddHSGui(), ImportGui(), ExportGui(), PreferencesGui()
    SnippetGui(), AboutGui(), SetHotkeys("main", $hwnd1)
    return
}
MainGui(){
    global
    OnMessage(WM("COMMAND"),"MsgHandler")

    _aot := (root.attributes.item[1].text ? "+" : "-") "AlwaysOnTop"
    Gui, 01: +LastFound +Resize +MinSize %_aot%
    $hwnd1 := WinExist(), MainMenu(), _aot := null

    Gui, 01: menu, MainMenu
    Gui, 01: add, Tab2, x0 y0 w800 h400 HWND$tabcont gGuiHandler vtabLast, % "Hotkeys|Hotstrings|Live Code"
    Gui, 01: add, StatusBar, HWND$StatBar

    ; Needs to be moved to a function
    ; also remember to change the number to be displayed by a variable.
    SB_SetParts(150,150,250,50)
    SB_SetText("`t0 Hotkeys currently active",1)
    SB_SetText("`t0 Hotstrings currently active",2)
    SB_SetText("`tv" script.version,4)

    Gui, 01: tab, Hotkeys
    Gui, 01: add, ListView, w780 h315 HWND$hkList Sort Grid AltSubmit gListHandler vhkList
                          , % "Type|Program Name|Hotkey|Program Path"
    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$hkDelim

    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 HWND$QShk vQShk, % "Quick Search"
    Gui, 01: font
    Gui, 01: add, Button, x+370 yp w75 HWND$hkAdd Default gGuiHandler, % "&Add"
    Gui, 01: add, Button, x+10 yp w75 HWND$hkClose gGuiHandler, % "&Close"

    Gui, 01: Tab, Hotstrings
    Gui, 01: add, ListView, w780 h205 HWND$hsList Grid AltSubmit gListHandler vhsList
                          , % "Options|Abbreviation|Expand To"
    Gui, 01: add, Groupbox, w780 h105 HWND$hsGbox, % "Quick Add"
    Gui, 01: add, Text, xp+100 yp+20 HWND$hsText1, % "Expand:"
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x+10 yp-3 w150 HWND$hsExpand vhsExpand, % "e.g. btw"
    Gui, 01: font
    Gui, 01: add, Text, x+10 yp+3 HWND$hsText2, % "To:"
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x+10 yp-3 w250 HWND$hsExpandTo vhsExpandto, % "e.g. by the way"
    Gui, 01: font
    Gui, 01: add, Checkbox, x+10 yp+5 HWND$hsCbox1 vhsIsCode, % "Run as Script"
    Gui, 01: add, CheckBox, x112 y+15 HWND$hsCbox2 Checked vhsAE, % "AutoExpand"
    Gui, 01: add, CheckBox, xp+235 yp HWND$hsCbox3 vhsDND, % "Do not delete typed abbreviation"
    Gui, 01: add, CheckBox, x112 y+10 HWND$hsCbox4 vhsTIOW, % "Trigger inside other words"
    Gui, 01: add, CheckBox, xp+235 yp HWND$hsCbox5 vhsSR, % "Send Raw (do not translate {Enter} or {key})"

    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$hsDelim
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 HWND$QShs vQShs, % "Quick Search"
    Gui, 01: font
    Gui, 01: add, Button, x+370 yp w75 HWND$hsAdd Default gGuiHandler, % "&Add"
    Gui, 01: add, Button, x+10 yp w75 HWND$hsClose gGuiHandler, % "&Close"

    Gui, 01: Tab, Live Code
    options.selectSingleNode("//@snplib").text ? (w:=640, status:=null) : (w:=790, status:="Hidden")
    $Sci1 := SCI_Add($hwnd1,5,25,w,320,"hidden","","lib\scilexer.dll")
    Gui, 01: add, Text, x650 y25 w145 h17 HWND$slTitle Center Border %status%, % "Snippet Library"

    Gui, 01: add, DropDownList, xp y+5 w145 HWND$slDDL %status% gGuiHandler Sort vslDDL
    _current := options.selectSingleNode("//SnippetLib/@current").text
    _cnt := options.selectSingleNode("//Group[@name='" _current "']/@count").text
    Gui, 01: add, ListView
                , w145 h270 HWND$slList -Hdr -ReadOnly  
                . Count%_cnt% AltSubmit Sort Grid %status% gListHandler vslList
                , % "Title"

    LoadSnpLib()

    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$lcDelim
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 HWND$QSlc vQSlc, % "Quick Search"
    Gui, 01: font
    Gui, 01: add, Button, x+370 yp w75 HWND$lcRun gGuiHandler, % "&Run"
    Gui, 01: add, Button, x+10 yp w75 HWND$lcClear gGuiHandler, % "&Clear"
    GuiAttach(1),initSci($Sci1)

    WinGet, cList1, ControlList
    WinGet, hList1, ControlListHWND

    hide := options.selectSingleNode("//@smm").text ? "Hide" : ("", main_toggle:=1)

    current:=cnt:=null
    ; I remove one pixel from w800 to cover the delimiter line on the right side
    ;
    ; The attach function redraws the tab on top of the Status bar.
    ; I made it so that the window is a little bit below the tab to avoid overlapping
    ; hence the h422.
    Gui, 01: show, w799 h422 %hide%, % "AutoHotkey Toolkit"
    
    return
}
AddHKGui(){
    global

    Gui, 02: +LastFound +Resize +MinSize +Owner1 +DelimiterSpace
    $hwnd2 := WinExist()

    Gui, 02: add, GroupBox, w350 h70, % "Hotkey Type"
    Gui, 02: add, Radio, xp+10 yp+20 Checked gGuiHandler vhkType, % "Script"
    Gui, 02: add, Radio, x+20 gGuiHandler, % "File"
    Gui, 02: add, Radio,x+20 gGuiHandler, % "Folder"
    Gui, 02: add, Edit, x20 yp+20 w220 Disabled HWND$hk2Path vhkPath, %a_programfiles%
    Gui, 02: add, Button, x+10 w100 Disabled HWND$hk2Browse gGuiHandler, % "&Browse..."

    Gui, 02: add, GroupBox, x10 w350 h70, % "Select Hotkey"
    ; Gui, 02: add, Edit, xp+10 yp+30 w155, % ""
    ; Gui, 02: add, CheckBox, x+10 yp+3, % "LWin"
    ; Gui, 02: add, CheckBox, x+10, % "RWin"

    ; SetHotkeys(lst,$hkddl, "Add Hotkey")
    Gui, 02: add, CheckBox, xp+10 yp+33, % "Ctrl"
    Gui, 02: add, CheckBox, x+10, % "Alt"
    Gui, 02: add, CheckBox, x+10, % "Shift"
    Gui, 02: add, CheckBox, x+10, % "Win"
    Gui, 02: add, DropDownList, x+10 yp-3 w140, % lst:=klist("all^", "mods msb")" None  "

    Gui, 02: add, GroupBox, x+20 y6 w395 h145, % "Advanced Options"
    Gui, 02: add, Text,xp+10 yp+15, % "Note: Comma delimited, case insensitive and accepts RegExs"
    Gui, 02: font, s8 cGray italic, Verdana
    Gui, 02: add, Edit, w375 HWND$hkIfWin vhkIfWin, % "If window active list (e.g. Winamp, Notepad, Fire.*)"
    Gui, 02: add, Edit, wp HWND$hkIfWinN vhkIfWinN
                      , % "If window NOT active list (e.g. Notepad++, Firefox, post.*\s)"
    Gui, 02: font
    Gui, 02: add, Checkbox, xp y+5 vLMod, % "Left mod: only use left modifier key"
    Gui, 02: add, Checkbox, vRMod, % "Right mod: only use right modifier key"
    Gui, 02: add, Checkbox, vWild, % "Wildcard: fire with other keys           "
    Gui, 02: add, Checkbox, x+10 yp-38 vSend, % "Send key to active window"
    Gui, 02: add, Checkbox, vHook, % "Install hook"
    Gui, 02: add, Checkbox, vfRel, % "Fire when releasing key"

    $Sci2 := SCI_Add($hwnd2,10,160,750,250,"","","lib\scilexer.dll")

    Gui, 02: add, Text, x0 y+280 w785 0x10 HWND$hk2Delim
    Gui, 02: add, Button, x600 yp+10 w75 HWND$hk2Add Default gGuiHandler, % "&Add"
    Gui, 02: add, Button, x+10 yp w75 HWND$hk2Cancel gGuiHandler, % "&Cancel"
    GuiAttach(2),initSci($Sci2)

    WinGet, cList2, ControlList
    WinGet, hList2, ControlListHWND

    Gui, 02: show, w770 h470 Hide, % "Add Hotkey"
    return
}
AddHSGui(){
    global

    Gui, 03: +LastFound +Resize +MinSize +Owner1
    $hwnd3 := WinExist()

    Gui, 03: add, GroupBox, w180 h55, % "Hotstring Options"
    Gui, 03: font, s8 cGray italic, Verdana
    Gui, 03: add, Edit, xp+10 yp+20 w70 HWND$hsOpt vhsOpt, % "e.g. rc*"
    Gui, 03: font
    Gui, 03: add, Checkbox, x+5 yp+3 gGuiHandler vhs2IsCode, % "Run as Script"

    Gui, 03: add, GroupBox, x+20 yp-23 w210 h55, % "Expand"
    Gui, 03: font, s8 cGray italic, Verdana
    Gui, 03: add, Edit, xp+10 yp+20 w190 HWND$hs2Expand vhs2Expand, % "e.g. btw"
    Gui, 03: font

    Gui, 03: add, GroupBox,x10 y+20 w400 h100, % "Advanced Options"
    Gui, 03: add, Text, xp+10 yp+20, % "Note: Comma delimited, case insensitive and accepts RegExs"
    Gui, 03: font, s8 cGray italic, Verdana
    Gui, 03: add, Edit, w380 HWND$hsIfWin vhsIfWin, % "If window active list (e.g. Winamp, Notepad, Fire.*)"
    Gui, 03: add, Edit, wp HWND$hsIfWinN vhsIfWinN
                      , % "If window NOT active list (e.g. Notepad++, Firefox, post.*\s)"
    Gui, 03: font

    Gui, 03: add, GroupBox, x10 w400 h300 HWND$hs2GBox, % "Expand to"
    $Sci3 := SCI_Add($hwnd3,20,195,380,265,"","","lib\scilexer.dll")

    Gui, 03: add, Text, x0 y+10 w440 0x10 HWND$hs2Delim
    Gui, 03: add, Button, xp+250 yp+10 w75 Default HWND$hs2Add gGuiHandler, % "&Add"
    Gui, 03: add, Button, x+10 yp w75 HWND$hsCancel gGuiHandler, % "&Cancel"
    GuiAttach(3),initSci($Sci3,0,0)

    WinGet, cList3, ControlList
    WinGet, hList3, ControlListHWND

    Gui, 03: show, w420 h530 Hide, % "Add Hotstring"
    return
}
ImportGui(){
    global

    Gui, 04: +LastFound +Resize +MinSize +Owner1
    $hwnd4 := WinExist()

    Gui, 04: add, GroupBox, w500 h100, % "Import from"
    Gui, 04: add, Radio, xp+10 yp+20 Checked gGuiHandler vimType , % "Folder"
    Gui, 04: add, Radio,x+10 gGuiHandler, % "File"
    Gui, 04: add, CheckBox, xp-58 y+10 HWND$imIncFolders Checked vimRecurse, % "Include subfolders"
    Gui, 04: add, CheckBox,x+10 Checked vimHK, % "Import Hotkeys"
    Gui, 04: add, CheckBox,x+10 Checked vimHS, % "Import Hotstrings"
    Gui, 04: add, Edit, x20 yp+20 w315 vimPath, % a_mydocuments
    Gui, 04: add, Button, x+10 w75 gGuiHandler, % "&Browse..."
    Gui, 04: add, Button, x+10 wp gGuiHandler, % "&Import"

    Gui, 04: add, ListView, x10 y+30 w500 r10 HWND$imList Sort Grid AltSubmit gListHandler vimList
                          , % "Type|Options|Acelerator|Command|Path"

    Gui, 04: add, Text, x0 y+10 w540 0x10 HWND$imDelim
    Gui, 04: add, Button, xp+274 yp+10 w75 HWND$imAccept Default gGuiHandler, % "&Accept"
    Gui, 04: add, Button, x+1 yp w75 HWND$imClear gGuiHandler, % "C&lear"
    Gui, 04: add, Button, x+10 yp w75 HWND$imCancel gGuiHandler, % "&Cancel"
    GuiAttach(4)

    Gui, 04: show, w520 h340 Hide , % "Import"
    return
}
ExportGui(){
    global

    Gui, 05: +LastFound +Owner1
    $hwnd5 := WinExist()

    Gui, 05: add, GroupBox, w480 h80, % "Export to"
    Gui, 05: add, CheckBox,xp+10 yp+20 Checked vexHK, % "Export Hotkeys"
    Gui, 05: add, CheckBox,x+10 Checked vexHS, % "Export Hotstrings"
    Gui, 05: add, Edit, x20 yp+20 w375 vexPath, % a_mydocuments "\export_" subStr(a_now,1,8) ".ahk"
    Gui, 05: add, Button, x+10 w75 gGuiHandler, % "&Browse..."

    Gui, 05: add, Text, x0 y+30 w520 0x10
    Gui, 05: add, Button, xp+330 yp+10 w75 gGuiHandler, % "&Export"
    Gui, 05: add, Button, x+10 wp gGuiHandler, % "&Cancel"
    GuiAttach(5)

    Gui, 05: show, w500 h140 Hide, % "Export"
    return
}
PreferencesGui(){
    global

    Gui, 06: -MinimizeBox -MaximizeBox +LastFound +Owner1
    Gui, 06: Default
    $hwnd6 := WinExist()

    Gui, 06: add, TreeView, y30 w150 h260 AltSubmit -0x4 0x200 -Buttons -HScroll gListHandler vPrefList

    ;{ TreeView Item List
    $P1 := TV_Add("General Preferences", 0, "Expand")
        $P1C1 := TV_Add("Code Detection", $P1, "Expand")
            TV_Add("Keywords", $P1C1, "Expand")
            TV_Add("Pastebin Options", $P1C1, "Expand")
        $P1C2 := TV_Add("Command Helper", $P1, "Expand")
        $P1C3 := TV_Add("Live Code", $P1, "Expand")
            TV_Add("Run Code With", $P1C3, "Expand")
            TV_Add("Keywords", $P1C3, "Expand")
            TV_Add("Syntax Styles", $P1C3, "Expand")
        $P1C4 := TV_Add("Screen Tools", $P1, "Expand")
        ; $P1C4 := TV_Add("Script Manager", $P1, "Expand")
    ;}

    Gui, 06: font, s16
    Gui, 06: add, Text, x+5 y0 HWND$Title vTitle, % "General Preferences"
    Gui, 06: font

    Gui, 06: add, Text, x165 y+5 w370 0x10

    { ; General Preferences GUI
    Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    $hwnd98 := WinExist()

    vars := "ssi|smm|sww|cfu"
    Loop, Parse, vars, |
        _%a_loopfield% := options.selectSingleNode("//@" a_loopfield).text

    Gui, 98: add, GroupBox, x3 y0 w345 h70, % "Startup"
    Gui, 98: add, CheckBox, xp+25 yp+20 Checked%_ssi% v_ssi, % "Show splash image"
    Gui, 98: add, CheckBox, x+70 Checked%_sww% v_sww, % "Start with Windows"
    Gui, 98: add, CheckBox, x28 y+10 Checked%_smm% v_smm, % "Start minimized"
    Gui, 98: add, CheckBox, x+91 Checked%_cfu% v_cfu, % "Check for updates"

    _mhk := options.selectSingleNode("MainKey").text
    vars := "ctrl|alt|shift|win"
    Loop, Parse, vars, |
        _%a_loopfield% := options.selectSingleNode("MainKey/@" a_loopfield).text

    Gui, 98: add, GroupBox, x3 y+20 w345 h55, % "Main GUI Hotkey"
    Gui, 98: add, CheckBox, xp+10 yp+23 Checked%_ctrl% v_ctrl, % "Ctrl"
    Gui, 98: add, CheckBox, x+10 Checked%_alt% v_alt, % "Alt"
    Gui, 98: add, CheckBox, x+10 Checked%_shift% v_shift, % "Shift"
    Gui, 98: add, CheckBox, x+10 Checked%_win% v_win, % "Win"
    Gui, 98: add, DropDownList, x+10 yp-3 w140 HWND$GP_DDL v_hkddl, % lst:=klist("all^", "mods msb")" None  "

    ; Fixes issue with the DDL selecting "BackSpace" instead of "B"
    if RegexMatch(_mhk, "\bB\b")
        Control,Choose,2,, ahk_id %$GP_DDL%
    else
        Control,ChooseString,%_mhk%,, ahk_id %$GP_DDL%

    SetHotkeys(lst,$GP_DDL, "Preferences")

    Gui, 98: add, GroupBox, x3 y+26 w345 h100, % "Suspend hotkeys on these windows"
    Gui, 98: add, Edit, xp+10 yp+20 w325 h70 v_swl, % options.selectSingleNode("SuspWndList").text

    _mods:=(_ctrl ? "^" : null)(_alt ? "!" : null)(_shift ? "+" : null)(_win ? "#" : null)

    if strLen(_mhk) = 1
        Hotkey, % _mods "`" _mhk, GuiClose
    else
        Hotkey, % _mods _mhk, GuiClose

    ; --
    vars:=_ssi:=_sww:=_smm:=_cfu:=_mods:=_mhk:=_ctrl:=_alt:=_shift:=_win:=null ; Clean
    Gui, 98: show, x165 y36 w350 h245 NoActivate
    }

    { ; Code Detection
    Gui, 97: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    $hwnd97 := WinExist()

    Gui, 97: add, GroupBox, x3 y0 w345 h170, % "Info"
    Gui, 97: add, Text, xp+10 yp+20 w330
                      , % "CODET attempts to detect AutoHotkey code copied to the clipboard.`n`n"
                        . "Due to the fact that some AHK keywords can be found in normal text or other "
                        . "programming languages there can be false detections.`n`n"
                        . "It allows you to upload the code to a pastebin service like the ones offered by "
                        . "www.autohotkey.net or www.pastebin.com.`n`n"
                        . "You can select the minimum amount of keywords to match (the more the more accurate) "
                        . "and you can also edit the keyword list to add or delete words as you want to fine tune "
                        . "CODET to match your needs."

    Gui, 97: add, Text, x0 y+20 w360 0x10
    Gui, 97: add, GroupBox, x3 yp+10 w345 h50, % "General Preferences"
    
    _codStat := options.selectSingleNode("//CoDet/@status").text
    _codAuto := options.selectSingleNode("//CoDet/@auto").text
    Gui, 97: add, CheckBox, xp+25 yp+20 Checked%_codStat% v_codStat, % "Enable Command Detection"
    Gui, 97: add, CheckBox, x+10 Checked%_codAuto% v_codAuto, % "Enable Auto Upload"
    Gui, 97: show, x165 y36 w350 h245 NoActivate
    }

    ; { ; Command Helper
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ; }

    ; { ; Live Code
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ; }

    ; { ; Screen Tools
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ; }

    Gui, 06: add, Text, x165 y+245 w370 0x10
    Gui, 06: add, Button, xp+190 yp+10 w75 gGuiHandler, % "&Save"
    Gui, 06: add, Button, x+10 w75 gGuiHandler, % "&Close"


    Gui, 01: Default
    Gui, 06: show, w520 h330 Hide, % "Preferences"
    return
}
SnippetGui(){
    global

    Gui, 07: +LastFound +Resize +MinSize +Owner1
    $hwnd7 := WinExist(),SnippetMenu()

    Gui, 07: add, GroupBox, w260 h80, % "Info"
    Gui, 07: add, Text,xp+10 yp+20, % "Title:"
    Gui, 07: add, Edit, x60 yp-3 w200 vslTitle
    Gui, 07: add, Text, x20 y+13 , % "Group:"
    Gui, 07: add, ComboBox, x60 yp-3 w200 vslGroup

    node := options.selectSingleNode("//SnippetLib").childNodes
    current := options.selectSingleNode("//SnippetLib/@current").text

    Loop, % node.length
    {
        _group := node.item[a_index-1].selectSingleNode("@name").text
        if  (_group = current)
            GuiControl,7:,slGroup, %_group%||
        else
            GuiControl,7:,slGroup, %_group%
    }

    Gui, 07: add, GroupBox, x10 w470 h300 HWND$slGBox, % "Snippet"
    $Sci4 := SCI_Add($hwnd7,20,110,450,270,"","","lib\scilexer.dll")

    Gui, 07: add, Text, x0 y400 w500 0x10 HWND$slDelim
    Gui, 07: add, Button, xp+320 yp+10 w75 Default HWND$slAdd gGuiHandler, % "&Add"
    Gui, 07: add, Button, x+10 yp w75 HWND$slCancel gGuiHandler, % "&Cancel"
    GuiAttach(7), initSci($Sci4)

    Gui, 07: show, w490 h440 Hide, % "Add Snippet"
    return
}
AboutGui(){
    global
    OnMessage(WM("MOUSEMOVE"),"MsgHandler")

    Gui, 08: -Caption +LastFound +Owner1 +Border
    $hwnd8 := WinExist()

    info    := "Author`t`t  : " script.author " <" script.email ">`n"
            .  "Script Version`t  : " script.version "`n"
            .  "Homepage`t  : "

    info2   := "Creation Date`t  : " script.crtdate "`n"
            .  "Modification Date : " script.moddate

    licence := "Copyright ©2011 " script.author " <GPLv3>`n`n"
            .  "This program is free software: you can redistribute it and/or modify it`n"
            .  "under the terms of the GNU General Public License as published by`n"
            .  "the Free Software Foundation, either version 3 of  the  License,`n"
            .  "or (at your option) any later version.`n`n"

            .  "This program is distributed in the hope that it will be useful,`n"
            .  "but WITHOUT ANY WARRANTY; without even the implied warranty  of`n"
            .  "MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.`n"
            .  "See  the GNU General Public License for more details.`n`n"

            .  "You should have received a copy of the GNU General Public License`n"
            .  "along with this program.  If not, see "

    Gui, 08: color, White, White
    Gui, 08: add, Picture, x0 y0, % "res\AHK-TK_About.png"
    Gui, 08: add, Text, x0 w450 0x10
    Gui, 08: add, Text, x10 yp+10, % info
    Gui, 08: add, Text, xp+92 yp+27 cBlue gGuiHandler, % script.homepage
    Gui, 08: add, Text, x10 y+10, % info2
    Gui, 08: add, GroupBox, x10 y+10 w400 h220, % "Licence"
    Gui, 08: add, Text, xp+20 yp+20, % licence
    Gui, 08: add, Text, xp+169 yp+169 cBlue gGuiHandler, % "http://www.gnu.org/licenses/gpl-3.0.txt"
    Gui, 08: add, Text, x0 y+30 w450 0x10
    Gui, 08: add, Button, xp+250 yp+10 w75 Disabled gGuiHandler, % "Credits"
    Gui, 08: add, Button, x+10 w75 gGuiHandler, % "&Close"

    Gui, 08: show, w420 h490 Hide
    return
}
GuiAttach(guiNum){
    global $tabcont,$hkList,$hkDelim,$QShk,$hkAdd,$hkClose,$StatBar,$slTitle,$slDDL,$slList
         , $hsList,$hsGbox,$hsText1,$hsExpand,$hsText2,$hsExpandTo,$hsCbox1,$hsCbox2,$hsCbox3,$hsCbox4,$hsCbox5
         , $Sci1,$Sci2,$Sci3,$Sci4,$hsDelim,$QShs,$hsAdd,$hsClose,$lcDelim,$QSlc,$lcRun,$lcClear,$hk2Delim
         , $hk2Add,$hk2Cancel,$hs2GBox,$hs2Delim,$hs2Add,$hsCancel
         , $imList,$imDelim,$imAccept,$imClear,$imCancel,$slGBox,$slDelim,$slAdd,$slCancel

    ; AutoHotkey ToolKit Gui
    if guiNum = 1
    {
        ; hotkeys tab
        attach($tabcont, "w h")
        attach($hkList, "w h")
        attach($StatBar, "w r1")
        attach($hkDelim, "y w")
        attach($QShk, "y")
        attach($hkAdd, "x y r2"),attach($hkClose, "x y r2")

        ; hotstrings Tab
        c:="$hsText1|$hsExpand|$hsText2|$hsExpandTo|$hsCbox1|$hsCbox2|$hsCbox3|$hsCbox4|$hsCbox5"
        Loop, Parse, c, |
            attach(%a_loopfield%, "x.5 y r1")

        attach($hsList, "w h r2")
        attach($hsGbox, "y w r2")

        attach($hsDelim, "y w")
        attach($QShs, "y")
        attach($hsAdd, "x y r2"),attach($hsClose, "x y r2")

        ; Live Code Tab
        attach($Sci1, "w h r2")
        attach($slTitle, "x")
        attach($slDDL, "x")
        attach($slList, "x h r2")
        attach($lcDelim, "y w")
        attach($QSlc, "y")
        attach($lcRun, "x y r2"),attach($lcClear, "x y r2")
    }

    ; Add Hotkey Gui
    if guiNum = 2
    {
        attach($Sci2, "w h r2")
        attach($hk2Delim, "y w")
        attach($hk2Add, "x y r2"),attach($hk2Cancel, "x y r2")
    }

    ; Add Hotstring Gui
    if guiNum = 3
    {
        attach($Sci3,"w h r2")
        attach($hs2GBox,"w h r2")
        attach($hs2Delim,"y w")
        attach($hs2Add,"x y r2"),attach($hsCancel,"x y r2")
    }

    ; Import Hotkeys/Hotstrings
    if guiNum = 4
    {
        attach($imList, "w h r2")
        attach($imDelim, "y w")
        attach($imAccept, "x y r2"),attach($imClear, "x y r2"),attach($imCancel, "x y r2")
    }

    ; Snippet Gui
    if guiNum = 7
    {
        attach($Sci4, "w h r2")
        attach($slGBox, "w h r2")
        attach($slDelim, "y w")
        attach($slAdd, "x y r2")
        attach($slCancel, "x y r2")
    }
}
SetHotkeys(list=0, $hwnd=0, title=0){
    static lst, $lhwnd, ltitle

    if (list && list != "main")
    {
        $lhwnd:=$hwnd, ltitle:=title
        StringReplace, lst,list,%a_space%None%a_space%%a_space%
        Loop, Parse, lst, %a_space%
        {
            Hotkey, IfWinActive, %title%
            if strLen(a_loopfield) = 1
                Hotkey, % "`" a_loopfield, hkcAction
            else
                Hotkey, %a_loopfield%, hkcAction
            Hotkey, IfWinActive
        }
        return
    }
    else if (!list && !$hwnd && !title)
    {
        Loop, Parse, lst, %a_space%
        {
            Hotkey, IfWinActive, %ltitle%
            if strLen(a_loopfield) = 1
                Hotkey, % "`" a_loopfield, Toggle
            else
                Hotkey, %a_loopfield%, Toggle
            Hotkey, IfWinActive
        }
        return
    }

    if list = main
    {
        ; The Hotkey command allow the hotkeys to run the labels inside the MenuHandler function
        ; sad but true
        Hotkey, IfWinActive, ahk_id %$hwnd%
        Hotkey, ^n, Gui_AddNew          ; Ctrl + N
        Hotkey, ^p, Gui_Preferences     ; Ctrl + P
        Hotkey, IfWinActive
    }
    return

    hkcAction:
        ; Fixes issue with the DDL selecting "BackSpace" instead of "B"
        if RegexMatch(a_thishotkey, "\bB\b")
            Control,Choose,2,, ahk_id %$lhwnd%
        else
            Control,ChooseString,%a_thishotkey%,, ahk_id %$lhwnd%
    return
}
initSci($hwnd, m0=40, m1=10){
    global conf, script, $Sci1

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    if ($hwnd = $Sci1 && options.selectSingleNode("//@linewrap").text)
        SCI_SetWrapMode("SC_WRAP_WORD", $hwnd)
    else if ($hwnd != $Sci1)
        SCI_SetWrapMode("SC_WRAP_WORD", $hwnd)

    SCI_SetMarginWidthN(0,m0, hwnd),SCI_SetMarginWidthN(1,m1, $hwnd)

    SCI_StyleSetfont("STYLE_DEFAULT", "Courier New", $hwnd)
    SCI_StyleSetSize("STYLE_DEFAULT", 10, $hwnd)
    SCI_StyleClearAll(hwnd)
}
LoadSnpLib(){
    global
    
    LV_Delete()
    GuiControl,,slDDL,|
    
    GuiControl, -Redraw, slList

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    current := options.selectSingleNode("//SnippetLib/@current").text
    node := options.selectSingleNode("//Group[@name='" current "']").childNodes
    Loop, % node.length
        LV_Add("", node.item[a_index-1].selectSingleNode("@title").text)
    
    GuiControl, +Redraw, slList
    
    node := options.selectSingleNode("//SnippetLib").childNodes
    Loop, % node.length
    {
        _group := node.item[a_index-1].selectSingleNode("@name").text
        if  (_group = current)
            GuiControl,,slDDL, %_group%||
        else
            GuiControl,,slDDL, %_group%
    }
}
GuiReset(guiNum){
    global

    ; Add Hotkey Gui
    if guiNum = 2
    {
        WinActivate, ahk_id %$hwnd1%
    }
}

; Handlers
GuiHandler(){
    global

    if !a_gui
        return

    Gui, %a_gui%: submit, Nohide
    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    ; tooltip % a_guicontrol " " a_guievent

    ; Handling URLs
    if (inStr(a_guicontrol, "http://") || inStr(a_guicontrol, "www."))
    {
        Run, % RegexReplace(system.defBrowser, "\""?\%1\""?", """" a_guicontrol """")
        return
    }

    ; AutoHotkey ToolKit Gui
    if (a_gui = 01)
    {
        if (a_guicontrol = "tabLast")
        {
            action := tabLast = "Live Code" ? "show" : "hide"
            slControls:=$slTitle "|" $slDDL "|" $slList
            MenuHandler(tabLast = "Live Code" ? "enable" : "disable")
            Control,%action%,,,ahk_id %$Sci1%
            
            if action = show
                ControlFocus,,ahk_id %$Sci1%
            
            if options.selectSingleNode("//@snplib").text
            {
                Loop, Parse, slControls, |
                    Control,%action%,,,ahk_id %a_loopfield%
            }
            return
        }

        if (a_guicontrol = "&Save") ; From First Run GUI
        {
            defConf(script.conf)
            conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild

            ; Startup Options:
            ; ssi = show splash image
            ; sww = start with windows
            ; smm = start minimized
            ; cfu = check for updates
            node := options.firstChild                              ; <-- Startup
                node.setAttribute("ssi", _ssi),node.setAttribute("sww", _sww)
                node.setAttribute("smm", _smm),node.setAttribute("cfu", _cfu)

            ; Main Hotkey:
            node := options.childNodes.item[1]                      ; <-- MainKey
                node.text := (_hkddl = "None" ? ("``", _win := 1) : _hkddl)
                node.setAttribute("ctrl", _ctrl), node.setAttribute("alt", _alt)
                node.setAttribute("shift", _shift), node.setAttribute("win", _win)

            ; Other Tools:
            ; ecd = enable command detection
            ; ech = enable command helper
            ; eft = enable forum tag-autocomplete
            ; est = enable screen tools
            node := options.childNodes.item[3]                      ; <-- CoDet
                node.setAttribute("status", _ecd)

            node := options.childNodes.item[4]                      ; <-- CMDHelper
                node.setAttribute("global", _ech),node.setAttribute("sci", _ech)
                node.setAttribute("forum", _ech),node.setAttribute("tags", _eft)

            node := options.childNodes.item[6]                      ; <-- ScrTools
                node.setAttribute("altdrag", _est),node.setAttribute("prtscr", _est)
            node := null

            conf.save(script.conf), root := options := null         ; Save & Clean

            Gui, destroy
            Pause                                                   ; UnPause
        }

        if (a_guicontrol = "slDDL")
        {
            Gui, 01: ListView, slList
            options.selectSingleNode("//SnippetLib/@current").text := slDDL
            node := options.selectSingleNode("//Group[@name='" slDDL "']").childNodes

            GuiControl, -Redraw, slList
            
            LV_Delete()
            Loop, % node.length
                LV_Add("", node.item[a_index-1].selectSingleNode("@title").text)

            GuiControl, +Redraw, slList
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            return
        }

        if (a_guicontrol = "&Add" && tabLast = "Hotkeys")
        {
            Gui, 01: +Disabled
            Gui, 02: show
            return
        }

        if (a_guicontrol = "&Add" && tabLast = "Hotstrings")
        {
            Gui, 01: +Disabled
            Gui, 03: show
            ControlFocus,,ahk_id %$Sci3%
            return
        }

        if (a_guicontrol = "&Run")
        {
                lcfPath := a_temp . "\" . rName(5, "code")        ; Random Live Code Path

                if a_gui = 1
                    SCI_GetText(SCI_GetLength($Sci1)+1, _code)
                else
                    _code := Clipboard

                if !InStr(_code,"Gui")
                    _code .= "`n`nExitApp"
                else if !InStr(_code,"GuiClose")
                {
                    if !InStr(_code,"return")
                        _code .= "`nreturn"
                    _code .= "`n`nGuiClose:`nExitApp"
                }

                live_code =
                (Ltrim
                    ;[Directives]{
                    #NoEnv
                    #SingleInstance Force
                    ; --
                    SetBatchLines -1
                    SendMode Input
                    SetWorkingDir %a_scriptdir%
                    ; --
                    ;}

                    sec         :=  1000               ; 1 second
                    min         :=  sec * 60           ; 1 minute
                    hour        :=  min * 60           ; 1 hour

                    %_code%

                    ^Esc::ExitApp
                )
                FileAppend, %live_code%, %lcfPath%

                rcw := options.selectSingleNode("//RCPaths/@current").text
                ahkpath := options.selectSingleNode("//RCPaths/" rcw).text
                if !ahkpath
                {
                    ahkpath := a_temp "\ahkl.bak"
                    FileInstall, res\ahkl.bak, %ahkpath%
                }

                Run, %ahkpath% %lcfPath%
            return
        }

        if (a_guicontrol = "&Clear")
        {
            SCI_ClearAll($Sci1)
            return
        }

        if (a_guicontrol = "&Close")
        {
            GuiClose:
            GuiEscape:
                WinGet, winstat, MinMax, ahk_id %$hwnd1%
                if (!WinActive("ahk_id " $hwnd1) && (winstat != ""))
                {
                    WinActivate, ahk_id %$hwnd1%
                    return
                }

                if main_toggle := !main_toggle
                    Gui, 01: show
                else
                    Gui, 01: Hide
            return
        }
    }

    ; Add Hotkey Gui
    if (a_gui = 02)
    {
        if (a_guicontrol = "hkType")
        {
            Control, disable,,,ahk_id %$hk2Path%
            Control, disable,,,ahk_id %$hk2Browse%
            SCI_StyleResetDefault($Sci2), SCI_SetReadOnly(false), initSci($Sci2)
        }
        else if (a_guicontrol = "File" || a_guicontrol = "Folder")
        {
            Control, enable,,,ahk_id %$hk2Path%
            Control, enable,,,ahk_id %$hk2Browse%
            SCI_ClearAll($Sci2),SCI_SetReadOnly(true),SCI_StyleSetBack("STYLE_DEFAULT", 0xe0dfe3)
            SCI_SetMarginWidthN(0,0),SCI_SetMarginWidthN(1,0)
        }

        if (a_guicontrol = "&Add")
        {
            GoSub, GeneralAdd
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            2GuiClose:
            2GuiEscape:
                Gui, 02: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; Add Hotstring Gui
    if (a_gui = 03)
    {
        if hs2IsCode
            initSci($Sci3)
        else
            initSci($Sci3,0,0)

        if a_guicontrol = &Add
        {
            GoSub, GeneralAdd
            return
        }

        if a_guicontrol = &Cancel
        {

            3GuiClose:
            3GuiEscape:
                Gui, 03: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; Import Hotkeys/Hotstrings
    if (a_gui = 04)
    {
        if (a_guicontrol = "imType")
        {
            Control, enable,,, ahk_id %$imIncFolders%
            GuiControl, 04:, imPath, %a_mydocuments%
            return
        }
        else if (a_guicontrol = "File")
        {
            Control, disable,,, ahk_id %$imIncFolders%
            GuiControl, 04:, imPath, %a_mydocuments%
            return
        }

        if (a_guicontrol = "&Browse...")
        {
            Gui, 04: +OwnDialogs
            if imType = 1
                FileSelectFolder, im, *%a_mydocuments%, 3, % "Select the folder"
            else if imType = 2
            {
                FileSelectFile, im, M3, %a_mydocuments%, % "Select the file"
                Loop, Parse, im, `n, `r
                {
                    if a_index = 1
                    {
                        path:=a_loopfield "\", _im:=""
                        continue
                    }
                    _im .= path . a_loopfield "`n"
                }
                im := _im
            }

            if im
                GuiControl, 04:, imPath, % RegexReplace(im, "\n", "|")
            else
                GuiControl, 04:, imPath, %a_mydocuments%
            return
        }

        if (a_guicontrol = "&Import")
        {
            if imType = 1
            {
                Loop, %imPath%\*.ahk,0,%imRecurse%
                {
                    impFile0 := a_index
                    FileRead, impFile%a_index%, % a_loopfilelongpath
                    if !hotExtract(impFile%a_index%, a_loopfilelongpath)
                        return
                }
            }
            else
            {
                Loop, Parse, imPath, |
                {
                    FileRead, impFile%a_index%, % a_loopfield
                    if !hotExtract(impFile%a_index%, a_loopfield)
                        return
                    if a_loopfield
                        impFile0 := a_index
                }
            }
            Msgbox, % LV_GetCount() " items imported."
            return
        }

        if (a_guicontrol = "&Accept")
        {
            GoSub, GeneralAdd
            return
        }

        if (a_guicontrol = "C&lear")
        {
            LV_Delete()
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            4GuiClose:
            4GuiEscape:
                Gui, 04: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; Export Hotkeys/Hotstrings
    if (a_gui = 05)
    {
        if (a_guicontrol = "&Browse...")
        {
            Gui, 01: +OwnDialogs
            FileSelectFile,exFile, S24
                          , % a_mydocuments "\export_" subStr(a_now,1,8) ".ahk"
                          , % "Save File as...", *.ahk; *.txt
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            5GuiClose:
            5GuiEscape:
                Gui, 05: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; Preferences
    if (a_gui = 06)
    {
        Loop, 8
        {
            _gui := a_index + 90
            Gui, %_gui%: submit, NoHide
        }

        if (a_guicontrol = "&Save")
        {
            ; [General Preferences]{
            ; Startup
            node := options.firstChild                              ; <-- Startup
                node.setAttribute("ssi", _ssi),node.setAttribute("sww", _sww)
                node.setAttribute("smm", _smm),node.setAttribute("cfu", _cfu)
                script.autostart(_sww)                              ; Save or Delete Registry Entry

            ; Main Hotkey
            node := options.childNodes.item[1]                      ; <-- MainKey
                ; Load old hotkey
                _octrl := node.attributes.item[0].text, _oalt := node.attributes.item[1].text
                _oshift := node.attributes.item[2].text, _owin := node.attributes.item[3].text
                _mhk := node.text

                { ; Disable Old Hotkey
                _mods:=(_octrl ? "^" : null)(_oalt ? "!" : null)(_oshift ? "+" : null)(_owin ? "#" : null)
                if strLen(_mhk) = 1
                    Hotkey, % _mods "`" _mhk, Off
                else
                    Hotkey, % _mods _mhk, Off
                }

                ; Load new hotkey
                node.text := (_hkddl = "None" ? ("``", _win := 1) : _hkddl)
                node.setAttribute("ctrl", _ctrl), node.setAttribute("alt", _alt)
                node.setAttribute("shift", _shift), node.setAttribute("win", _win)

                { ; Enable New Hotkey
                _mods:=(_ctrl ? "^" : null)(_alt ? "!" : null)(_shift ? "+" : null)(_win ? "#" : null)
                if strLen(_hkddl) = 1
                    Hotkey, % _mods "`" _hkddl, GuiClose
                else
                    Hotkey, % _mods _hkddl, GuiClose
                }

            ; Suspend hotkeys on these windows
            node := options.childNodes.item[2]                      ; <-- SuspWndList
                node.text := _swl
            node := null
            ;}
            
            ; [Code Detection]{
            ; Status
            options.selectSingleNode("//CoDet/@status").text := _codStat
            options.selectSingleNode("//CoDet/@auto").text := _codAuto
            ;}
            
            conf.transformNodeToObject(xsl, conf)
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            if conf.xml
                MsgBox, 0x40
                      , % "Operation Succeded"
                      , % "Your settings were saved correctly."
            else
                MsgBox, 0x10
                      , % "Operation Failed"
                      , % "There was a problem while saving the settings.`n"
                        . "The configuration file could not be reloaded."
            return
        }

        if (a_guicontrol = "&Close")
        {
            6GuiClose:
            6GuiEscape:
                Gui, 06: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; Add Snippet
    if (a_gui = 07)
    {
        if (a_guicontrol = "&Add")
        {
            Gui, 01: Default                            ; Fixes an issue with the List View
            Gui, 01: submit, NoHide                     ; Retrieve values from DropDown List
            SCI_GetText(SCI_GetLength($Sci4)+1, _snip)  ; Retrieve text from scintilla control

            Gui, %a_gui%: submit                        ; Submits Gui 7
            WinActivate, ahk_id %$hwnd1%
            Gui, 01: -Disabled
            Gui, 01: ListView, slList

            node := options.selectSingleNode("//SnippetLib/Group[@name='" slGroup "']"), _groupExist := node.text
            if (editingNode)
            {
                editingNode := False
                _current := options.selectSingleNode("//SnippetLib/@current").text
                _groupNode :=  options.selectSingleNode("//Group[@name='" _current "']")    ; Select correct Group
                _editNode := _groupNode.selectSingleNode("Snippet[@title='" _seltxt "']")
                _editNode.setAttribute("title", slTitle), _editNode.text := _snip
                
                LV_Delete()                
                GuiControl, -Redraw, slList
                
                node := options.selectSingleNode("//Group[@name='" slGroup "']").childNodes
                Loop, % node.length
                    LV_Add("", node.item[a_index-1].selectSingleNode("@title").text)
                
                GuiControl, +Redraw, slList
            }
            else if (_groupExist)
            {
                node := options.selectSingleNode("//SnippetLib/Group[@name='" slGroup "']/@count")
                node.text := node.text + 1

                _p := options.selectSingleNode("//SnippetLib/Group[@name='" slGroup "']")
                    _pc := conf.createElement("Snippet"), _pc.setAttribute("title", slTitle)
                            _cd := conf.createCDATASection("`n" _snip "`n`t`t`t`t`t")

                _pc.appendChild(_cd), _p.appendChild(_pc)
                options.selectSingleNode("//SnippetLib/@current").text := slGroup

                GuiControl,ChooseString,slDDL, %slGroup%
                LV_Add("",slTitle)
            }
            else
            {
                node := options.selectSingleNode("//SnippetLib")
                _p := conf.createElement("Group"), _p.setAttribute("name", slGroup), _p.setAttribute("count", 1)
                    _pc := conf.createElement("Snippet"), _pc.setAttribute("title", slTitle)
                        _cd := conf.createCDATASection("`n" _snip "`n`t`t`t`t`t")

                _pc.appendChild(_cd), _p.appendChild(_pc)
                node.appendChild(_p), node.setAttribute("current", slGroup)
                node:=_p:=_pc:=_cd:=null

                GuiControl,07:,slGroup, %slGroup%||
                GuiControl,,slDDL, %slGroup%||

                LV_Delete()
                LV_Add("",slTitle)
            }

            node:=_p:=_pc:=_cd:=_editNode:=null                                ; Clean
            conf.transformNodeToObject(xsl, conf)
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            7GuiClose:
            7GuiEscape:
                Gui, 07: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }

    ; About Gui
    if (a_gui = 08)
    {
        if (a_guicontrol = "&Close")
        {
            8GuiClose:
            8GuiEscape:
                Gui, 08: Hide
                WinActivate, ahk_id %$hwnd1%
                Gui, 01: -Disabled
            return
        }
    }
}
MenuHandler(stat=0){
    global
    static tog_aot, tog_lw, tog_ech, tog_sl, tog_ro:=0

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    tog_aot := root.selectSingleNode("//@alwaysontop").text, tog_ech := options.selectSingleNode("//@sci").text
    tog_lw  := options.selectSingleNode("//@linewrap").text, tog_sl  := options.selectSingleNode("//@snplib").text

    if (stat)
    {
        ; switch state of some menu items depending on which tab we are in at the moment
        Menu, MainMenu, %stat%, Edit
        Menu, MainMenu, %stat%, Search

        Menu, View, %stat%, Snippet Library
        Menu, View, %stat%, Show Symbols
        Menu, View, %stat%, Zoom
        Menu, View, %stat%, Line Wrap

        Menu, Settings, %stat%, Run Code With
        Menu, Settings, %stat%, Enable Command Helper
        ; Menu, Settings, %stat%, Context Menu Options

        Menu, File, %stat%, &Open`t`tCtrl+O
        Menu, File, %stat%, &Save`t`tCtrl+S
        Menu, File, %stat%, Save As`t`tCtrl+Shift+S
        ; Menu, File, %stat%, Close`t`tCtrl+W
        ; Menu, File, %stat%, Close All`t`tCtrl+Shift+W
        return
    }

    ; Snippet Menu
    if (a_thismenuitem = "New")
    {
        Gui, 01: +Disable
        Gui, 07: show
        return
    }

    if (a_thismenuitem = "Edit")
    {
        ListHandler(a_thismenuitem)
        return
    }
    
    if (a_thismenuitem = "Rename")
    {
        Send, {F2}
        ListHandler(a_thismenuitem)
        return
    }

    if (a_thismenuitem = "Delete")
    {
        ListHandler(a_thismenuitem)
        return
    }

    ; Main Menu
    if (a_thismenuitem = "&New`t`tCtrl+N")
    {
        Gui_AddNew:
            Gui, 01: Submit, Nohide
            if tabLast = Hotkeys
            {
                Gui, 01: +Disabled
                Gui, 02: show
            }
            else if tabLast = Hotstrings
            {
                Gui, 01: +Disabled
                Gui, 03: show
                ControlFocus,,ahk_id %$Sci3%
            }
            else if tabLast = Live Code
            {
                if options.selectSingleNode("//@snplib").text
                {
                    Gui, 01: +Disabled
                    Gui, 07: show
                }
                return
            }
        return
    }

    if (a_thismenuitem = "Import Hotkeys/Hotstrings")
    {
        Gui, 01: +Disabled
        Gui, 04: show
        return
    }

    if (a_thismenuitem = "Export Hotkeys/Hotstrings")
    {
        Gui, 01: +Disabled
        Gui, 05: show
        return
    }

    if (a_thismenuitem = "Set Read Only")
    {
        Menu, Edit, ToggleCheck, %a_thismenuitem%
        SCI_SetReadOnly(tog_ro := !tog_ro, $Sci1)
        return
    }

    if (a_thismenuitem = "Always On Top")
    {
        Menu, View, ToggleCheck, %a_thismenuitem%
        alwaysontop := ((tog_aot := !tog_aot) ? "+" : "-") "AlwaysOnTop"
        Gui, %a_gui%: %alwaysontop%
        root.setAttribute("alwaysontop", tog_aot)
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "Snippet Library")
    {
        slControls:=$slTitle "|" $slDDL "|" $slList
        Menu, View, ToggleCheck, %a_thismenuitem%
        
        if tog_sl := !tog_sl
        {
            ControlMove,,,, % _guiwidth - 160,, ahk_id %$Sci1%
            attach($Sci1, "w h r2")
            Loop, Parse, slControls, |
                Control, show,,, ahk_id %a_loopfield%
        }
        else
        {
            ControlMove,,,, % _guiwidth - 10,, ahk_id %$Sci1%
            attach($Sci1, "w h r2")
            Loop, Parse, slControls, |
                Control, hide,,, ahk_id %a_loopfield%
        }

        options.selectSingleNode("//@snplib").text := tog_sl
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "Line Wrap")
    {
        Menu, View, ToggleCheck, %a_thismenuitem%
        SCI_SetWrapMode(tog_lw := !tog_lw, $Sci1)
        options.selectSingleNode("//@linewrap").text := tog_lw
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "Enable Command Helper")
    {
        Menu, Settings, ToggleCheck, %a_thismenuitem%
        ; cmdHelper(tog_ech := !tog_ech)
        options.selectSingleNode("//@sci").text := !tog_ech
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "L-Ansi" || a_thismenuitem = "L-Unicode"
    ||  a_thismenuitem = "Basic"  || a_thismenuitem = "IronAHK")
    {
        rcwSet(a_thismenuitem)
        return
    }

    if (a_thismenuitem = "&Preferences`t`tCtrl+P")
    {
        Gui_Preferences:
            Gui, 01: +Disabled
            Gui, 06: show
        return
    }

    if (a_thismenuitem = "Check for Updates")
    {
        script.update(script.version)
        return
    }

    if (a_thismenuitem = "About")
    {
        Gui, 01: +Disabled
        Gui, 08: show
        return
    }

}
ListHandler(sParam=0){
    global

    Gui, 01: ListView, %a_guicontrol%
    _selrow := LV_GetNext(), LV_GetText(_seltxt, _selrow)
    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild

    if (sParam = "Edit")
    {
        editingNode := True
        _current := options.selectSingleNode("//SnippetLib/@current").text
        _groupNode :=  options.selectSingleNode("//Group[@name='" _current "']")          ; Select correct Group
        _editNode := _groupNode.selectSingleNode("Snippet[@title='" _seltxt "']")
        GuiControl,07:,slTitle, %_seltxt%
        GuiControl,07: ChooseString,slGroup, %_current%
        SCI_SetText(_editNode.text,$Sci4)
        
        Gui, 01: +Disable
        Gui, 07: Show
        return
    }
    
    if (sParam = "Delete")
    {
        _current := options.selectSingleNode("//SnippetLib/@current").text
        Loop, % LV_GetCount("Selected")
        {
            if !next := LV_GetNext()
                break

            LV_GetText(_title, next)
            LV_Delete(next)

            node :=  options.selectSingleNode("//Group[@name='" _current "']")          ; Select correct Group
            node.removeChild(node.selectSingleNode("Snippet[@title='" _title "']"))

            node := options.selectSingleNode("//Group[@name='" _current "']/@count")    ; Reduce Child Count
            node.text := node.text - 1

            if (node.text = 0)
            {
                node := options.selectSingleNode("//SnippetLib")
                node.removeChild(options.selectSingleNode("//Group[@name='" _current "']"))

                ; Replace with next Group
                _current := options.selectSingleNode("//SnippetLib/Group/@name").text
                options.selectSingleNode("//SnippetLib/@current").text := _current

                ; Load DDL with updated information
                GuiControl,,slDDL,|
                node := options.selectSingleNode("//SnippetLib").childNodes
                _current := options.selectSingleNode("//SnippetLib/@current").text

                Loop, % node.length
                {
                    _group := node.item[a_index-1].selectSingleNode("@name").text
                    if  (_group = _current)
                        GuiControl,,slDDL, %_group%||
                    else
                        GuiControl,,slDDL, %_group%
                }

                node := options.selectSingleNode("//Group[@name='" _current "']").childNodes
                GuiControl, -Redraw, slList
                
                Loop, % node.length
                    LV_Add("", node.item[a_index-1].selectSingleNode("@title").text)
                
                GuiControl, +Redraw, slList
            }
        }
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_guicontrol = "imList")
    {
        if (a_guievent = "K" && a_eventinfo = 46)
        {
            Loop, % LV_GetCount("Selected")
            {
                if !next := LV_GetNext()
                    break
                LV_Delete(next)
            }
            return
        }
    }

    if (a_guicontrol = "PrefList")
    {
        Loop 8
        {
            _gui := a_index+90
            Gui, %_gui%: submit, NoHide
        }

        if (a_guievent = "Normal")
        {
            TV_GetText(selPref, a_eventinfo)
            if selPref
                ControlSetText,, %selPref%, ahk_id %$Title%
            prefControl(a_eventinfo)
            return
        }
    }

    if (a_guicontrol = "hkList")
    {
        if (a_guievent = "DoubleClick" && !_selrow)
        {
            LV_Modify(0,"-Select"),LV_Modify(0,"-Focus")
            Gui, 01: +Disabled
            Gui, 02: show
            return
        }
    }

    if (a_guicontrol = "hsList")
    {
        if (a_guievent = "DoubleClick" && !_selrow)
        {
            LV_Modify(0,"-Select"),LV_Modify(0,"-Focus")
            Gui, 01: +Disabled
            Gui, 03: show
            ControlFocus,,ahk_id %$Sci3%
            return
        }
    }

    if (a_guicontrol = "slList" || sParam = "Rename")
    {
        if (a_guievent = "DoubleClick" && !_selrow)
        {
            LV_Modify(0,"-Select"),LV_Modify(0,"-Focus")
            Gui, 01: +Disabled
            Gui, 07: show
        }

        if (a_guievent = "DoubleClick")
        {
            _current := options.selectSingleNode("//SnippetLib/@current").text
            _snip := options.selectSingleNode("//Group[@name='" _current "']/Snippet[@title='" _seltxt "']").text
            SCI_AddText(_snip,0,$Sci1)
            return
        }

        if (a_guievent = "RightClick")
        {
            Menu, Snippet, show
            return
        }

        if (a_guievent = "K" && a_eventinfo = 46)
        {
            ListHandler("Delete")
            return
        }

        if (a_guievent = "E" || sParam = "Rename")
        {
            Send, {Delete}                      ; Needed because we cannot append with the input command.
            
            ; Need this hotkey to be able to cancel the renaming process cleanly
            ; by clicking.
            Hotkey, *LButton, CancelInput, On   ; Using On to enable if it is disabled by label below.
            Input, slNewTitle,CV,{Enter}{Esc}

            if !inStr(ErrorLevel, "EndKey:Escape")
            {
                _current := options.selectSingleNode("//SnippetLib/@current").text
                _title := slNewTitle ? slNewTitle : _seltxt
                node :=  options.selectSingleNode("//Group[@name='" _current "']")
                node.selectSingleNode("Snippet[@title='" _seltxt "']/@title").text:=_title
                conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            }
            Hotkey, *LButton, Off               ; If we finished editing normally then turn off the hotkey.
            return

            CancelInput:
                Send {Enter}
                Hotkey, *LButton, Off
            Return
        }
    }

    if !LV_GetCount("Selected")
        LV_Modify(0,"-Focus")
}
MsgHandler(wParam,lParam, msg, hwnd){
    static
    hCurs:=DllCall("LoadCursor","UInt",0,"Int",32649,"UInt") ;IDC_HAND
    global cList1,hList1,cList2,hList2,cList3,hList3,$QShk,$QShs,$QSlc,$Sci1,$Sci2,$Sci3
         , $hsOpt,$hsExpand,$hs2Expand,$hsExpandTo,$hkIfWin,$hkIfWinN,$hsIfWin,$hsIfWinN
         , $GP_E1, $GP_DDL
         , hSciL:=$Sci1 "," $Sci2 "," $Sci3

    if (msg = WM("MOUSEMOVE"))
    {
        MouseGetPos,,,,ctrl
        If ctrl in Static4,Static7
        DllCall("SetCursor","UInt",hCurs)
        Return
    }

    if (msg = WM("COMMAND"))
    {
        if lParam in %hSciL%
            return
        if ((wParam&0xFFFF0000)>>16 = 0x0100)   ; EN_SETFOCUS
        {
            if (lParam = $GP_E1)
            {
                SetHotkeys()                    ; Disable hotkeys
                return
            }

            ControlGetText,sText,, ahk_id %lParam%
            if a_gui
            {
                Gui, %a_gui%: font, s8 cBlack norm
                GuiControl, font, % getID(lParam, cList%a_gui%, hList%a_gui%)
            }
            if (inStr(sText, "e.g. ") || lParam = $QShk || lParam = $QShs || lParam = $QSlc)
                ControlSetText,,, ahk_id %lParam%
            return
        }

        if ((wParam&0xFFFF0000)>>16 = 0x0200) ; EN_KILLFOCUS
        {
            if (lParam = $GP_E1)
            {
                SetHotkeys()                    ; Re-Enable hotkeys
                return
            }

            ControlGetText,cText,, ahk_id %lParam%

            if ((!cText && inStr(sText, "e.g. ")) || lParam = $QShk || lParam = $QShs || lParam = $QSlc)
            {
                if a_gui
                {
                    Gui, %a_gui%: font, s8 cGray italic, Verdana
                    GuiControl, font, % getID(lParam, cList%a_gui%, hList%a_gui%)
                }
                ControlSetText,,%sText%, ahk_id %lParam%
                return
            }

            if (!cText && sText)
            {
                if a_gui
                {
                    Gui, %a_gui%: font, s8 cGray italic, Verdana
                    GuiControl, font, % getID(lParam, cList%a_gui%, hList%a_gui%)
                }

                if (lParam = $hsOpt)
                    ControlSetText,, % "e.g. rc*", ahk_id %lParam%

                if (lParam = $hsExpand || lParam = $hs2Expand)
                    ControlSetText,, % "e.g. btw", ahk_id %lParam%

                if (lParam = $hsExpandTo)
                    ControlSetText,, % "e.g. by the way", ahk_id %lParam%

                if (lParam = $hkIfWin || lParam = $hsIfWin)
                    ControlSetText,, % "If window active list (e.g. Winamp, Notepad, Fire.*)", ahk_id %lParam%

                if (lParam = $hkIfWinN || lParam = $hsIfWinN)
                    ControlSetText,, % "If window NOT active list (e.g. Notepad++, Firefox, post.*\s)"
                                   , ahk_id %lParam%
                return
            }
        }
    }
}

; Other
getID(hwnd, controls, handles){

    Loop, Parse, handles,`n, `r
        if (a_loopfield = hwnd)
            match:=a_index

    Loop, Parse, controls, `n,`r
        if (a_index = match)
            return a_loopfield
}
hotExtract(file, path, isAccept=0){
    global imHK, imHS

    ; This variable contains the regex for importing multiline hotkeys and hotstrings.
    ; This ternary checks if imHK is set, if it is it checks if imHS is also set.
    ; If imHK is not set then we check if imHS is set by itself or not.
    #mLine:=imHK ? "mi)^(?P<HKOPT>[<>*~$]+)?(?P<HK>[\w\s#!^+&]+)(?<![:;])::(\s+;.*)?$"
    . (imHK && imHS ? "|" : "")
    . (imHS ? "^:(?P<HSOPT>[*?BCKOPRSIEZ0-9]+)?:(?P<HS>.*)(?<![;])::(\s+;.*)?$" : "") : ""
    . (imHS ? "mi)^:(?P<HSOPT>[*?BCKOPRSIEZ0-9]+)?:(?P<HS>.*)(?<![;])::(\s+;.*)?$" : "")

    ; Same as above but only for single lined hotkeys and hotstrings.
    #sLine:=imHK ? "i)^(?P<HKOPT>[<>*~$]+)?(?P<HK>[\w\s#!^+&]+)(?<![:;])::(?P<HKCODE>[^;]+)"
    . (imHK && imHS ? "|" : "")
    . (imHS ? "^:(?P<HSOPT>[*?BCKOPRSIEZ0-9]+)?:(?P<HS>.*)(?<![;])::(?P<HSCODE>[^;]+)" : "") : ""
    . (imHS ? "i)^:(?P<HSOPT>[*?BCKOPRSIEZ0-9]+)?:(?P<HS>.*)(?<![;])::(?P<HSCODE>[^;]+)" : "")

    if (!#mLine || !#sLine)
    {
        Msgbox, 0x10
              , % "Error while trying to import."
              , % "You must select what to import my friend.`nEither hotkeys, hotstrings or both."
        return 0
    }
    
    GuiControl, -Redraw, imList
    Loop, Parse, file, `n,`r
    {
        SplitPath, path,_fName
        if multiline
        {
            if inStr(a_loopfield, "return")
            {
                subCode := "(Multiline) " RegexReplace(subStr(_code,1,40), "\s+", " ")
                LV_Add(""
                      , _mlHK ? "Hotkey" : "Hotstring"
                      , (_mlHKOPT || _mlHSOPT) ? RegexReplace(_mlHKOPT _mlHSOPT, "^\s+") : "-"
                      , RegexReplace(_mlHK _mlHS, "^\s+")
                      , subCode
                      , path)

                Loop, 5
                {
                    if a_index = 4
                    {
                        LV_ModifyCol(a_index, 250)
                        continue
                    }
                    LV_ModifyCol(a_index, "AutoHdr")
                }
                multiline:=False,_code:="",_mlHK:="",_mlHS:="",_mlHKOPT:="",_mlHSOPT:=""
            }
            else
                _code .= RegexReplace(a_loopfield, "^\s+") "`n"
        }

        if RegexMatch(a_loopfield, #mLine, ml)
        {
            multiline:=True,_mlHK:=mlHK ? mlHK : _mlHK,_mlHS:=mlHS ? mlHS : _mlHS
           ,_mlHKOPT:=mlHKOPT ? mlHKOPT : _mlHKOPT,_mlHSOPT:=mlHSOPT ? mlHSOPT : _mlHSOPT
           continue
        }

        if RegexMatch(a_loopfield, #sLine, sl)
        {
            LV_Add(""
                  , slHK ? "Hotkey" : "Hotstring"
                  , (slHKOPT || slHSOPT) ? RegexReplace(slHKOPT slHSOPT, "^\s+") : "-"
                  , RegexReplace(slHK slHS, "^\s+")
                  , slHKCODE slHSCODE
                  , path)

            Loop, 5
            {
                if a_index = 4
                {
                    LV_ModifyCol(a_index, 250)
                    continue
                }
                LV_ModifyCol(a_index, "AutoHdr")
            }
            continue
        }
    }
    GuiControl, +Redraw, imList
    return 1
}
rcwSet(menu=0){
    global conf, script
    static names:="L-Ansi|L-Unicode|Basic|IronAHK"

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    node := options.selectSingleNode("//RCPaths").childNodes
    loop, Parse, names, |
    {
        if !node.item[a_index - 1].text
            Menu, RCW, disable, %a_loopfield%
        else if !menu
            Menu, RCW, check, % options.selectSingleNode("//RCPaths/@current").text
        else if (menu = a_loopfield)
        {
            Loop, Parse, names, |
                Menu, RCW, uncheck, %a_loopfield%       ; Make sure all others are unchecked
            Menu, RCW, check, %a_loopfield%
            options.selectSingleNode("//RCPaths/@current").text := a_loopfield
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        }
    }
    return
}
prefControl(pref=0){
    global

    if !pref
        return

    if (pref = $P1)
        Gui, 98: show, NoActivate
    else
        Gui, 98: hide
        
    if (pref = $P1C1)
        Gui, 97: show, NoActivate
    else
        Gui, 97: hide
}
defConf(path){
    global script

    s_version := script.version, hlpPath := subStr(a_ahkpath, 1,-14) "AutoHotkey.chm"
    a_isunicode ? (unicode := a_ahkpath, current := "L-Unicode") : (ansi := a_ahkpath,current := "L-Ansi")
    template=
    (
<?xml version="1.0" encoding="UTF-8"?>
<AHK-Toolkit version="%s_version%" alwaysontop="0">
    <Options>
        <Startup ssi="1" sww="1" smm="1" cfu="1"/>
        <MainKey ctrl="0" alt="0" shift="0" win="1">``</MainKey>
        <SuspWndList/>
        <CoDet status="1" auto="0">
            <Pastebin current="Autohotkey">
                <AutoHotkey private="0" nick="">http://www.autohotkey.net/paste/</AutoHotkey>
                <PasteBin private="0" subdomain="" expiration="1H">http://pastebin.com/api_public.php</PasteBin>
                <Paste2>http://paste2.org/new-paste</Paste2>
                <Gist/>
            </Pastebin>
            <History max="10"/>
            <Keywords min="5">
            if exitapp gosub goto ifequal ifexist ifgreater ifgreaterorequal ifinstring ifless iflessorequal
            ifmsgbox ifnotequal ifnotexist ifnotinstring ifwinactive ifwinexist ifwinnotactive ifwinnotexist
            onexit setbatchlines settimer suspend static global local byref autotrim blockinput clipwait click
            control controlclick controlfocus controlget controlgetfocus controlgetpos controlgettext controlmove
            controlsend controlsendraw controlsettext coordmode critical detecthiddentext detecthiddenwindows
            driveget drivespacefree endrepeat envadd envdiv envget envmult envset envsub envupdate fileappend
            filecopy filecopydir filecreatedir filecreateshortcut filedelete filegetattrib filegetshortcut
            filegetsize filegettime filegetversion fileinstall filemove filemovedir fileread filereadline
            filerecycle filerecycleempty fileremovedir fileselectfile fileselectfolder filesetattrib filesettime
            formattime getkeystate groupactivate groupadd groupclose groupdeactivate gui guicontrol guicontrolget
            hideautoitwin hotkey imagesearch inidelete iniread iniwrite input inputbox keyhistory keywait
            listhotkeys listlines listvars mouseclick mouseclickdrag mousegetpos mousemove msgbox numget numset
            outputdebug pixelgetcolor pixelsearch postmessage regdelete registercallback regread regwrite reload
            runas runwait send sendevent sendinput sendmessage sendmode sendplay sendraw setcapslockstate
            setcontroldelay setdefaultmousespeed setenv setformat setkeydelay setmousedelay setnumlockstate
            setscrolllockstate setstorecapslockmode settitlematchmode setwindelay setworkingdir soundbeep soundget
            soundgetwavevolume soundplay soundset soundsetwavevolume splashimage splashtextoff splashtexton
            splitpath statusbargettext statusbarwait stringcasesense stringgetpos stringleft stringlen stringlower
            stringmid stringreplace stringright stringsplit stringtrimleft stringtrimright stringupper sysget
            thread tooltip transform traytip urldownloadtofile winactivate winactivatebottom winclose winget
            wingetactivestats wingetactivetitle wingetclass wingetpos wingettext wingettitle winhide winkill
            winmaximize winmenuselectitem winminimize winminimizeall winminimizeallundo winmove winrestore winset
            winsettitle winshow winwait winwaitactive winwaitclose winwaitnotactive abs acos asc asin atan ceil
            chr cos dllcall exp fileexist floor il_add il_create il_destroy instr islabel ln log lv_add lv_delete
            lv_deletecol lv_getcount lv_getnext lv_gettext lv_insert lv_insertcol lv_modify lv_modifycol
            lv_setimagelist mod onmessage round regexmatch regexreplace sb_seticon sb_setparts sb_settext sin sqrt
            strlen substr tan tv_add tv_delete tv_getchild tv_getcount tv_getnext tv_get tv_getparent tv_getprev
            tv_getselection tv_gettext tv_modify varsetcapacity winactive winexist allowsamelinecomments
            clipboardtimeout commentflag errorstdout escapechar hotkeyinterval hotkeymodifiertimeout hotstring
            include includeagain installkeybdhook installmousehook maxhotkeysperinterval maxmem maxthreads
            maxthreadsbuffer maxthreadsperhotkey noenv notrayicon singleinstance usehook winactivateforce shift
            lshift rshift alt lalt ralt lcontrol rcontrol ctrl lctrl rctrl lwin rwin appskey altdown altup
            shiftdown shiftup ctrldown ctrlup lwindown lwinup rwindown rwinup lbutton rbutton mbutton wheelup
            wheeldown xbutton1 xbutton2 joy1 joy2 joy3 joy4 joy5 joy6 joy7 joy8 joy9 joy10 joy11 joy12 joy13 joy14
            joy15 joy16 joy17 joy18 joy19 joy20 joy21 joy22 joy23 joy24 joy25 joy26 joy27 joy28 joy29 joy30 joy31
            joy32 joyx joyy joyz joyr joyu joyv joypov joyname joybuttons joyaxes joyinfo space tab enter escape
            backspace delete insert pgup pgdn printscreen ctrlbreak scrolllock capslock numlock numpad0 numpad1
            numpad2 numpad3 numpad4 numpad5 numpad6 numpad7 numpad8 numpad9 numpadmult numpadadd numpadsub
            numpaddiv numpaddot numpaddel numpadins numpadclear numpadup numpaddown numpadleft numpadright
            numpadhome numpadend numpadpgup numpadpgdn numpadenter f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14
            f15 f16 f17 f18 f19 f20 f21 f22 f23 f24 browser_back browser_forward browser_refresh browser_stop
            browser_search browser_favorites browser_home volume_mute volume_down volume_up media_next media_prev
            media_stop media_play_pause launch_mail launch_media launch_app1 launch_app2 a_ahkpath a_ahkversion
            a_appdata a_appdatacommon a_autotrim a_batchlines a_caretx a_carety a_computername a_controldelay
            a_cursor a_dd a_ddd a_dddd a_defaultmousespeed a_desktop a_desktopcommon a_detecthiddentext
            a_detecthiddenwindows a_endchar a_eventinfo a_exitreason a_formatfloat a_formatinteger a_gui
            a_guievent a_guicontrol a_guicontrolevent a_guiheight a_guiwidth a_guix a_guiy a_hour a_iconfile
            a_iconhidden a_iconnumber a_icontip a_index a_ipaddress1 a_ipaddress2 a_ipaddress3 a_ipaddress4
            a_isadmin a_iscompiled a_issuspended a_keydelay a_language a_lasterror a_linefile a_linenumber
            a_loopfield a_loopfileattrib a_loopfiledir a_loopfileext a_loopfilefullpath a_loopfilelongpath
            a_loopfilename a_loopfileshortname a_loopfileshortpath a_loopfilesize a_loopfilesizekb
            a_loopfilesizemb a_loopfiletimeaccessed a_loopfiletimecreated a_loopfiletimemodified a_loopreadline
            a_loopregkey a_loopregname a_loopregsubkey a_loopregtimemodified a_loopregtype a_mday a_min a_mm a_mmm
            a_mmmm a_mon a_mousedelay a_msec a_mydocuments a_now a_nowutc a_numbatchlines a_ostype a_osversion
            a_priorhotkey a_programfiles a_programs a_programscommon a_screenheight a_screenwidth a_scriptdir
            a_scriptfullpath a_scriptname a_sec a_space a_startmenu a_startmenucommon a_startup a_startupcommon
            a_stringcasesense a_tab a_temp a_thisfunc a_thishotkey a_thislabel a_thismenu a_thismenuitem
            a_thismenuitempos a_tickcount a_timeidle a_timeidlephysical a_timesincepriorhotkey
            a_timesincethishotkey a_titlematchmode a_titlematchmodespeed a_username a_wday a_windelay a_windir
            a_workingdir a_yday a_year a_yweek a_yyyy clipboard clipboardall comspec errorlevel programfiles true
            false ltrim rtrim ahk_id ahk_pid ahk_class ahk_group processname minmax controllist statuscd
            filesystem setlabel alwaysontop mainwindow nomainwindow useerrorlevel altsubmit hscroll vscroll
            imagelist wantctrla wantf2 visfirst return wantreturn backgroundtrans minimizebox maximizebox sysmenu
            toolwindow exstyle check3 checkedgray readonly notab lastfound lastfoundexist alttab shiftalttab
            alttabmenu alttabandmenu alttabmenudismiss controllisthwnd hwnd deref pow bitnot bitand bitor bitxor
            bitshiftleft bitshiftright sendandmouse mousemouveoff hkey_local_machine hkey_users hkey_current_user
            hkey_classes_root hkey_current_config hklm hku hkcu hkcr hkcc reg_sz reg_expand_sz reg_multi_sz
            reg_dword reg_qword reg_binary reg_link reg_resource_list reg_full_resource_descriptor
            reg_resource_requirements_list reg_dword_big_endian regex rgb belownormal abovenormal xdigit alpha
            upper lower alnum topmost transparent transcolor redraw idlast togglecheck toggleenable nodefault
            nostandard deleteall noicon groupbox button checkbox dropdownlist ddl combobox statusbar treeview
            listbox listview datetime monthcal updown iconsmall sortdesc nosort nosorthdr hdr autosize range font
            resize owner nohide minimize maximize restore noactivate cancel destroy center margin owndialogs
            guiescape guiclose guisize guicontextmenu guidropfiles tabstop choosestring enabled disabled visible
            notimers interrupt priority waitclose OnClipboardChange OnGUIClose OnGUIEscape OnGUICancel
            </Keywords>
    )
    template2=
    (
		</CoDet>
		<CMDHelper global="1" sci="1" forum="1" tags="1">
			<HelpKey ctrl="1" alt="0" shift="0" win="0">F1</HelpKey>
			<TagsKey ctrl="1" alt="0" shift="0" win="0">F2</TagsKey>
			<HelpPath online="0">%hlpPath%</HelpPath>
		</CMDHelper>
		<LiveCode linewrap="1" highlighting="1" url="1" symbols="0" snplib="0">
			<RCPaths current="%current%">
				<L-Ansi>%ansi%</L-Ansi>
				<L-Unicode>%unicode%</L-Unicode>
				<Basic/>
				<IronAHK/>
			</RCPaths>
            <SnippetLib current="Example Snippets">
				<Group name="Example Snippets" count="3">
                    <Snippet title="Coord Saver">
/*
************************************************************************************
* This script saves X and Y coordinates in a file every time you click.            *
* Very useful for quickly determining positions on the screen or to record several *
* x y positions to be parsed later on by a macro which would click those positions *
* automatically.                                                                   *
*                                                                                  *
* Use the Right Mouse button or the Esc key to exit the application.               *
************************************************************************************
*/

CoordMode, Mouse, Screen
s_file := a_desktop . "\coords.txt"         ; Change as desired

Loop
{
    MouseGetPos, X, Y
    ToolTip, x(`%X`%)``, y(`%Y`%)                ; Tooltip to make everything easier
    Sleep 10
}

Esc::
RButton::
    ExitApp
~LButton::FileAppend, `%X`%``,`%Y`%``n, `%s_file`%  ; Save coords to parse e.g. 300,400
                    </Snippet>
					<Snippet title="Schedule Shutdown">
/*
************************************************************************************
* All Live Code scripts can make use the variables 'sec' 'min' and 'hour'          *
*                                                                                  *
* The following script schedules a shutdown on the specified time.                 *
* Note that we need to divide by 1000 because the shutown command                  *
* only accepts seconds while our variables return milliseconds.                    *
*                                                                                  *
* Also as we are dividing, time would return a decimal number                      *
* so we need to get rid of the '.000000' before passing it to the shutdown command *
************************************************************************************
*/

Gui, add, Groupbox,w235 h50, Shutdown in:
Gui, add, Edit, xp+10 yp+20 w25 vhh
Gui, add, Text, x+5 yp+3, Hours
Gui, add, Edit, x+10 yp-3 w25 vmm
Gui, add, Text, x+5 yp+3, Minutes
Gui, add, Edit, x+10 yp-3 w25 vss
Gui, add, Text, x+5 yp+3, Seconds
Gui, add, Text, x0 y+20 w260 0x10
Gui, add, Button, x170 yp+5 w75 Default gGuiHandler, &amp;Schedule

Gui, show, w255
return

GuiHandler:
    Gui, submit
    hh := !hh ? 0 : hh, mm := !mm ? 0 : mm,ss := !ss ? 0 : ss
    time := regexreplace(time:=(hh*hour + mm*min + ss*sec)/1000, "\.\d+")
    Run, `%comspec`% /c "Shutdown -s -t `%time`% -f"
    ExitApp
                    </Snippet>
					<Snippet title="Text Control - Style Ref.">
/*
************************************************************************************
* This Script is just a demostration of the styles that you can apply to           *
* Text controls.                                                                   *
*                                                                                  *
* To apply a style just write the code like this:                                  *
* Gui, add, Text, [options] [style]                                                *
* Ex. Gui, add, Text, w50 h50 x20 y25 0x4                                          *
*                                                                                  *
* As you can see this opens tons of posibilities in your Gui Creation and with     *
* enough creativity you can create cool interfaces!                                *
* Dont limit yourself to the defaults!                                             * *                                                                                  *
* **Press Esc to close the Aplication                                              *
************************************************************************************
*/

; --[Main]------------------------------------------------------------------------

0x4=
`(
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

As you can see this opens tons of posibilities in your Gui Creation and
with enough creativity you can create cool interfaces!
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

Esc::
GuiClose:
    ExitApp
                    </Snippet>
                    <Snippet title="Version Test">
version := "AHK Version: " a_ahkversion 
unicode := "Supports Unicode: " `(a_isunicode ? "Yes" : "No"`)
Msgbox `% version "``n" unicode
					</Snippet>
				</Group>
			</SnippetLib>
    )
    template3=
    (
			<Keywords>
				<Directives list="0">
                allowsamelinecomments clipboardtimeout commentflag errorstdout escapechar hotkeyinterval
                hotkeymodifiertimeout hotstring if iftimeout ifwinactive ifwinexist include includeagain
                installkeybdhook installmousehook keyhistory ltrim maxhotkeysperinterval maxmem maxthreads
                maxthreadsbuffer maxthreadsperhotkey menumaskkey noenv notrayicon persistent singleinstance
                usehook warn winactivateforce
                </Directives>
				<Commands list="1">
                autotrim blockinput clipwait control controlclick controlfocus controlget controlgetfocus
                controlgetpos controlgettext controlmove controlsend controlsendraw controlsettext coordmode
                critical detecthiddentext detecthiddenwindows drive driveget drivespacefree edit endrepeat envadd
                envdiv envget envmult envset envsub envupdate fileappend filecopy filecopydir filecreatedir
                filecreateshortcut filedelete filegetattrib filegetshortcut filegetsize filegettime filegetversion
                fileinstall filemove filemovedir fileread filereadline filerecycle filerecycleempty fileremovedir
                fileselectfile fileselectfolder filesetattrib filesettime formattime getkeystate groupactivate
                groupadd groupclose groupdeactivate gui guicontrol guicontrolget hideautoitwin hotkey if ifequal
                ifexist ifgreater ifgreaterorequal ifinstring ifless iflessorequal ifmsgbox ifnotequal ifnotexist
                ifnotinstring ifwinactive ifwinexist ifwinnotactive ifwinnotexist imagesearch inidelete iniread
                iniwrite input inputbox keyhistory keywait listhotkeys listlines listvars menu mouseclick
                mouseclickdrag mousegetpos mousemove msgbox outputdebug pixelgetcolor pixelsearch postmessage
                process progress random regdelete regread regwrite reload run runas runwait send sendevent
                sendinput sendmessage sendmode sendplay sendraw setbatchlines setcapslockstate setcontroldelay
                setdefaultmousespeed setenv setformat setkeydelay setmousedelay setnumlockstate setscrolllockstate
                setstorecapslockmode settitlematchmode setwindelay setworkingdir shutdown sort soundbeep soundget
                soundgetwavevolume soundplay soundset soundsetwavevolume splashimage splashtextoff splashtexton
                splitpath statusbargettext statusbarwait stringcasesense stringgetpos stringleft stringlen
                stringlower stringmid stringreplace stringright stringsplit stringtrimleft stringtrimright
                stringupper sysget thread tooltip transform traytip urldownloadtofile winactivate
                winactivatebottom winclose winget wingetactivestats wingetactivetitle wingetclass wingetpos
                wingettext wingettitle winhide winkill winmaximize winmenuselectitem winminimize winminimizeall
                winminimizeallundo winmove winrestore winset winsettitle winshow winwait winwaitactive
                winwaitclose winwaitnotactive fileencoding
                </Commands>
				<FlowControl list="2">
                break continue else exit exitapp gosub goto loop onexit pause repeat return settimer sleep suspend
                static global local byref while until for
                </FlowControl>
				<Functions list="3">
                abs acos asc asin atan ceil chr cos dllcall exp fileexist floor getkeystate numget numput
                registercallback il_add il_create il_destroy instr islabel isfunc ln log lv_add lv_delete
                lv_deletecol lv_getcount lv_getnext lv_gettext lv_insert lv_insertcol lv_modify lv_modifycol
                lv_setimagelist mod onmessage round regexmatch regexreplace sb_seticon sb_setparts sb_settext sin
                sqrt strlen substr tan tv_add tv_delete tv_getchild tv_getcount tv_getnext tv_get tv_getparent
                tv_getprev tv_getselection tv_gettext tv_modify varsetcapacity winactive winexist trim ltrim rtrim
                fileopen strget strput object isobject objinsert objremove objminindex objmaxindex objsetcapacity
                objgetcapacity objgetaddress objnewenum objaddref objrelease objclone _insert _remove _minindex
                _maxindex _setcapacity _getcapacity _getaddress _newenum _addref _release _clone comobjcreate
                comobjget comobjconnect comobjerror comobjactive comobjenwrap comobjunwrap comobjparameter
                comobjmissing comobjtype comobjvalue comobjarray
                </Functions>
				<BuiltInVars list="4">
                a_ahkpath a_ahkversion a_appdata a_appdatacommon a_autotrim a_batchlines a_caretx a_carety
                a_computername a_controldelay a_cursor a_dd a_ddd a_dddd a_defaultmousespeed a_desktop
                a_desktopcommon a_detecthiddentext a_detecthiddenwindows a_endchar a_eventinfo a_exitreason
                a_formatfloat a_formatinteger a_gui a_guievent a_guicontrol a_guicontrolevent a_guiheight
                a_guiwidth a_guix a_guiy a_hour a_iconfile a_iconhidden a_iconnumber a_icontip a_index
                a_ipaddress1 a_ipaddress2 a_ipaddress3 a_ipaddress4 a_isadmin a_iscompiled a_issuspended
                a_keydelay a_language a_lasterror a_linefile a_linenumber a_loopfield a_loopfileattrib
                a_loopfiledir a_loopfileext a_loopfilefullpath a_loopfilelongpath a_loopfilename
                a_loopfileshortname a_loopfileshortpath a_loopfilesize a_loopfilesizekb a_loopfilesizemb
                a_loopfiletimeaccessed a_loopfiletimecreated a_loopfiletimemodified a_loopreadline a_loopregkey
                a_loopregname a_loopregsubkey a_loopregtimemodified a_loopregtype a_mday a_min a_mm a_mmm a_mmmm
                a_mon a_mousedelay a_msec a_mydocuments a_now a_nowutc a_numbatchlines a_ostype a_osversion
                a_priorhotkey a_programfiles a_programs a_programscommon a_screenheight a_screenwidth a_scriptdir
                a_scriptfullpath a_scriptname a_sec a_space a_startmenu a_startmenucommon a_startup
                a_startupcommon a_stringcasesense a_tab a_temp a_thishotkey a_thismenu a_thismenuitem
                a_thismenuitempos a_tickcount a_timeidle a_timeidlephysical a_timesincepriorhotkey
                a_timesincethishotkey a_titlematchmode a_titlematchmodespeed a_username a_wday a_windelay a_windir
                a_workingdir a_yday a_year a_yweek a_yyyy clipboard clipboardall comspec errorlevel programfiles
                true false a_thisfunc a_thislabel a_ispaused a_iscritical a_isunicode a_ptrsize
                </BuiltInVars>
				<Keys list="5">
                shift lshift rshift alt lalt ralt control lcontrol rcontrol ctrl lctrl rctrl lwin rwin appskey
                altdown altup shiftdown shiftup ctrldown ctrlup lwindown lwinup rwindown rwinup lbutton rbutton
                mbutton wheelup wheeldown xbutton1 xbutton2 joy1 joy2 joy3 joy4 joy5 joy6 joy7 joy8 joy9 joy10
                joy11 joy12 joy13 joy14 joy15 joy16 joy17 joy18 joy19 joy20 joy21 joy22 joy23 joy24 joy25 joy26
                joy27 joy28 joy29 joy30 joy31 joy32 joyx joyy joyz joyr joyu joyv joypov joyname joybuttons
                joyaxes joyinfo space tab enter escape esc backspace bs delete del insert ins pgup pgdn home end
                up down left right printscreen ctrlbreak pause scrolllock capslock numlock numpad0 numpad1 numpad2
                numpad3 numpad4 numpad5 numpad6 numpad7 numpad8 numpad9 numpadmult numpadadd numpadsub numpaddiv
                numpaddot numpaddel numpadins numpadclear numpadup numpaddown numpadleft numpadright numpadhome
                numpadend numpadpgup numpadpgdn numpadenter f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16
                f17 f18 f19 f20 f21 f22 f23 f24 browser_back browser_forward browser_refresh browser_stop
                browser_search browser_favorites browser_home volume_mute volume_down volume_up media_next
                media_prev media_stop media_play_pause launch_mail launch_media launch_app1 launch_app2 blind
                click raw wheelleft wheelright
                </Keys>
				<Parameters list="6">
                ltrim rtrim join ahk_id ahk_pid ahk_class ahk_group processname minmax controllist statuscd
                filesystem setlabel alwaysontop mainwindow nomainwindow useerrorlevel altsubmit hscroll vscroll
                imagelist wantctrla wantf2 vis visfirst wantreturn backgroundtrans minimizebox maximizebox sysmenu
                toolwindow exstyle check3 checkedgray readonly notab lastfound lastfoundexist alttab shiftalttab
                alttabmenu alttabandmenu alttabmenudismiss controllisthwnd hwnd deref pow bitnot bitand bitor
                bitxor bitshiftleft bitshiftright sendandmouse mousemove mousemoveoff hkey_local_machine
                hkey_users hkey_current_user hkey_classes_root hkey_current_config hklm hku hkcu hkcr hkcc reg_sz
                reg_expand_sz reg_multi_sz reg_dword reg_qword reg_binary reg_link reg_resource_list
                reg_full_resource_descriptor caret reg_resource_requirements_list reg_dword_big_endian regex pixel
                mouse screen relative rgb low belownormal normal abovenormal high realtime between contains in is
                integer float number digit xdigit alpha upper lower alnum time date not or and topmost top bottom
                transparent transcolor redraw region id idlast count list capacity eject lock unlock label serial
                type status seconds minutes hours days read parse logoff close error single shutdown menu exit
                reload tray add rename check uncheck togglecheck enable disable toggleenable default nodefault
                standard nostandard color delete deleteall icon noicon tip click show edit progress hotkey text
                picture pic groupbox button checkbox radio dropdownlist ddl combobox statusbar treeview listbox
                listview datetime monthcal updown slider tab tab2 iconsmall tile report sortdesc nosort nosorthdr
                grid hdr autosize range xm ym ys xs xp yp font resize owner submit nohide minimize maximize
                restore noactivate na cancel destroy center margin owndialogs guiescape guiclose guisize
                guicontextmenu guidropfiles tabstop section wrap border top bottom buttons expand first lines
                number uppercase lowercase limit password multi group background bold italic strike underline norm
                theme caption delimiter flash style checked password hidden left right center section move focus
                hide choose choosestring text pos enabled disabled visible notimers interrupt priority waitclose
                unicode tocodepage fromcodepage yes no ok cancel abort retry ignore force on off all send wanttab
                monitorcount monitorprimary monitorname monitorworkarea pid base useunsetlocal useunsetglobal
                localsameasglobal
                </Parameters>
            </Keywords>
    )
    template4=
    (
            <Styles>
                <Style name="Default" id="0" fgColor="000000" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Comment Line" id="1" fgColor="008000" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Comment Block" id="2" fgColor="008000" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Escape Secuence" id="3" fgColor="FF0000" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Syn Operator" id="4" fgColor="FF0000" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Exp Operator" id="5" fgColor="0000FF" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="String" id="6" fgColor="808080" bgColor="FFFFFF" fName="" fStyle="2"/>
                <Style name="Number" id="7" fgColor="FF8000" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Identifier" id="8" fgColor="000000" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Label" id="9" fgColor="0080FF" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Variables" id="10" fgColor="FF8000" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Variable Delimiter" id="11" fgColor="FF8000" bgColor="FFFFFF" fName="" fStyle="3"/>
                <Style name="Error" id="12" fgColor="EE0000" bgColor="FF8080" fName="" fStyle="1"/>
                <!--Keywords -->
                <Style name="Directives" id="13" fgColor="0000FF" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Commands" id="14" fgColor="0000FF" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Flow Control" id="15" fgColor="0000FF" bgColor="FFFFFF" fName="" fStyle="1"/>
                <Style name="Functions" id="16" fgColor="FF80FF" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="Built-in Variables" id="17" fgColor="FF8000" bgColor="FFFFFF" fName="" fStyle="3"/>
                <Style name="Keys and Buttons" id="18" fgColor="000000" bgColor="FFFFFF" fName="" fStyle="3"/>
                <Style name="Parameters" id="19" fgColor="408080" bgColor="FFFFFF" fName="" fStyle="0"/>
                <Style name="User Defined" id="20" fgColor="FF0000" bgColor="FFFFFF" fName="" fStyle="0"/>
            </Styles>
        </LiveCode>
        <ScrTools altdrag="1" prtscr="1">
            <Imagebin current="Imageshack">
                <Imagebin nick="">http://imagebin.org/index.php?page=add</Imagebin>
                <Imageshack private="0" user="" pass="">http://www.imageshack.us/upload_api.php</Imageshack>
            </Imagebin>
        </ScrTools>
    </Options>
    <Hotkeys count="0"/>
    <Hotstrings count="0"/>
</AHK-Toolkit>
    )
    FileDelete, %path%
    Sleep, 500
    
    ; Appending tabs because AutoHotkey deletes them at the beginning of the continuation section.
    FileAppend, %template%`n`t`t%template2%`n`t`t`t%template3%`n`t`t`t%template4%, %path%, UTF-8
    return ErrorLevel
}
debug(msg,delimiter = False){
    global debugfile, sdebug, script
    static ft := True   ; First time

    t := delimiter = 1 ? msg := "* ------------------------------------------`n" msg
    t := delimiter = 2 ? msg := msg "`n* ------------------------------------------"
    t := delimiter = 3 ? msg := "* ------------------------------------------`n" msg
                             .  "`n* ------------------------------------------"
    if (!debugfile){
        sdebug && ft ? (msg := "* ------------------------------------------`n"
                            .  "* " script.name " Debug ON`n* " script.name "[Start]`n"
                            .  "* getparams() [Start]`n" msg, ft := 0)
        OutputDebug, %msg%
    }
    else if (debugfile){
        ft ? (msg .= "* ------------------------------------------`n"
                  .  "* " script.name " Debug ON`n* " script.name
                  .  " [Start]`n* getparams() [Start]", ft := 0)
        FileAppend, %msg%`n, %debugfile%
    }
}
getparams(){
    global
    ; First we organize the parameters by priority [-sd, then -d , then everything else]
    ; I want to make sure that if i select to save a debug file, the debugging will be ON
    ; since the beginning because i use the debugging inside the next parameter checks as well.
    Loop, %0%
        param .= %a_index% .  a_space           ; param will contain the whole list of parameters

    if (InStr(param, "-h") || InStr(param, "--help")
    ||  InStr(param, "-?") || InStr(param, "/?")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 0x40
              , % "Accepted Parameters"
              , % "The script accepts the following parameters:`n`n"
                . "-h    --help`tOpens this dialog.`n"
                . "-v    --version`tOpens a dialog containing the current script version.`n"
                . "-d    --debug`tStarts the script with debug ON.`n"
                . "-sd  --save-debug`tStarts the script with debug ON but saves the info on the `n"
                . "`t`tspecified txt file.`n"
                . "-sc  --source-code`tSaves a copy of the source code on the specified dir, specially `n"
                . "`t`tuseful when the script is compiled and you want to see the source code."
        ExitApp
    }
    if (InStr(param, "-v") || InStr(param, "--version")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 0x40
              , % "Version"
              , % "Author: " script.author " <" script.email ">`n" "Version: " script.name " v" script.version "`t"
        ExitApp
    }
    if (InStr(param, "-d")
    ||  InStr(param, "--debug")){
        sparam := "-d "                         ; replace sparam with -d at the beginning.
    }
    if (InStr(param, "-sd")
    ||  InStr(param, "--save-debug")){
        RegexMatch(param,"-sd\s(\w+\.\w+)", df) ; replace sparam with -sd at the beginning
        sparam := "-sd " df1  a_space           ; also save the output file name next to it
    }
    Loop, Parse, param, %a_space%
    {
        if (a_loopfield = "-d" || a_loopfield = "-sd"
        ||  InStr(a_loopfield, ".txt")){        ; we already have those, so we just add the
            continue                            ; other parameters
        }
        sparam .= a_loopfield . a_space
    }
    sparam := RegexReplace(sparam, "\s+$","")   ; Remove trailing spaces. Organizing is done

	Loop, Parse, sparam, %a_space%
    {
        if (sdebug && !debugfile && (!a_loopfield || !InStr(a_loopfield,".txt")
        || InStr(a_loopfield,"-"))){
            debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
            Msgbox, 0x10
                  , % "Error"
                  , % "You must provide a name to a txt file to save the debug output.`n`n"
                    . "usage: " a_scriptname " -sd file.txt"
            ExitApp
        }
        else if (sdebug){
            debugfile ? :debugfile := a_loopfield
            debug ? debug("")
        }
        if (a_loopfield = "-d"
        ||  a_loopfield = "--debug"){
            debug := True, sdebug := False
            debug ? debug("* " script.name " Debug ON`n* " script.name " [Start]`n* getparams() [Start]", 1)
        }
        if (a_loopfield = "-sd"
        ||  a_loopfield = "--save-debug"){
            sdebug := True, debug := True
        }
        if (a_loopfield = "-sc"
        ||  a_loopfield = "--source-code"){
            sc := True
            debug ? debug("* Copying source code")
            FileSelectFile, instloc, S16, source_%a_scriptname%
                          , % "Save source file to..."
                          , % "AutoHotkey Script (*.ahk)"
            if (!instloc){
                debug ? debug("* Canceled. ExitApp [1]", 2)
                ExitApp
            }
            FileInstall,AHK-Toolkit.ahk, %instloc%
            if (!ErrorLevel){
                debug ? debug("* Source code successfully copied")
                MsgBox, 0x40
                      , % "Source code copied"
                      , % "The source code was successfully copied"
                      , 10 ; 10s timeout
            }
            else
            {
                debug ? debug("* Error while copying the source code")
                Msgbox, 0x10
                      , % "Error while copying"
                      , % "There was an error while copying the source code.`nPlease check that "
                        . "the file is not already present in the current directory and that "
                        . "you have write permissions on the current folder."
                ExitApp
            }
        }
    }
    debug ? : debug("* " script.name " Debug OFF")
    if (sdebug && !debugfile){                      ; needed in case -sd is the only parameter given
        debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
        Msgbox, 0x10
              , % "Error"
              , % "You must provide a name to a txt file to save the debug output.`n`n"
                . "usage: " a_scriptname " -sd file.txt"
        ExitApp
    }
    if (sc = True){
        debug ? debug("* ExitApp [0]", 2)
        ExitApp
    }
    debug ? debug("* getparams() [End]")
    return
}
update(lversion, rfile="github", logurl="", vline=5){
    global script, debug

    debug ? debug("* update() [Start]", 1)

    if a_thismenuitem = Check for Updates
        Progress, 50,,, % "Updating..."

    logurl := rfile = "github" ? "https://www.github.com/" script.author "/" script.name "/raw/master/Changelog.txt" :
    RunWait %ComSpec% /c "Ping -n 1 google.com",, Hide  ; Check if we are connected to the internet
    if connected := !ErrorLevel
    {
        debug ? debug("* Downloading log file")

        if a_thismenuitem = Check for Updates
            Progress, 90

        UrlDownloadToFile, %logurl%, %a_temp%\logurl
        FileReadLine, logurl, %a_temp%\logurl, %vline%
        debug ? debug("* Version: " logurl)
        RegexMatch(logurl, "v(.*)", Version)
        if (rfile = "github"){
            if (a_iscompiled)
                rfile := "http://github.com/downloads/" script.author "/" script.name "/" script.name "-" Version "-Compiled.zip"
            else
                rfile := "http://github.com/" script.author "/" script.name "/zipball/" Version
        }
        debug ? debug("* Local Version: " lversion " Remote Version: " Version1)
        if (Version1 > lversion){
            Progress, Off
            debug ? debug("* There is a new update available")
            Msgbox, 0x40044
                  , % "New Update Available"
                  , % "There is a new update available for this application.`n"
                    . "Do you wish to upgrade to " Version "?"
                  , 10 ; 10s timeout
            IfMsgbox, Timeout
            {
                debug ? debug("* Update message timed out", 3)
                return 1
            }
            IfMsgbox, No
            {
                debug ? debug("* Update aborted by user", 3)
                return 2
            }
            FileSelectFile, lfile, S16, %a_temp%
            debug ? debug("* Downloading file to: " lfile)
            UrlDownloadToFile, %rfile%, %lfile%
            Msgbox, 0x40040
                  , % "Download Complete"
                  , % "To install the new version simply replace the old file with the one`n"
                    . "that was downloaded.`n`n The application will exit now."
            Run, %lfile%
            ExitApp
        }
        else if a_thismenuitem = Check for Updates
        {
            Progress, Off
            debug ? (debug("* Script is up to date"), debug("* update() [End]", 2))
            Msgbox, 0x40040
                  , % "Script is up to date"
                  , % "You are using the latest version of this script.`n"
                    . "Current version is v" lversion
                  , 10 ; 10s timeout

            IfMsgbox, Timeout
            {
                debug ? debug("* Update message timed out", 3)
                return 1
            }
            return 0
        }
        else
        {
            debug ? (debug("* Script is up to date"), debug("* update() [End]", 2))
            return 0
        }
    }
    else
    {
        Progress, Off
        debug ? (debug("* Connection Failed", 3), debug("* update() [End]", 2))
        return 3
    }
}
splash(img=0){
    global

    Gui, 99: -Caption +LastFound +Border +AlwaysOnTop +Owner
    $hwnd := WinExist()
    WinSet, Transparent, 0

    Gui, 99: add, Picture, x0 y0, % img
    Gui, 99: show, w500 h200 NoActivate

    Loop, 255
    {
        alpha += 1
        WinSet, Transparent, %alpha%
    }

    Sleep, 2.5*sec

    Loop, 255
    {
        alpha--
        WinSet, Transparent, %alpha%
    }

    Gui, 99: destroy
    return
}
autostart(status){
    if status
    {
        RegWrite, REG_SZ, HKCU
                        , Software\Microsoft\Windows\CurrentVersion\Run
                        , AutoHotkey Toolkit
                        , %a_scriptfullpath%
    }
    else
    {
        RegDelete, HKCU
                 , Software\Microsoft\Windows\CurrentVersion\Run
                 , AutoHotkey Toolkit
    }
}
klist(inc="all", exc="", sep=" "){
    Static lPunct,$reRF,vAll,vLower,vUpper,vNum,vAlnum,vPunct,msb,mods,fkeys,npad,kbd,nil=

    if strLen(sep) > 1
        return  False     ; You can only specify 1 character as the separator

    ; List of keyboard and mouse names as defined in "List of Keys, Mouse Buttons, and Joystick Controls".
    vNum  :="0 1 2 3 4 5 6 7 8 9 "
    vLower:="a b c d e f g h i j k l m n o p q r s t u v w x y z "
    vUpper:="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z "
    vAlnum:= (RegexMatch(inc, "(all|alphanum)\^") ? vUpper : vLower) vNum
    vPunct:="! "" # $ % & ' ( ) * + , - . / : `; < = > ? @ [ \ ] ^ `` { | } ~ "
    msb   :="LButton RButton MButton WheelDown WheelUp "
    mods  :="AppsKey LWin RWin LControl RControl LShift RShift LAlt RAlt Control Alt Shift "
    fkeys :="F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 "
    npad  :="NumLock Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 "
          . "Numpad9 NumpadIns NumpadEnd NumpadDown NumpadPgDn NumpadLeft NumpadClear NumpadRight NumpadHome "
          . "NumpadUp NumpadPgUp NumpadDot NumpadDel NumpadDiv NumpadMult NumpadAdd NumpadSub NumpadEnter "
    kbd   :="Space Tab Enter Escape Backspace Delete Insert Home End PgUp PgDn Up Down Left Right "
          . "ScrollLock CapsLock PrintScreen CtrlBreak Pause Break Sleep "
    vAll  := RegexReplace(RegexReplace(vPunct vAlnum msb mods fkeys npad kbd , "\s", sep),"\" sep "$")
    kwords:= "lower|upper|num|punct|alphanum|msb|mods|fkeys|npad|kbd"
    $reRF :="(\s?)+(?P<Start>[a-zA-Z0-9])-(?P<End>[a-zA-Z0-9])(\s?)+"
    lPunct:=",,,!,"",#,$,%,&,',(,),*,+,-,.,/,:,;,<,=,>,?,@,[,\,],^,``,{,|,},~" ; as a list for the if [in] command
    if (inStr(inc, "all") && !exc)
        return vAll

    While(RegexMatch(exc, kwords, match)){
        exc := RegexReplace(exc, "\b" match "\b(\s?)+"
                           , match = "alphanum" ? vAlnum    : nil
                           . match = "lower"    ? vLower    : nil
                           . match = "upper"    ? vUpper    : nil
                           . match = "num"      ? vNum      : nil
                           . match = "punct"    ? vPunct    : nil
                           . match = "msb"      ? msb       : nil
                           . match = "mods"     ? mods      : nil
                           . match = "fkeys"    ? fkeys     : nil
                           . match = "npad"     ? npad      : nil
                           . match = "kbd"      ? kbd       : nil)
    }

    ; Advanced including options.
    ; This little loop allows excluding ranges like "1-5" or "a-d".
    ; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not allowed.
    While(Regexmatch(inc, $reRF, r)){
        Loop % asc(rEnd) - asc(rStart) + 1 ; the + 1 is to include the last character in range.
            lst .= chr(a_index + asc(rStart) - 1) a_space

        inc := RegexReplace(inc, $reRF, "", "", 1)
    }

    ; This will include user specified keys and will replace keywords by their respective lists.
    lst .= inc a_space
        . (inStr(inc,"all") ? vAlnum vPunct msb mods fkeys npad kbd : nil)
        . (inStr(inc,"alphanum") && !inStr(exc, "alphanum") ? vAlnum : nil)
        . (inStr(inc, "lower") && !inStr(inc,"alphanum") && !inStr(exc, "lower") ? vLower : nil)
        . (inStr(inc, "upper") && !inStr(inc,"alphanum") && !inStr(exc, "upper") ? vUpper : nil)
        . (RegexMatch(inc,"\bnum\b") && !RegexMatch(exc,"\bnum\b") ? vNum : nil)
        . (inStr(inc, "punct") && !inStr(exc, "punct") ? vPunct : nil)
        . (inStr(inc, "msb") && !inStr(exc, "msb") ? msb : nil)
        . (inStr(inc, "fkeys") && !inStr(exc, "fkeys") ? fkeys : nil)
        . (inStr(inc, "npad") && !inStr(exc, "npad") ? npad : nil)
        . (inStr(inc,"kbd") && !inStr(exc,"kbd") ? kbd : nil)
        . (inStr(inc,"mods^") && !inStr(exc,"mods") ? mods : inStr(inc,"mods") && !inStr(exc,"mods") ? nil
        . RegexReplace(mods, "(AppsKey|LControl|RControl|LShift|RShift|LAlt|RAlt)(\s?)+") : nil)

    ; Advanced excluding options.
    ; This little loop allows excluding ranges like "1-5" or "a-d".
    ; The rage should always be positive i. e. ranges like "6-1" or "h-b" are not allowed.
    While(Regexmatch(exc, $reRF, r)){
        Loop % asc(rEnd) - asc(rStart) + 1    ; the + 1 is to include the last character in range.
            StringReplace,lst,lst,% chr(a_index + asc(rStart) - 1) a_space

        exc := RegexReplace(exc, $reRF, "", "", 1)
    }

    ; Remove excluded keys from list.
    Loop, Parse, exc, %a_space%
    {
        ; needed Regex to avoid deleting "NumpadEnter" when trying to delete "Enter" and such.
        if strLen(a_loopfield) > 1
            lst := RegexReplace(lst, "i)\b" a_loopfield "\b\s?")
        else if a_loopfield in %lPunct%
            lst := a_loopfield ? RegexReplace(lst, "\" a_loopfield "\s?") : lst
        else if (a_loopfield != "")
            lst := RegexReplace(lst, "\b" a_loopfield "\b\s?")
    }

    ; Cleaning.
    lst := RegexReplace(lst,"(\s?)+[a-zA-Z0-9]-[a-zA-Z0-9](\s?)+") ; remove ranges from include.
    lst := RegexReplace(lst,"i)(all\^?|lower|upper|\bnum\b|alphanum\^?|punct|msb|mods\^?|fkeys|npad|kbd)(\s?)+")
    return RegexReplace(RegexReplace(lst, "\s", sep), "\" sep "$")
} ; Function End.
rName(length = "", filext = ""){
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

; Storage
WM(var){
    static

    MOUSEMOVE:=0x200,COMMAND:=0x111
    EDITLABEL:=a_isunicode ? 4214 : 4119
    return lvar:=%var%
}
;}

;[Hotkeys/Hotstrings]{
^CtrlBreak::Reload
;}
