/*
--[Example Script]------------------------------------------------------------------
*/
/*
#singleinstance force
Quick Showcase see description for more info:
msgbox % "Same as before but uppercase chars that can be pressed without modifiers`n`n"keylist := klist("all")
msgbox % "Same as before but uppercase chars that can be pressed without modifiers`n`n"keylist := klist("all-up")
msgbox % "This returns only lowercase alpha keys`n`n"keylist := klist("lower")
msgbox % "This returns only uppercase alpha keys`n`n"keylist := klist("upper")
msgbox % "This returns alpha keys (uppercase)and numbers`n`n"keylist := klist("alphanumup")
msgbox % "This returns alpha keys (lowercase)and numbers`n`n"keylist := klist("alphanumlow")
msgbox % "This returns only numbers`n`n"keylist := klist("num")
msgbox % "This returns punctuation signs that dont require modifiers`n`n"keylist := klist("punct")
msgbox % "These are mouse keys`n`n"keylist := klist(0,1)
msgbox % "These are all keyboard keys (non ascii)`n`n"keylist := klist(0,0,1)
msgbox % "This removes A-G from the keylist`n`n"keylist := klist(2,0,0,exc := "A|B|C|D|E|F|G")
msgbox % "This returns mouse keys and includes the specified keys to the list`n`n"keylist := klist(0,1,0,exc := "", inc := "Enter|Backspace|Escape")
Esc::ExitApp

***** Script 1 *****
keylist := "None|" . keylist := klist(1,0,0,ex := "", in := "Enter|Backspace|Delete")
Gui, add, groupbox, x10 y+20 w410 h50, Select Hotkey
Gui, add, dropdownlist, w170 xp+10 yp+20 vhk_ddl, %keylist%
Gui, add, checkbox, x+10 yp+5 vmod_ctrl, Ctrl
Gui, add, checkbox, x+20 vmod_alt, Alt
Gui, add, checkbox, x+20 vmod_shift, Shift
Gui, add, checkbox, x+20 vmod_win, Win
Gui, add, text, w440 x0 y+20 0x10
Gui, add, button, w100 h25 x320 yp+10, Exit
Gui, Show, w430,Add New hotkey
Return

ButtonExit:
ExitApp
***** End *****

***** Script 2 *****

keylist := klist(2,1,1,exclude:="LButton|WheelDown|WheelUp|Escape")
loop, parse, keylist, |
    hotkey, *%a_loopfield%, blockkeys ; <--- Note the *, that is for blocking modified keys like "Alt + A" and such
return

blockkeys:
return

Esc::ExitApp ; <----- Note that this one works because we excluded the Escape Key (Alone)
!Esc::Pause ; <----- Note that this hotkey WONT work because we are blocking the Alt key

***** End *****
*/

/*
--[Function]------------------------------------------------------------------------
*/

/*
Function        : klist([ascii, mouse, keyboard, exclude, include])
Author          : RaptorX
Version         : 0.1
Created         : July 01 , 2010
Updated         : July 03 , 2010

Description:
--------------
All arguments are optional.

This function returns a list of keys from the keyboard or mouse ready to be parsed.
Useful to create a bunch of hotkeys, display a list of keys on a combo box or any other general use in which 
you need a list of keys to operate on and you dont want to manually type them.

When all parameters are omitted it returns a list of the common ascii characters (a-z, 0-9, and punctuation
signs) separated by "|" to be parsed later on.

Note that the function is case sensitive, I made it this way because my main intention was to show a list of 
hotkeys from a combo-box and wanted to use all uppercase letters instead of their lowercase version.

Quick reference:
---------------
keylist := klist() --> this returns the basic ascii characters that dont require modifier keys such as Ctrl or Alt
keylist := klist("lower") --> a-z
keylist := klist("upper") --> A-Z
keylist := klist("alphanumup") --> A-Z and 0-9
keylist := klist("alphanumlow") --> a-z and 0-9
keylist := klist("num") --> 0-9
keylist := klist("punct") --> this returns punctuation signs that dont require modifier keys
keylist := klist(0,1) --> returns mouse keys such as LMouse... if you want to add XButton1 or WheelLeft use the
include argument
keylist := klist(0,0,1) --> this returns the list of keyboard buttons such as Enter and Escape
keylist := klist(1,0,0, exc := "a|b|c|d|e|f|g") --> return ascii keys without a-g (exclude)
keylist := klist(0,1,0, exc := "", inc := "Enter|Backspace|Escape") --> mouse keys + others (Include)
keylist := klist(0,1,1) --> this returns all mouse and keyboard buttons
keylist := klist(0,1,1,exclude:="Escape|Backspace|Delete|Insert") --> same as above but removes those keys.
keylist := klist(1,0,1,exclude:="", var) --> use all the keyboard and ascii keys and include a list of keys
contained in the variable %var%.

Arguments:
--------------
[ascii] all/all-up/none/lower/upper/num/alphanumup/alphanumlow/punct/true/false/0/1/2
Appends a list of the common ascii characters to the return value.

-True / 1 / all - Appends all characters (lowercase) that can be pressed without modifiers, ex. "[" but not "{"
-All-up / 2- Same as above but returns uppercase alpha instead.
-Lower- Appends only lowercase alphabetic characters
-Upper- Same as above but only Uppercase.
-Num- Appends only numbers
-Alphanumup- Appends Alphabetic characters as well as numbers, uses uppercase.
-Alphanumlow- Appends Alphabetic characters as well as numbers, uses lowercase.
-Punct- Sends only punctuation signs that can be pressed without modifiers, ex. ";" but not ":"
-False / 0 / none- do not Append ascii characters at all

[mouse] true/false/1/0
Appends a list of the COMMON mouse keys to the return value, if you want other keys like WheelLeft, WheelRight ,
XButton1 or XButton2 use the "Include" argument

[keyboard] true/false/1/0
Appends a list of keys from the keyboard other than the ascii characters stated above.

[exclude] byref variable
Excludes the specified keys from the return value.
Specify a variable that contains a list separated by "|". If you dont want to exclude too many keys simply use
the := operator to assign keys right there when calling the function, ex. klist(1,1,1,exclude := "A|B|C")

IMPORTANT: Do NOT append "|" at the beginning or at the end of the list because it will cause problems with the
StringReplace used to exclude the items from the list.

[include] byref variable
Appends the specified keys to the return value.
this works the same as the exclude argument above and it is used mainly to add keys not added in my main list
like the Media Buttons or Special SCxxx keys.
*/
klist(ascii = "all", mouse = false, keyboard = false, Byref exclude = "", Byref include = ""){
    StringCaseSense, On
     ascii_list  := "44,45,46,47,48,49,50,51,52,53,54,55,56,57,59,61,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,"
     . "80,81,82,83,84,85,86,87,88,89,90,91,92,93,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,"
     . "113,114,115,116,117,118,119,120,121,122"

    mouse_list := "LButton|RButton|MButton|WheelDown|WheelUp"
    kb_list := "Space|Tab|Enter|Escape|Backspace|Delete|Insert|Home|End|PgUp|PgDn|Up|Down|Left|Right|"
    . "ScrollLock|CapsLock|NumLock|Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|"
    . "Numpad9|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|"
    . "NumpadUp|NumpadPgUp|NumpadDot|NumpadDel|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|F1|F2|F3|F4|"
    . "F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24|AppsKey|LWin|RWin|LControl|"
    . "RControl|LShift|RShift|LAlt|RAlt|Control|Alt|Shift|PrintScreen|CtrlBreak|Pause|Break|Help|Sleep"

    if ascii
    {
        Loop, parse, ascii_list, `,
                mixed := mixed . "|" . nchar := chr(a_loopfield)

        if (ascii = "all" || ascii = 1)
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[^A-Z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if (ascii = "all-up" || ascii = 2)
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[^a-z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if (ascii = "none" || ascii = 0)
        {
            Sleep, 1
        }
        else if ascii = lower
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[a-z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if ascii = upper
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[A-Z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if ascii = num
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[0-9]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if ascii = alphanumup
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[0-9A-Z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if ascii = alphanumlow
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[0-9a-z]")
                    keylist := keylist . "|" . a_loopfield
        }
        else if ascii = punct
        {
            loop, parse, mixed, |
                if RegExMatch(a_loopfield, "[^a-zA-Z0-9]")
                    keylist := keylist . "|" . a_loopfield
        }
    }

    if mouse
        keylist := keylist . "|" . mouse_list

    if keyboard
        keylist := keylist . "|" . kb_list
    

    loop, parse, exclude, |
        {
            If (a_loopfield = "Win" || a_loopfield = "Alt" || a_loopfield = "Control" || a_loopfield = "Shift")
            {
            StringReplace, keylist, keylist, |L%a_loopfield%
            StringReplace, keylist, keylist, |R%a_loopfield%
            }
            StringReplace, keylist, keylist, |%a_loopfield%
        }

    if include
        keylist := keylist . "|" . include

    StringTrimLeft, keylist, keylist, 1
    StringCaseSense, off
    return keylist
} ; Function End