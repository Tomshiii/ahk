; { \\ #Includes
#Include <Classes\ptf>
; }

editScript(script, overrideEditor?) {
    editor := SubStr(origReg := RegRead("HKCR\AutoHotkeyScript\Shell\Edit\Command"), 1, InStr(origReg, A_space '"%l"',, 1, 1))
    if editor = "" {
        if !FileExist(A_ProgramFiles "\AutoHotkey\UX\ui-editor.ahk") {
            ;// throw
            errorLog(TargetError("Could not determine an editor nor find the AHK editor script", -1),,, true)
            return
        }
        Run(A_ProgramFiles "\AutoHotkey\UX\ui-editor.ahk")
        return
    }
    if InStr(editor, "Microsoft VS Code\Code.exe",, 1, 1) && !WinExist("ahk_exe Code.exe") {
        Run(editor)
        ToolTip("waiting for vscode to open")
        WinWait("ahk_exe Code.exe")
        ToolTip("")
        sleep 1000
        Run(editor A_Space Format('"{}"', script))
        return
    }
    Run(editor A_Space Format('"{}"', script))
    return
}