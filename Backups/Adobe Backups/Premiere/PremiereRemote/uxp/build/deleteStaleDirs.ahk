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

extensions := [
    ["PremiereRemote", "de.sebinside.premiereremote_"],
    ["AERemote",       "de.sebinside.aeremote_"]
]
for ext in extensions {
    while installed := getExtensionVersion(ext[1], true) {
        try DirDelete(installed.dir "\" ext[2] installed.version, true)
        catch
            ExitApp(CONST.ErrorCode.PREMIEREREMOTE_DELETE_STALE_DIRS_FAIL)
    }
}
ExitApp(CONST.ErrorCode.GENERIC_PASS)