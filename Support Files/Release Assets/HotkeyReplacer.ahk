#Warn VarUnset, StdOut

; { \\ #Includes
#Include *i <Classes\Settings>
#Include *i <KSA\Keyboard Shortcut Adjustments>
#Include *i <Classes\dark>
#Include *i <Classes\ptf>
#Include *i <GUIs\tomshiBasic>
#Include *i <Functions\getLocalVer>
; #Include *i <Other\print>
; }

try {
    UserSettings := UserPref() ?? false
}

if !IsSet(UserSettings)
    {
        MsgBox("This script requires the user to properly generate a symlink using ``CreateSymLink.ahk```n`nPlease run ``CreateSymLink.ahk`` to do so and then try running this script again.", "HotkeyReplacer.ahk requires SymLink")
        return
    }

forRelease := getLocalVer()

;// The below block makes sure the `forRelease` variable is set before contiuning as if it isn't the script will run into errors
if !IsSet(forRelease) || forRelease = ""
    {
        MsgBox("No ``My Scripts.ahk`` file found in the release folder.`nThe script should be located:`n``" ptf.rootDir "\My Scripts.ahk``", "Error", 48)
        return
    }

;localVer // v2.10.1

TraySetIcon(ptf.Icons "\myscript.png")

class HotkeyReplacer {
    UserDir := ""
    UserIniLocation := ""
    MyScriptsLoc => ptf.rootDir "\My Scripts.ahk"
    KSAIniLoc => ptf["KSAini"]
    tempDir => A_Temp "\tomshi"
    tempMS => this.tempDir "\tempMS.ahk"

    /**
     * prompts the user to select their in use root directory of the tomshi repo
     */
    __getUserLoc() {
        getUserFile := FileSelect("D" 2,, "Select the root directory of your current in-use script path")
        if getUserFile = ""
            ExitApp()
        return getUserFile
    }

    /**
     * This function checks to ensure both `My Scripts.ahk` & `KSA.ini` can be found in the user's defined location
     */
    __checkFiles() {
        this.UserDir := this.__getUserLoc()
        this.UserIniLocation := this.UserDir "\lib\KSA\Keyboard Shortcuts.ini"
        if !FileExist(this.UserDir "\My Scripts.ahk") || !FileExist(this.UserIniLocation)
            throw ValueError("Could not find ``My Scripts.ahk`` or ``Keyboard Shortcuts.ini`` within the chosen directory.", -1)
    }

    /**
     * This function will enumerate through the user's KSA.ini file and use that as a base to replace the release version of the tomshi repo.
     * This function uses a function within `KeyShortAdjust()` to generate a map to do so
     */
    __replaceUserKSA(*) {
        this.__checkFiles()
        FileCopy(this.UserIniLocation, ptf.Backups "\keyboard Shortcuts_Backup.ini", 1)
        readSections := IniRead(this.UserIniLocation)
        allSections := StrSplit(readSections, ["`n", "`r"])
        for v in allSections {
            sectionArr := KeyShortAdjust().__CreateMap(v, this.UserIniLocation)
            for k, v2 in sectionArr {
                if KSA.HasOwnProp(k) {
                    IniWrite(v2, ptf["KSAini"], v, k)
                    ; print(Format("value: {}, section: {}, key: {}, file: {}", v2, v, k, ptf["KSAini"]))
                }
            }
        }
        ;// move on to my scripts
        this.__replaceUserMyScripts()
    }

    /**
     * This function will enumerate through the user's My Scripts.ahk file and generate a map of `;Hotkey; tag`/`hotkey::` combo
     */
    __generateMSMap(string) {
        hotkeyMap := Map()
        loop {
            if !location := InStr(string, "hotkey;",,, A_Index)
                break
            hotkeyKey := SubStr(string, location + 9, InStr(string, "::", 1, location, 1) - location - 9) ;creating a substring of just the hotkey

            nameLocation := InStr(string, ";", 1, location, -1) ;getting the beginning location of the hotkey tag
            hotkeyName := SubStr(string, nameLocation + 1, location - nameLocation - 1) ;getting the name of the hotkey tag
            if !hotkeyMap.Has(hotkeyName)
                hotkeyMap.Set(hotkeyName, hotkeyKey)
        }
        return hotkeyMap
    }

    /**
     * This function will enumerate through the user's My Scripts.ahk file and use that as a base to replace the release version of the tomshi repo.
     */
    __replaceUserMyScripts() {
        ;// backup script
        FileCopy(ptf.rootDir "\My Scripts.ahk", ptf.Backups "\My Scripts_Backup.ahk", 1)
        readUserMS := FileRead(this.UserDir "\My Scripts.ahk")
        readReleaseMS := FileRead(ptf.rootDir "\My Scripts.ahk")
        UserHotkeys := this.__generateMSMap(readUserMS)
        ReleaseHotkeys := this.__generateMSMap(readReleaseMS)

        ;// creating dirs we'll need later
        if !DirExist(this.tempDir)
            DirCreate(this.tempDir)
        if FileExist(this.tempMS)
            FileDelete(this.tempMS)
        ;// create baseline file
        FileAppend(readReleaseMS, this.tempMS)

        for k, v in UserHotkeys {
            readMS := FileRead(this.tempMS)

            if !ReleaseHotkeys.Has(k)
                continue
            if ReleaseHotkeys[k] = v
                continue

            ;//! attempting to do the below without first generating substrings would not work, it seems strreplace requires substrings?? not just a string to replace
            ;// find the hotkey tag
            keyLocation := InStr(readMS, ";" k "Hotkey;`r",,, 1)
            ;// find the hotkey itself directly after it
            valueLocation := InStr(readMS, ReleaseHotkeys[k] "::",, keyLocation, 1)
            ;// create a substring to later search for
            needle := SubStr(readMS, keyLocation, (valueLocation + StrLen(ReleaseHotkeys[k] "::")-keyLocation))
            ;// create a substring to later replace the original substring with
            replaceString := StrReplace(needle, ReleaseHotkeys[k] "::", v "::")
            ;// replace the substring
            tempWrite := StrReplace(readMS, needle, replaceString, 0, &didPass, 1)

            ;// debugging
            /* if !IsSet(didPass)
                didPass := "unset"
            print(Format("
            (
                has: {}
                finding:
                {}
                replacing with:
                {}
                success?: {}
            )", ReleaseHotkeys.Has(k), needle, replaceString, didPass
            )) */
            if FileExist(this.tempDir "\tempMS.ahk")
                FileDelete(this.tempDir "\tempMS.ahk")
            FileAppend(tempWrite, this.tempDir "\tempMS.ahk")
        }
        FileMove(this.tempDir "\tempMS.ahk", ptf.rootDir "\My Scripts.ahk", 1)
        this.__finish()
    }

    /**
     * What will happen when the class has finished
     */
    __finish() {
        MsgBox("Attempting to replace the user's ``KSA`` & ``My Scripts`` values has completed. A backup of the original files can be found here:`n" ptf.Backups)
        ExitApp()
    }
}

HKR := HotkeyReplacer()
replaceIt := ObjBindMethod(HKR, '__replaceUserKSA')

;defining the informational gui
ReplacerGui := tomshiBasic(11.5,, "-Resize +MinSize500x380 -MaximizeBox", "Tomshi Hotkey Replacer for " forRelease)

;title and text
titletext := "Welcome to Hotkey Replacer for " forRelease
titleWidth := 362 + ((StrLen(forRelease)-4)*8)
title := ReplacerGui.Add("Text", "X105 Y8 W" titleWidth " Center R1.5", titletext)

title.SetFont("S15 Bold")
text := ReplacerGui.Add("Text", "X15 W530 Y+5 Center", "
(
    HotkeyReplacer is only designed to be used if you already have a version of my scripts in use. If you don't, feel free to exit out of this script.`n
    This script is designed to replace most* of the hotkeys in the release version of ``My Scripts.ahk`` with the hotkeys you have in your own local copy. It also replaces any custom values set within ``Keyboard Shortcuts.ini```n
    This script works by detecting the ``;xHotkey;`` tag I have above every hotkey and doing some string replacement to replace the release version with any you've changed locally.`n
    Please be aware that any hotkeys you've added yourself will not be transfered over and there may still be some manual adjustment needed in that case.
)")

;buttons
replaceButton := ReplacerGui.AddButton("x400", "replace")
replaceButton.OnEvent("Click", replaceIt)
cancelButton := ReplacerGui.AddButton("X+10", "cancel")
cancelButton.OnEvent("Click", (*) => ReplacerGui.Destroy())

if UserSettings.dark_mode = true
    dark.allButtons(ReplacerGui)

;status bar
SB := ReplacerGui.Add("StatusBar")
SB.SetFont("S10")
SB.SetText("  " forRelease)

;show gui
ReplacerGui.Show("Center")
ReplacerGui.GetClientPos(,, &guiwidth, &height)
title.GetPos(,, &width)
title.Move((guiWidth-width)/2)