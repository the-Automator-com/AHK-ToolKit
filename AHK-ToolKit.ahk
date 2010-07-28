/*
Author:         RaptorX	<graptorx@gmail.com>		
Script Name:    AHK-ToolKit
Script Version: 0.1.6
Homepage:       

Creation Date: July 11, 2010 | Modification Date: July 28, 2010

[GUI Number Index]

GUI 01 - Main [AHK-ToolKit]
GUI 99 - PasteBin Popup
GUI 98 - Send to PasteBin
GUI 97 - Pastebin Success Popup
GUI 96 - Add Hotkey
GUI 50 - First Run / Splash
*/

;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
SetBatchLines -1
; --
SendMode Input
SetWorkingDir %A_ScriptDir%
;-

;+--> ; ---------[Basic Info]---------
s_name      := "AutoHotkey ToolKit"            ; Script Name
s_version   := "0.1.6"                  ; Script Version
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
s_xml       := "ahk_tk.xml"             ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
Clipboard :=
FileRead, ahk_keywords, res\key.lst     ; Used for the PasteBin routines
reg_run := "Software\Microsoft\Windows\CurrentVersion\Run"
exc := "ScrollLock|CapsLock|NumLock|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft"
. "|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel|LWin|RWin|LControl"
. "|RControl|LShift|RShift|LAlt|RAlt|CtrlBreak"
keylist := "None||" . klist(1,0,1, exc)
xpath_load := xpath_load(xml, "res\" . s_xml)

; First Run GUI
if !xpath_load
{
    Gui, 50: add, Text,x10, % "This is the first time that you run AHK-Toolkit.`n"
                            . "Please Take a few seconds to setup some initial options.`n"
    Gui, 50: Font, cBlue
    Gui, 50: add, Text,x10, % "Startup Options"
    Gui, 50: add, Text, w265 x+10 yp+7 0x10
    Gui, 50: Font
    Gui, 50: add, CheckBox, x10 Checked vsww, % "Start with Windows"
    Gui, 50: add, CheckBox, x10 Checked vssg, % "Show Splash Gui"
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
    Gui, 50: add, Text,x10, % "If no hotkey is selected the default `nwill be Win + ``  (accent)"
    Gui, 50: add, Text, w370 x0 y+20 0x10
    Gui, 50: add, Button, w100 x260 yp+10 gFR_Save, Save
    Gui, 50: Show, w365, % "First Run"
    Pause
}
;-

;+--> ; ---------[Main]---------
Gosub, XMLREAD

; Hotkey Maker GUI[Main]
;{
Gui, add, Tab2, w620 h340 x0 y0, % "Hotkeys|Hotstrings|Live Code|Options"
Gui, add, StatusBar,, % "Add new hotkeys / hotstrings"
Gui, add, ListView,w600 r15 Sort Grid AltSubmit vlv_hklist, % "Type|Program Name|Hotkey|Program Path"
Gui, add, Text, w630 x0 y+10 0x10
Gui, add, Button, w100 h25 x400 yp+10, % "Add"
Gui, add, Button, w100 h25 x510 yp, % "Cancel"
Gui, Show, Hide ;w619 h341
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
Gui, 99: add, Button, w60 h25 x10 yp+10, % "Yes"
Gui, 99: add, Button, w60 h25 x+10, % "No"
Gui, 99: add, CheckBox, x+10 yp+6 Checked%pastepop_ena% gDisablePopup vpastepop_ena, % "Enable Popup"
Gui, 99: Show, NoActivate w250 h150 x%monRight% y%monBottom%
WinGet, 99Hwnd, ID,, % "AHK Code Detected"
Gui, 99: Show, Hide ; w250 h150
;}

; Send To PasteBin GUI
;{
Gui, 98: Font, s8, Courier New
Gui, 98: add, Edit, w620 h400 vahk_code
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
Gui, 98: add, Button, w100 h25 x300 yp+10, % "Upload"
Gui, 98: add, Button, w100 h25 x405 yp, % "Save to File"
Gui, 98: add, Button, w100 h25 x530 yp, % "Cancel"
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
Gui, 96: add, Edit, w270 xp+10 yp+20, %a_programfiles%
Gui, 96: add, Button, w100 x+10, % "Browse..."
Gui, 96: add, Radio, x110 y+5 vr_selprog, % "Select a File"
Gui, 96: add, Radio,x+10, % "Select a Folder"
Gui, 96: add, GroupBox, w400 h70 x10, % "Select Hotkey"
Gui, 96: add, DropDownList, w200 xp+10 yp+30 vddl_key  ; % add klist
Gui, 96: add, CheckBox, x+10 yp+3, % "Ctrl"
Gui, 96: add, CheckBox, x+10, % "Alt"
Gui, 96: add, CheckBox, x+10, % "Shift"
Gui, 96: add, CheckBox, x+10, % "Win"
Gui, 96: add, Text, w425 x0 y+35 0x10
Gui, 96: add, Button, w100 h25 x200 yp+10, % "Add"
Gui, 96: add, Button, w100 h25 x+10 yp, % "Cancel"
Gui, 96: Show, Hide ; w420 h210
;}

if ssg
    Gosub, SplashGui
Return ; End of autoexecute area
;-

;+--> ; ---------[Labels]---------
FR_Save:
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
    
 xpath(xml, "/root[+1]/@FirstRun/text()", "1")
 xpath(xml, "/root/hotkeys[+1]")
 xpath(xml, "/root/hotstrings[+1]")
 xpath(xml, "/root/options[+1]")
 xpath(xml, "/root/options/STPP[+1]/@value/text()", "1")
 xpath(xml, "/root/options/SSG[+1]/@value/text()", ssg)
 xpath(xml, "/root/options/MHK[+1]/@value/text()", mainctrl . mainalt . mainshift . mainwin . ddl_mainhkey)
 xpath_save(xml, "res\" . s_xml)
 Pause 
 Gosub, SWW
 
 Gui, 50: Destroy
return
;}

SWW:                                                                ; Start With Windows subroutine.
;{
 if sww
    RegWrite, REG_SZ, HKCU, %reg_run%, ahk-tk, %a_scriptfullpath%
 else
 {
    RegRead, sww_exist, HKCU, %reg_run%, ahk-tk
    if sww_exist
        RegDelete, HKCU, %reg_run%, ahk-tk
 }
return
;}

XMLREAD:
;{
 ssg := xpath(xml, "/root/options/SSG/@value/text()")
 mhk := xpath(xml, "/root/options/MHK/@value/text()")
 pastepop_ena := xpath(xml, "/root/options/STPP/@value/text()")
 Hotkey, %mhk%, MasterHotkey
return
;}

SplashGui:
;{
 mhk := hkSwap(mhk, "long")
 Gui, 50: -Caption +Toolwindow +Border +AlwaysOnTop
 Gui, 50: Font, s12 w600, Verdana
 Gui, 50: add, Text, w580 Center, % "Welcome to " . s_name "`nVersion " . s_version
 Gui, 50: add, Text, w610 x0 0x10
 Gui, 50: Font, s11 w400
 Gui, 50: add, Text, x10 yp+10, % "AHK-ToolKit has been activated."
 Gui, 50: add, Text, y+5, % "The current hotkey for the main window is: "
 Gui, 50: Font,w600 
 Gui, 50: add, Text, x+5 yp, % mhk
 Gui, 50: Show, w600
 Sleep, 5 * sec
 Gui, 50: Destroy
return
;}

OnClipboardChange:
;{
 kword_count:=
/*
* This checks if the clipboard contains keywords from ahk scripting
* if it contains more than x ammount of keywords it will fire up the pastebin
* routines. You can change this to suit you better.
*/
 Loop, parse, ahk_keywords, `n, `r
 {
    if clipboard contains %a_loopfield%
        kword_count++
 }
 if kword_count >= 3
 {
    kword_count := 
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

99ButtonYes:                                                        ; Popup YES
;{
 Gui, Hide                                                          ; Hide Popup
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
 StringReplace, clipboard, clipboard, &, `%26, 1 
 StringReplace, clipboard, clipboard, +, `%2B, 1
 ; Finish Replacing
 
 GuiControl, 98:, ahk_code, %clipboard%
 Gui, 98: Show, w640 h550, % "Send To Pastebin"
 Gui, 98: Submit, NoHide
return 
;}

99ButtonNo:                                                         ; Popup No
;{
 Gui, Hide
return
;}

98ButtonUpload:                                                     ; Send to Pastebin Upload
;{
 Gui, 98: Submit
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

98ButtonSavetoFile:                                                 ; Send to Pastebin Save To File
;{
 Gui, 98: +OwnDialogs
 FileSelectFile, f_saved, S24, %a_desktop%, Save script as..., AutoHotkey (*.ahk)
 if !f_saved
    return
 /*
 * The following fixes back the code replacement done earlier to prevent
 * issues with httpQUERY.
 */
 StringReplace, ahk_code, ahk_code, `%26, &, 1 
 StringReplace, ahk_code, ahk_code, `%2B, +, 1
 ; Finish Replacing
 
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
;}

98ButtonCancel:                                                     ; Send to Pastebin Cancel
;{
 Gui, Hide
return
;}

DisablePopup:
;{
 Gui, 99: Submit, NoHide
 msgbox % pastepop_ena
 Msgbox, % "You have chosen to disable the Pastebin Alert, to enable it again go to the options tab"
 xpath(xml, "/root/options/STPP/@value/text()", pastepop_ena)
 xpath_save(xml, "res\" . s_xml)
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
ButtonCancel:
;{
 main_toggle := !main_toggle
 if main_toggle
    Gui, Show, w619 h341, AutoHotkey ToolKit
 else
    Gui, Hide
return
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
    global paste_url
    global ahk_code
    global wa_Right
    global wa_Bottom
    global sec
    FormatTime,cur_time,,[MMM/dd/yyyy - HH:mm:ss]
    xpos := wa_Right - 250 - 5 
    ypos := wa_Bottom - 90
    clipboard := paste_url
    Gui, 97: Show, x%xpos% y%ypos%
    Loop, parse, ahk_code, `n, `r
    {
        if a_index = 20
            break
        code_preview := code_preview . "`n" . a_loopfield
    }
    FileAppend, 
    (
;--> %cur_time% %paste_url% :
----------------------------------------------------------------------
%code_preview%
----------------------------------------------------------------------`n`n
    ), res\pastebin-log.dat
    Sleep, 3 * sec
    Gui, 97: Hide
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
