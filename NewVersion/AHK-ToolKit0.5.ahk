/*
 * =============================================================================================== *
 * Author           : RaptorX   <graptorx@gmail.com>
 * Script Name      : AutoHotkey ToolKit
 * Script Version   : 0.5
 * Homepage         : http://www.autohotkey.com/forum/topic61379.html#376087
 *
 * Creation Date    : July 11, 2010
 * Modification Date: December 24, 2010
 *
 * Description      :
 * ------------------
 *
 * -----------------------------------------------------------------------------------------------
 * License          :           Copyright ©2010 RaptorX <GPLv3>
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
 * GUI 01 - Main GUI[AutoHotkey ToolKit]
 *
 * =============================================================================================== *
 */

;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
; --
SetBatchLines -1
SendMode Input
SetWorkingDir %A_ScriptDir%
; --
;-

;+--> ; ---------[Basic Info]---------
s_name      := "AHK-Toolkit"            ; Script Name
s_version   := "0.5"                    ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
getparams()
; update(s_version)
;-

;+--> ; ---------[General Variables]---------
sec         :=  1000 	                ; 1 second
min         :=  60*sec  	            ; 1 minute
hour        :=  60*min  	            ; 1 hour
; --
SysGet, mon, Monitor                    ; Get the boundaries of the current screen
SysGet, wa_, MonitorWorkArea            ; Get the working area of the current screen
; --
s_nxs       := "config.nxs"             ; Optional nxs file
;-

;+--> ; ---------[User Configuration]---------
;-

TrayMenu(), MainGui(), AddhkGui()
;+--> ; ---------[Labels]---------
tabHandler:                         ; Tab Handler for the Scintilla Control
    Gui, Submit, Nohide
    action := tabLast = "Live Code" ? "Show" : "Hide"
    Control,%action%,,,ahk_id %hSci1%
    MainMenu(tabLast = "Live Code" ? "enable" : "disable")
return

guiHandler:
return

menuHandler:
return

lvHandler:
return

GuiSize:                            ; Gui Size Handler
    SB_SetParts(150,150,a_guiwidth-370,50)
    Gui, ListView, hkList
    LV_ModifyCol(4, "AutoHdr")
    Gui, ListView, hsList
    LV_ModifyCol(3, "AutoHdr")
return

MasterHotkey:
ButtonClose:
GuiClose:
GuiEscape:
    main_toggle := !main_toggle
    if main_toggle
        Gui, show, w799 h422
    else
        Gui, Hide
return

Exit:
    ExitApp
;-

;+--> ; ---------[Functions]---------
MainGui(){
    global

    Gui, +LastFound +Resize +MinSize
    hwnd1 := WinExist(), MainMenu("init")

    Gui, Menu, MainMenu
    Gui, add, Tab2, x0 y0 w800 h400 HWNDtabcont gtabHandler vtabLast, % "Hotkeys|Hotstrings|Live Code"
    Gui, add, StatusBar, HWNDStatBar
    
    ; Needs to be moved to a better location
    ; also remember to change the number displayed by a variable.
    SB_SetParts(150,150,250,50)
    SB_SetText("`t0 Hotkeys currently active",1)
    SB_SetText("`t0 Hotstrings currently active",2)
    SB_SetText("`tv" s_version,4)

    Gui, Tab, Hotkeys
    Gui, add, ListView, w780 r20 Sort Grid AltSubmit HWNDhkList glvHandler vhkList
                      , % "Type|Program Name|Hotkey|Program Path"
    Gui, add, Text, x0 y350 w820 0x10 HWNDhkDelim
    Gui, add, Edit, x10 yp+10 w250 HWNDhQShk vQShk, % "Quick Search"
    Gui, add, Button, x+370 yp w75 HWNDhkAdd Default gGuiHandler, % "&Add"
    Gui, add, Button, x+10 yp w75 HWNDhkClose, % "&Close"

    Gui, Tab, Hotstrings
    Gui, add, ListView, w780 r12 Grid AltSubmit HWNDhsList glvHandler vhsList, % "Options|Abbreviation|Expand To"
    Gui, add, Groupbox, w780 h105 HWNDhsGbox, % "Quick Add"
    Gui, add, Text, xp+100 yp+20 HWNDhsText1, % "Expand:"
    Gui, add, Edit, x+10 yp-3 w150 HWNDhsEdit1 vhsExpand
    Gui, add, Text, x+10 yp+3 HWNDhsText2, % "To:"
    Gui, add, Edit, x+10 yp-3 w250 HWNDhsEdit2 glvHandler vhsExpandto
    Gui, add, Checkbox, x+10 yp+5 HWNDhsCbox1 visCode, % "Run AHK Code"
    Gui, add, CheckBox, x112 y+15 Checked HWNDhsCbox2 vhsAE, % "AutoExpand"
    Gui, add, CheckBox, xp+235 yp HWNDhsCbox3 vhsDND, % "Do not delete typed abbreviation"
    Gui, add, CheckBox, x112 y+10 HWNDhsCbox4 vhsTIOW, % "Trigger inside other words"
    Gui, add, CheckBox, xp+235 yp HWNDhsCbox5 vhsSR, % "Send Raw (do not translate {Enter} or {key})"
    Gui, add, Text, x0 y350 w820 0x10 HWNDhsDelim
    Gui, add, Edit, x10 yp+10 w250 HWNDhQShs vQShs, % "Quick Search"
    Gui, add, Button, x+370 yp w75 HWNDhsAdd Default, % "&Add"
    Gui, add, Button, x+10 yp w75 HWNDhsClose, % "&Close"

    Gui, Tab, Live Code
    hSci1:=SCI_Add(hwnd1, 5,25,790,320,"hidden","", "dll\scilexer.dll")
    Gui, add, Text, x0 y350 w820 0x10 HWNDlcDelim
    Gui, add, Edit, x10 yp+10 w250 HWNDhQSlc vQSlc, % "Quick Search"
    Gui, add, Button, x+370 yp w75 HWNDlcRun Default, % "&Run"
    Gui, add, Button, x+10 yp w75 HWNDlcClear, % "&Clear"
    GuiAttach()

    SCI_SetWrapMode("SC_WRAP_WORD")
    SCI_SetMarginWidthN(0,40)
    SCI_SetMarginWidthN(1,10)

    SCI_StyleSetFont("STYLE_DEFAULT", "Courier New")
    SCI_StyleSetSize("STYLE_DEFAULT", 10)
    SCI_StyleSetHotspot("STYLE_DEFAULT", True)
    SCI_StyleClearAll()
    SCI_SendEditor("SCI_SETHOTSPOTACTIVEUNDERLINE", True)

    ; I remove one pixel from w800 to cover the delimiter line on the right side
    ;
    ; The attach function redraws the tab on top of the Status bar.
    ; I made it so that the window is a little bit below the tab to avoid overlapping
    ; hence the h422.
    Gui, show, w799 h422 hide
    return hwnd1
}
AddhkGui(){
    ; Gui, 02: add, GroupBox, w400 h70, % "Hotkey Type"
    ; Gui, 02: add, Edit, xp+10 yp+20 w270 Disabled, %a_programfiles%
    ; Gui, 02: add, Button, x+10 w100 Disabled, % "&Browse..."
    ; Gui, 02: add, Radio, x20 y+5 Checked, % "Launch Script"
    ; Gui, 02: add, Radio, x+10, % "Launch File"
    ; Gui, 02: add, Radio,x+10, % "Launch Folder"
    ; Gui, 02: add, GroupBox, x10 w400 h70, % "Select Hotkey"
    ; Gui, 02: add, DropDownList, xp+10 yp+30 w200
    ; Gui, 02: add, CheckBox, x+10 yp+3, % "Ctrl"
    ; Gui, 02: add, CheckBox, x+10, % "Alt"
    ; Gui, 02: add, CheckBox, x+10, % "Shift"
    ; Gui, 02: add, CheckBox, x+10, % "Win"
    ; Gui, 02: add, Text, x0 y+35 w450 0x10
    ; Gui, 02: add, Button, x250 yp+10 w75 Default, % "&Add"
    ; Gui, 02: add, Button, x+10 yp w75, % "&Cancel"
    
    Gui, 02: show, w420 h210
}
MainMenu(stat="init"){

    if stat = init
    {
        Menu, iexport, add, Import Hotkeys/Hotstrings, MenuHandler
        Menu, iexport, add
        Menu, iexport, add, Export Hotkeys to file, MenuHandler
        Menu, iexport, add, Export Hotstrings to file, MenuHandler

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
        Menu, Edit, add, Set Read Only Flag, MenuHandler
        Menu, Edit, add, Clear Read Only Flag, MenuHandler
        Menu, Edit, disable, Clear Read Only Flag

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
        Menu, View, add
        Menu, View, add, Show Symbol, :Symbols
        Menu, View, add, Zoom, :Zoom
        Menu, View, add, Word Wrap, MenuHandler

        Menu, Settings, add, &Preferences`t`tCtrl+P, MenuHandler

        Menu, Managers, add, Script Manager, MenuHandler
        Menu, Managers, add, Snippet Library, MenuHandler

        Menu, Help, add, Help, MenuHandler
        Menu, Help, add, Documentation, MenuHandler
        Menu, Help, disable, Documentation
        Menu, Help, add
        Menu, Help, add, About, MenuHandler

        Menu, MainMenu, add, File, :File
        Menu, MainMenu, add, Edit, :Edit
        Menu, MainMenu, disable, Edit
        Menu, MainMenu, add, Search, :Search
        Menu, MainMenu, disable, Search
        Menu, MainMenu, add, View, :View
        Menu, MainMenu, disable, View
        Menu, MainMenu, add, Settings, :Settings
        Menu, MainMenu, add, Managers, :Managers
        Menu, MainMenu, add, Help, :Help
        return
    }

    Menu, MainMenu, %stat%, Edit
    Menu, MainMenu, %stat%, Search
    Menu, MainMenu, %stat%, View

    Menu, File, %stat%, &Open`t`tCtrl+O
    Menu, File, %stat%, &Save`t`tCtrl+S
    Menu, File, %stat%, Save As`t`tCtrl+Shift+S
    Menu, File, %stat%, Close`t`tCtrl+W
    Menu, File, %stat%, Close All`t`tCtrl+Shift+W
}
TrayMenu(){
    Menu, Tray, NoStandard
    Menu, Tray, Click, 1
    Menu, Tray, add, % "Show Main Gui", MasterHotkey
    Menu, Tray, Default, % "Show Main Gui"
    Menu, Tray, add
    Menu, Tray, Standard
}
GuiAttach(){
    global tabcont,hkList,hkDelim,hQShk,hkAdd,hkClose,StatBar
         , hsList,hsGbox,hsText1,hsEdit1,hsText2,hsEdit2,hsCbox1,hsCbox2,hsCbox3,hsCbox4,hsCbox5,hsDelim
         , hQShs,hsAdd,hsClose,lcDelim,hQSlc,lcRun,lcClear,hSci1

    ; hotkeys tab
    attach(tabcont, "w h")
    attach(hkList, "w h")
    attach(StatBar, "w r1")
    attach(hkDelim, "w y")
    attach(hQShk, "y")
    attach(hkAdd, "x y r2")
    attach(hkClose, "x y r2")

    ; hotstrings Tab
    c:="hsText1|hsEdit1|hsText2|hsEdit2|hsCbox1|hsCbox2|hsCbox3|hsCbox4|hsCbox5"
    Loop, Parse, c, |
        attach(%a_loopfield%, "x.5 y r1")

    attach(hsList, "w h r2")
    attach(hsGbox, "w y r2")

    attach(hsDelim, "w y r2")
    attach(hQShs, "y")
    attach(hsAdd, "x y r2")
    attach(hsClose, "x y r2")

    ; Live Code Tab
    attach(hSci1, "w h r2")
    attach(lcDelim, "w y r2")
    attach(hQSlc, "y")
    attach(lcRun, "x y r2")
    attach(lcClear, "x y r2")
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
        Msgbox, 64, % "Accepted Parameters"
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
        Msgbox, 64, % "Version"
                  , % "Author: " s_author " <" s_email ">`n" "Version: " s_name " v" s_version "`t"
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
            Msgbox, 16, % "Error"
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
            debug ? debug("* " s_name " Debug ON`n* " s_name " [Start]`n* getparams() [Start]", 1)
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
                MsgBox, 64, % "Source code copied"
                          , % "The source code was successfully copied"
                          , 10 ; 10s timeout
            }
            else
            {
                debug ? debug("* Error while copying the source code")
                Msgbox, 16, % "Error while copying"
                          , % "There was an error while copying the source code.`nPlease check that "
                          . "the file is not already present in the current directory and that "
                          . "you have write permissions on the current folder."
                          , 10 ; 10s timeout
            }
        }
    }
    debug ? : debug("* " s_name " Debug OFF")
    if (sdebug && !debugfile){                      ; needed in case -sd is the only parameter given
        debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
        Msgbox, 16, % "Error"
                  , % "You must provide a name to a txt file to save the debug output.`n`n"
                  .   "usage: " a_scriptname " -sd file.txt"
        ExitApp
    }
    if (sc = True){
        debug ? debug("* ExitApp [0]", 2)
        ExitApp
    }
    debug ? debug("* getparams() [End]", 2)
    return
}
debug(msg,delimiter = False){
    global debugfile, sdebug, s_name
    static ft := True   ; First time

    t := delimiter = 1 ? msg := "* ------------------------------------------`n" msg
    t := delimiter = 2 ? msg := msg "`n* ------------------------------------------"
    t := delimiter = 3 ? msg := "* ------------------------------------------`n" msg
                             .  "`n* ------------------------------------------"
    if (!debugfile){
        sdebug && ft ? (msg := "* ------------------------------------------`n"
                            .  "* " s_name " Debug ON`n* " s_name "[Start]`n"
                            .  "* getparams() [Start]`n" msg, ft := 0)
        OutputDebug, %msg%
    }
    else if (debugfile){
        ft ? (msg .= "* ------------------------------------------`n"
                  .  "* " s_name " Debug ON`n* " s_name
                  .  " [Start]`n* getparams() [Start]", ft := 0)
        FileAppend, %msg%`n, %debugfile%
    }
}
update(lversion, rfile="github", logurl="", vline=5){
    global s_author, s_name, debug

    debug ? debug("* update() [Start]", 1)
    t := rfile = "github" ? logurl := "https://www.github.com/" s_author "/" s_name "/raw/master/Changelog.txt"
    RunWait %ComSpec% /c "Ping -n 1 -w 10 google.com",, Hide  ; Check if we are connected to the internet
    if connected := !ErrorLevel
    {
        debug ? debug("* Downloading log file")
        UrlDownloadToFile, %logurl%, %a_temp%\logurl
        FileReadLine, logurl, %a_temp%\logurl, %vline%
        debug ? debug("* Version: " logurl)
        RegexMatch(logurl, "v(.*)", Version)
        if (rfile = "github"){
            if (a_iscompiled)
                rfile := "http://github.com/downloads/" s_author "/" s_name "/" s_name "-" Version "-Compiled.zip"
            else
                rfile := "http://github.com/" s_author "/" s_name "/zipball/" Version
        }
        debug ? debug("* Local Version: " lversion " Remote Version: " Version1)
        if (Version1 > lversion){
            debug ? debug("* There is a new update available")
            Msgbox, 68, % "New Update Available"
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
            Msgbox, 64, % "Download Complete"
                      , % "To install the new version simply replace the old file with the one`n"
                      .   "that was downloaded.`n`n The application will exit now."
            Run, %lfile%
            ExitApp
        }
        debug ? (debug("* Script is up to date"), debug("* update() [End]", 2))
        return 0
    }
    else
    {
        debug ? (debug("* Connection Failed", 3), debug("* update() [End]", 2))
        return 3
    }
}
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
^CtrlBreak::Reload
;-

;+--> ; ---------[Includes]---------
#include lib\attach.h.ahk
#include lib\hash.h.ahk
#include lib\SCI.h.ahk
;-
