/*
Author:         RaptorX	<graptorx@gmail.com>		
Script Name:    AHK-ToolKit
Script Version: 0.1

Creation Date: July 11, 2010 | Modification Date:

[GUI Number Index]

GUI 01 - Main []
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
s_name      := "AHK-ToolKit"        ; Script Name
s_version   := "0.1"                ; Script Version
s_author    := "RaptorX"            ; Script Author
s_email     := "graptorx@gmail.com" ; Author's contact email
;-

;+--> ; ---------[General Variables]---------
sec         :=  1000 	    ; 1 second
min         :=  sec * 60	; 1 minute
hour        :=  min * 60	; 1 hour
; --
mid_scrw    :=  a_screenwidth / 2
mid_scrh    :=  a_screenheight / 2
; --
s_ini       := ; Optional ini file
s_xml       := ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
;-

;+--> ; ---------[Main]---------
; First Run Configuration
; The GUI will be destroyed so it can be used later on.

;-

;+--> ; ---------[Labels]---------
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
