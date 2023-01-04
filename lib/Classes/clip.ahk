/************************************************************************
 * @description A class to encapsulate often used functions to manipulate the clipboard
 * @author tomshi
 * @date 2023/01/05
 * @version 1.0.2
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\errorLog>
; }

class clip {
    /**
     * Ths function stores the current clipboard and then clears it
     * @param {VarRef} storeClip? The variable you wish to store the clipboard
     * @returns {Object} Alternatively returns an object containing the stored clipboard
     * ```
     * clipb := clip.clear(&stored)      ;// clear the clipboard
     * A_Clipboard := clip.storedClip    ;// return the stored clipboard
     * A_Clipboard := stored             ;// return the stored clipboard
     * ```
     */
    static clear(&storedClip?) {
        storedClip := ClipboardAll()
        A_Clipboard := ""
        return {storedClip: storedClip}
    }

    /**
     * Attempts to copy any highlighted text then waits for the clipboard to contain data
     * @param {Var} storedClip? is the variable you're storing the clipboard in. If the clipwait times out, this function will attempt to return the clipboard to this variable
     * @param {Integer} waitSec the time in `seconds` you want clipwait to wait. Defaults to `0.1s`
     * @returns {Boolean} True/False depending on if the clipboard recieved any data
     */
    static copyWait(storedClip?, waitSec := 0.1) {
        SendInput("^c")
        if !this.wait(storedClip?, waitSec)
            return false
        return true
    }

    /**
     * This function will wait for the clipboard to contain data, if it times out, it will attempt to return the clipboard to the passed variable
     * @param {Var} storedClip? is the variable you're storing the clipboard in. If the clipwait times out, this function will attempt to return the clipboard to this variable
     * @param {Integer} waitSec the time in `seconds` you want clipwait to wait. Defaults to `0.1s`
     * @returns {Boolean} True/False depending on if the clipboard recieved any data
     */
    static wait(storedClip?, waitSec := 0.1) {
        if !ClipWait(waitSec)
            {
                if IsSet(storedClip)
                    A_Clipboard := storedClip
                errorLog(UnsetError("Couldn't copy data to clipboard", -1),, 1)
                return false
            }
        return true
    }

    /**
     * This function returns the clipboard to the stored variable on a delay
     * @param {Var} returnClip is the variable you're storing the clipboard in.
     * @param {Integer} delay the delay in `ms` you want the function to wait before returning the clipboard
     */
    static delayReturn(returnClip, delay := 1000) => SetTimer(() => this.returnClip(returnClip), -delay)

    /**
     * This function returns the clipboard to the stored variable
     * @param {Var/Object} returnClip is the variable/object you're storing the clipboard in. If this parameter is an object it MUST have a parameter `clipObj.storedClip`
     */
    static returnClip(returnClip) {
        if !IsObject(returnClip)
            {
                A_Clipboard := returnClip
                return
            }
        if returnClip.HasOwnProp("storedClip")
            A_Clipboard := returnClip.storedClip
    }
}