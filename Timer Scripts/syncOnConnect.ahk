#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance force

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Functions\syncDirectories.ahk
; }

Persistent()
OnMessage(0x0219, WM_DEVICECHANGE)