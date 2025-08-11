/************************************************************************
 * @description a class to contain often used functions relating to keys
 * @file key.ahk
 * @author tomshi
 * @date 2025/08/11
 * @version 1.1.3
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\errorLog>
#Include <Functions\getHotkeys>
#Include <Functions\getHotkeysArr>
; }

class keys {
    static modMap := Map(
        "<^>!", "LCtrl&RAlt",
        "<+>!", "LShift&RAlt",
        "<^", "LCtrl",
        ">^", "RCtrl",
        "<!", "LAlt",
        ">!", "RAlt",
        "<+", "LShift",
        ">+", "RShift",
        "<#", "LWin",
        ">#", "RWin",
        "^", "Ctrl",
        "!", "Alt",
        "+", "Shift",
        "#", "LWin"
    )

    /**
     * A helper function to convert string representations of hotkeys to their vk counterpart for use with ahk functions like `KeyWait()`
     */
    static vk(variable) {
        if !this.modMap.Has(variable)
            return false
        check := GetKeyVK(this.modMap[variable])
        return Format("vk{:X}", check)
    }

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
     * @param {Integer} [which=1] determines which hotkey should be waited for in the event that the user tries to activate with two hotkeys. This integer is the index of the array returned from `getHotkeysArr()`. ie; if the user is using the activation hotkey `!p::` - `!` is [1], `p` is [2]. So if the user puts `2` as this parameter, the function will move forward after `p` is released
     * @returns {Boolean/Array} if `A_ThisHotkey` is blank, this function will return boolean `false`, otherwise this function will attempt to return the array received from `getHotkeysArr()`
     */
    static allWait(which := 1) {
        if A_ThisHotkey = ""
            return false
        if Type(which) != "Integer" {
            ;// throw
            errorLog(TypeError("Incorrect Type in Parameter #1", -1, which),,, 1)
        }
        getKeys := getHotkeysArr()
        for i, v in getKeys {
            if A_Index > getKeys.Length
                break
            currentIndex := (getKeys.Length+1)-A_Index
            if (currentIndex) < which
                break
            try keyState := (GetKeyState(getKeys[currentIndex], "P")) ? true : false
            if !keyState
                continue
            try KeyWait(getKeys[currentIndex])
        }
        return getKeys
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