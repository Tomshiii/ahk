; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
; }

editScript(script, overrideEditor?) {
    editor := SubStr(origReg := RegRead("HKCR\AutoHotkeyScript\Shell\Edit\Command"), 1, InStr(origReg, A_space '"%l"',, 1, 1))
    if InStr(editor, "Microsoft VS Code\Code.exe",, 1, 1) && !WinExist("ahk_exe Code.exe") {
        Run(editor)
        ToolTip("waiting for vscode to open")
        WinWait("ahk_exe Code.exe")
        ToolTip("")
        sleep 1000
        Run(editor A_Space script)
        return
    }
    Run(editor A_Space script)
    return
}