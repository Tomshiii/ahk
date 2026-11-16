; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\constants.ahk
#Include Functions\getCCXVersion.ahk
; }

full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp()
}

loop {
    currentVer := getExtensionVersion(, true)
    try DirDelete(currentVer.dir "\de.sebinside.premiereremote_" currentVer.version, true)
    catch {
        ExitApp(CONST.ErrorCode.PREMIEREREMOTE_DELETE_STALE_DIRS_FAIL)
    }
} until (getExtensionVersion() = "")
ExitApp(CONST.ErrorCode.GENERIC_PASS)