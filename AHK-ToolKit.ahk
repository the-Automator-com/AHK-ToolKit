/*
 * =============================================================================================== *
 * Author           : RaptorX   <graptorx@gmail.com>
 * Script Name      : AutoHotkey ToolKit (AHK-ToolKit)
 * Script Version   : 0.5
 * Homepage         : http://www.autohotkey.com/forum/topic61379.html#376087
 *
 * Creation Date    : July 11, 2010
 * Modification Date: August 26, 2011
 *
 * Description      :
 * ------------------
 * This small program is a set of "tools" that i use regularly.
 *
 * A convenient GUI that serves as a hotkey and hotstring manager allows you to keep all of them
 * in an easy to read list.
 *
 * The Live Code tab allows you to quickly test ahk code without having to save a file even if 
 * Autohotkey is not installed in the computer you are using. Also there are other tools like the Command Detector and the Screen and Forum Tools that improve
 * the way i help other people while in IRC and ahk Forums.
 *
 * I hope other people find it useful. You can modify it and improve it as you like. Feel free 
 * to contact me if you want your changes to be added in the official release.
 *
 * -----------------------------------------------------------------------------------------------
 * License          :       Copyright ©2010-2011 RaptorX <GPLv3>
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
 * GUI 01 - First Time Run
 * GUI 01 - AutoHotkey ToolKit [MAIN GUI]
 * GUI 02 - Add Hotkey
 * GUI 03 - Add Hotstring
 * GUI 04 - Import Hotkeys/Hotstrings
 * GUI 05 - Export Hotkeys/Hotstrings
 * GUI 06 - Preferences
 * GUI 07 - Add Snippet
 * GUI 08 - About
 * GUI 97 - Code Detection
 * GUI 98 - General Preferences
 * GUI 99 - Splash Window
 *
 * =============================================================================================== *
 */

;[Includes]{
#include *i %a_scriptdir%
#include lib\sci.h.ahk
#include lib\hash.h.ahk
#include lib\klist.h.ahk
#include lib\attach.h.ahk
#include lib\hkSwap.h.ahk
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
class scriptobj
{
    name        := "AHK-ToolKit"                                             ; Script Name
    version     := "0.5"                                                     ; Script Version
    author      := "RaptorX"                                                 ; Script Author
    email       := "graptorx@gmail.com"                                      ; Author's contact email
    homepage    := "http://www.autohotkey.com/forum/topic61379.html#376087"  ; Script Homepage
    crtdate     := "July 11, 2010"                                           ; Script Creation Date
    moddate     := "July 05, 2011"                                           ; Script Modification Date
    conf        := "conf.xml"                                                ; Configuration file

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
        sparam := RegexReplace(sparam, "\s+$")      ; Remove trailing spaces. Organizing is done

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
                FileInstall,AHK-ToolKit.ahk, %instloc%
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

        logurl := rfile = "github" ? "https://raw.github.com/" script.author 
                                   . "/" script.name "/master/Changelog.txt" : logurl

        RunWait %ComSpec% /c "Ping -n 1 google.com" ,, Hide  ; Check if we are connected to the internet
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
} script := new scriptobj, script.getparams()
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
defBrowser:=monLEFT:=monRIGHT:=monTOP:=monBOTTOM:=waLEFT:=waRIGHT:=waTOP:=waBOTTOM:=null  ; Set all to null
;--
; Configuration file objects
conf := ComObjCreate("MSXML2.DOMDocument"), xsl := ComObjCreate("MSXML2.DOMDocument")
style =
(
<!-- Extracted from: http://www.dpawson.co.uk/xsl/sect2/pretty.html (v2) -->
<!-- Cdata info from: http://www.altova.com/forum/default.aspx?g=posts&t=1000002342 -->
<!-- Modified By RaptorX -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml"
            indent="yes"
            encoding="UTF-8"/>

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
<!-- I have to keep the indentation here in this file as i want it to be on the XML file -->
)
xsl.loadXML(style), style:=null
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
    script.splash("res\img\AHK-TK_Splash.png")

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

HotkeyHandler:  ;{
    HotkeyHandler(a_thishotkey)
return
;}

GuiSize:        ;{ Gui Size Handler
4GuiSize:
    if (a_gui = 1)
    {
        _lists := "hkList|shkList|hsList|shsList"
        _guiwidth := a_guiwidth, _guiheight:= a_guiheight
        SB_SetParts(150,150,a_guiwidth-370,50)

        Loop, Parse, _lists, |
        {
            Gui, 01: ListView, % a_loopfield
            if (a_loopfield = "hkList" || a_loopfield = "shkList")
                LV_ModifyCol(2, "Center"), LV_ModifyCol(3, "Center")
            Loop, 4
                LV_ModifyCol(a_index, "AutoHdr")
        }

        if (a_eventinfo = 1)
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

Exit:
    Process,Close, %hslPID%
    if FileExist(a_temp "\ahkl.bak")
        FileDelete, %a_temp%\ahkl.bak

    if FileExist(a_temp "\*.code")
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
    Menu, Tray, Icon, res/AHK-TK.ico
    Menu, iexport, add, Import Hotkeys/Hotstrings, MenuHandler
    Menu, iexport, disable, Import Hotkeys/Hotstrings
    Menu, iexport, add
    Menu, iexport, add, Export Hotkeys/Hotstrings, MenuHandler

    Menu, File, add, &New`tCtrl+N, MenuHandler
    Menu, File, add, Delete`tDEL, MenuHandler
    Menu, File, add
    Menu, File, add, &Open`tCtrl+O, MenuHandler
    Menu, File, disable, &Open`tCtrl+O
    Menu, File, add, &Save`tCtrl+S, MenuHandler
    Menu, File, disable, &Save`tCtrl+S
    Menu, File, add, Save As`tCtrl+Shift+S, MenuHandler
    Menu, File, disable, Save As`tCtrl+Shift+S
    Menu, File, add
    Menu, File, add, Import/Export, :iexport
    Menu, File, add
    Menu, File, add, Exit, Exit

    Menu, LO, add, Duplicate Line`tCtrl+D, MenuHandler
    Menu, LO, add, Split Lines`tCtrl+I, MenuHandler
    Menu, LO, add, Join Lines`tCtrl+J, MenuHandler
    Menu, LO, add, Move up current Line`tCtrl+Shift+Up, MenuHandler
    Menu, LO, add, Move down current Line`tCtrl+Shift+Down, MenuHandler

    Menu, Convert Case,add, Convert to Lowercase`tCtrl+U, MenuHandler
    Menu, Convert Case,add, Convert to Uppercase`tCtrl+Shift+U, MenuHandler

    Menu, Edit, add, Undo`tCtrl+Z, MenuHandler
    Menu, Edit, disable, Undo`tCtrl+Z
    Menu, Edit, add, Redo`tCtrl+Y, MenuHandler
    Menu, Edit, disable, Redo`tCtrl+Y
    Menu, Edit, add
    Menu, Edit, add, Cut`tCtrl+X, MenuHandler
    Menu, Edit, add, Copy`tCtrl+C, MenuHandler
    Menu, Edit, add, Paste`tCtrl+V, MenuHandler
    Menu, Edit, add, Select All`tCtrl+A, MenuHandler
    Menu, Edit, add
    Menu, Edit, add, Convert Case, :Convert Case
    Menu, Edit, add, Line Operations, :LO
    Menu, Edit, add, Trim Trailing Space`tCtrl+Space, MenuHandler
    Menu, Edit, add
    Menu, Edit, add, Set Read Only, MenuHandler

    Menu, Search, add, Find...`tCtrl+F, MenuHandler
    Menu, Search, add, Find in Files...`tCtrl+Shift+F, MenuHandler
    Menu, Search, add, Find Next...`tF3, MenuHandler
    Menu, Search, add, Find Previous...`tShift+F3, MenuHandler
    Menu, Search, add, Find && Replace`tCtrl+H, MenuHandler
    Menu, Search, add, Go to Line`tCtrl+G, MenuHandler
    Menu, Search, add, Go to Matching Brace`tCtrl+B, MenuHandler
    Menu, Search, disable, Go to Matching Brace`tCtrl+B

    Menu, Symbols, add, Show Spaces and TAB, MenuHandler
    Menu, Symbols, add, Show End Of Line, MenuHandler
    Menu, Symbols, add, Show All Characters, MenuHandler

    Menu, Zoom, add, Zoom in`tCtrl+Numpad +, MenuHandler
    Menu, Zoom, add, Zoom out`tCtrl+Numpad -, MenuHandler
    Menu, Zoom, add, Default Zoom`tCtrl+=, MenuHandler

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
    Menu, Settings, add, &Preferences`tCtrl+P, MenuHandler

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
    Gui, 01: +LastFound +Resize +MinSize650x300 %_aot%
    $hwnd1 := WinExist(), MainMenu(), _aot:=null
    tabLast := "Hotkeys"    ; Helps when deleting an item on the Hotkeys tab, before actually clicking the tabs.

    Gui, 01: menu, MainMenu
    Gui, 01: add, Tab2, x0 y0 w800 h400 HWND$tabcont gGuiHandler vtabLast, % "Hotkeys|Hotstrings|Live Code"
    Gui, 01: add, StatusBar, HWND$StatBar

    updateSB()

    _cnt := root.selectSingleNode("//Hotkeys/@count").text
    Gui, 01: tab, Hotkeys
    Gui, 01: add, ListView, w780 h315 HWND$hkList Count%_cnt% Sort Grid AltSubmit gListHandler vhkList
                          , % "Type|Program Name|Hotkey|Program Path"
    Gui, 01: add, ListView, w780 h315 xp yp HWND$shkList Count%_cnt% Sort Grid AltSubmit gListHandler vshkList
                          , % "Type|Program Name|Hotkey|Program Path"

    GuiControl, hide, shkList

    Load("Hotkeys")

    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$hkDelim
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 HWND$QShk gGuiHandler vQShk, % "Quick Search"
    Gui, 01: font
    Gui, 01: add, Button, x+370 yp w75 HWND$hkAdd Default gGuiHandler, % "&Add"
    Gui, 01: add, Button, x+10 yp w75 HWND$hkClose gGuiHandler, % "&Close"

    _cnt := root.selectSingleNode("//Hotstrings/@count").text
    Gui, 01: Tab, Hotstrings
    Gui, 01: add, ListView, w780 h205 HWND$hsList Count%_cnt% Grid AltSubmit gListHandler vhsList
                          , % "Type|Options|Abbreviation|Expand To"
    Gui, 01: add, ListView, w780 h205 xp yp HWND$shsList Count%_cnt% Grid AltSubmit gListHandler vshsList
                          , % "Type|Options|Abbreviation|Expand To"

    GuiControl, hide, shsList

    Gui, 01: add, Groupbox, w780 h105 HWND$hsGbox, % "Quick Add"
    Gui, 01: add, Text, xp+100 yp+20 HWND$hsText1, % "Expand:"
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x+10 yp-3 w150 HWND$hsExpand vhsExpand, % "e.g. btw"
    Gui, 01: font
    Gui, 01: add, Text, x+10 yp+3 HWND$hsText2, % "To:"
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x+10 yp-3 w250 HWND$hsExpandto vhsExpandto, % "e.g. by the way"
    Gui, 01: font
    Gui, 01: add, Checkbox, x+10 yp+5 HWND$hsCbox1 vhsIsCode, % "Run as Script"
    Gui, 01: add, CheckBox, x112 y+15 HWND$hsCbox2 Checked vhsAE, % "AutoExpand"
    Gui, 01: add, CheckBox, xp+235 yp HWND$hsCbox3 vhsDND, % "Do not delete typed abbreviation"
    Gui, 01: add, CheckBox, x112 y+10 HWND$hsCbox4 vhsTIOW, % "Trigger inside other words"
    Gui, 01: add, CheckBox, xp+235 yp HWND$hsCbox5 vhsSR, % "Send Raw (do not translate {Enter} or {key})"

    Load("HotStrings")

    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$hsDelim
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 HWND$QShs gGuiHandler vQShs, % "Quick Search"
    Gui, 01: font
    Gui, 01: add, Button, x+370 yp w75 HWND$hsAdd Default gGuiHandler, % "&Add"
    Gui, 01: add, Button, x+10 yp w75 HWND$hsClose gGuiHandler, % "&Close"

    Gui, 01: Tab, Live Code
    options.selectSingleNode("//@snplib").text ? w:=640 : w:=790
    $Sci1 := SCI_Add($hwnd1,5,25,w,320,"hidden","","lib\scilexer.dll")
    
    Gui, 01: add, Text, x650 y25 w145 h17 HWND$slTitle Center Border Hidden, % "Snippet Library"
    Gui, 01: add, DropDownList, xp y+5 w145 HWND$slDDL Hidden gGuiHandler Sort vslDDL
    _current := options.selectSingleNode("//SnippetLib/@current").text
    _cnt := options.selectSingleNode("//Group[@name='" _current "']/@count").text
    Gui, 01: add, ListView
                , w145 h270 HWND$slList -Hdr -ReadOnly
                . Count%_cnt% AltSubmit Sort Grid Hidden gListHandler vslList
                , % "Title"

    Load("SnpLib")

    Gui, 01: add, Text, x0 y350 w820 0x10 HWND$lcDelim
    Gui, 01: font, s8 cGray italic, Verdana
    Gui, 01: add, Edit, x10 yp+10 w250 Disabled HWND$QSlc gGuiHandler vQSlc, % "Quick Search"
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

    Gui, 02: add, GroupBox, w240 h55, % "Hotkey Name"
    Gui, 02: add, Edit, x20 yp+20 w220 HWND$hkName vhkName
    
    Gui, 02: add, GroupBox, xp-10 yp+40 w350 h70, % "Hotkey Type"
    Gui, 02: add, Radio, xp+10 yp+20 Checked gGuiHandler vhkType, % "Script"
    Gui, 02: add, Radio, x+20 gGuiHandler, % "File"
    Gui, 02: add, Radio,x+20 gGuiHandler, % "Folder"
    Gui, 02: add, Edit, x20 yp+20 w220 Disabled HWND$hk2Path vhkPath, %a_programfiles%
    Gui, 02: add, Button, x+10 w100 Disabled HWND$hk2Browse gGuiHandler, % "&Browse..."

    Gui, 02: add, GroupBox, x10 w350 h70, % "Select Hotkey"

    Gui, 02: add, CheckBox, xp+10 yp+33 vhkctrl, % "Ctrl"
    Gui, 02: add, CheckBox, x+10 vhkalt, % "Alt"
    Gui, 02: add, CheckBox, x+10 vhkshift, % "Shift"
    Gui, 02: add, CheckBox, x+10 vhkwin, % "Win"
    Gui, 02: add, DropDownList, x+10 yp-3 w140 vhkey, % lst:=klist("all^", "mods msb")" None  "
    ; SetHotkeys(lst,$hkddl, "Add Hotkey")

    Gui, 02: add, GroupBox, x+20 y6 w395 h205, % "Advanced Options"
    Gui, 02: add, Text,xp+10 yp+15, % "Note: Comma delimited, case insensitive and accepts RegExs"
    Gui, 02: font, s8 cGray italic, Verdana
    Gui, 02: add, Edit, w375 HWND$hkIfWin vhkIfWin, % "If window active list (e.g. Winamp, Notepad, Fire.*)"
    Gui, 02: add, Edit, wp HWND$hkIfWinN vhkIfWinN
                      , % "If window NOT active list (e.g. Notepad++, Firefox, post.*\s)"
    Gui, 02: font
    Gui, 02: add, Checkbox, xp y+5 vhkLMod, % "Left mod: only use left modifier key"
    Gui, 02: add, Checkbox, vhkRMod, % "Right mod: only use right modifier key"
    Gui, 02: add, Checkbox, vhkWild, % "Wildcard: fire with other keys           "
    Gui, 02: add, Checkbox, vhkSend, % "Send key to active window"
    Gui, 02: add, Checkbox, vhkHook, % "Install hook"
    Gui, 02: add, Checkbox, vhkfRel, % "Fire when releasing key"
    
    $Sci2 := SCI_Add($hwnd2,10,220,750,250,"","","lib\scilexer.dll")

    Gui, 02: add, Text, x0 y+280 w785 0x10 HWND$hk2Delim
    Gui, 02: add, Button, x600 yp+10 w75 HWND$hk2Add Default gGuiHandler, % "&Add"
    Gui, 02: add, Button, x+10 yp w75 HWND$hk2Cancel gGuiHandler, % "&Cancel"
    GuiAttach(2),initSci($Sci2)

    WinGet, cList2, ControlList
    WinGet, hList2, ControlListHWND

    Gui, 02: show, w770 h520 Hide, % "Add Hotkey"
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
                          , % "Type|Acelerator|Command|Path"

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
    Gui, 06: add, Picture, x165 y36 vAHKTK_UC Hidden, % "res\img\AHK-TK_UnderConstruction.png"
    
    ;{ General Preferences GUI
    Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    $hwnd98 := WinExist()

    vars := "ssi|smm|sww|cfu"
    Loop, Parse, vars, |
        _%a_loopfield% := options.selectSingleNode("//@" a_loopfield).text

    Gui, 98: add, GroupBox, x3 y0 w345 h70, % "Startup"
    Gui, 98: add, CheckBox, xp+25 yp+20 Checked%_ssi% v_ssi gGuiHandler, % "Show splash image"
    Gui, 98: add, CheckBox, x+70 Checked%_sww% v_sww gGuiHandler, % "Start with Windows"
    Gui, 98: add, CheckBox, x28 y+10 Checked%_smm% v_smm gGuiHandler, % "Start minimized"
    Gui, 98: add, CheckBox, x+91 Checked%_cfu% v_cfu gGuiHandler, % "Check for updates"

    _mhk := options.selectSingleNode("MainKey").text
    vars := "ctrl|alt|shift|win"
    Loop, Parse, vars, |
        _%a_loopfield% := options.selectSingleNode("MainKey/@" a_loopfield).text
    _mods:=(_ctrl ? "^" : null)(_alt ? "!" : null)(_shift ? "+" : null)(_win ? "#" : null)
    _mainhotkey := _mods _mhk

    Gui, 98: add, GroupBox, x3 y+20 w345 h55, % "Main GUI Hotkey"
    Gui, 98: add, CheckBox, xp+10 yp+23 Checked%_ctrl% v_ctrl gGuiHandler, % "Ctrl"
    Gui, 98: add, CheckBox, x+10 Checked%_alt% v_alt gGuiHandler, % "Alt"
    Gui, 98: add, CheckBox, x+10 Checked%_shift% v_shift gGuiHandler, % "Shift"
    Gui, 98: add, CheckBox, x+10 Checked%_win% v_win gGuiHandler, % "Win"
    Gui, 98: add, DropDownList, x+10 yp-3 w140 HWND$GP_DDL v_hkddl gGuiHandler
                , % lst:=klist("all^", "mods msb")" None  "

    Control,ChooseString,%_mhk%,, ahk_id %$GP_DDL%
    ; SetHotkeys(lst,$GP_DDL, "Preferences")

    Gui, 98: add, GroupBox, x3 y+26 w345 h100 Disabled, % "Suspend hotkeys on these windows"
    Gui, 98: add, Edit, xp+10 yp+20 w325 h70 HWND$GP_E1 v_swl gGuiHandler Disabled
                , % options.selectSingleNode("SuspWndList").text

    if strLen(_mhk) = 1
        Hotkey, % _mods "`" _mhk, GuiClose
    else
        Hotkey, % _mods _mhk, GuiClose

    ; --
    vars:=_ssi:=_sww:=_smm:=_cfu:=_mods:=_mhk:=_ctrl:=_alt:=_shift:=_win:=null ; Clean
    Gui, 98: show, x165 y36 w350 h245 NoActivate
    ;}

    ;{ Code Detection
    Gui, 97: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    $hwnd97 := WinExist()

    Gui, 97: add, GroupBox, x3 y0 w345 h170, % "Info"
    Gui, 97: add, Text, xp+10 yp+20 w330 Disabled
                      , % "CODET attempts to detect AutoHotkey code copied to the clipboard.`n`n"
                        . "Then it allows you to upload the code to a pastebin service like the ones offered by "
                        . "www.autohotkey.net or www.pastebin.com.`n`n"
                        . "Due to the fact that some AHK keywords can be found in normal text or other "
                        . "programming languages there can be false detections.`n`n"
                        . "You can select the minimum amount of keywords to match (the more the more accurate) "
                        . "and you can also edit the keyword list to add or delete words as you want to fine tune "
                        . "CODET to match your needs."

    Gui, 97: add, Text, x0 y+20 w360 0x10
    Gui, 97: add, GroupBox, x3 yp+10 w345 h50, % "General Preferences"

    _codStat := options.selectSingleNode("//CoDet/@status").text
    _codAuto := options.selectSingleNode("//CoDet/@auto").text
    Gui, 97: add, CheckBox, xp+25 yp+20 Checked%_codStat% v_codStat gGuiHandler Disabled
                          , % "Enable Command Detection"
    Gui, 97: add, CheckBox, x+10 Checked%_codAuto% v_codAuto gGuiHandler Disabled, % "Enable Auto Upload"
    Gui, 97: show, x165 y36 w350 h245 NoActivate
    ;}

    ;{ Command Helper
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ;}

    ;{ Live Code
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ;}

    ;{ Screen Tools
    ; Gui, 98: -Caption +LastFound +Owner6 -0x80000000 +0x40000000 +DelimiterSpace ; +Border -WS_POPUP +WS_CHILD
    ; $hwnd98 := WinExist()
    ; Gui, 98: show, x165 y36 w350 h245 NoActivate
    ;}
    
    Gui, 06: add, Text, x165 y+8 w370 0x10                          ; y is 10 - 2px of the Picture control.
    Gui, 06: add, Button, xp+105 yp+10 w75 gGuiHandler, % "&OK"
    Gui, 06: add, Button, x+10 w75 gGuiHandler, % "&Close"
    Gui, 06: add, Button, x+10 w75 HWND$Apply Disabled gGuiHandler, % "&Apply"


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

    licence := "Copyright ©2010-2011 " script.author " <GPLv3>`n`n"
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
    Gui, 08: add, Picture, x0 y0, % "res\img\AHK-TK_About.png"
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
         , $hsList,$hsGbox,$hsText1,$hsExpand,$hsText2,$hsExpandto,$hsCbox1,$hsCbox2,$hsCbox3,$hsCbox4,$hsCbox5
         , $Sci1,$Sci2,$Sci3,$Sci4,$hsDelim,$QShs,$hsAdd,$hsClose,$lcDelim,$QSlc,$lcRun,$lcClear,$hk2Delim
         , $hk2Add,$hk2Cancel,$hs2GBox,$hs2Delim,$hs2Add,$hsCancel
         , $imList,$imDelim,$imAccept,$imClear,$imCancel,$slGBox,$slDelim,$slAdd,$slCancel
         , $shsList, $shkList

    ; AutoHotkey ToolKit Gui
    if (guiNum = 1)
    {
        ; hotkeys tab
        attach($tabcont, "w h")
        attach($hkList, "w h")
        attach($shkList, "w h")
        attach($StatBar, "w r1")
        attach($hkDelim, "y w")
        attach($QShk, "y")
        attach($hkAdd, "x y r2"),attach($hkClose, "x y r2")

        ; hotstrings Tab
        c:="$hsText1|$hsExpand|$hsText2|$hsExpandto|$hsCbox1|$hsCbox2|$hsCbox3|$hsCbox4|$hsCbox5"
        Loop, Parse, c, |
            attach(%a_loopfield%, "x.5 y r1")

        attach($hsList, "w h r2")
        attach($shsList, "w h r2")
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
    if (guiNum = 2)
    {
        attach($Sci2, "w h r2")
        attach($hk2Delim, "y w")
        attach($hk2Add, "x y r2"),attach($hk2Cancel, "x y r2")
    }

    ; Add Hotstring Gui
    if (guiNum = 3)
    {
        attach($Sci3,"w h r2")
        attach($hs2GBox,"w h r2")
        attach($hs2Delim,"y w")
        attach($hs2Add,"x y r2"),attach($hsCancel,"x y r2")
    }

    ; Import Hotkeys/Hotstrings
    if (guiNum = 4)
    {
        attach($imList, "w h r2")
        attach($imDelim, "y w")
        attach($imAccept, "x y r2"),attach($imClear, "x y r2"),attach($imCancel, "x y r2")
    }

    ; Snippet Gui
    if (guiNum = 7)
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

    if (list = "main")
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
        Control,ChooseString,%a_thishotkey%,, ahk_id %$lhwnd%
    return
}
InitSci($hwnd, m0=40, m1=10){
    global conf, script, $Sci1

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    if ($hwnd = $Sci1 && options.selectSingleNode("//@linewrap").text)
        SCI_SetWrapMode("SC_WRAP_WORD", $hwnd)
    else if ($hwnd != $Sci1)
        SCI_SetWrapMode("SC_WRAP_WORD", $hwnd)

    SCI_SetMarginWidthN(0,m0, $hwnd),SCI_SetMarginWidthN(1,m1, $hwnd)

    SCI_StyleSetfont("STYLE_DEFAULT", "Courier New", $hwnd)
    SCI_StyleSetSize("STYLE_DEFAULT", 10, $hwnd)
    SCI_StyleClearAll($hwnd)
}
Add(type){
    global
    ; stupid ahk fails if i dont reload the freaking xml file in here again... tired of searching for the reason.
    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild

    if (type = "hotkey")
    {
        Gui, 01: Default
        Gui, 01: ListView, hkList
        node := root.selectSingleNode("//Hotkeys")
        hkey := RegexReplace(hkey, "\'", "&apos;")
        if (editingHK)
        {
            editingHK := False
            Msgbox, 0x124
                  , % "Hotkey already present"
                  , % "The Hotkey you are trying to create already exist.`n"
                    . "Do you want to edit the existing hotkey?"
                    
            IfMsgbox No
                return
            else
            {
                SCI_GetText(SCI_GetLength($Sci2)+1,_hkscript)
                currNode := node.selectSingleNode("//hk[@key='" RegexReplace(oldkey, "\'", "&apos;") "']")
                currNode.attributes.getNamedItem("key").value := hkey
                currNode.attributes.getNamedItem("type").value := hkType
                currNode.selectSingleNode("name").text := hkName
                currNode.selectSingleNode("path").text := hkType != "Script" ? hkPath : ""
                currNode.selectSingleNode("script").text := _hkscript
                currNode.selectSingleNode("ifwinactive").text := inStr(hkIfWin, "e.g.") ? "" : hkIfWin
                currNode.selectSingleNode("ifwinnotactive").text := inStr(hkIfWinN, "e.g.") ? "" : hkIfWinN
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=null
            Load("Hotkeys")
            return
        }
        else
        {
            Hotkey, % RegexReplace(hkey, "&apos;", "'"), HotkeyHandler, On
            SCI_GetText(SCI_GetLength($Sci2)+1,_hkscript)
            node.attributes.item[0].text() += 1
                _c := conf.createElement("hk")
                _c.setAttribute("type", hkType), _c.setAttribute("key", hkey)
                    _cc1 := conf.createElement("name"), _cc1.text := hkName
                    _cc2 := conf.createElement("path"), _cc2.text := hkType != "Script" ? hkPath : ""
                    _cc3 := conf.createElement("script"), _cc3.text := _hkscript
                    _cc4 := conf.createElement("ifwinactive"), _cc4.text := inStr(hkIfWin, "e.g.") ? "" : hkIfWin
                    _cc5 := conf.createElement("ifwinnotactive"),_cc5.text:=inStr(hkIfWinN, "e.g.")? "" : hkIfWinN
            Loop 5
                if (_cc%a_index%.text)
                    _c.appendChild(_cc%a_index%)
            node.appendChild(_c)

            LV_Add("", hkType
                     , hkName
                     , hkSwap(RegexReplace(hkey, "&apos;", "'"), "long")
                     , hkType!= "Script" ? hkPath : strLen(_hkscript)>40 ? subStr(_hkscript,1,40) "..." : _hkscript)
            Loop, 4
                LV_ModifyCol(a_index,"AutoHdr")
        }
        conf.transformNodeToObject(xsl, conf), updateSB()
        conf.save(script.conf), conf.load(script.conf) root:=options:=_c:=_cc1:=_cc2:=_cc3:=_cc4:=_cc5:=null
        return
    }

    if (type = "hotstring")
    {
        Gui, 01: Default
        Gui, 01: ListView, hsList
        node := root.selectSingleNode("//Hotstrings")

        if (editingHS)
        {
            editingHS := False
            Msgbox, 0x124
                  , % "Hotstring already present"
                  , % "The hotstring you are trying to create already exist.`n"
                    . "Do you want to edit the existing hotstring?"

            IfMsgbox No
                return
            else
            {
                SCI_GetText(SCI_GetLength($Sci3)+1,hsExpandTo)
                currNode := node.selectSingleNode("//hs[expand='" RegexReplace(oldhs, "\'", "&apos;") "']")
                currNode.attributes.getNamedItem("iscode").value := hs2IsCode
                currNode.attributes.getNamedItem("opts").value := hsOpt
                currNode.selectSingleNode("expand").text := RegexReplace(hsExpand, "\'", "&apos;")
                currNode.selectSingleNode("expandto").text := hsExpandTo
                currNode.selectSingleNode("ifwinactive").text := inStr(hsIfWin, "e.g.") ? "" : hsIfWin
                currNode.selectSingleNode("ifwinnotactive").text := inStr(hsIfWinN, "e.g.") ? "" : hsIfWinN
                FileDelete, % a_temp "\hslauncher.code"
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=_c:=_cc1:=_cc2:=_cc3:=_cc4:=null
            Load("Hotstrings")
            return
        }
        else
        {
            node.attributes.item[0].text() += 1
                _c := conf.createElement("hs"), _c.setAttribute("iscode", hsIsCode), _c.setAttribute("opts", hsOpt)
                    _cc1 := conf.createElement("expand"), _cc1.text() := RegexReplace(hsExpand, "\'", "&apos;")
                    _cc2 := conf.createElement("expandto"), _cc2.text() := hsExpandTo
                    _cc3 := conf.createElement("ifwinactive"), _cc3.text() := inStr(hsIfWin, "e.g.") ? "" : hsIfWin
                    _cc4 := conf.createElement("ifwinnotactive"),_cc4.text():=inStr(hsIfWinN, "e.g.")? "" : hsIfWinN
            Loop 4
                if (_cc%a_index%.text)
                    _c.appendChild(_cc%a_index%)
            node.appendChild(_c)

            if RegexMatch(hsExpandTo, "(\n|\r)")
            {
                if (hsIsCode)
                    _code := "`n:" hsOpt ":" hsExpand "::`n" hsExpandTo "`nreturn`n"
                else
                    _code := "`n:" hsOpt ":" hsExpand "::`n(`n" hsExpandTo "`n)`nreturn`n"                    
            }
            else
            {
                if (hsIsCode)
                    _code := "`n:" hsOpt ":" hsExpand "::`n" hsExpandTo "`nreturn`n"
                else
                    _code := "`n:" hsOpt ":" hsExpand "::" hsExpandTo "`n"
            }
            
            hsExpandTo := RegexReplace(hsExpandTo, "(\n|\r)", " [``n] ")
            
            LV_Add("", hsIsCode ? "Script" : "Text"
                     , hsOpt
                     , hsExpand
                     , strLen(hsExpandto) > 40 ? subStr(hsExpandto,1,40) "..." : hsExpandto)
            
            Loop, 4
                LV_ModifyCol(a_index,"AutoHdr")
        }
        FileAppend, %_code%, % a_temp "\hslauncher.code"
        
        If (a_ahkpath && FileExist(a_temp "\hslauncher.code"))
            Run, % a_ahkpath " " a_temp "\hslauncher.code",,, hslPID
        else
            Run, % "res\ahkl.bak " a_temp "\hslauncher.code",,, hslPID
            
        conf.transformNodeToObject(xsl, conf), updateSB()
        conf.save(script.conf), conf.load(script.conf) root:=options:=_c:=_cc1:=_cc2:=_cc3:=_cc4:=null
        return
    }
}
Load(type){
    global

    if (type = "Hotkeys")
    {
        Gui, 01: ListView, hkList

        LV_Delete()
        GuiControl, -Redraw, hkList

        conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
        node := options.selectSingleNode("//Hotkeys").childNodes
        Loop, % node.length
        {
            _path := node.item[a_index-1].selectSingleNode("path").text
            _script := node.item[a_index-1].selectSingleNode("script").text
            _hk := RegexReplace(node.item[a_index-1].selectSingleNode("@key").text, "&apos;", "'")
            LV_Add("", node.item[a_index-1].selectSingleNode("@type").text
                     , node.item[a_index-1].selectSingleNode("name").text
                     , hkSwap(_hk, "long")
                     , _path ? _path : (strLen(_script) > 40 ? subStr(_script, 1, 40) "..." : _script))
            
            
            Hotkey,  % _hk, HotkeyHandler, On
        }
        LV_ModifyCol(2, "Center"), LV_ModifyCol(3, "Center")
        GuiControl, +Redraw, hkList
        return
    }

    if (type = "Hotstrings")
    {
        if !FileExist(a_temp "\hslauncher.code")
        {
            hsfileopts =
            (Ltrim
                ;+--> ; ---------[Directives]---------
                #NoEnv
                #SingleInstance Force
                #NoTrayIcon
                ; --
                SetBatchLines -1
                SendMode Input
                SetTitleMatchMode, Regex
                SetWorkingDir %A_ScriptDir%
                ;-
                !F11::Suspend`n
            )
            FileAppend, %hsfileopts%, % a_temp "\hslauncher.code"
        }
        
        Gui, 01: ListView, hsList

        LV_Delete()
        GuiControl, -Redraw, hsList

        conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
        node := options.selectSingleNode("//Hotstrings").childNodes
        _code := ""             ; Clean code
        Loop, % node.length
        {
            _opts := node.item[a_index-1].selectSingleNode("@opts").text
            _iscode := node.item[a_index-1].selectSingleNode("@iscode").text
            _expand := RegexReplace(node.item[a_index-1].selectSingleNode("expand").text, "&apos;", "'")
            _expandto := node.item[a_index-1].selectSingleNode("expandto").text
            
            if RegexMatch(_expandto, "(\n|\r)")
            {
                if (_iscode)
                    _code .= "`n:" _opts ":" _expand "::`n" _expandto "`nreturn`n"
                else
                    _code .= "`n:" _opts ":" _expand "::`n(`n" _expandto "`n)`nreturn`n"                    
            }
            else
            {
                if (_iscode)
                    _code .= "`n:" _opts ":" _expand "::`n" _expandto "`nreturn`n"
                else
                    _code .= "`n:" _opts ":" _expand "::" _expandto "`n"
            }
            
            _expandto := RegexReplace(node.item[a_index-1].selectSingleNode("expandto").text, "(\n|\r)", " [``n] ")
            
            LV_Add("", _iscode ? "Script" : "Text"
                     , _opts
                     , _expand
                     , strLen(_expandto) > 40 ? subStr(_expandto, 1, 40) "..." : _expandto)
        }
        FileAppend, %_code%, % a_temp "\hslauncher.code"
        
        If (a_ahkpath && FileExist(a_temp "\hslauncher.code"))
            Run, % a_ahkpath " " a_temp "\hslauncher.code",,, hslPID
        else
            Run, % "res\ahkl.bak " a_temp "\hslauncher.code",,, hslPID
        
        GuiControl, +Redraw, hsList
        return
    }

    if (type = "SnpLib")
    {   
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
        return
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
GuiClose(guiNum){
    global $hwnd1

    Gui, %guiNum%: Hide
    WinActivate, ahk_id %$hwnd1%
    Gui, 01: -Disabled
}
ApplyPref(){
    global      ; It accesses hotkey variables and others.

    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild

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
    if !conf.xml
        MsgBox, 0x10
              , % "Operation Failed"
              , % "There was a problem while saving the settings.`n"
                . "The configuration file could not be reloaded."
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

            if (action = "show")
                ControlFocus,,ahk_id %$Sci1%

            if options.selectSingleNode("//@snplib").text != 0
                Loop, Parse, slControls, |
                    Control,%action%,,,ahk_id %a_loopfield%
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

            conf.transformNodeToObject(xsl, conf)
            conf.save(script.conf), conf.load(script.conf), root:=options:=null             ; Save & Clean

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
            conf.transformNodeToObject(xsl, conf)
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            return
        }

        if (a_guicontrol = "QShk" && tabLast = "Hotkeys")
        {
            if (QShk && QShk != "Quick Search")
            {
                GuiControl, show, shkList
                GuiControl, hide, hkList
                Gui, 01: ListView, shkList
                LV_Delete()     ; Delete contents of shsList to avoid creating double results

                Gui, 01: ListView, hkList
                Loop, % LV_GetCount()
                {
                    Gui, 01: ListView, hkList
                    LV_GetText(_type, a_index, 1), LV_GetText(_name, a_index, 2)
                    LV_GetText(_hkey, a_index, 3), LV_GetText(_path, a_index, 4)
                    if (inStr(_name, QShk) || inStr(_path, QShk))
                    {
                        Gui, 01: ListView, shkList
                        LV_Add("", _type
                                 , _name
                                 , _hkey
                                 , _path)
                        Loop, 4
                            LV_ModifyCol(a_index, "AutoHdr")
                    }
                }
            }
            else
            {
                GuiControl, show, hkList
                GuiControl, hide, shkList
                Gui, 01: ListView, shkList
                LV_Delete()
            }
            return
        }

        if (a_guicontrol = "QShs" && tabLast = "Hotstrings")
        {
            if (QShs && QShs != "Quick Search")
            {
                GuiControl, show, shsList
                GuiControl, hide, hsList
                Gui, 01: ListView, shsList
                LV_Delete()     ; Delete contents of shsList to avoid creating double results

                Gui, 01: ListView, hsList
                Loop, % LV_GetCount()
                {
                    Gui, 01: ListView, hsList
                    LV_GetText(_type, a_index, 1), LV_GetText(_opts, a_index, 2)
                    LV_GetText(_expand, a_index, 3), LV_GetText(_expandto, a_index, 4)
                    if (inStr(_expand, QShs) || inStr(_expandto, QShs))
                    {
                        Gui, 01: ListView, shsList
                        LV_Add("", _type
                                 , _opts
                                 , _expand
                                 , _expandto)
                    }
                }
            }
            else
            {
                GuiControl, show, hsList
                GuiControl, hide, shsList
                Gui, 01: ListView, shsList
                LV_Delete()
            }
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
            if (inStr(hsExpand, "e.g.") || inStr(hsExpandto, "e.g."))
            {
                Gui, 01: +Disabled
                Gui, 03: show
                ControlFocus,,ahk_id %$Sci3%
            }
            else
            {
                hsOpt := (hsAE ? "*" : "") (hsDND ? "B0" : "")
                      .  (hsTIOW ? "?" : "") (hsSR ? "R" : "")
                Add("hotstring")
            }
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

            )
            if !InStr(_code, "^Esc::ExitApp")
                live_script .= "^Esc::ExitApp"
            
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
                /*
                    Bring the window forward with hotkey if it doesnt have focus.
                    Fixed the issue with losing focus when clicking the tray icon
                    preventing the normal hide/show behaviour by clicking the icon by
                    checking the time passed since last hotkey press.
                */
                WinGet, winstat, MinMax, ahk_id %$hwnd1%
                if (!WinActive("ahk_id " $hwnd1) && (winstat != "")
                && (A_TimeSinceThisHotkey < 100 && A_TimeSinceThisHotkey != -1))
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

        if (a_guicontrol = "&Browse...")
        {
            Gui, 02: +OwnDialogs
            
            if (hkType = 2) ; File
                FileSelectFile, _path, 1, %a_programfiles%, % "Please select the file to launch."
                                        , % "(*.exe; *.ahk)"
            else if (hkType = 3) ; Folder
                FileSElectFolder, _path, *%a_programfiles%, 3, % "Please select the file to launch."
            
            StringSplit, _name, _path, \
            
            if (_name0)
            {
                _name := RegexReplace(_name%_name0%, "im)\.[^\/:*?""<>|]{1,3}$")
                StringUpper,_name, _name, T
                GuiControl, 02:, hkPath, % _path
                GuiControl, 02:, hkName, % _name
            }
            else
            {
                GuiControl, 02:, hkName,
                GuiControl, 02:, hkPath, %a_programfiles%
            }
            return
        }
        
        if (a_guicontrol = "&Add")
        {
            if inStr(hkey, "None")
            {
                Msgbox, 0x10
                      , % "Error while trying to create new Hotkey"
                      , % "Please select the key that you want to use as a hotkey."
                return
            }

            hkey := (hkHook ? "`$" : "") (hkSend ? "`~" : "") (hkWild ? "`*" : "") (hkLMod ? "`<" : "")
                 .  (hkRMod ? "`>" : "") (hkctrl ? "`^" : "") (hkalt  ? "`!" : "") (hkshift ? "`+": "")
                 .  (hkwin  ? "`#" : "") hkey (hkfRel ? " UP": "")
            hkType := hkType = 1 ? "Script" : hkType = 2 ? "File" : hkType = 3 ? "Folder" : ""
            
            Add("hotkey")

            Gui, %a_gui%: Submit
            WinActivate, ahk_id %$hwnd1%
            Gui, 01: -Disabled
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            2GuiClose:
            2GuiEscape:
                GuiClose(2)
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

        if (a_guicontrol = "&Add")
        {
            if inStr(hs2Expand, "e.g.")
            {
                Msgbox, 0x10
                      , % "Error while trying to create new Hotstring"
                      , % "Please type in the abbreviation that you want to expand"
                return
            }

            hsExpand:=hs2Expand,SCI_GetText(SCI_GetLength($Sci3)+1,hsExpandTo),hsIsCode:=hs2IsCode
            Add("hotstring")

            Gui, %a_gui%: Submit
            WinActivate, ahk_id %$hwnd1%
            Gui, 01: -Disabled

            return
        }

        if (a_guicontrol = "&Cancel")
        {
            3GuiClose:
            3GuiEscape:
                GuiClose(3)
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
            if (imType = 1)
                FileSelectFolder, im, *%a_mydocuments%, 3, % "Select the folder"
            else if (imType = 2)
            {
                FileSelectFile, im, M3, %a_mydocuments%, % "Select the file"
                Loop, Parse, im, `n, `r
                {
                    if (a_index = 1)
                    {
                        path:=a_loopfield "\", _im:=""
                        continue
                    }
                    _im .= path . a_loopfield "`n"
                }
                im := _im
            }

            if (im)
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
            Add("Import")
            
            Gui, %a_gui%: Submit
            WinActivate, ahk_id %$hwnd1%
            Gui, 01: -Disabled
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
                GuiClose(4)
            return
        }
    }

    ; Export Hotkeys/Hotstrings
    if (a_gui = 05)
    {
        if (a_guicontrol = "&Browse...")
        {
            Gui, 05: +OwnDialogs
            FileSelectFile, exFile
                          , S24
                          , % a_mydocuments "\export_" subStr(a_now,1,8) ".ahk"
                          , % "Save File as...", *.ahk; *.txt
            return
        }

        if (a_guicontrol = "&Export")
        {
            if FileExist(exPath)
            {
                Msgbox, 0x124
                      , % "The file exists"
                      , % "The filename that you selected appears already exist.`n"
                        . "Do you want to append to the existing file?"

                IfMsgbox No
                    return
            }
            
            if (exHK)
            {
                node := root.selectSingleNode("//Hotkeys")
                FileAppend, % "; Hotkeys Exported with AutoHotkey Toolkit v" script.version "`n", %exPath%
                Loop % node.attributes.item[0].text
                {
                    _hk := node.selectSingleNode("//hk[" a_index - 1 "]/@key").text
                    _hk := RegexReplace(_hk, "&apos;", "'")
                    _path := node.selectSingleNode("//hk[" a_index - 1 "]/path").text
                    _script := node.selectSingleNode("//hk[" a_index - 1 "]/script").text
                    _ifWin := node.selectSingleNode("//hk[" a_index - 1 "]/ifwinactive").text "`n"
                    _ifWinN := node.selectSingleNode("//hk[" a_index - 1 "]/ifwinnotactive").text "`n"
                    
                    if (node.selectSingleNode("//hk[" a_index - 1 "]/@type").text = "Script")
                        _code := (_ifWin != "`n" ? "#IfWinActive " _ifWin : "") 
                              .  (_ifWinN != "`n" ? "#IfWinNotActive " _ifWinN : "")
                              .   _hk "::`n" _script "`nreturn`n"
                              .  (_ifWin != "`n" ? "#IfWinActive" : "")
                              .  (_ifWinN != "`n" ? "#IfWinNotActive" : "")
                    else
                        _code := (_ifWin != "`n" ? "#IfWinActive " _ifWin : "") 
                              .  (_ifWinN != "`n" ? "#IfWinNotActive " _ifWinN : "") 
                              .   _hk "::Run, " _path
                              .  (_ifWin != "`n" ? "#IfWinActive" : "")
                              .  (_ifWinN != "`n" ? "#IfWinNotActive" : "")

                    FileAppend, %_code%`n, %exPath%
                }
            }
            
            if (exHS)
            {
                node := root.selectSingleNode("//Hotstrings")
                FileAppend, % "; Hotstrings Exported with AutoHotkey Toolkit v" script.version "`n", %exPath%
                Loop % node.attributes.item[0].text
                {
                    _opts := node.selectSingleNode("//hs[" a_index - 1 "]/@opts").text
                    _expand := node.selectSingleNode("//hs[" a_index - 1 "]/expand").text
                    _expand := RegexReplace(_expand, "&apos;", "'")
                    _expandto := node.selectSingleNode("//hs[" a_index - 1 "]/expandto").text
                    _ifWin := node.selectSingleNode("//hs[" a_index - 1 "]/ifwinactive").text "`n"
                    _ifWinN := node.selectSingleNode("//hs[" a_index - 1 "]/ifwinnotactive").text "`n"
                    
                    if (node.selectSingleNode("//hs[" a_index - 1 "]/@iscode").text)
                        _code := (_ifWin != "`n" ? "#IfWinActive " _ifWin : "") 
                              .  (_ifWinN != "`n" ? "#IfWinNotActive " _ifWinN : "")
                              .   ":" _opts ":" _expand "::`n" _expandto "`nreturn`n"
                              .  (_ifWin != "`n" ? "#IfWinActive" : "")
                              .  (_ifWinN != "`n" ? "#IfWinNotActive" : "")
                    else
                        _code := (_ifWin != "`n" ? "#IfWinActive " _ifWin : "") 
                              .  (_ifWinN != "`n" ? "#IfWinNotActive " _ifWinN : "") 
                              .   ":" _opts ":" _expand "::" _expandto
                              .  (_ifWin != "`n" ? "#IfWinActive" : "")
                              .  (_ifWinN != "`n" ? "#IfWinNotActive" : "")

                    FileAppend, %_code%`n, %exPath%
                }
            }
            
            Gui, %a_gui%: Submit
            WinActivate, ahk_id %$hwnd1%
            Gui, 01: -Disabled
            return
        }
        
        if (a_guicontrol = "&Cancel")
        {
            5GuiClose:
            5GuiEscape:
                GuiClose(5)
            return
        }
    }

    ; Preferences
    if (a_gui = 06 || a_gui > 80)
    {
        Loop, 8
        {
            _gui := a_index + 90
            Gui, %_gui%: submit, NoHide
        }

        if (a_guicontrol = "&OK")
        {
            ApplyPref(), GuiClose(6)
            return
        }

        if (a_guicontrol = "&Close")
        {
            6GuiClose:
            6GuiEscape:
                GuiClose(6) ; , GuiReset()
            return
        }

        if (a_guicontrol = "&Apply")
        {
            Control,disable,,,ahk_id %$Apply%
            ApplyPref()
            return
        }

        ; Any other control would enable the Apply button.
        Control,enable,,,ahk_id %$Apply%
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

            node:=_p:=_pc:=_cd:=_editNode:=null                     ; Clean
            conf.transformNodeToObject(xsl, conf)
            conf.save(script.conf), conf.load(script.conf)          ; Save and Load
            return
        }

        if (a_guicontrol = "&Cancel")
        {
            7GuiClose:
            7GuiEscape:
                GuiClose(7)
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
                GuiClose(8)
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
        ; Menu, MainMenu, %stat%, Edit
        ; Menu, MainMenu, %stat%, Search

        Menu, View, %stat%, Snippet Library
        ; Menu, View, %stat%, Show Symbols
        ; Menu, View, %stat%, Zoom
        Menu, View, %stat%, Line Wrap

        Menu, Settings, %stat%, Run Code With
        ; Menu, Settings, %stat%, Enable Command Helper
        ; Menu, Settings, %stat%, Context Menu Options

        ; Menu, File, %stat%, &Open`tCtrl+O
        ; Menu, File, %stat%, &Save`tCtrl+S
        ; Menu, File, %stat%, Save As`tCtrl+Shift+S
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
    if (a_thismenuitem = "&New`tCtrl+N")
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

    if (a_thismenuitem = "Delete`tDEL")
    {
        if (tabLast = "Live Code")
        {
            ListHandler("Delete")
            return
        }
        else if (tabLast = "Hotkeys")
        {
            node := root.selectSingleNode("//Hotkeys")
            Loop, % LV_GetCount("Selected")
            {
                if !next := LV_GetNext()
                    break
                LV_GetText(_hkey, next, 3), LV_Delete(next)
                
                if node.attributes.item[0].text() <= 0
                    node.attributes.item[0].text() := 0
                else
                    node.attributes.item[0].text() -= 1
                node.removeChild(node.selectSingleNode("//hk[@key='" hkSwap(_hkey, "short") "']"))
                Hotkey, % hkSwap(_hkey, "short"), OFF
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=node:=null         ; Save & Clean
            return
        }
        else if (tabLast = "Hotstrings")
        {
            FileDelete, % a_temp "\hslauncher.code"
            node := root.selectSingleNode("//Hotstrings")
            Loop, % LV_GetCount("Selected")
            {
                if !next := LV_GetNext()
                    break
                LV_GetText(_expand, next, 3), LV_Delete(next)
                
                if node.attributes.item[0].text() <= 0
                    node.attributes.item[0].text() := 0
                else
                    node.attributes.item[0].text() -= 1
                node.removeChild(node.selectSingleNode("//hs[expand='" _expand "']"))
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=node:=null         ; Save & Clean
            Load("Hotstrings")
            return
        }
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
        conf.transformNodeToObject(xsl, conf)
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
        conf.transformNodeToObject(xsl, conf)
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "Line Wrap")
    {
        Menu, View, ToggleCheck, %a_thismenuitem%
        SCI_SetWrapMode(tog_lw := !tog_lw, $Sci1)
        options.selectSingleNode("//@linewrap").text := tog_lw
        conf.transformNodeToObject(xsl, conf)
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "Enable Command Helper")
    {
        Menu, Settings, ToggleCheck, %a_thismenuitem%
        ; cmdHelper(tog_ech := !tog_ech)
        options.selectSingleNode("//@sci").text := !tog_ech
        conf.transformNodeToObject(xsl, conf)
        conf.save(script.conf), conf.load(script.conf)          ; Save and Load
        return
    }

    if (a_thismenuitem = "L-Ansi" || a_thismenuitem = "L-Unicode"
    ||  a_thismenuitem = "Basic"  || a_thismenuitem = "IronAHK")
    {
        rcwSet(a_thismenuitem)
        return
    }

    if (a_thismenuitem = "&Preferences`tCtrl+P")
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
    ; tooltip % a_guicontrol " " a_guievent

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
        conf.transformNodeToObject(xsl, conf)
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

    if (a_guicontrol = "hkList" || a_guicontrol = "shkList")
    {
        if (a_guievent = "DoubleClick")
        {
            if !_selrow
            {
                LV_Modify(0,"-Select"),LV_Modify(0,"-Focus")
                Gui, 01: +Disabled
                Gui, 02: show
                return
            }
            editingHK := True
            LV_GetText(_hk, _selrow, 3)
            oldkey := _hkey := hkSwap(_hk, "short")
            node := root.selectSingleNode("//Hotkeys/hk[@key='" RegexReplace(_hkey, "\'", "&apos;") "']")

            _hkType := node.attributes.getNamedItem("type").value
            _hkName := node.selectSingleNode("name").text
            _hkPath := node.selectSingleNode("path").text
            _hkIfWin := node.selectSingleNode("ifwinactive").text
            _hkIfWinN := node.selectSingleNode("ifwinnotactive").text
            _script := node.selectSingleNode("script").text
            
            _guivars := "hkName|hkPath|hkIfWin|hkIfWinN"

            Loop, Parse, _guivars, |
                GuiControl, 2:, % a_loopfield, % _%a_loopfield%
            
            GuiControl, 2:, % _hkType, 1
            if (_hkType = "Script")
            {
                Control, disable,,,ahk_id %$hk2Path%
                Control, disable,,,ahk_id %$hk2Browse%
                SCI_StyleResetDefault($Sci2), SCI_SetReadOnly(false), initSci($Sci2)
            }
            else if (_hkType = "File" || _hkType = "Folder")
            {
                Control, enable,,,ahk_id %$hk2Path%
                Control, enable,,,ahk_id %$hk2Browse%
                SCI_ClearAll($Sci2),SCI_SetReadOnly(true),SCI_StyleSetBack("STYLE_DEFAULT", 0xe0dfe3)
                SCI_SetMarginWidthN(0,0),SCI_SetMarginWidthN(1,0)
            }
            
            if (_script)
               SCI_SetText(_script, $Sci2)
            
            _guivars := "hkctrl ^|hkalt !|hkshift +|hkwin #|hkLMod <|hkRMod >|hkWild *|hkSend ~|hkHook $|hkfRel UP"
            
            Loop, Parse, _guivars, |
            {
                StringSplit, _key, a_loopfield, %a_space%
                GuiControl, 2:, % _key1, % inStr(_hkey, _key2) ? "1" : "0"
            }
            RegexMatch(_hkey, "im)[^\^!+#<>*~$ ]+", _hkey)
            GuiControl, 2: ChooseString, hkey, % _hkey
            Gui, 02: show
        }

        if (a_guievent = "K" && a_eventinfo = 46)
        {
            node := root.selectSingleNode("//Hotkeys")
            Loop, % LV_GetCount("Selected")
            {
                if !next := LV_GetNext()
                    break
                LV_GetText(_hkey, next, 3), LV_Delete(next)
                
                if node.attributes.item[0].text() <= 0
                    node.attributes.item[0].text() := 0
                else
                    node.attributes.item[0].text() -= 1
                node.removeChild(node.selectSingleNode("//hk[@key='" hkSwap(RegexReplace(_hkey, "\'", "&apos;")
                                                                                        , "short") "']"))
                Hotkey, % hkSwap(_hkey, "short"), OFF
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=node:=null         ; Save & Clean
            return
        }

    }

    if (a_guicontrol = "hsList" || a_guicontrol = "shsList")
    {
        if (a_guievent = "DoubleClick")
        {
            if !_selrow
            {
                LV_Modify(0,"-Select"),LV_Modify(0,"-Focus")
                Gui, 01: +Disabled
                Gui, 03: show
                ControlFocus,,ahk_id %$Sci3%
                return
            }
            editingHS := True
            LV_GetText(_expand, _selrow, 3), oldhs := _expand
            node := root.selectSingleNode("//Hotstrings/hs[expand='" RegexReplace(_expand, "\'", "&apos;") "']")

            _hs2IsCode := node.attributes.getNamedItem("iscode").value
            _hsOpt := node.attributes.getNamedItem("opts").value
            _hs2Expand := RegexReplace(node.selectSingleNode("expand").text, "&apos;", "'")
            _hs2Expandto := node.selectSingleNode("expandto").text
            _hsIfWin := node.selectSingleNode("ifwinactive").text
            _hsIfWinN := node.selectSingleNode("ifwinnotactive").text
            _guivars := "hs2IsCode|hsOpt|hs2Expand|hsIfWin|hsIfWinN"

            Loop, Parse, _guivars, |
                GuiControl, 3:, % a_loopfield, % _%a_loopfield%

            if _hs2IsCode
                initSci($Sci3)
            else
                initSci($Sci3,0,0)

            SCI_SetText(_hs2Expandto, $Sci3)
            Gui, 03: show
        }

        if (a_guievent = "K" && a_eventinfo = 46)
        {
            FileDelete, % a_temp "\hslauncher.code"
            node := root.selectSingleNode("//Hotstrings")
            Loop, % LV_GetCount("Selected")
            {
                if !next := LV_GetNext()
                    break
                LV_GetText(_expand, next, 3), LV_Delete(next)
                
                if node.attributes.item[0].text() <= 0
                    node.attributes.item[0].text() := 0
                else
                    node.attributes.item[0].text() -= 1
                node.removeChild(node.selectSingleNode("//hs[expand='" RegexReplace(_expand, "\'", "&apos;") "']"))
            }
            conf.transformNodeToObject(xsl, conf), updateSB()
            conf.save(script.conf), conf.load(script.conf) root:=options:=node:=null         ; Save & Clean
            Load("Hotstrings")
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
                conf.transformNodeToObject(xsl, conf)
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
HotkeyHandler(hk){
    global script, conf
    
    conf.load(script.conf), root:=conf.documentElement, options:=root.firstChild
    
    node := root.selectSingleNode("//Hotkeys")
    
    hk := RegexReplace(hk, "\'", "&apos;")
    _path := node.selectSingleNode("//hk[@key='" hk "']/path").text
    _type := node.selectSingleNode("//hk[@key='" hk "']/@type").text
    _script := node.selectSingleNode("//hk[@key='" hk "']/script").text
    
    if (_type = "Script")
    {
        lcfPath := a_temp . "\" . rName(5, "code")        ; Random Live Code Path

        if !InStr(_script,"Gui")
            _script .= "`n`nExitApp"
        else if !InStr(_script,"GuiClose")
        {
            if !InStr(_script,"return")
                _script .= "`nreturn"
            _script .= "`n`nGuiClose:`nExitApp"
        }

        live_script =
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

            %_script%

        )
        
        if !InStr(_script, "^Esc::ExitApp")
            live_script .= "^Esc::ExitApp"
            
        FileAppend, %live_script%, %lcfPath%

        rcw := options.selectSingleNode("//RCPaths/@current").text
        ahkpath := options.selectSingleNode("//RCPaths/" rcw).text
        if !ahkpath
        {
            if !FileExist(ahkpath := a_temp "\ahkl.bak")
                FileInstall, res\ahkl.bak, %ahkpath%
        }

        Run, %ahkpath% %lcfPath%
        return
    }
    else
        Run, % _path
    return
}
MsgHandler(wParam,lParam, msg, hwnd){
    static
    hCurs:=DllCall("LoadCursor","UInt",0,"Int",32649,"UInt") ;IDC_HAND
    global cList1,hList1,cList2,hList2,cList3,hList3,$QShk,$QShs,$QSlc,$Sci1,$Sci2,$Sci3
         , $hsOpt,$hsExpand,$hs2Expand,$hsExpandto,$hkIfWin,$hkIfWinN,$hsIfWin,$hsIfWinN
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

        if (wParam>>16 = 0x0100)    ; EN_SETFOCUS
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

            if (inStr(sText, "e.g. ") || inStr(sText, "Quick Search"))
                ControlSetText,,, ahk_id %lParam%

            return
        }

        if (wParam>>16 = 0x0200)    ; EN_KILLFOCUS
        {
            if (lParam = $GP_E1)
            {
                SetHotkeys()                    ; Re-Enable hotkeys
                return
            }

            ControlGetText,cText,, ahk_id %lParam%

            if (!cText && (inStr(sText, "e.g. ") || inStr(sText, "Quick Search")))
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

                if (lParam = $QShk || lParam = $QShs)
                    ControlSetText,, % "Quick Search", ahk_id %lParam%

                if (lParam = $hsOpt)
                    ControlSetText,, % "e.g. rc*", ahk_id %lParam%

                if (lParam = $hsExpand || lParam = $hs2Expand)
                    ControlSetText,, % "e.g. btw", ahk_id %lParam%

                if (lParam = $hsExpandto)
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
hotExtract(file, path){
    global imHK, imHS

    Gui, 04: Default
    Gui, 04: ListView, imList
    
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
                      , ((_mlHKOPT || _mlHSOPT) ? RegexReplace(_mlHKOPT _mlHSOPT, "^\s+") : "")
                      . ((_mlHK || _mlHS) ? RegexReplace(_mlHK _mlHS, "^\s+") : "")
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
            ; this process keep old hotkey/hotstring information so i can parse multiline items correctly
            multiline:=True,_mlHK:=mlHK ? mlHK : _mlHK,_mlHS:=mlHS ? mlHS : _mlHS
           ,_mlHKOPT:=mlHKOPT ? mlHKOPT : _mlHKOPT,_mlHSOPT:=mlHSOPT ? mlHSOPT : _mlHSOPT
           continue
        }

        if RegexMatch(a_loopfield, #sLine, sl)
        {
            msgbox % slhk " " RegexReplace(slHK slHS, "^\s+")
            LV_Add(""
                  , slHK ? "Hotkey" : "Hotstring"
                  , ((slHKOPT || slHSOPT) ? RegexReplace(slHKOPT slHSOPT, "^\s+") : "")
                  . ((slHK || slHS) ? RegexReplace(slHK slHS, "^\s+") : "")
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
    global conf, script, xsl
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
            conf.transformNodeToObject(xsl, conf)
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
    
    ; Temporal Code
    if (pref != $P1 && pref != $P1C1)
        GuiControl, 06: show, AHKTK_UC
    else
        GuiControl, 06: hide, AHKTK_UC
}
defConf(path){
    global script

    s_version := script.version, hlpPath := subStr(a_ahkpath, 1,-14) "AutoHotkey.chm"
    a_isunicode ? (unicode := a_ahkpath, current := "L-Unicode") : (ansi := a_ahkpath, current := "L-Ansi")
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
				<Group name="Example Snippets" count="4">
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
 * Dont limit yourself to the defaults!                                             *
 *                                                                                  *
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
/*
 ************************************************************************************
 * This Script is just a quick way to determine which version of Autohotkey         *
 * is being used by the Live Code feature.                                          *
 *                                                                                  *
 * It is meant as a way of checking that you set up the correct path to a different *
 * version of Autohotkey and that the program is accessing that path correctly      *
 ************************************************************************************
 */

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
updateSB(){
    global script, root, $hwnd1

    WinGetPos,,, _w,, ahk_id %$hwnd1%
    SB_SetParts(150,150,_w - 378,50) ; including 8 pixes for the borders.
    SB_SetText("`t" root.selectSingleNode("//Hotkeys/@count").text " Hotkeys currently active",1)
    SB_SetText("`t" root.selectSingleNode("//Hotstrings/@count").text " Hotstrings currently active",2)
    SB_SetText("`tv" script.version,4)
    return
}

; Storage
WM(var){
    static

    MOUSEMOVE:=0x200,COMMAND:=0x111
    EDITLABEL:=a_isunicode ? 4214 : 4119
    return lvar:=%var%
}
;}

;[Classes]{
;}

;[Hotkeys/Hotstrings]{
^CtrlBreak::Reload
;}
