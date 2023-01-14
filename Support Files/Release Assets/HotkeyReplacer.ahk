; { \\ #Includes
#Include "%A_ScriptDir%"
#Include "..\..\lib\Classes\dark.ahk"
; }

forRelease := getLocalVer()

;the below block makes sure the `forRelease` variable is set before contiuning as if it isn't the script will run into errors
if !IsSet(forRelease) || forRelease = ""
    {
        MsgBox("No ``My Scripts.ahk`` file found in the release folder.`nThe script should be located:`n``" A_ScriptDir "\v2.x.x\My Scripts.ahk``", "Error", 48)
        return
    }

;localVer // v2.8
if FileExist("..\Icons\myscript.png")
    TraySetIcon("..\Icons\myscript.png")
;defining the informational gui
ReplacerGui := Gui("-Resize +MinSize500x380 -MaximizeBox", "Tomshi Hotkey Replacer for " forRelease)
ReplacerGui.SetFont("S11.5")
;nofocus
ReplacerGui.AddButton("Default X0 Y0 w0 h0", "_")

;title and text
titletext := "Welcome to Hotkey Replacer for " forRelease
titleWidth := 362 + ((StrLen(forRelease)-4)*8)
title := ReplacerGui.Add("Text", "X105 Y8 W" titleWidth " Center R1.5", titletext)
;logoImg := ReplacerGui.Add("Picture", "X246 Y+10", A_ScriptDir "\" forRelease "\Support Files\Icons\myscript.png")
title.SetFont("S15 Bold")
text := ReplacerGui.Add("Text", "X30 W530 Y+5 Center", "This script is only designed to be used if you already have a version of my scripts in use. If you don't, feel free to exit out of this script.`n`nThis script is designed to replace all of the hotkeys in the release version of ``My Scripts.ahk`` with the hotkeys you have in your own local copy.`n`nThis script works by detecting the ``;xHotkey;`` tag I have above every hotkey and doing some string replacement to replace the release version with any you've changed locally.`n`nPlease be aware that any hotkeys you've added yourself will not be transfered over and there may still be some manual adjustment needed in that case.")

;progress bar
prog := ReplacerGui.Add("Progress", "X18 Y+20 w400 h20 cblue Smooth vMyProgress")
prog.Opt("BackgroundSilver")

;status bar
SB := ReplacerGui.Add("StatusBar")
SB.SetFont("S10")
SB.SetText("  " forRelease)

;buttons
replaceButton := ReplacerGui.Add("Button", "X+10 Y+-30", "replace")
replaceButton.OnEvent("Click", replace)
cancelButton := ReplacerGui.Add("Button", "X+10", "cancel")
cancelButton.OnEvent("Click", cancel)

if FileExist(ptf.SettingsLoc "\settings.ini") ;the user has run my scripts before and a settings menu exists
    {
        if IniRead(ptf.SettingsLoc "\settings.ini", "Settings", "dark mode") = "true" ;then we check if the user wants dark mode
            goDark()
    }
else
    goDark() ;otherwise we just default to it so it's in line with the rest of my scripts

;show gui
ReplacerGui.Show("Center")
ReplacerGui.GetClientPos(,, &guiwidth, &height)
title.GetPos(,, &width)
title.Move((guiWidth-width)/2)


; ==============================================================================
; Functions
;

;the function that will go through and replace the release hotkeys with the users hotkeys
replace(*)
{
    ;get the users local path
    getUserFile := FileSelect("D" 2,, "Select your current in-use script path")
    if getUserFile = ""
        return
    getUserFile2 := getUserFile ;for the ini loop

    ;find My Scripts.ahk
    loop files getUserFile "\*.ahk", "F"
        {
            SB.SetText("  locating ``My Scripts.ahk`` in the user directory")
            if A_LoopFileName = "My Scripts.ahk"
                getUserFile := A_LoopFileFullPath
            else
                continue
        }
    ;find ksa.ini
    loop files getUserFile2 "\lib\KSA\*.ini", "F"
        {
            SB.SetText("  locating ``Keyboard Shortcuts.ini`` in the user directory")
            if A_LoopFileName = "Keyboard Shortcuts.ini"
                getUserIniFile := A_LoopFileFullPath
            else
                continue
        }
    ;attempt to read My Scripts.ahk
    try {
        checkstring := FileRead(getUserFile)
    } catch as e {
        ReplacerGui["MyProgress"].Value := 100
        prog.Opt("cRed")
        SB.SetText("  ⚠️ error")
        MsgBox("No ``My Scripts.ahk`` file found in the user folder.`nPlease ensure you haven't renamed the script", "Error", 48)
        ReplacerGui.Destroy()
        return
    }
    ;attempt to read ksa.ini
    try {
        checkstring2 := FileRead(getUserIniFile)
    } catch as e {
        ReplacerGui["MyProgress"].Value := 100
        prog.Opt("cRed")
        SB.SetText("  ⚠️ error")
        MsgBox("No ``Keyboard Shortcuts.ini`` file found in the user folder.`nPlease ensure you haven't renamed the script", "Error", 48)
        ReplacerGui.Destroy()
        return
    }
    ;check for release version of My Scripts.ahk
    if FileExist("..\..\My Scripts.ahk")
        releaseFile := FileRead("..\..\My Scripts.ahk")
    else
        {
            ReplacerGui["MyProgress"].Value := 100
            prog.Opt("cRed")
            SB.SetText("  ⚠️ error")
            MsgBox("Couldn't find the release version of ``My Scripts.ahk``", "Error", 48)
            ReplacerGui.Destroy()
            return
        }
    ;check for release version of ksa.ini
    if FileExist("..\..\lib\KSA\Keyboard Shortcuts.ini")
        releaseIniFile := FileRead("..\..\lib\KSA\Keyboard Shortcuts.ini")
    else
        {
            ReplacerGui["MyProgress"].Value := 100
            prog.Opt("cRed")
            SB.SetText("  ⚠️ error")
            MsgBox("Couldn't find the release version of ``Keyboard Shortcuts.ini``", "Error", 48)
            ReplacerGui.Destroy()
            return
        }
    SB.SetText("  creating backup")
    ;create backup
    if DirExist("..\..\Backups") && !FileExist("..\..\Backups\My Scripts.ahk")
        FileCopy("..\..\My Scripts.ahk", "..\..\Backups")
    ;delete any ini files that were generated by hotkeyreplacer (this is incase the user runs the script again)
    if FileExist(A_ScriptDir "\hotkeys.ini")
        FileDelete(A_ScriptDir "\hotkeys.ini")
    if FileExist(A_ScriptDir "\hotkeynames.ini")
        FileDelete(A_ScriptDir "\hotkeynames.ini")

    SB.SetText("  creating baseline ini files")
    ;create baseline ini files
    if !FileExist(A_ScriptDir "\hotkeys.ini")
        FileAppend("[Hotkeys]", A_ScriptDir "\hotkeys.ini")
    if !FileExist(A_ScriptDir "\hotkeynames.ini")
        FileAppend("[Hotkey Names]", A_ScriptDir "\hotkeynames.ini")

    SB.SetText("  creating temp folders")
    ;create temp folder
    if !DirExist(A_Temp "\tomshi")
        DirCreate(A_Temp "\tomshi")
    if FileExist(A_Temp "\tomshi\My Scripts.ahk")
        FileDelete(A_Temp "\tomshi\My Scripts.ahk")
    SB.SetText("  creating baseline file")
    ;create baseline file
    FileAppend(releaseFile, A_Temp "\tomshi\My Scripts.ahk")

    hotkeyNum := 0 ;counting how many hotkey values there so we can update the progress bar
    ;generate user hotkeys into an ini file
    loop {
        location := InStr(checkstring, "Hotkey;", 1,, A_Index) ;getting the location of the hotkey tag
        if location = 0 ;if none is found, break the loop
            break
        SB.SetText("  generating user hotkeys: " A_Index)
        endHotkey := InStr(checkstring, "::", 1, location, 1) ;finding the end of the hotkey directly below the tag
        hotkeyKey := SubStr(checkstring, location + 9, endHotkey - location - 9) ;creating a substring of just the hotkey

        hotkeyNum += 1

        nameLocation := InStr(checkstring, ";", 1, location, -1) ;getting the beginning location of the hotkey tag
        hotkeyName := SubStr(checkstring, nameLocation + 1, location - nameLocation - 1) ;getting the name of the hotkey tag
        IniWrite(hotkeyKey, A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index) ;writing the hotkey itself to an ini file
        IniWrite(hotkeyName, A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index) ;writing the hotkey tag name to an ini file
    }

    iterateHotkeyNum := Ceil(50/hotkeyNum)
    ;use the ini file to replace hotkeys
    if FileExist(A_ScriptDir "\hotkeys.ini") && FileExist(A_ScriptDir "\hotkeynames.ini")
        {
            loop {
                try {
                    getHotkeys := IniRead(A_ScriptDir "\hotkeys.ini", "Hotkeys", A_Index) ;reading the hotkey
                    getHotkeyName := IniRead(A_ScriptDir "\hotkeynames.ini", "Hotkey Names", A_Index) ;reading the hotkey tag name
                    ;MsgBox(getHotkeys A_Space getHotkeyName)
                } catch as e
                    break ;when the script is done replacing hotkeys this line will break the loop
                if !InStr(releaseFile, getHotkeyName "Hotkey;", 1,, 1)
                    continue ;if the release version removes a hotkey, this line will make the loop skip it
                try {
                    getHotkeyPos := InStr(releaseFile, getHotkeyName "Hotkey;", 1,, 1) ;from here down we're basically doing the same as the first loop but for the realease version of `My Scripts.ahk` so we can replace it with the user hotkey instead
                    if getHotkeyPos = 0
                        break
                    SB.SetText("  replacing user hotkeys: " A_Index)

                    ReplacerGui["MyProgress"].Value += iterateHotkeyNum ;updating the progress bar

                    endPos := InStr(releaseFile, ";", 1, getHotkeyPos, 1)
                    length := InStr(releaseFile, ":", 1, endPos, 1)
                    replace := SubStr(releaseFile, endPos + 2, length - endpos - 2)
                    ;MsgBox(replace)
                    ;MsgBox(getHotkeys A_Space getHotkeyName A_Space replace)
                    newScript := StrReplace(releaseFile, ";" getHotkeyName "Hotkey;`r" replace, ";" getHotkeyName "Hotkey;`r" getHotkeys, 1,, 1) ;this line is replacing the release hotkey with the user hotkey
                    if FileExist(A_Temp "\tomshi\My Scripts.ahk")
                        FileDelete(A_Temp "\tomshi\My Scripts.ahk")
                    FileAppend(newScript, A_Temp "\tomshi\My Scripts.ahk") ;this line is creating a temporary versino of our new hotkey replaced script in a temp folder
                    releaseFile := FileRead(A_Temp "\tomshi\My Scripts.ahk")
                } catch as e {
                    SB.SetText("  ⚠️ error")
                    MsgBox("Something went wrong trying to build a new script", "Oops")
                }
            }
            SB.SetText("  moving generated ``My Scripts.ahk`` file")
            FileMove(A_Temp "\tomshi\My Scripts.ahk", "..\..\My Scripts.ahk", 1) ;once the script is done it replaces the release script with the temp versio we created
            ;MsgBox("The attempt to replace hotkeys in ``My Scripts`` has completed.`nA backup of the original script is in the ``\Backups`` folder in case something went wrong") ;and alert the user the process is complete
        }

    ;generate user KSA values into an ini file
    if !FileExist(getUserIniFile)
        {
            SB.SetText("  ⚠️ error")
            MsgBox("Couldn't find the release version of ``Keyboard Shortcuts.ini``", "Error", 48)
            ReplacerGui.Destroy()
            return
        }
    try {
        checkstring := FileRead(getUserIniFile)
    } catch as e {
        SB.SetText("  ⚠️ error")
        MsgBox("No ``Keyboard Shortcuts.ini`` file found in the user folder.`nPlease ensure you haven't renamed the file", "Error", 48)
        ReplacerGui.Destroy()
        return
    }

    SB.SetText("  creating backup")
    ;create backup
    if DirExist("..\..\Backups") && !FileExist("..\..\Backups\Keyboard Shortcuts.ini")
        FileCopy("..\..\lib\KSA\Keyboard Shortcuts.ini", "..\..\Backups")

    ;delete any ini files that were generated by hotkeyreplacer (this is incase the user runs the script again)
    if FileExist(A_ScriptDir "\ksahotkeys.ini")
        FileDelete(A_ScriptDir "\ksahotkeys.ini")
    if FileExist(A_ScriptDir "\ksahotkeynames.ini")
        FileDelete(A_ScriptDir "\ksahotkeynames.ini")

    SB.SetText("  creating baseline ini files")
    ;create baseline ini files
    if !FileExist(A_ScriptDir "\ksahotkeys.ini")
        FileAppend("[ksa Hotkeys]", A_ScriptDir "\ksahotkeys.ini")
    if !FileExist(A_ScriptDir "\ksahotkeynames.ini")
        FileAppend("[ksa Hotkey Names]", A_ScriptDir "\ksahotkeynames.ini")

    SB.SetText("  checking temp folders")
    ;create temp folder
    if !DirExist(A_Temp "\tomshi")
        DirCreate(A_Temp "\tomshi")
    if FileExist(A_Temp "\tomshi\Keyboard Shortcuts.ini")
        FileDelete(A_Temp "\tomshi\Keyboard Shortcuts.ini")
    SB.SetText("  creating baseline file")
    ;create baseline file
    FileAppend(releaseIniFile, A_Temp "\tomshi\Keyboard Shortcuts.ini")

    ksaNum := 0 ;counting how many ksa values there so we can update the progress bar
    ;generate user ksa hotkeys
    loop {
        location := InStr(checkstring, "=", 1,, A_Index) ;getting the location of the = sign
        if location = 0 ;if none is found, break the loop
            break
        SB.SetText("  generating user ksa hotkeys: " A_Index)
        endHotkey := InStr(checkstring, '"', 1, location, 2) ;finding the end of the hotkey using the quote marks
        hotkeyKey := SubStr(checkstring, location + 1, endHotkey + 1 - location - 1)

        ksaNum += 1

        nameLocation := InStr(checkstring, "]", 1, location, -1)
        hotkeyName := SubStr(checkstring, nameLocation + 3, location - nameLocation - 3)
        IniWrite(hotkeyKey, A_ScriptDir "\ksahotkeys.ini", "ksa Hotkeys", A_Index) ;writing the hotkey itself to an ini file
        IniWrite(hotkeyName, A_ScriptDir "\ksahotkeynames.ini", "ksa Hotkey Names", A_Index) ;writing the hotkey tag name to an ini file
        /* MsgBox(hotkeyName)
        if A_index > 5
            return */
    }

    iterateksaNum := Ceil(50/ksaNum)
    ;use ini file to replace ksa hotkeys
    if FileExist(A_ScriptDir "\ksahotkeys.ini") && FileExist(A_ScriptDir "\ksahotkeynames.ini")
        {
            loop {
                try {
                    getHotkeys := IniRead(A_ScriptDir "\ksahotkeys.ini", "ksa Hotkeys", A_Index) ;reading the hotkey
                    getHotkeyName := IniRead(A_ScriptDir "\ksahotkeynames.ini", "ksa Hotkey Names", A_Index) ;reading the hotkey tag name
                    ;MsgBox(getHotkeys A_Space getHotkeyName)
                } catch as e
                    break ;when the script is done replacing hotkeys this line will break the loop

                if !InStr(releaseIniFile, getHotkeyName "=", 1,, 1)
                    continue
                try {
                    gethotkeyPos := InStr(releaseIniFile, getHotkeyName "=", 1,, 1)
                    if getHotkeyPos = 0
                        break
                    SB.SetText("  replacing user ksa hotkeys: " A_Index)

                    ReplacerGui["MyProgress"].Value += iterateksaNum ;updating the progress bar

                    endPos := InStr(releaseIniFile, "=", 1, getHotkeyPos, 1)
                    length := InStr(releaseIniFile, '"', 1, endPos, 2)
                    replace := SubStr(releaseIniFile, endPos + 1, (length + 1) - (endPos + 1))
                    /* MsgBox(replace)
                    if A_index > 5
                        return */
                    newIni := StrReplace(releaseIniFile, getHotkeyName "=" replace, getHotkeyName "=" '"' getHotkeys '"', 1,, 1)
                    if FileExist(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                        FileDelete(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                    FileAppend(newIni, A_Temp "\tomshi\Keyboard Shortcuts.ini") ;this line is creating a temporary versino of our new hotkey replaced script in a temp folder
                    releaseIniFile := FileRead(A_Temp "\tomshi\Keyboard Shortcuts.ini")
                } catch as e {
                    SB.SetText("  ⚠️ error")
                    MsgBox("Something went wrong trying to build a .ini file", "Oops")
                }
            }
        }
        SB.SetText("  moving generated ``Keyboard Shortcuts.ini`` file")
    FileMove(A_Temp "\tomshi\Keyboard Shortcuts.ini", "..\..\lib\KSA\Keyboard Shortcuts.ini", 1)

    SB.SetText("  complete ✔️")

    MsgBox("The attempt to replace hotkeys in ``My Scripts`` & ``Keyboard Shortcuts.ini`` has completed.`nA backup of the original script/.ini file is in the ``\Backups`` folder in case something went wrong") ;and alert the user the process is complete
    ReplacerGui.Destroy() ;we then close the gui window
}

cancel(*) => ReplacerGui.Destroy()

goDark(darkmode := true, DarkorLight := "Dark")
{
        dark.titleBar(ReplacerGui.Hwnd, darkmode)
        dark.button(replaceButton.Hwnd, DarkorLight)
        dark.button(cancelButton.Hwnd, DarkorLight)
}

;// the below function can't get "included" because the main version requires <Classes/ptf> and that'll cause a whole slew of issues for users that haven't generated a symlink yet
/**
 * This function retrieves the local version (or the string after a specified tag) and then returns it.
 *
 * This script will trim whitespace, tabs, newlines & carriage return
 * @param {any} varRead If this variable is populated, it will read from that string instead of filereading a new variable.
 * @param {string} script is the name of the script you wish to read (if in the root dir, otherwise the remaining filepath to it)
 * @param {string} searchTag is what you want the function to search for
 * @param {string} endField is what you want "InStr" to search for to be the end of your string
 * @returns {string}
 */
 getLocalVer(varRead?, script := "My Scripts.ahk", searchTag := "@version", endField := "*") {
    if IsSet(varRead)
        read := varRead
    else
        read := FileRead("..\..\" script)
    ver := Trim(
        SubStr(read
              , verFind := InStr(read, searchTag,, 1, 1) + (StrLen(searchTag)+1)
              , InStr(read, endField,, verFind, 1)-verFind
            )
        , " `t`n`r"
    )
    return ver
}