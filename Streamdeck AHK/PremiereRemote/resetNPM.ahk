; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ptf.ahk
; }

;// this script is just to rebuild the webserver for `PremiereRemote` as
;// any time you change anything in the `index` file, you need to rebuild it
try keepWin := A_Args[1]
try Hide := A_Args[2]
try folder := A_Args[3]
dir     := A_AppData "\Adobe\CEP\extensions\" (IsSet(folder) ? folder : "PremiereRemote") "\host\"
command := "npm run build"
which := (IsSet(folder) && InStr(folder, "AE") ? "AERemote" : "PremiereRemote")
if !DirExist(dir) {
    MsgBox(command " isn't installed in the default directory.")
    return
}

cmd.run(, false, IsSet(keepWin) ? checkBool(keepWin) : true, command, dir, (IsSet(Hide) && hide != "false") ? "Hide" : "")
if !IsSet(Hide) {
    switch which {
        case "PremiereRemote":
            if WinExist(Editors.Premiere.winTitle) {
                MsgBox("The PremiereRemote extension will need to be closed and reopened within Premiere",, "T1.5")
            }
        case "AERemote":
            if WinExist(Editors.AE.winTitle) {
                MsgBox("The AERemote extension will need to be closed and reopened within After Effects",, "T1.5")
            }
    }
}