/**
 * A class to contain often used blockinput functions for easier coding.
 */
 class block {
    /**
     * This function is a part of the class `block`
     *
     * Blocks all user inputs [IF YOU GET STUCK IN A SCRIPT PRESS YOUR REFRESH HOTKEY (CTRL + R BY DEFAULT) OR USE CTRL + ALT + DEL to open task manager and close AHK]
     */
    static On() => (BlockInput("SendAndMouse"), BlockInput("MouseMove"), BlockInput("On")) ;it has recently come to my attention that all 3 of these operate independantly and doing all 3 of them at once is no different to just using "BlockInput "on"" but uh. oops, too late now I guess

    /**
     * This function is a part of the class `block`
     *
     * turns off the blocks on user input
     */
    static Off() => (Blockinput("MouseMoveOff"), BlockInput("off"))
}