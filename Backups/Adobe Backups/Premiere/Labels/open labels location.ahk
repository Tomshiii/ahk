SetWorkingDir(A_ScriptDir)

Dir := A_MyDocuments "\Adobe\Common\Assets\Label Color Presets\"
if !DirExist(Dir) {
    MsgBox("It doesn't appear like the requested folder exists. You may not have exported any labels yet.", "Error attempting to run Adobe folder", 0x30)
    return
}
Run(Dir)