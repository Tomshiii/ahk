/************************************************************************
 * @description
 * @author tomshi
 * @date 2026/11/12
 * @version 1.1.0
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
     * Syntatic sugar for only using `Notify.Show()` if the tag doesn't already exist. Do NOT respecify the `tag` in `options`. A command is sent to `Core Functionality.ahk` to process all `Notify` GUIs there so scripts that exit early do not leave a crashed GUI behind.
     * @param [options] Defaults if not passed; `show=Fade@250 hide=Fade@250 dga=1`
     * @returns {void}
    */
    static showIfNotExist(tag, title := '', msg := '', image := '', sound := '', callback := '', options := '', doWinWait := false) {
        if InStr(options, "tag=") {
            ;// throw
            errorLog(PropertyError("The user has redefined ``tag`` in ``options``", -1),,, true)
            return
        }
        options := "show=Fade@250 hide=Fade@250 dga=1 " options
        proccessed := WM.Send_WM_COPYDATA("NotifyNotExist," tag "|||" title "|||" msg "|||" image "|||" sound "|||" callback "|||" options, "Core Functionality.ahk")
        if doWinWait = true && proccessed
            WinWait("_" tag,, 1)
        return
    }

    /**
     * Destroys duplicate `Notify` GUIs if they exist. Command is executed instantly and locally.
     * @param {String} [tag] to `Notify` GUI tag to check
     * @param {Boolean} [force=false] passes `force` to `Notify.Destroy()`
     * @returns {void}
     */
    static destroyDupes(tag, force := false) {
        if !chck := this.checkMultiple(tag)
            return
        for _, v in chck {
            if A_Index = chck.Length
                break
            try Notify.Destroy(v, force)
        }
    }

    /**
     * Determines if multiple `Notify` GUIs exist.
     * @param {String} [tag] to `Notify` GUI tag to check
     * @returns {void}
     */
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

    /**
     * Deletes the requested `Notify` GUI if it exists. A command is sent to `Core Functionality.ahk` to process deletion of all `Notify` GUIs for the specified tag.
     * @param {String} [tag] to `Notify` GUI tag to check
     * @param {Boolean} [force=false] passes `force` to `Notify.Destroy()`
     * @returns {void}
     */
    static deleteIfExist(tag, force := false, minTime := 1500) => (WM.Send_WM_COPYDATA("NotifyDeleteIfExist," tag "," force "," minTime, "Core Functionality.ahk"))

}