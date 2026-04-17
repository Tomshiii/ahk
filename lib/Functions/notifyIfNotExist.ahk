; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\CLSID_Objs.ahk
#Include Classes\errorLog.ahk
#Include Classes\WM.ahk
#Include Other\Notify\Notify.ahk
; }

/** syntatic sugar for only using `Notify.Show()` if the tag doesn't already exist. Do NOT respecify the `tag` in `options`. Notify's will be logged using `Log()`. If no `show`/`hide` option is present in `options` `show=Fade@250 hide=Fade@250` will be added
*/
notifyIfNotExist(tag, title := '', msg := '', image := '', sound := '', callback := '', options := '', doWinWait := false) {
    if InStr(options, "tag=") {
        ;// throw
        errorLog(PropertyError("The user has redefined ``tag`` in ``options``", -1),,, true)
        return
    }
    options := (!InStr(options, " show=")) ? options A_Space "show=Fade@250" : options
    options := (!InStr(options, " hide=")) ? options A_Space "hide=Fade@250" : options
    WM.Send_WM_COPYDATA("NotifyNotExist," tag "," title "," msg "," image "," sound "," callback "," options, "Core Functionality.ahk")
    if doWinWait = true
        WinWait("_" tag,, 1)
    return
}