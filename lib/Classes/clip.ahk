/************************************************************************
 * @description A class to encapsulate often used functions to manipulate the clipboard or interact with highlighted text
 * @author tomshi
 * @date 2023/06/30
 * @version 1.0.4.1
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\errorLog>
; }

class clip {
    /**
     * Ths function stores the current clipboard and then clears it
     * @param {VarRef} storeClip? The variable you wish to store the clipboard
     * @returns {Object} Alternatively returns an object containing the stored clipboard
     * ```
     * clipb := clip.clear(&stored)      ;// clear the clipboard
     * A_Clipboard := clipb.storedClip   ;// return the stored clipboard
     * A_Clipboard := stored             ;// return the stored clipboard
     * ```
     */
    static clear(&storedClip?) {
        storedClip := A_Clipboard
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

    /**
     * This function runs a search of highlighted text.
     * @param {String} url the url (search engine) you wish to use. Provide everything before the part of the url that is your search quiry
     */
    static search(url := "https://www.google.com/search?d&q=") {
        store := this.clear()
        if !this.copyWait(store.storedClip)
            return
        Run(url A_Clipboard)
        this.returnClip(store.storedClip)
    }

    /**
     * This function will attempt to determine whether to capitilise or completely lowercase the highlighted text depending on which is more frequent
     */
    static capitilise() {
        store := this.clear()
        if !this.copyWait(store.storedClip)
            return
        length := StrLen(A_Clipboard)
        /* if length > 9999 ;personally I started encountering issues at about 16k characters but I'm dropping that just to be safe
            {
                check := MsgBox("Strings that are too large may take a long time to process and are generally unable to be stopped without using taskmanager to kill the process`n`nThey also may eventually start sending gibberish as things aren't able to keep up`n`nAre you sure you wish to continue?", "Double Check", "4 48 4096")
                if check = "No"
                    return
            } */
        upperCount := 0
        lowerCount := 0
        nonAlphaCount := 0
        loop length
            {
                test := SubStr(A_Clipboard, A_Index, 1)
                if IsUpper(test) = true
                    upperCount += 1
                else if IsLower(test) = true
                    lowerCount += 1
                else if IsAlpha(test) = false
                    nonAlphaCount += 1
            }
        tool.Cust("Uppercase char = " upperCount "`nLowercase char = " lowerCount "`nAmount of char counted = " length - nonAlphaCount, 2000)
        if upperCount >= ((length - nonAlphaCount)/2)
            StringtoX := StrLower(A_Clipboard)
        else if lowerCount >= ((length - nonAlphaCount)/2)
            StringtoX := StrUpper(A_Clipboard)
        else
            {
                this.returnClip(store.storedClip)
                msg := "Couldn't determine whether to Uppercase or Lowercase the clipboard`nUppercase char = " upperCount "`nLowercase char = " lowerCount "`nAmount of char counted = " length - nonAlphaCount
                errorLog(Error(msg, -1),, {time: 2.0})
                return
            }
        SendInput("{BackSpace}")
        A_Clipboard := ""
        A_Clipboard := StringtoX
        this.Wait(store.storedClip)
        SendInput("{ctrl down}v{ctrl up}")
        this.delayReturn(store.storedClip)
    }
}