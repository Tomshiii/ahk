; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\settings.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\generateAdobeShortcut.ahk
#Include Other\Notify\Notify.ahk
; }

#SingleInstance force

UserSettings := CLSID_Objs.load("UserSettings")

try warning := A_Args[1]
if !IsSet(warning) || (warning != false && warning != "false") {
    Notify.Show(, 'This script assumes you`'ve installed adobe programs to their default path and the correct version is selected within settingsGUI().', 'iconi',,, 'dur=4 maxW=500 bdr=0x75AEDC tag=origNotifShort')
}
defaults := "C:\Program Files\Adobe\"

if !generateAdobeShortcut(UserSettings, "Adobe Premiere Pro", UserSettings.prem_Year) {
    if Notify.Exist("origNotifShort")
        Notify.Destroy("origNotifShort")
    Notify.Show('Error generating shortcut', 'Premiere Pro may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: ' UserSettings.premVer, 'C:\Windows\System32\imageres.dll|icon94', 'soundx',, 'dur=4 bc=0xC72424 show=Fade@250 hide=Fade@250 maxW=500')
}
if !generateAdobeShortcut(UserSettings, "Adobe After Effects", UserSettings.ae_Year) {
    if Notify.Exist("origNotifShort")
        Notify.Destroy("origNotifShort")
    Notify.Show('Error generating shortcut', 'After Effects may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: ' UserSettings.aeVer, 'C:\Windows\System32\imageres.dll|icon94', 'soundx',, 'dur=4 bc=0xC72424 show=Fade@250 hide=Fade@250 maxW=500')
}
if !generateAdobeShortcut(UserSettings, "Adobe Photoshop", UserSettings.ps_Year) {
    if Notify.Exist("origNotifShort")
        Notify.Destroy("origNotifShort")
    Notify.Show('Error generating shortcut', 'Photoshop may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: ' UserSettings.psVer, 'C:\Windows\System32\imageres.dll|icon94', 'soundx',, 'dur=4 bc=0xC72424 maxW=500 show=Fade@250 hide=Fade@250')
}