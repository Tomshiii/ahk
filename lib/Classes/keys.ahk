/************************************************************************
 * @description a class to contain often used functions relating to keys
 * @file key.ahk
 * @author tomshi
 * @date 2023/02/15
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Functions\getHotkeys>
#Include <Functions\errorLog>
; }

class keys {
    /**
     * This function loops through as many possible SC and vk keys and sends the {Up} keystroke for it.
     * Originally from: 東方永夜抄#4008 in the ahk discord
     * this link may die: https://discord.com/channels/115993023636176902/1057690143231840347/1057704109408522240
     */
    static allUp() {
        loop 128 {
            which := Format("sc{:x}", A_Index)
            Send("{Blind}{" which " Up}") ;// send Up keystroke
            Send("{Blind}{Esc}") ;// try to mitigate any damage from an UP keystroke doing something
            ToolTip("Sending " GetKeyName(which) " Up")
        }
        loop 256 {
            which := Format("vk{:x}", A_Index)
            Send("{Blind}{" which " Up}") ;// send Up keystroke
            Send("{Blind}{Esc}") ;// try to mitigate any damage from an UP keystroke doing something
            ToolTip("Sending " GetKeyName(which) " Up")
        }
        tool.Cust("Sending {Up} commands complete")
    }

    /**
     * This function is designed to remove the hassle that can sometimes occur by using `KeyWait`. If a function is launched via something like a streamdeck `A_ThisHotkey` will be blank, if you design a function to only be activated with one button but then another user tries to launch it from two an error will be thrown. This function will automatically determine what's required and stop errors occuring
     * @param {String} which determines which hotkey should be waited for in the event that the user tries to activate with two hotkeys
     * @returns {Object} this function can return the two hotkeys as an object the same way that `getHotkeys()` would
     * ```
     * RAlt & p::
     * {
     *    hotkeys := getHotkeys()
     *    MsgBox(hotkeys.first)  ; returns "RAlt"
     *    MsgBox(hotkeys.second) ; returns "p"
     * }
     *
     * !p::
     * {
     *    getHotkeys(&first, &second)
     *    MsgBox(first)  ; returns "vk12"
     *    MsgBox(second) ; returns "p"
     * }
     * ```
     */
    static allWait(which := "both") {
        if Type(which) != "string" {
            ;// throw
            errorLog(TypeError("Incorrect Type in Parameter #1", -1, which),,, 1)
        }
        if (which != "both" && which != "first" && which != "second") {
            ;// throw
            errorLog(ValueError("Incorrect Value in Parameter #1", -1, which),,, 1)
        }
        if (A_ThisHotkey != "" && !InStr(A_ThisHotkey, "&")) && StrLen(A_ThisHotkey) != 2
            KeyWait(A_ThisHotkey)
        else if A_ThisHotkey != ""
            {
                keys := getHotkeys()
                switch which {
                    case "first":  KeyWait(keys.first)
                    case "second": KeyWait(keys.second)
                    default:
                        KeyWait(keys.second)
                        KeyWait(keys.first)
                }
                return {first: keys.first, second: keys.second}
            }
    }

    /**
     * Check to see if the desired key is virtually stuck down
     * @param {String} key is the key you wish to check
     */
    static check(key) {
        if GetKeyState(key) && !GetKeyState(key, "P")
            {
                tool.Cust(key " was stuck")
                SendInput("{" key " Up}")
            }
    }
}