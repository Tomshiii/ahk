#Include <Classes\settings>
#Include <Functions\generateAdobeShortcut>
#Include <Other\Notify>

UserSettings := UserPref()
premYear := UserSettings.prem_Year
aeYear   := UserSettings.ae_Year
psYear   := UserSettings.ps_Year


Notify.Show(, "This script assumes you've installed adobe programs to their default path.", 'iconi',,, 'POS=BR TC=black MC=black BC=75AEDC DUR=4 show=Fade@250 hide=Fade@250')
defaults := "C:\Program Files\Adobe\"

generateAdobeShortcut(UserSettings, "Adobe Premiere Pro", UserSettings.prem_Year)
generateAdobeShortcut(UserSettings, "Adobe After Effects", UserSettings.ae_Year)
generateAdobeShortcut(UserSettings, "Photoshop", UserSettings.ps_Year)