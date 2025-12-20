#Warn VarUnset, StdOut

;// This script is designed to assist the user of my repo in getting their feet off the ground by parsing through their keyboard shortcut file and attempting to auto assign KSA.ini values based on it.
/*
This process is **NOT** perfect, some values may still be entered incorrectly or just outright skipped due to the nature of trying to convert the way adobe stores their values to the way ahk can read them.
It also doesn't help that Premiere & After Effects store their data differently making it even more prone to small errors.
**Please** report any issues with this process or any errors you come across, making sure to provide as much information as possible.
*/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include GUIs\adobeKSA.ahk
; }

ksaGUI := adobeKSA()
ksaGUI.Show()