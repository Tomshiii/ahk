; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\checkBool.ahk
#Include Other\FileGetExtendedProp.ahk
; }

/**
 * Determines the path/version of the installed version of Premiere of After Effects.
 * This function will generally return information about the most recently installed year version for the given program. ie, if you have Premiere 2026 installed, then install 2025, it will return information about 2025
 * Photoshop does not create a separate folder for the `beta` version so if `psIsBeta` equals `false` this function will attempt to locate the latest installed year version of Photoshop
 * @link "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\"
 * @param {Object} exeNames must provide `{baseName: , beta: }` which are both the normal name and the beta name as found in the registry. ie; `{baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"}`
 * @param {Object} [UserSettings=unset] if you've already set a `UserPref()` object, you can pass it through here, otherwise it will be generated
 * @returns {Object|false} `{path: "path\to\.exe", version: "v2x.y.z"}`
 */
determineAdobeVer(exeNames, UserSettings?) {
    try UserSettings := CLSID_Objs.clone("UserSettings")
    catch {
        UserSettings := UserPref(true)
    }
    whichBeta := InStr(exeNames.baseName, "Premiere") ? UserSettings.premIsBeta : (InStr(exeNames.baseName, "After Effects") ? UserSettings.aeIsBeta : UserSettings.psIsBeta)
    whichExe := (checkBool(whichBeta) = false) ? exeNames.baseName : exeNames.beta
    regInstalledVer := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" whichExe,, 0)
    if (regInstalledVer != false && regInstalledVer != "0") && SubStr(regInstalledVer, 1, 1) = '"' && SubStr(regInstalledVer, -1, 1) = '"'
        regInstalledVer := SubStr(regInstalledVer, 2, StrLen(regInstalledVer)-2)
    if regInstalledVer = false || !FileExist(regInstalledVer)
        return false
    if InStr(exeNames.baseName, "Photoshop") {
        SplitPath(regInstalledVer,, &currDir)
        SplitPath(currDir,, &allDirs)
        switch {
            case InStr(currDir, "(Beta)") && !checkBool(UserSettings.psIsBeta):
                vers := []
                loop files allDirs "\*", "D" {
                    if !InStr(A_LoopFileName, "Adobe Photoshop") || InStr(A_LoopFileName, "(Beta)")
                        continue
                    vers.Push(A_LoopFileName)
                }
                if vers.Length > 0 {
                    vers.Sort("C")
                    vers.Reverse()
                    yearDir := allDirs "\" vers[1]
                }

                regInstalledVer := (IsSet(yearDir) && FileExist(yearDir "\Photoshop.exe")) ? yearDir "\Photoshop.exe" : regInstalledVer
            case !InStr(currDir, "(Beta)") && checkBool(UserSettings.psIsBeta):
                regInstalledVer := allDirs "\Adobe Photoshop (Beta)\Photoshop.exe"
        }
    }
    exeVer := FileGetExtendedProp(regInstalledVer,, "System.Software.ProductVersion")["System.Software.ProductVersion"]
    exeVer := SubStr(exeVer, finalDot := InStr(exeVer, ".",, -1), 2) = ".0" ? SubStr(exeVer, 1, finalDot-1) : exeVer
    return {path: regInstalledVer, version: exeVer}
}