/************************************************************************
 * @description A class to contain often used blockinput functions for easier coding.
 * @author tomshi
 * @date 2025/04/11
 * @version 1.3.7
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\Mip>
#Include <Classes\errorLog>
; }


class block {
    choices := Mip("send", 1, "mouse", 1, "sendandmouse", 1, "default", 1, "on", 1, "mousemove", 1, "mousemoveoff", 1, "off", 1)

    /**
     * This function is designed to be internal to the class and isn't intended to be manually called. It checks the users custom input settings to make sure they're a usable option. This function will also alert the user about the intricacies of using `BlockInput("On"/"Off")`
     * @param {String} args is the users passed in custom option
     */
    __inputs(args) {
        if !this.choices.Has(args) {
                ;// throw
                errorLog(ValueError("Incorrect value in parameter #1", -2, args),,, 1)
            }
        if args = "on" || args = "off"
            {
                UserSettings := UserPref()
                checkIni := UserSettings.block_aware
                if checkIni = "false"
                    {
                        alert := MsgBox("
                        (
                            Using ``BlockInput("On")/BlockInput("Off")`` may not work as expected if you're using windows UAC and this script hasn't been run as admin. Consider using a different block mode for more usable & shareable code.

                            Would you like to be alerted of this again in the future?
                        )", "Block Mode Warning", "4 48 4096")
                        if alert = "No"
                            {
                                UserSettings.block_aware := true
                                UserSettings.__delAll()
                                UserSettings := ""
                            }
                    }
            }
        BlockInput(args)
    }

    /**
     * By default this function will blocks all user inputs (`BlockInput("SendAndMouse") & BlockInput("MouseMove")`).
     *
     * Otherwise pass `send`, `mouse`, `sendandmouse`, `default`, `on` or `mousemove`
     *
     * *[IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (WIN + SHIFT + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]*
     * @param {String} [option=unset] is the desired block mode. If this parameter is omitted `BlockInput("SendAndMouse") & BlockInput("MouseMove")` will be enabled
     */
    static On(option?) {
        if !IsSet(option)
            {
                ;// don't use `BlockInput("On")` it can have issues with UAC if script not run as admin
                BlockInput("SendAndMouse"), BlockInput("MouseMove")
                return
            }
        this().__inputs(option)
    }

    /**
     * This function by default will unblock all user input (`BlockInput("Default") & BlockInput("MouseMoveOff")`).
     *
     * Otherwise pass `mousemoveoff`, `off`
     * @param {String} [option=unset] is the desired block mode the user wishes to disable. If this parameter is omitted `BlockInput("Default") & BlockInput("MouseMoveOff")` will be disabled
     */
    static Off(option?) {
        if !IsSet(option)
            {
                BlockInput("Default"), BlockInput("MouseMoveOff")
                return
            }
        this().__inputs(option)
    }
}

class block_ext {
    blocker := {}
    modifiers := "{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}"
    defaultAdditional := "{Tab}{F4}{Enter}{sc01C}{NumpadEnter}{sc11C}{vk0D}"

    /**
     * @param [blockMouse=true] Determine whether to also block mouse input. Defaults to `true`
     * @param [allowModifiers=true] Determines whether to allow certain modifiers to pass through. It is recommended to leave this enabled so the user still has *some* inputs available to them in the event of failed logic leaving inputs blocked. You may optionally provide your own list of allowed modifiers. Simply pass one long string containing all modifiers.
     * @param [additionalKeys=this.defaultAdditional] Determines any additional keys that are allowed to pass through. By default the following are set; `"{Tab}{F4}{Enter}{sc01C}{NumpadEnter}{sc11C}{vk0D}"`. If the user wishes to change this list, simply pass your own string to this parameter, although it is recommended to also include these as a miniumum.
     *
     * #### It should be noted that the user should still be able to use <kbd>win + shift + r</kbd> to reload scripts
     */
    On(blockMouse := true, allowModifiers := true, additionalKeys := this.defaultAdditional) {
        this.blocker := InputHook("L0 I")
        this.blocker.KeyOpt("{All}", "S")
        ; Exclude the modifiers
        suppress := (allowModifiers = true) ? this.modifiers : ((allowModifiers = false) ? "" : allowModifiers)
        this.blocker.KeyOpt(suppress, "-S")
        this.blocker.KeyOpt(additionalKeys, "+V")
        (blockMouse = true) ? (BlockInput("SendAndMouse"), BlockInput("MouseMove")) : BlockInput('Send')
        this.blocker.Start()
    }

    Off() {
        try this.blocker.Stop()
        BlockInput("Default"), BlockInput("MouseMoveOff")
        this.blocker := {}
    }
}