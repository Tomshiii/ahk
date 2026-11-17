; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\constants.ahk
#Include Other\print.ahk
; }
installedPath := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\client"
SplitPath(A_LineFile,, &linePath)
backupPath := linePath

try override := A_Args[1]
try ec := A_Args[2]
ec := IsSet(ec) && ec != 0 && ec != "0" ? ec : false

if !DirExist(installedPath) {
    if !(ec ?? 0) {
        MsgBox("PremiereRemote does not appear to be installed, the operation will abort.")
        return
    }
    ExitApp(CONST.ErrorCode.PREMIEREREMOTE_NOT_INSTALLED)
}

if !IsSet(override) || (override != false && override != "false") {
    if warning := MsgBox("This operation will override the currently installed files. Do you wish to continue?", "Are you sure?", "4 Icon! 0x1000") = "No"
        return
}

actionsDir := installedPath "\src\actions\ae"
if !DirExist(actionsDir)
    DirCreate(actionsDir)

loop files backupPath "\*.ts", "FR" {
    relDir := SubStr(A_LoopFileDir, StrLen(backupPath) + 2)
    destDir := relDir = "" ? actionsDir : actionsDir "\" relDir
    if !DirExist(destDir)
        DirCreate(destDir)
    FileCopy(A_LoopFileFullPath, destDir "\" A_LoopFileName, true)
}
ExitApp(CONST.ErrorCode.GENERIC_PASS)