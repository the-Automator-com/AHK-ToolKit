/*
Author:         RaptorX	<graptorx@gmail.com>		
Script Name:    AHK-ToolKit
Script Version: 0.1.3
Homepage:       

Creation Date: July 11, 2010 | Modification Date: July 18, 2010

[GUI Number Index]

GUI 01 - Main []
GUI 99 - PasteBin Popup
GUI 98 - Send to PasteBin
*/

;+--> ; ---------[Includes]---------
#Include *i C:\Documents and Settings\RaptorX\My Documents\AutoHotkey ; Current Library
#include lib/httpquery.ahk
;-

;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
SetBatchLines -1
; --
SendMode Input
SetWorkingDir %A_ScriptDir%
;-

;+--> ; ---------[Basic Info]---------
s_name      := "AHK-ToolKit"            ; Script Name
s_version   := "0.1.3"                  ; Script Version
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
s_xml       := ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
Clipboard :=
FileRead, ahk_keywords, res/key.lst     ; Used for the PasteBin routines
;-

;+--> ; ---------[Main]---------
; PasteBin Popup GUI
Gui, 99: -Caption +Border +AlwaysOnTop +ToolWindow
Gui, 99: Font, s10 w600, Verdana
Gui, 99: add, Text, w250 x0 Center,AHK Code Detected
Gui, 99: add, Text, w260 x0 0x10
Gui, 99: Font, s8 normal
Gui, 99: add, Text, w250 x5 yp+5, % "You have copied text that contains some AutoHotkey Keywords. `n`nDo you want to upload it to a pastebin service?"
Gui, 99: add, Text, w260 x0 0x10
Gui, 99: add, Button, w60 h25 x10 yp+10, Yes
Gui, 99: add, Button, w60 h25 x+10, No
Gui, 99: add, CheckBox, x+10 yp+6 Checked gDisablePopup vpastepop_ena, % "Enable Popup"
Gui, 99: Show, NoActivate w250 h150 x%monRight% y%monBottom%
WinGet, 99Hwnd, ID,,AHK Code Detected
Gui, 99: Show, Hide

; Send To PasteBin GUI
Gui, 98: Font, s8, Courier New
Gui, 98: add, Edit, w620 h400 vahk_code,
Gui, 98: Font
Gui, 98: add, Text, w650 x0 0x10
Gui, 98: add, GroupBox, w620 h80 x10 yp+5, Options
Gui, 98: add, Text, xp+10 yp+20, % "Upload  to:"
Gui, 98: add, Text, x+83, % "Description / Post Title:"
Gui, 98: add, Text, x+25, % "Nick / Subdomain:"
Gui, 98: add, Text, x+45, % "Privacy:"
Gui, 98: add, Text, x+42, % "Expiration:"
Gui, 98: add, DropDownList, w125 x20 y+10 gDDL_Pastebin vddl_pastebin, AutoHotkey.net||Pastebin.com|Paste2.org
Gui, 98: add, Edit, w125 x+10 vpb_name
Gui, 98: add, Edit, w125 x+10 vpb_subdomain
Gui, 98: add, DropDownList, w70 x+10 vpb_exposure Disabled, Public||Private
Gui, 98: add, DropDownList, w115 x+10 vpb_expiration Disabled, Never|10 Minutes||1 Hour|1 Day|1 Month
Gui, 98: add, Text, w650 x0 0x10
Gui, 98: add, Button, w100 h25 x300 yp+10, % "Upload"
Gui, 98: add, Button, w100 h25 x405 yp, % "Save to File"
Gui, 98: add, Button, w100 h25 x530 yp, % "Cancel"
Gui, 98: Show, Hide
;-

;+--> ; ---------[Labels]---------
OnClipboardChange:
 kword_count:=
 StringReplace, clipboard, clipboard, &, `%26, 1    ; This prevents issues when using httpquery since &
                                                    ; has a special meaning in an url... this converts it to 
                                                    ; hex value which will be converted back to & by httpquery.
 Loop, Parse, ahk_keywords, `n, `r
 {
    if clipboard contains %a_loopfield%
        kword_count++
 }
 if kword_count >= 3
 {
    kword_count := 
    Goto, Pastebin
 }
return

PasteBin:
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
 sleep, 3 * sec
 Gui, 99: Hide
 }
return

99ButtonYes:                                                        ; Popup YES
 Gui, Hide                                                          ; Hide Popup
 GuiControl, 98:, ahk_code, %clipboard%
 Gui, 98: Show, w640 h550, Send To Pastebin
 Gui, 98: Submit, NoHide
return 

99ButtonNo:                                                         ; Popup No
 Gui, Hide
return

98ButtonUpload:
 Gui, 98: Submit
 if ddl_pastebin = Autohotkey.net
 {
    if pb_subdomain
        irc_stat = 1
    else
        irc_stat = 0
        
    URL  := "http://www.autohotkey.net/paste/"
    POST := "text=" . ahk_code
        . "&irc=" . irc_stat
        . "&ircnick=" . pb_subdomain
        . "&ircdescr=" . pb_name
        . "&submit=submit"
    
    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    uid := RegexMatch(paste_url, "Paste\s(#(.*)<)", Match)
    uid := RegexMatch(Match2, "^\w+", Match)
    paste_url := "http://www.autohotkey.net/paste/" . Match
    pasted()
 } 
 else if ddl_pastebin = Pastebin.com 
 {
    Gui, 98: Submit
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
    POST := "paste_code=" . ahk_code
        . "&paste_name=" . pb_name
        . "&paste_subdomain=" . pb_subdomain
        . "&paste_exposure=" . pb_exposure
        . "&paste_expire_date=" . pb_expiration


    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    pasted()
 }
 else if ddl_pastebin = Paste2.org
 {
    URL  := "http://paste2.org/new-paste"
    POST := "lang=text"
        . "&description=" . pb_name
        . "&code=" . ahk_code
        . "&parent=0"
    
    httpquery(paste_url := "", URL, POST)
    VarSetCapacity(paste_url, -1)
    
    RegexMatch(paste_url, "Paste\s(\b\d+)", Match)
    paste_url := "http://paste2.org/p/" . Match1
    pasted()
 }
return

98ButtonSavetoFile:
 Gui, 98: +OwnDialogs
 FileSelectFile, f_saved, S24, %a_desktop%, Save script as..., AutoHotkey (*.ahk)
 if !f_saved
    return
 ;***
 ; The following piece of code fixes the issue with saving a file without adding the extension while the file
 ; existed as "file.ahk", which caused the file to be saved as "file.ahk.ahk" and added a msgbox if the user
 ; is overwriting an existing file
 ;*
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

98ButtonCancel:                                                     ; Send to Pastebin Cancel
 Gui, Hide
return

DisablePopup:
Msgbox, % "You have chosen to disable the Pastebin Alert, to enable it again go to the program settings"
; Write to xml file here
return

DDL_Pastebin:
 Gui, 98: Submit, NoHide
 if ddl_pastebin = AutoHotkey.net 
    ena_control(1,1,0,0)
 else if ddl_pastebin = Pastebin.com 
    ena_control(1,1,1,1)
 else if ddl_pastebin = Paste2.org
    ena_control(1,0,0,0)
return
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
    global paste_url
    global ahk_code
    clipboard := paste_url
    Loop, parse, ahk_code, `n, `r
    {
        if a_index = 20
            break
        code_preview := code_preview . "`n" . a_loopfield
    }
    FileAppend, 
    (
;--> %paste_url% :
----------------------------------------------------------------------
%code_preview%
----------------------------------------------------------------------`n`n
    ), pastebin-log.dat ; TODO change location to folder
}
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
!Esc::ExitApp
Pause::Reload
F3::Pause
;+> ; [Ctrl + F5] Send Current Date
^F5::Send, % a_mmmm " "a_dd ", " a_yyyy
;-
;+> ;[Ctrl + Shift + A/Z] BW ally
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
 Goto, ^+a
return 
#IfWinActive
;-
;- 

/*
 *==================================================================================
 *                          		END OF FILE
 *==================================================================================
 */
