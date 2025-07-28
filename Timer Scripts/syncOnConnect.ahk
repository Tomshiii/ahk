#Requires AutoHotkey v2.0
#NoTrayIcon
#Include <Functions\syncDirectories>

Persistent()
OnMessage(0x0219, WM_DEVICECHANGE)