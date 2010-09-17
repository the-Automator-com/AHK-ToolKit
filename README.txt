--AutoHotkey ToolKit--
      v0.4.12b

This script was originally meant for 1) showing the potential of autohotkey and 2) make it easier
for me to help others while on the IRC/Forum and help with my general tasks. Now I believe that it has more potential.

If you like the script, please comment, and if you did find any bugs comment as well, I have been working very 
actively on this project and I plan on continuing the work for a while longer. So any info on how can I improve this 
script is very welcomed! 

Main features:

* Create hotkeys to launch programs without need to restart the script
  -- I am planning on allowing hotkeys to run ahk commands as well.

* Create normal or multi-line hotstrings on the fly also without needing to restart the script
  -- they can be ahk commands as well.

* Small Editor to write and execute autohotkey scripts even when you dont have autohotkey installed in the PC
  -- I use it to test code without having to save a file for it.
     But this really shines when the script is compiled and you are in a 
     pc  that does not have AHK installed.

* Detect AutoHotkey scripts copied to the clipboard and allow you to upload it to a pastebin service or save it to 
  a file.
  -- This little gem copies the link of the created pastebin to the clipboard  
      and restores your old clipboard once you Ctrl + V.
  -- If you use AutoHotkey.net as the pastebin (you can choose 2 other)
     you can specify a nickname and your paste will be auto announced in
     IRC channel.
  -- It also auto replace #Include files by the actual files in case you forgot
     no more: "oh i forgot to mention that thereare includes there, 
     remove those lines!".
     
* Detect selected AHK command and open online documentation by pressing Shift. If you are in the forum creating a
  new post or replying to an existing post the selected command will get [url] tags instead linking to the online
  documentation.


Secondary features:

* Auto run selected code
  -- If you Ctrl + Alt Click selected text that is ahk code it will be run 
      automatically. You can also Ctrl + Alt + Drag to select the text and 
      once you let go of the Left Mouse button the script will be run.

* Alt + Click on a window will take a screen shot of it and upload it to Imagebin.org. The link will be copied to the Clipboard for easy share. Once you Ctrl + V your old clipboard will be restored.

* Alt + Dragging the mouse will take a screen shot of the selected area and do the same as above.
