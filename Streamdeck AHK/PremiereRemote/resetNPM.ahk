; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ptf.ahk
; }

;// this script is just to rebuild the webserver for `PremiereRemote`/`AERemote` as
;// any time you change anything in the `index` file, you need to rebuild it
try keepWin := A_Args[1]
try Hide := A_Args[2]

dir     := A_AppData "\Adobe\CEP\extensions\AERemote\host\"
command := "npm run build"

if !DirExist(dir) {
    MsgBox("AERemote isn't installed in the default directory.")
    return
}

getResp := cmd.result(command, keepWin ?? false,, dir)
resp := RegExReplace(getResp, "^(?:.*\R){4}", "")
if !InStr(resp, "Build successful. Modifying index.jsx now.") {
    A_Clipboard := resp
    MsgBox("Build failed with the following error (also copied to clipboard):`n`n" resp)
    return
}
if !IsSet(Hide) {
    if WinExist(Editors.AE.winTitle) {
        MsgBox("The AERemote extension will need to be closed and reopened within After Effects",, "T2 262144")
    }
}