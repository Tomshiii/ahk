#Include <Classes\settings>
#Include <Other\Notify>

UserSettings := UserPref()
premYear := UserSettings.prem_Year
aeYear   := UserSettings.ae_Year
psYear   := UserSettings.ps_Year


Notify.Show(, "This script assumes you've installed adobe programs to their default path.", 'iconi',,, 'TC=black MC=black BC=75AEDC DUR=4 show=Fade@250 hide=Fade@250')
defaults := "C:\Program Files\Adobe\"
createShort(def, year, exeName) {
    if FileExist(def year exeName) {
        name := exeName
        name := (InStr(name, "\Support Files\AfterFX.exe")) ? (name := StrReplace(name, "\Support Files\", ""))
                                                            : (name := StrReplace(name, "\", ""))
        try FileCreateShortcut(def year exeName, StrReplace(name, ".exe", ".lnk"))
    }
}

createShort(defaults, "Adobe Premiere Pro " premYear, "\Adobe Premiere Pro.exe")
createShort(defaults, "Adobe After Effects " aeYear, "\Support Files\AfterFX.exe")
createShort(defaults, "Adobe Photoshop " psYear, "\Photoshop.exe")