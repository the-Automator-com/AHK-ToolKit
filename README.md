                    -----------------------------------------------------------
                                          AutoHotkey ToolKit
                    -----------------------------------------------------------

----[Features]-------------------------------------------------------------------------------------
Main features:

o Create hotkeys to launch programs without need to restart the script
  - I am planning on allowing hotkeys to run ahk commands as well.

o Create normal or multi-line hotstrings on the fly also without needing to restart the script
  - they can be ahk commands as well.

o Small Editor to write and execute autohotkey scripts even when you dont have autohotkey installed in the PC
  - I use it to test code without having to save a file for it.
    But this really shines when the script is compiled and you are in a 
    pc  that does not have AHK installed.

o Detect AutoHotkey scripts copied to the clipboard and allow you to upload it to a pastebin service or save it to 
  a file.
  - This little gem copies the link of the created pastebin to the clipboard  
     and restores your old clipboard once you Ctrl + V.
  - If you use AutoHotkey.net as the pastebin (you can choose 2 other)
    you can specify a nickname and your paste will be auto announced in
    IRC channel.
  - It also auto replace #Include files by the actual files in case you forgot
    no more: "oh i forgot to mention that thereare includes there, 
    remove those lines!".
     
o Detect selected AHK command and open online documentation by pressing Shift. If you are in the forum creating a
  new post or replying to an existing post the selected command will get [url] tags instead linking to the online
  documentation.


Secondary features:

o Auto run selected code
  - If you Ctrl + Alt Click selected text that is ahk code it will be run 
    automatically. You can also Ctrl + Alt + Drag to select the text and 
    once you let go of the Left Mouse button the script will run.

o Alt + Click on a window will take a screen shot of it and upload it to an anonymous Imageshack acount if 
  you did not specify one on the options. 
  The link will be copied to the Clipboard for easy share. Once you Ctrl + V your old clipboard will be restored.

o Alt + Dragging the mouse will take a screen shot of the selected area and do the same as above.

----[Author]---------------------------------------------------------------------------------------
    This program was created by RaptorX on July 11, 2010 
----[Licence]--------------------------------------------------------------------------------------
 
 * License:         Copyright ©2010 RaptorX <GPLv3>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 
----[Known Bugs]-----------------------------------------------------------------------------------
----[TODO]-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------