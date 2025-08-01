/************************************************************************
 * @description a class to contain often used functions relating to keys
 * @file key.ahk
 * @author tomshi
 * @date 2025/07/31
 * @version 1.0.6
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\errorLog>
#Include <Functions\getHotkeys>
; }

class keys {

    static modifiers := Map(
        "#", 1,     "!", 1,
        "^", 1,     "+", 1,
        "&", 1,     "<", 1,
        ">", 1,     "*", 1,
        "~", 1,     "$", 1,
        "<!", 1,    "<^", 1, "<+", 1,
        ">!", 1,    ">^", 1, ">+", 1,
    )

    /**
     * This function is a wrapper function for the loops in `keys.allUp()` and is to cut repeat code
     * @param {String} form is the string that will be used in `Format()`
     * @param {Integer} loopNum is the amount of loops that will occur
     */
    __cycle(form, loopNum) {
        loop loopNum {
            which := Format(form, A_Index)
            if which = ""
                continue
            Send("{Blind}{" which " Up}") ;// send Up keystroke
            Send("{Blind}{Esc}") ;// try to mitigate any damage from an UP keystroke doing something
            ToolTip("Sending " GetKeyName(which) " Up")
        }
    }

    /**
     * This function is a wrapper function for the loops in `keys.allCheck()` and is to cut repeat code
     * @param {String} form is the string that will be used in `Format()`
     * @param {Integer} loopNum is the amount of loops that will occur
     */
    __check(form, loopNum, sendUp) {
        arr := []
        loop loopNum {
            which := GetKeyName(Format(form, A_Index))
            if which = ""
                continue
            if (GetKeyState(which) && !GetKeyState(which, "P"))
                {
                    if sendUp = true
                        {
                            Send("{Blind}{" which " Up}") ;// send Up keystroke
                            Send("{Blind}{Esc}") ;// try to mitigate any damage from an UP keystroke doing something
                            ToolTip("Sending " GetKeyName(which) " Up")
                            continue
                        }
                    arr.Push(which)
                }
        }
        return arr
    }

    /**
     * This function loops through as many possible SC and vk keys and sends the {Up} keystroke for it.
     * Originally from: 東方永夜抄#4008 in the ahk discord
     * @link this link may die: https://discord.com/channels/115993023636176902/1057690143231840347/1057704109408522240
     */
    static allUp() {
        SetTimer(check, -1)
        check() {
            this().__cycle("sc{:x}", 128)
            this().__cycle("vk{:x}", 256)
            tool.Cust("Sending {Up} commands complete")
        }
    }

    /**
     * This function loops through as many possible SC and vk keys and checks whether they are stuck down. If they are, an {UP} keystroke will be sent.
     * This function is a variation of `allUp()`
     * @param {Boolean} sendUp If this variable is set to true it will send an UP keystroke to all keys. If it is set to false the function will instead return an array containing the KeyName of all keys that are potentially stuck down
     * @return {Array} returns an array containing the names of all keys that are potentially stuck down
     */
    static allCheck(sendUp := true) {
        sc := this().__check("sc{:x}", 128, sendUp)
        vk := this().__check("vk{:x}", 256, sendUp)
        tool.Cust("Checking keys complete")
        if sendUp
            return true
        arr := []
        for v in sc
            arr.Push(v)
        for v in vk
            arr.Push(v)
        return arr
    }

    /**
     * This function is designed to remove the hassle that can sometimes occur by using `KeyWait`. If a function is launched via something like a streamdeck `A_ThisHotkey` will be blank, if you design a function to only be activated with one button but then another user tries to launch it from two an error will be thrown. This function will automatically determine what's required and stop errors occuring
     * @param {String} which determines which hotkey should be waited for in the event that the user tries to activate with two hotkeys. Must be either `"both"`, `"first"`, or `"second"`
     * @returns {Object} this function will attempt to return the two hotkeys as an object the same way that `getHotkeys()` would
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
        if ((A_ThisHotkey != "" && !InStr(A_ThisHotkey, "&")) &&
            (StrLen(A_ThisHotkey) != 2 && (!this.modifiers.Has(SubStr(A_ThisHotkey, 1, 1)) && !this.modifiers.Has(SubStr(A_ThisHotkey, 2, 1))))
        )
            KeyWait(A_ThisHotkey)
        else if A_ThisHotkey != ""
            {
                keys := getHotkeys()
                switch which {
                    case "first":  KeyWait(keys.first)
                    case "second": KeyWait(keys.second)
                    default:
                        if keys != false {
                            KeyWait(keys.second)
                            KeyWait(keys.first)
                            return {first: keys.first, second: keys.second}
                        }
                        ;// when the activation hotkey is multiple modifiers (ie. ^!f::)
                        for k, v in this.modifiers {
                            key := ""
                            switch k {
                                case "!":    key := "Alt"
                                case "<!":   key := "LAlt"
                                case ">!":   key := "RAlt"
                                case "^":    key := "Ctrl"
                                case "^":    key := "Ctrl"
                                case "<^":   key := "LCtrl"
                                case ">^":   key := "RCtrl"
                                case "+":    key := "Shift"
                                case "+":    key := "Shift"
                                case "<+":   key := "LShift"
                                case ">+":   key := "RShift"
                                case "#":    key := "Win"
                                case "<#":   key := "LWin"
                                case ">#":   key := "RWin"
                                case "<^>!": key := "AltGr"
                                default: key := k
                            }
                            try keyState := (GetKeyState(key, "P")) ? true : false
                            if InStr(A_ThisHotkey, k) && keyState = true
                                KeyWait(key)
                        }
                        return false
                }
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