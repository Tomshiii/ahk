SetWorkingDir(A_ScriptDir)

if !DirExist(A_MyDocuments "\AutoHotkey")
    DirCreate(A_MyDocuments "\AutoHotkey")
if DirExist(A_MyDocuments "\AutoHotkey\Lib")
    DirDelete(A_MyDocuments "\AutoHotkey\Lib")

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
    ExitApp
}

path := '"' A_ScriptDir "\..\..\Lib" '"'

cmdLine := 'mklink /D "' A_MyDocuments '\AutoHotkey\Lib" ' path '"'
;final command should look like;
; mklink /D "mydocumentspathhere\AutoHotkey\Lib" "rootrepopath\lib"
Run('*RunAs ' A_ComSpec)
WinWaitActive("ahk_exe cmd.exe")
sleep 1000
SendInput(cmdLine)
SendInput("{Enter}")
sleep 500
WinClose("ahk_exe cmd.exe")