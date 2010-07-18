/*
Author:         RaptorX	<graptorx@gmail.com>		
Script Name:    AHK-ToolKit
Script Version: 0.1.1

Creation Date: July 11, 2010 | Modification Date: July 18, 2010

[GUI Number Index]

GUI 01 - Main []
GUI 99 - PasteBin Popup
GUI 98 - Send to PasteBin
*/

;+--> ; ---------[Includes]---------
#Include *i C:\Documents and Settings\RaptorX\My Documents\AutoHotkey ; Current Library
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
s_version   := "0.1.1"                  ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
;-

;+--> ; ---------[General Variables]---------
sec         :=  1000                    ; 1 second
min         :=  sec * 60	            ; 1 minute
hour        :=  min * 60	            ; 1 hour
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
Gui, 99: add, Text, w250 x5 yp+5, % "You have copied text that contains some AutoHotkey Keywords. `n`nDo you want to upload them to a pastebin service?"
Gui, 99: add, Text, w260 x0 0x10
Gui, 99: add, Button, w60 h25 x10 yp+10, Yes
Gui, 99: add, Button, w60 h25 x+10, No
Gui, 99: add, CheckBox, x+10 yp+6 Checked gDisablePopup vpastepop_ena, % "Enable Popup"
Gui, 99: Show, NoActivate w250 h150 x%monRight% y%monBottom%
WinGet, 99Hwnd, ID,,AHK Code Detected
Gui, 99: Show, Hide

; Send To PasteBin GUI
Gui, 98: Font, s8, Courier New
Gui, 98: add, Edit, w400 h400 vahk_code,
Gui, 98: Font
Gui, 98: add, Text, w430 x0 0x10
Gui, 98: add, GroupBox, w400 h120 x10 yp+5, Options
Gui, 98: add, Text, xp+10 yp+20, % "Upload  to:`t`t`tPost Expiration`t`t`tPublic:"
Gui, 98: add, DropDownList, gDDL_Pastebin vddl_pastebin, AutoHotkey.net||Pastebin.com
Gui, 98: add, DropDownList, w125 x180 y455 vpb_expiration Disabled, Never|10 Minutes||1 Hour|1 Day|1 Month
Gui, 98: add, DropDownList, w50 x340 y455 vpb_privacy Disabled, Yes||No
Gui, 98: add, Text, x20 yp+30, % "Subdomain:`t`t`tPost Name / Title:"
Gui, 98: add, Edit, w125 x20 yp+20 vpb_subdomain Disabled
Gui, 98: add, Edit, w210 x+35 vpb_name Disabled
Gui, 98: add, Text, w430 x0 0x10
Gui, 98: add, Button, w100 h25 x10, % "Upload"
Gui, 98: add, Button, w100 h25 x+20, % "Save to File"
Gui, 98: add, Button, w100 h25 x+80, % "Cancel"
Gui, 98: Show, Hide
;-

;+--> ; ---------[Labels]---------
OnClipboardChange:
kword_count:=
 Loop, Parse, ahk_keywords, `n, `r
 {
    if clipboard contains %a_loopfield%
        kword_count++
 }
 if kword_count > 3
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
 }
return

99ButtonYes:
 Gui, Hide                                      ; Hide Popup
 GuiControl, 98:, ahk_code, %clipboard%
 Gui, 98: Show, w420 h600, Send To Pastebin
return 

99ButtonNo:
 Gui, Hide
return

98ButtonCancel:
 Gui, Hide
return

DisablePopup:
Msgbox, % "You have chosen to disable the Pastebin Alert, to enable it again go to the program options"
; Write to xml file here
return

DDL_Pastebin:
return
;-

;+--> ; ---------[Functions]---------
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
