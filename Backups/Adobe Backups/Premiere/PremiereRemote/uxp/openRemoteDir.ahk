;// opens the directory for the PremiereRemote extension
dir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\uxp"
if !DirExist(dir)
    return
Run(dir)