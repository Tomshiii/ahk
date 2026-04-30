; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ptf.ahk
; }

;// this script is just to rebuild the webserver for `PremiereRemote` as
;// any time you change anything in the `index` file, you need to rebuild it
try keepWin := A_Args[1]
try Hide := A_Args[2]
dir     := A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\"
command := "npm run build"

if !DirExist(dir) {
    MsgBox("PremiereRemote isn't installed in the default directory.")
    return
}

cmd.run(, false, IsSet(keepWin) ? keepWin : true, command, dir, IsSet(Hide) ? "Hide" : "")
if !IsSet(Hide) {
    if WinExist(Editors.Premiere.winTitle) {
        MsgBox("The PremiereRemote extension will need to be closed and reopened within Premiere",, "T1.5")
    }
}