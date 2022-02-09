#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from

;script version
;v2.3.1.2a3
;This file must be in the same directory as the folder v{Release} that you downloaded from github. 

global Release := "v2.3.1.1"

;\\begin script to find users myscript hotkeys
;select users version of my scripts.ahk file
MsgBox("First you need to select your own local version of`n[My Scripts.ahk]", "Info", "64 4096")
selectfile := FileSelect("1",, "Select your local version of 'My Scripts.ahk'", "*.ahk")
if selectfile = ""
    return
myscripts_string := FileRead(selectfile)

;checking to ensure the user script is above v2.3.1 - the minimum required
userversionvpos := InStr(myscripts_string, 'v',,,2)
userversionendpos := InStr(myscripts_string, '"', , userversionvpos, 1)
userversionstartpos := userversionvpos + 1
userversionend := userversionendpos - userversionstartpos
userversion := SubStr(myscripts_string, userversionstartpos, userversionend)
if VerCompare(userversion, "2.3.1") < 0
    {
        MsgBox("This installer will only function on a script higher than v2.3.1`nThe selected script is on v" userversion)
        return
    }

;defining the release version of the script
replace_release := FileRead(A_WorkingDir "\" Release "\My Scripts.ahk")
;below is gathering the users custom set hotkeys

doublecheck := MsgBox("If you have added any ';xHotkey; tags yourself this installer might fail`nPress cancel if you do not wish to continue", "Info", "1 64 4096")
if doublecheck = "Cancel"
    return
;dealing with directories we'll need
if not DirExist(A_Temp "\tomshi")
    DirCreate(A_Temp "\tomshi")
if FileExist(A_Temp "\tomshi\hotkeyrelease.ini")
    FileDelete(A_Temp "\tomshi\hotkeyrelease.ini")
if FileExist(A_Temp "\tomshi\hotkeyuser.ini")
    FileDelete(A_Temp "\tomshi\hotkeyuser.ini")
;create baseline changelog
FileAppend(replace_release, A_Temp "\tomshi\My Scripts.ahk")
;keys counts how many links are found
keys := 0
loop {
    ;FINDING HOTKEYS IN RELEASE FILE
    findHotkey := InStr(replace_release, "Hotkey;",,, A_Index)
    if findHotkey = 0
        break
    Hotkey_begin := findHotkey + 9
    findHotkey_end := InStr(replace_release, ":",, findHotkey, 2)
    hotkey_end := findHotkey_end - 1
    Hotkey_length := hotkey_end - Hotkey_begin
    hotkey_sub := SubStr(replace_release, Hotkey_begin, Hotkey_length)
    valuehotkey := IniWrite(hotkey_sub, A_Temp "\tomshi\hotkeyrelease.ini", "hotkeys", A_Index)
    ;FINDING HOTKEYS IN USER FILE
    findHotkey2 := InStr(myscripts_string, "Hotkey;",,, A_Index)
    if findHotkey2 = 0
        break
    Hotkey_begin2 := findHotkey2 + 9
    findHotkey2_end := InStr(myscripts_string, ":",, findHotkey2, 2)
    hotkey_end2 := findHotkey2_end - 1
    Hotkey_length2 := hotkey_end2 - Hotkey_begin2
    hotkey_sub2 := SubStr(myscripts_string, Hotkey_begin2, Hotkey_length2)
    valuehotkey2 := IniWrite(hotkey_sub2, A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
    ;MsgBox("begin " Hotkey_begin "`nend " hotkey_end "`nlength " Hotkey_length "`nstring ." hotkey_sub ".") ;debugging
    keys += 1
}
loop keys {
    read := FileRead(A_Temp "\tomshi\My Scripts.ahk")
    refhotkey := IniRead(A_Temp "\tomshi\hotkeyrelease.ini", "hotkeys", A_Index)
    replacehotkey := IniRead(A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
    attempt := StrReplace(read, refhotkey, replacehotkey, 1,, 1)
    if FileExist(A_Temp "\tomshi\My Scripts.ahk")
        FileDelete(A_Temp "\tomshi\My Scripts.ahk")
    FileAppend(attempt, A_Temp "\tomshi\My Scripts.ahk")
}
if FileExist(A_WorkingDir "\" Release "\My Scripts.ahk")
    FileDelete(A_WorkingDir "\" Release "\My Scripts.ahk")
if FileExist(A_Temp "\tomshi\My Scripts.ahk")
    FileMove(A_Temp "\tomshi\My Scripts.ahk", A_WorkingDir "\" Release "\My Scripts.ahk")
if FileExist(A_Temp "\tomshi\hotkeyrelease.ini")
    FileMove(A_Temp "\tomshi\hotkeyrelease.ini", A_WorkingDir "\hotkeyrelease.ini", 1)
if FileExist(A_Temp "\tomshi\hotkeyuser.ini")
    FileMove(A_Temp "\tomshi\hotkeyuser.ini", A_WorkingDir "\hotkeyuser.ini", 1)

