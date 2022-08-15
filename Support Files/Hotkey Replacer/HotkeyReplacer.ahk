forRelease := getVer()

/*
 This function will grab the release version from the `My Scripts.ahk` file itself. This function makes it so I don't have to change this variable manually every release
 */
getVer()
{
    loop files A_ScriptDir "\*.ahk", "R" ;this loop searches the current script directory for the `My Scripts.ahk` script
        {
            if A_LoopFileName = "My Scripts.ahk"
                {
                    myScriptDir := A_LoopFileFullPath
                    break
                }
            else
                continue
        }
    try {
        releaseString := FileRead(myScriptDir) ;then we're putting the script into memory
    } catch as e {
        return
    } ;then the below block is doing some string manipulation to grab the release version from it
    foundpos := InStr(releaseString, 'v',,,2)
	endpos := InStr(releaseString, '"', , foundpos, 1)
	end := endpos - foundpos
	version := SubStr(releaseString, foundpos, end)
    return version ;before returning the version back to the function
}

;the below block makes sure the `forRelease` variable is set before contiuning as if it isn't the script will run into errors
if !IsSet(forRelease) || forRelease = ""
    {
        MsgBox("No ``My Scripts.ahk`` file found in the release folder.`nThe script should be located:`n``" A_ScriptDir "\v2.x.x\My Scripts.ahk``", "Error", 48)
        return
    }

;localVer // v2.4

;defining the informational gui
ReplacerGui := Gui("", "Tomshi Hotkey Replacer for " forRelease)
ReplacerGui.SetFont("S11.5")
;nofocus
removedefault := ReplacerGui.Add("Button", "Default X0 Y0 w0 h0", "_")
title := ReplacerGui.Add("Text", "X8 Y8 W400 H25", "Welcome to the replace script for " forRelease)
title.SetFont("S15 Bold")
text := ReplacerGui.Add("Text", "W530 Y+3", "This script is only designed to be used if you already have a version of my scripts in use. If you don't, feel free to exit out of this script and simply place the release folder wherever you wish (and renaming it to whatever you wish).`n`nThis script is designed to replace all of the hotkeys in the release version of ``My Scripts.ahk`` with the hotkeys you have in your own local copy.`n`nThis script works by detecting the ``;xHotkey;`` tag I have above every hotkey and doing some string replacement to replace the release version with any you've changed locally.`n`nPlease be aware that any hotkeys you've added yourself will not be transfered over and there may still be some manual adjustment needed in that case.")


replaceButton := ReplacerGui.Add("Button", "X375 Y+5", "replace")
replaceButton.OnEvent("Click", replace)
cancelButton := ReplacerGui.Add("Button", "X+10", "cancel")
cancelButton.OnEvent("Click", cancel)


ReplacerGui.Show("Center AutoSize")

;the function that will go through and replace the release hotkeys with the users hotkeys
replace(*)
{
    getUserFile := FileSelect("D" 2,, "Select your current in-use script path")
    if getUserFile = ""
        return
    getUserFile2 := getUserFile ;for the ini loop

    loop files getUserFile "\*.ahk", "F"
        {
            if A_LoopFileName = "My Scripts.ahk"
                getUserFile := A_LoopFileFullPath
            else
                continue
        }
    loop files getUserFile2 "\KSA\*.ini", "F"
        {
            if A_LoopFileName = "Keyboard Shortcuts.ini"
                getUserIniFile := A_LoopFileFullPath
            else
                continue
        }

    try {
        checkstring := FileRead(getUserFile)
    } catch as e {
        ReplacerGui.Destroy()
        MsgBox("No ``My Scripts.ahk`` file found in the user folder.`nPlease ensure you haven't renamed the script", "Error", 48)
        return
    }
    try {
        checkstring2 := FileRead(getUserIniFile)
    } catch as e {
        ReplacerGui.Destroy()
        MsgBox("No ``Keyboard Shortcuts.ini`` file found in the user folder.`nPlease ensure you haven't renamed the script", "Error", 48)
        return
    }
    if FileExist(A_ScriptDir "\" forRelease "\My Scripts.ahk")
        releaseFile := FileRead(A_ScriptDir "\" forRelease "\My Scripts.ahk")
    else
        {
            ReplacerGui.Destroy()
            MsgBox("Couldn't find the release version of ``My Scripts.ahk``", "Error", 48)
            return
        }
    if FileExist(A_ScriptDir "\" forRelease "\KSA\Keyboard Shortcuts.ini")
        releaseIniFile := FileRead(A_ScriptDir "\" forRelease "\KSA\Keyboard Shortcuts.ini")
    else
        {
            ReplacerGui.Destroy()
            MsgBox("Couldn't find the release version of ``Keyboard Shortcuts.ini``", "Error", 48)
            return
        }
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
        location := InStr(checkstring, "Hotkey;", 1,, A_Index) ;getting the location of the hotkey tag
        if location = 0 ;if none is found, break the loop
            break
        endHotkey := InStr(checkstring, "::", 1, location, 1) ;finding the end of the hotkey directly below the tag
        hotkeyKey := SubStr(checkstring, location + 9, endHotkey - location - 9) ;creating a substring of just the hotkey

        nameLocation := InStr(checkstring, ";", 1, location, -1) ;getting the beginning location of the hotkey tag
        hotkeyName := SubStr(checkstring, nameLocation + 1, location - nameLocation - 1) ;getting the name of the hotkey tag
        IniWrite(hotkeyKey, A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index) ;writing the hotkey itself to an ini file
        IniWrite(hotkeyName, A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index) ;writing the hotkey tag name to an ini file
    }

    if FileExist(A_ScriptDir "\hotkeys.ini") && FileExist(A_ScriptDir "\hotkeynames.ini")
        {
            loop {
                try {
                    getHotkeys := IniRead(A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index) ;reading the hotkey
                    getHotkeyName := IniRead(A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index) ;reading the hotkey tag name
                    ;MsgBox(getHotkeys A_Space getHotkeyName)
                } catch as e
                    break ;when the script is done replacing hotkeys this line will break the loop
                if InStr(releaseFile, getHotkeyName "Hotkey;",,, 1)
                    {
                        try {
                            getHotkeyPos := InStr(releaseFile, getHotkeyName "Hotkey;", 1,, 1) ;from here down we're basically doing the same as the first loop but for the realease version of `My Scripts.ahk` so we can replace it with the user hotkey instead
                            if getHotkeyPos = 0
                                break
                            endPos := InStr(releaseFile, ";", 1, getHotkeyPos, 1)
                            length := InStr(releaseFile, ":", 1, endPos, 1)
                            replace := SubStr(releaseFile, endPos + 2, length - endpos - 2)
                            ;MsgBox(replace)
                            ;MsgBox(getHotkeys A_Space getHotkeyName A_Space replace)
                            newScript := StrReplace(releaseFile, replace, getHotkeys, 1,, 1) ;this line is replacing the release hotkey with the user hotkey
                            if FileExist(A_Temp "\tomshi\My Scripts.ahk")
                                FileDelete(A_Temp "\tomshi\My Scripts.ahk")
                            FileAppend(newScript, A_Temp "\tomshi\My Scripts.ahk") ;this line is creating a temporary versino of our new hotkey replaced script in a temp folder
                            releaseFile := FileRead(A_Temp "\tomshi\My Scripts.ahk")
                        } catch as e {
                            MsgBox("Something went wrong trying to build a new script", "Oops")
                        }
                    }
                else
                    continue ;if the release version removes a hotkey, this line will make the loop skip it
            }
            FileMove(A_Temp "\tomshi\My Scripts.ahk", A_ScriptDir "\" forRelease "\My Scripts.ahk", 1) ;once the script is done it replaces the release script with the temp versio we created
            ;MsgBox("The attempt to replace hotkeys in ``My Scripts`` has completed.`nA backup of the original script is in the ``\Backups`` folder in case something went wrong") ;and alert the user the process is complete
        }

    if FileExist(getUserIniFile)
        { 
            releaseFile := ""
            try {
                checkstring := FileRead(getUserIniFile)
            } catch as e {
                ReplacerGui.Destroy()
                MsgBox("No ``Keyboard Shortcuts.ini`` file found in the user folder.`nPlease ensure you haven't renamed the file", "Error", 48)
                return
            }

            if DirExist(A_ScriptDir "\" forRelease "\Backups") && !FileExist(A_ScriptDir "\" forRelease "\Backups\Keyboard Shortcuts.ini")
                FileCopy(A_ScriptDir "\" forRelease "\KSA\Keyboard Shortcuts.ini", A_ScriptDir "\" forRelease "\Backups")

            if FileExist(A_ScriptDir "\ksahotkeys.ini")
                FileDelete(A_ScriptDir "\ksahotkeys.ini")
            if FileExist(A_ScriptDir "\ksahotkeynames.ini")
                FileDelete(A_ScriptDir "\ksahotkeynames.ini")
            
            if not FileExist(A_ScriptDir "\ksahotkeys.ini")
                FileAppend("[ksa Hotkeys]", A_ScriptDir "\ksahotkeys.ini")
            if not FileExist(A_ScriptDir "\ksahotkeynames.ini")
                FileAppend("[ksa Hotkey Names]", A_ScriptDir "\ksahotkeynames.ini")

            if not DirExist(A_Temp "\tomshi")
                DirCreate(A_Temp "\tomshi")
            if FileExist(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                FileDelete(A_Temp "\tomshi\Keyboard Shortcuts.ini")
            ;create baseline file
            FileAppend(releaseIniFile, A_Temp "\tomshi\Keyboard Shortcuts.ini")

            ;generate user hotkeys
            loop {
                location := InStr(checkstring, "=", 1,, A_Index) ;getting the location of the = sign
                if location = 0 ;if none is found, break the loop
                    break
                endHotkey := InStr(checkstring, '"', 1, location, 2) ;finding the end of the hotkey using the quote marks
                hotkeyKey := SubStr(checkstring, location + 1, endHotkey + 1 - location - 1)

                nameLocation := InStr(checkstring, "]", 1, location, -1)
                hotkeyName := SubStr(checkstring, nameLocation + 3, location - nameLocation - 3)
                IniWrite(hotkeyKey, A_ScriptDir "\ksahotkeys.ini", "ksa Hotkeys", A_Index) ;writing the hotkey itself to an ini file
                IniWrite(hotkeyName, A_ScriptDir "\ksahotkeynames.ini", "ksa Hotkey Names", A_Index) ;writing the hotkey tag name to an ini file
                /* MsgBox(hotkeyName)
                if A_index > 5
                    return */
            }

            if FileExist(A_ScriptDir "\ksahotkeys.ini") && FileExist(A_ScriptDir "\ksahotkeynames.ini")
                {
                    loop {
                        try {
                            getHotkeys := IniRead(A_ScriptDir "\ksahotkeys.ini", "ksa Hotkeys", A_Index) ;reading the hotkey
                            getHotkeyName := IniRead(A_ScriptDir "\ksahotkeynames.ini", "ksa Hotkey Names", A_Index) ;reading the hotkey tag name
                            ;MsgBox(getHotkeys A_Space getHotkeyName)
                        } catch as e
                            break ;when the script is done replacing hotkeys this line will break the loop

                        if InStr(releaseIniFile, getHotkeyName "=",,, 1)
                            {
                                try {
                                    gethotkeyPos := InStr(releaseIniFile, getHotkeyName "=", 1,, 1)
                                    if getHotkeyPos = 0
                                        break
                                    endPos := InStr(releaseIniFile, "=", 1, getHotkeyPos, 1)
                                    length := InStr(releaseIniFile, '"', 1, endPos, 2)
                                    replace := SubStr(releaseIniFile, endPos + 1, (length + 1) - (endPos + 1))
                                    /* MsgBox(replace)
                                    if A_index > 5
                                        return */
                                    newIni := StrReplace(releaseIniFile, replace, '"' getHotkeys '"', 1,, 1)
                                    if FileExist(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                                        FileDelete(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                                    FileAppend(newIni, A_Temp "\tomshi\Keyboard Shortcuts.ini") ;this line is creating a temporary versino of our new hotkey replaced script in a temp folder
                                    releaseIniFile := FileRead(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                                } catch as e {
                                    MsgBox("Something went wrong trying to build a .ini file", "Oops")
                                }
                            }
                        else
                            continue
                    }
                }
            FileMove(A_Temp "\tomshi\Keyboard Shortcuts.ini", A_ScriptDir "\" forRelease "\KSA\Keyboard Shortcuts.ini", 1)
        }
    else
        {
            ReplacerGui.Destroy()
            MsgBox("Couldn't find the release version of ``Keyboard Shortcuts.ini``", "Error", 48)
            return
        }
        
    ReplacerGui.Destroy() ;we then close the gui window
    MsgBox("The attempt to replace hotkeys in ``My Scripts`` & ``Keyboard Shortcuts.ini`` has completed.`nA backup of the original script/.ini file is in the ``\Backups`` folder in case something went wrong") ;and alert the user the process is complete
}

cancel(*)
{
    ReplacerGui.Destroy()
}