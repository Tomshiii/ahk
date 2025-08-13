#Include <Classes\cmd>
#Include <Classes\ptf>

;// this script is just to rebuild the webserver for `PremiereRemote` as
;// any time you change anything in the `index` file, you need to rebuild it

dir     := A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\"
command := "npm run build"

if !DirExist(dir) {
    MsgBox("PremiereRemote isn't installed in the default directory.")
    return
}

cmd.run(,,1, command, dir)
if WinExist(Editors.Premiere.winTitle) {
    MsgBox("The PremiereRemote extension will need to be closed and reopened within Premiere")
}