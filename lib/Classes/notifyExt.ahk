/************************************************************************
 * @description
 * @author tomshi
 * @date 2026/04/17
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Classes\wm.ahk
#Include Functions\detect.ahk
#Include Other\Notify\Notify.ahk
; }

class notifyExt {

    /**
     * syntatic sugar for only using `Notify.Show()` if the tag doesn't already exist. Do NOT respecify the `tag` in `options`. Notify's will be logged using `Log()`.
     * If no `show`/`hide` option is present in `options` `show=Fade@250 hide=Fade@250` will be added
    */
    static notifyIfNotExist(tag, title := '', msg := '', image := '', sound := '', callback := '', options := '', doWinWait := false) {
        if InStr(options, "tag=") {
            ;// throw
            errorLog(PropertyError("The user has redefined ``tag`` in ``options``", -1),,, true)
            return
        }
        options := (!InStr(options, " show=")) ? options A_Space "show=Fade@250" : options
        options := (!InStr(options, " hide=")) ? options A_Space "hide=Fade@250" : options
        proccessed := WM.Send_WM_COPYDATA("NotifyNotExist," tag "|||" title "|||" msg "|||" image "|||" sound "|||" callback "|||" options, "Core Functionality.ahk")
        if doWinWait = true && proccessed
            WinWait("_" tag,, 1)
        return
    }

    static destroyDupes(tag) {
        if !chck := this.checkMultiple(tag)
            return
        for _, v in chck {
            if A_Index = chck.Length
                break
            try Notify.Destroy(v)
        }
    }

    static checkMultiple(tag) {
        Critical('On')
        orig := detect(0, 'RegEx')
        list := WinGetList('i)^NotifyGUI_[0-1]_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_\d{17}_\Q' tag '\E$ ahk_class AutoHotkeyGUI')
        hwndArr := []
        for id in list {
            hwndArr.Push(id)
        }

        resetOrigDetect(orig)
        Critical('Off')
        return (hwndArr.Length > 0 ? hwndArr : false)
    }
}