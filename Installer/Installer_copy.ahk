#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from

;script version
;v2.3.1.2a4
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

doublecheck := MsgBox("If you have added any ';xHotkey; tags yourself this installer might fail or cause issues`nIf I have removed any hotkeys in any release, this installer may fail, you may notice your own hotkeys for that code no longer get copied over, or get copied to the wrong places. Make sure to double check the resulting file before use`n`nPress cancel if you do not wish to continue", "Info", "1 64 4096")
if doublecheck = "Cancel"
    return
;dealing with directories we'll need
if not DirExist(A_Temp "\tomshi")
    DirCreate(A_Temp "\tomshi")
if FileExist(A_Temp "\tomshi\hotkeyrelease.ini")
    FileDelete(A_Temp "\tomshi\hotkeyrelease.ini")
if FileExist(A_Temp "\tomshi\hotkeyuser.ini")
    FileDelete(A_Temp "\tomshi\hotkeyuser.ini")
if FileExist(A_Temp "\tomshi\hotkeyrelease_name.ini")
    FileDelete(A_Temp "\tomshi\hotkeyrelease_name.ini")
if FileExist(A_Temp "\tomshi\hotkeyrelease_name_user.ini")
    FileDelete(A_Temp "\tomshi\hotkeyrelease_name_user.ini")
;create baseline file
FileAppend(replace_release, A_Temp "\tomshi\My Scripts.ahk")
;keys counts how many links are found
keys := 0
loop {
    ;FINDING HOTKEYS IN RELEASE FILE
    findHotkey := InStr(replace_release, "Hotkey;",,, A_Index)
    if findHotkey = 0
        goto user
    hotkeynamestart := InStr(replace_release, ";",, findHotkey, -1)
    hotkeyname := SubStr(replace_release, hotkeynamestart + 1, findHotkey - hotkeynamestart - 1)
    nameini := IniWrite(hotkeyname, A_Temp "\tomshi\hotkeyrelease_name.ini", "hotkeys", A_Index)
    Hotkey_begin := findHotkey + 9
    findHotkey_end := InStr(replace_release, ":",, findHotkey, 2)
    hotkey_end := findHotkey_end + 1
    Hotkey_length := hotkey_end - hotkeynamestart - 1
    hotkey_sub := SubStr(replace_release, hotkeynamestart - 1, Hotkey_length)
    valuehotkey := IniWrite(hotkey_sub, A_Temp "\tomshi\hotkeyrelease.ini", "hotkeys", A_Index)
    
    ;FINDING HOTKEYS IN USER FILE
    user:
    findHotkey2 := InStr(myscripts_string, "Hotkey;",,, A_Index)
    keys += 1
    if findHotkey2 = 0
        break
    hotkeynamestart2 := InStr(myscripts_string, ";",, findHotkey2, -1)
    hotkeyname2 := SubStr(myscripts_string, hotkeynamestart2 + 1, findHotkey2 - hotkeynamestart2 - 1)
    nameini2 := IniWrite(hotkeyname2, A_Temp "\tomshi\hotkeyrelease_name_user.ini", "hotkeys", A_Index)
    Hotkey_begin2 := findHotkey2 + 9
    findHotkey2_end := InStr(myscripts_string, ":",, findHotkey2, 2)
    hotkey_end2 := findHotkey2_end + 1
    Hotkey_length2 := hotkey_end2 - hotkeynamestart2 - 1
    hotkey_sub2 := SubStr(myscripts_string, hotkeynamestart2 - 1, Hotkey_length2)
    valuehotkey2 := IniWrite(hotkey_sub2, A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
    
    ;MsgBox("begin " Hotkey_begin "`nend " hotkey_end "`nlength " Hotkey_length "`nstring ." hotkey_sub "." "`nuser string ." hotkey_sub2 ".") ;debugging
}
loop keys {
    try {
        start:
        loopattempt := A_Index
        name_release := IniRead(A_Temp "\tomshi\hotkeyrelease_name.ini", "hotkeys", A_Index)
        name_user := IniRead(A_Temp "\tomshi\hotkeyrelease_name_user.ini", "hotkeys", A_Index)
        read := FileRead(A_Temp "\tomshi\My Scripts.ahk")
        refhotkey := IniRead(A_Temp "\tomshi\hotkeyrelease.ini", "hotkeys", A_Index)
        replacehotkey := IniRead(A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
        if name_user = name_release
            goto attempt
        else
            {
                IniDelete(A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
                IniDelete(A_Temp "\tomshi\hotkeyuser.ini", "hotkeys", A_Index)
                goto start
            }
            
        attempt:
        attempt := StrReplace(read, refhotkey, replacehotkey, 1,, 1)
        ;MsgBox("name_release ." name_release ".`nname_user ." name_user ".`nrelease hotkey ." refhotkey ".`nuser hotkey ." replacehotkey ".")
        ;;;something needds to be done here in the case of a mismatch
    } catch as e {
        ToolTip("a replace encountered a mismatch due to the user file, errors may occur")
        SetTimer(remove, -2000)
        remove() {
            ToolTip("")
        }
    }
    try {
        if FileExist(A_Temp "\tomshi\My Scripts.ahk")
            FileDelete(A_Temp "\tomshi\My Scripts.ahk")
        FileAppend(attempt, A_Temp "\tomshi\My Scripts.ahk")
    } catch as f {
        ToolTip("an append failed")
        SetTimer(remove2, -1000)
        remove2() {
            ToolTip("")
        }
    }
    
}
if FileExist(A_WorkingDir "\" Release "\My Scripts.ahk")
    FileDelete(A_WorkingDir "\" Release "\My Scripts.ahk")
if FileExist(A_Temp "\tomshi\My Scripts.ahk")
    FileMove(A_Temp "\tomshi\My Scripts.ahk", A_WorkingDir "\" Release "\My Scripts.ahk")
if FileExist(A_Temp "\tomshi\hotkeyrelease.ini")
    FileMove(A_Temp "\tomshi\hotkeyrelease.ini", A_WorkingDir "\hotkeyrelease.ini", 1)
if FileExist(A_Temp "\tomshi\hotkeyuser.ini")
    FileMove(A_Temp "\tomshi\hotkeyuser.ini", A_WorkingDir "\hotkeyuser.ini", 1)
