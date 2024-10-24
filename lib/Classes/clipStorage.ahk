/************************************************************************
 * @description a class of functions designed to store/send strings
 * @author tomshi
 * @date 2024/10/24
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\clip>
#Include <Other\JSON>
; }

class clipStorage {

    static clipStorageDir := ptf.SupportFiles "\Clipboard Storage"
    static clipStorageINI := this.clipStorageDir "\clipStorage.ini"

    /**
     * An internal function that handles generating the new file to a temp location, then replacing the old file.
     * @param {Object} jsonObj the jsonObj you need to create a new file with
     */
    static __tempMoveReplace(jsonObj) {
        if !DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        tempPath := A_Temp "\tomshi\clipStorage.ini"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(JSON.stringify(jsonObj), tempPath)
        try FileMove(tempPath, this.clipStorageINI, true)
    }

    /**
     * An internal function to handle validating whether the clipStorage.ini file contains all of the default parameters. It will add any if they are missing
     * @param {VarRef} storageObj a required parameter to pass back the generated json object
     * @param {Array} recreateNumbers an array of any values the user wishes to add to the list of defaults. This value does not need to be a number, but does need to be a string
     */
    static __validateNumbers(&storageObj, recreateNumbers := []) {
        checkObj := JSON.parse(FileRead(this.clipStorageINI),, false)
        loop 10 {
            currentNum := String(A_Index-1)
            if !checkObj.HasOwnProp(currentNum)
                checkObj.%currentNum% := ""
        }
        for v  in recreateNumbers {
            if !checkObj.HasOwnProp(v)
                checkObj.%v% := ""
        }
        this.__tempMoveReplace(checkObj)
        storageObj := checkObj
    }

    /**
     * An internal function to handle creating a fresh clipStorage.ini file if it does not exist
     * @param {VarRef} storageObj a required parameter to pass back the generated json object
     * @param {Array} recreateNumbers an array of any values the user wishes to add to the list of defaults. This value does not need to be a number, but does need to be a string
     */
    static __createStorageFile(&storageObj, recreateNumbers := []) {
        storageObj := {}
        loop 10 {
            number := String(A_Index-1)
            storageObj.%number% := ""
        }
        for v in recreateNumbers {
            if !storageObj.HasOwnProp(v)
                storageObj.%v% := ""
        }
        FileAppend(JSON.stringify(storageObj), this.clipStorageINI)
    }

    /**
     * An internal function to determine if the activation hotkey includes a number, as the user did not pass a custom "key" into the storage function, a number is required.
     * @param {String} checkHotkey the activation hotkey to check (should be A_ThisHotkey)
     * @param {VarRef} number the number to pass back in the event the activation hotkey contains one
     */
    static __validateNumber(checkHotkey, &number) {
        loop {
            getChar := SubStr(checkHotkey, A_Index, 1)
            if !getChar {
                ;// throw
                errorLog(ValueError("Activation hotkey does not include a number", -1),,, true)
                return
            }
            if !IsNumber(getChar)
                continue
            number := getChar
            break
        }
    }

    /**
     * Wipes the old clipStorage.ini file and generates a new one
     * @param {Array} recreateNumbers an array of any values the user wishes to add to the list of defaults. This value does not need to be a number, but does need to be a string
     */
    static clearAll(recreateNumbers := []) {
        if !DirExist(this.clipStorageDir)
            DirCreate(this.clipStorageDir)
        if FileExist(this.clipStorageINI) {
            FileDelete(this.clipStorageINI)
            this.__createStorageFile(&storageObj, recreateNumbers)
        }
        tool.Cust("Clipboard storage has been reset")
    }

    /**
     * This function stores the current Clipboard to the desired number. If the `number` parameter of this function remains unset, it will require the activation hotkey to be either one of the number keys, or one of the numpad keys. Otherwise the user may pass in a custom "key" string.
     * @param {String} [number=unset] A custom "key" used when the user does not wish to use a number key as the activation hotkey. This "key" can be anything as long as it is a string
     * @param {Array} recreateNumbers an array of any values the user wishes to add to the list of defaults. This value does not need to be a number, but does need to be a string
     */
    static store(number := unset, recreateNumbers := []) {
        if !DirExist(this.clipStorageDir)
            DirCreate(this.clipStorageDir)
        if !FileExist(this.clipStorageINI) {
            this.__createStorageFile(&storageObj, recreateNumbers)
        } else {
            this.__validateNumbers(&storageObj, recreateNumbers)
        }

        if !IsSet(number) {
            this.__validateNumber(A_ThisHotkey, &number)
        }

        storageObj.%number% := A_Clipboard
        this.__tempMoveReplace(storageObj)
    }

    /**
     * This function sends the value stored in the current storage slot.
     * @param {String} [number=unset] A custom "key" used when the user does not wish to use a number key as the activation hotkey. This "key" can be anything as long as it is a string
     */
    static send(number := unset) {
        if !DirExist(this.clipStorageDir)
            DirCreate(this.clipStorageDir)
        if !FileExist(this.clipStorageINI) {
            tool.Cust("Nothing is currently stored in the desired slot")
            return
        }

        if !IsSet(number) {
            this.__validateNumber(A_ThisHotkey, &number)
        }

        storageObj := JSON.parse(FileRead(this.clipStorageINI),, false)
        if !storageObj.HasOwnProp(number) || storageObj.%number% = "" {
            tool.Cust("Nothing is currently stored in the desired slot: " number)
            return
        }

        origClip := clip.clear()
        A_Clipboard := storageObj.%number%
        if !ClipWait(2) {
            clip.returnClip(origClip)
            return
        }
        SendInput("^v")
        clip.returnClip(origClip)
    }

    /** Opens the current clipStorage.ini file */
    static open() {
        if !DirExist(this.clipStorageDir)
            DirCreate(this.clipStorageDir)
        if !FileExist(this.clipStorageINI) {
            tool.Cust("A storage file does not currently exist. A new one will be generated.")
            this.__createStorageFile(&storageObj)
        }

        Run(this.clipStorageINI,,, &pid)
        if !WinWait("ahk_class Notepad",, 2)
            return
        WinActivate("ahk_class Notepad")
    }
}