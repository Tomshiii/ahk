;// opens the directory for the PremiereRemote extension
dir := A_AppData "\Adobe\UXP\Plugins\External\PremiereRemote-uxp\client"
if !DirExist(dir) && !DirExist(A_AppData "\Adobe\UXP\Plugins\External")
    return
if !DirExist(dir) && DirExist(A_AppData "\Adobe\UXP\Plugins\External") {
    Run(A_AppData "\Adobe\UXP\Plugins\External")
    return
}
Run(dir)