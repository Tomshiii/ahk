; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Other\Notify\Notify.ahk
; }

/** syntatic sugar for only using `Notify.Show()` if the tag doesn't already exist. Do NOT respecify the `tag` in `options`. Notify's will be logged using `Log()`. If no `show`/`hide` option is present in `options` `show=Fade@250 hide=Fade@250` will be added
*/
notifyIfNotExist(tag, title := '', msg := '', image := '', sound := '', callback := '', options := '') {
    if InStr(options, "tag=") {
        ;// throw
        errorLog(PropertyError("The user has redefined ``tag`` in ``options``", -1),,, true)
        return
    }
    try {
        Critical()
        logger := Log()
        logMsg := (InStr(msg, "`n")) ? '`n`t`t`t`t"' StrReplace(msg, "`n", "`n`t`t`t`t") '"' : '"' msg '"'
        (title != '') ? logger.Append(Format('Notify produced the following -`n`t`t`t// Title: "{1}"`n`t`t`t// Message: {2}`n`t`t`t// tag: "{3}"', title, logMsg, tag))
                      : logger.Append(Format('Notify produced the following -`n`t`t`t// Message: {1}`n`t`t`t// tag: "{2}"', logMsg, tag))
        Critical("Off")
    }
    options := (!InStr(options, " show=")) ? options A_Space "show=Fade@250" : options
    options := (!InStr(options, " hide=")) ? options A_Space "hide=Fade@250" : options
    if !Notify.Exist(tag)
        return Notify.Show(title, msg, image, sound, callback, options . " tag=" tag)
}