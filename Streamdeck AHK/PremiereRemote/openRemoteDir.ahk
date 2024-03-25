;// opens the directory for the PremiereRemote extension

dir := A_AppData "\Adobe\CEP\extensions\PremiereRemote"
if !DirExist(dir)
    return
Run(dir)