;// opens the directory for the PremiereRemote extension
dir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\client"
if !DirExist(dir)
    return
Run(dir)