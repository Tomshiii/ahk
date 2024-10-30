#Include <Classes\settings>
#Include <Functions\generateAdobeShortcut>
#Include <Other\Notify>

UserSettings := UserPref()
premYear := UserSettings.prem_Year
aeYear   := UserSettings.ae_Year
psYear   := UserSettings.ps_Year


Notify.Show(, "This script assumes you've installed adobe programs to their default path and the correct version is selected within settingsGUI().", 'iconi',,, 'POS=BR TC=black MC=black BC=75AEDC DUR=4 show=Fade@250 hide=Fade@250')
defaults := "C:\Program Files\Adobe\"

if !generateAdobeShortcut(UserSettings, "Adobe Premiere Pro", UserSettings.prem_Year)
    Notify.Show("Error generating shortcut", "Premiere Pro may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: " UserSettings.premVer, 'iconx', 'soundx',, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
if !generateAdobeShortcut(UserSettings, "Adobe After Effects", UserSettings.ae_Year)
    Notify.Show("Error generating shortcut", "After Effects may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: " UserSettings.aeVer, 'iconx', 'soundx',, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
if !generateAdobeShortcut(UserSettings, "Photoshop", UserSettings.ps_Year)
    Notify.Show("Error generating shortcut", "Photoshop may not be installed or the proper version has not been selected within settingsGUI()`nCurrent selected version: " UserSettings.psVer, 'iconx', 'soundx',, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')