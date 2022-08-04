forRelease := "v2.3"

;localVer // v2.3

;defining the informational gui
InstallerGui := Gui("", "Tomshi Script Installer for " forRelease)
InstallerGui.SetFont("S11.5")
;nofocus
removedefault := InstallerGui.Add("Button", "Default X0 Y0 w0 h0", "_")
title := InstallerGui.Add("Text", "X8 Y8 W400", "Welcome to the installer for " forRelease)
title.SetFont("S15 Bold")
text := InstallerGui.Add("Text", "W530", "This script is designed to replace all of the hotkeys in the release version of ``My Scripts.ahk`` with the hotkeys you have in your own local copy.`n`nThis script works by detecting the ``;xHotkey;`` tag I have above every hotkey and doing some string replacement to replace the release version with any you've changed locally.`n`nPlease be aware that any hotkeys you've added yourself will not be transfered over and there may still be some manual adjustment needed in that case.`n`nThis script is only designed to be used if you already have a version of my scripts. If you don't, feel free to exit out of this script and simply place the release folder wherever you wish (and renaming it to whatever you wish).")


replaceButton := InstallerGui.Add("Button", "X375 Y335", "replace")
replaceButton.OnEvent("Click", replace)
cancelButton := InstallerGui.Add("Button", "X+10", "cancel")
cancelButton.OnEvent("Click", cancel)


InstallerGui.Show("Center AutoSize")

;the function that will go through and replace the release hotkeys with the users hotkeys
replace(*)
{
    getUserFile := FileSelect("D" 2,, "Select your current in-use script path")
    if getUserFile = ""
        return

    loop files getUserFile "\*.ahk", "F"
        {
            if A_LoopFileName = "My Scripts.ahk"
                getUserFile := A_LoopFileFullPath
            else
                continue
        }

    try {
        checkstring := FileRead(getUserFile)
    } catch as e {
        MsgBox("No My Scripts.ahk file found")
        return
    }
    releaseFile := FileRead(A_ScriptDir "\" forRelease "\My Scripts.ahk")
    if DirExist(A_ScriptDir "\" forRelease "\Backups") && !FileExist(A_ScriptDir "\" forRelease "\Backups\My Scripts.ahk")
        FileCopy(A_ScriptDir "\" forRelease "\My Scripts.ahk", A_ScriptDir "\" forRelease "\Backups")
    if FileExist(A_ScriptDir "\hotkeys.ini")
        FileDelete(A_ScriptDir "\hotkeys.ini")
    if FileExist(A_ScriptDir "\hotkeynames.ini")
        FileDelete(A_ScriptDir "\hotkeynames.ini")

    if not FileExist(A_ScriptDir "\hotkeys.ini")
        FileAppend("[Hotkeys]", A_ScriptDir "\hotkeys.ini")
    if not FileExist(A_ScriptDir "\hotkeynames.ini")
        FileAppend("[Hotkey Names]", A_ScriptDir "\hotkeynames.ini")

    if not DirExist(A_Temp "\tomshi")
        DirCreate(A_Temp "\tomshi")
    if FileExist(A_Temp "\tomshi\My Scripts.ahk")
        FileDelete(A_Temp "\tomshi\My Scripts.ahk")
    ;create baseline file
    FileAppend(releaseFile, A_Temp "\tomshi\My Scripts.ahk")

    ;generate user hotkeys
    loop {
        location := InStr(checkstring, "Hotkey;", 1,, A_Index)
        if location = 0
            break
        endHotkey := InStr(checkstring, "::", 1, location, 1)
        hotkeyKey := SubStr(checkstring, location + 9, endHotkey - location - 9)

        nameLocation := InStr(checkstring, ";", 1, location, -1)
        hotkeyName := SubStr(checkstring, nameLocation + 1, location - nameLocation - 1)
        IniWrite(hotkeyKey, A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index)
        IniWrite(hotkeyName, A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index)

    }

    if FileExist(A_ScriptDir "\hotkeys.ini") && FileExist(A_ScriptDir "\hotkeynames.ini")
        {
            loop {
                try {
                    getHotkeys := IniRead(A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index)
                    getHotkeyName := IniRead(A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index)
                    ;MsgBox(getHotkeys A_Space getHotkeyName)
                } catch as e
                    break
                if InStr(releaseFile, getHotkeyName "Hotkey;",,, 1)
                    {
                        try {
                            getHotkeyPos := InStr(releaseFile, getHotkeyName "Hotkey;", 1,, 1)
                            if getHotkeyPos = 0
                                break
                            endPos := InStr(releaseFile, ";", 1, getHotkeyPos, 1)
                            length := InStr(releaseFile, ":", 1, endPos, 1)
                            replace := SubStr(releaseFile, endPos + 2, length - endpos - 2)
                            ;MsgBox(replace)
                            ;MsgBox(getHotkeys A_Space getHotkeyName A_Space replace)
                            newScript := StrReplace(releaseFile, replace, getHotkeys, 1,, 1)
                            if FileExist(A_Temp "\tomshi\My Scripts.ahk")
                                FileDelete(A_Temp "\tomshi\My Scripts.ahk")
                            FileAppend(newScript, A_Temp "\tomshi\My Scripts.ahk")
                            releaseFile := FileRead(A_Temp "\tomshi\My Scripts.ahk")
                        } catch as e {
                            MsgBox("Something went wrong trying to build a new script", "Oops")
                        }
                    }
                else
                    continue
            }
            FileMove(A_Temp "\tomshi\My Scripts.ahk", A_ScriptDir "\" forRelease "\My Scripts.ahk", 1)
            InstallerGui.Destroy()
            MsgBox("Attempting to replace hotkeys in ``My Scripts`` complete.`nA backup of the original script is in the ``\Backups`` folder in case something went wrong")
        }
}

cancel(*)
{
    InstallerGui.Destroy()
}