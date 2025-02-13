#Include <Classes\cmd>
#Include <Classes\reset>
#Include <Other\Notify\Notify>

;// this script is specifically designed to update THIS REPO'S git repo. It should also work for other users if they clone my repo

cmd.run(,,, "git fetch", ptf.rootDir, "Hide")
sleep 1000
getStatus := cmd.result("git status -uno",,, ptf.rootDir)
if InStr(getStatus, "Your branch is up to date") {
    Notify.Show(, 'Git branch is up to date. No update required', 'C:\Windows\System32\imageres.dll|icon176', 'Windows Battery Low',, 'bdr=lime')
    return
}
Notify.Show(, 'Git branch updating now... Please wait', 'C:\Windows\System32\imageres.dll|icon176', 'Windows Battery Low',, 'bdr=lime')

getLocalStatus := cmd.result("git status --short",,, ptf.rootDir)
switch getLocalStatus {
    case "": cmd.run(,,, "git pull", ptf.rootDir, "Hide")
    default:
        cmd.run(,,, "git stash", ptf.rootDir, "Hide")
        sleep 3000
        cmd.run(,,, "git pull", ptf.rootDir, "Hide")
        sleep 3000
        cmd.run(,,, "git stash pop", ptf.rootDir, "Hide")
}
Notify.Show(, 'Recent Github changes have been applied.`nA reload is recommended!', 'C:\Windows\System32\imageres.dll|icon176', 'Windows Battery Low',, 'bdr=Purple')
if MsgBox("Github changes have been applied.`nWould you like to reload all scripts now?", "Would you like to reload?", "4132") != "Yes"
    return
reset.ext_reload()