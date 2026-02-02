; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Other\Notify\Notify.ahk
; }

/** syntatic sugar for only using `Notify.Show()` if the tag doesn't already exist. Do NOT respecify the `tag` in `options` */
notifyIfNotExist(tag, title := '', msg := '', image := '', sound := '', callback := '', options := '') {
    if InStr(options, "tag=") {
        ;// throw
        errorLog(PropertyError("The user has redefined ``tag`` in ``options``", -1),,, true)
        return
    }
    if !Notify.Exist(tag)
        Notify.Show(title, msg, image, sound, callback, options . "tag=" tag)
}