/************************************************************************
 * @description Speed up interactions with VSCode
 * @author tomshi
 * @date 2025/03/22
 * @version 1.2.3.8
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\keys>
#Include <Classes\errorLog>
#Include <Other\Notify\Notify>
#Include <Functions\getHotkeys>
#Include <Functions\delaySI>
; }

class VSCode {

    static exeTitle := browser.vscode.winTitle
    static winTitle := "Visual Studio Code " this.exeTitle
    static class := browser.vscode.class
    static path := ptf.ProgFi "\Microsoft VS Code\Code.exe"

    /**
     * A function to cut repeat code amongst functions below
     *
     * @param {VarRef} orig passes back the original clipboard
     * @param {Boolean} focusFirst determines whether to focus the code window at the beginning or end of the function
     * @param {String} copyOrCut determines whether to send ^c or ^x
     */
    __getHighlightState(&orig, focusFirst := true, copyOrCut := "^c") {
        if copyOrCut !== "^c" && copyOrCut !== "^x"
            {
                ;// throw
                errorLog(ValueError("Invalid hotkey in Parameter #3", -1, copyOrCut),,, 1)
            }
        if focusFirst = true
            SendInput(KSA.focusCode)
        orig := ClipboardAll()
        A_Clipboard := ""
        SendInput(copyOrCut)
        if !ClipWait(0.1) && focusFirst = false
            SendInput(KSA.focusCode)
    }

    /**
     * A function to cut repeat code amongst functions below
     *
     * @param {VarRef} store passes back the clipboard
     * @param {String} which is to determine whether you wish to copy or cut the line. Defaults to copy and can be omitted
     */
    __getLine(&store, which := "") {
        SendInput("{End}")
        switch which {
            case "cut": SendInput("{Shift Down}{Home}{Shift Up}" "^x")
            default:    SendInput("{Shift Down}{Home}{Shift Up}" "^c" "{End}")
        }
        sleep 50
        store := A_Clipboard
        sleep 50
    }

    /**
      * A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal"). This scripts is updated to navigate around the scripts in my repo only, it isn't super flexible and would need a bit of tinkering if you have anything else in your vscode workspace.
      *
      * @param {Integer} script is the amount of down inputs the script needs to input to get to the required script. Will default to 0
     */
    static script(script := 0)
    {
        keys.allWait("first")
        block.On()
        sleep 50
        delaySI(50, KSA.focusExplorerWin, KSA.focusExplorerWin, KSA.focusWork, KSA.collapseFold, KSA.collapseFold, "{Up 5}", "{Enter}")
        __closeOut(ttp) => (sleep(50), block.Off(), tool.Wait(), tool.Cust(ttp, 2.0))
        switch A_ThisHotkey {
            case KSA.functionHotkey:   ;// this opens my ..\lib\functions folder
                delaySI(50, "{Down 2}{Enter}", "{Down 2}{Enter}", "{Down 2}{Enter}", "{Up 1}{Enter}")
                __closeOut("The function folder has been expanded")
                return
            case KSA.testHotkey:       ;// I have a dummy test .ahk file I use constantly, this is simply navigating to it
                delaySI(50, "{Down 5}{Enter}", "{Down 22}{Enter}")
                __closeOut("The test file has been selected")
                return
        }
        SendInput("{Down " script "}")
        sleep 25
        SendInput("{Enter}")
        SendInput(KSA.focusCode)
        __closeOut("The proper file should now be focused")
    }

    /**
     * I have a habit of always trying to ^f in the explorer window instead of the code window
     *
     * This macro REQUIRES `editor.emptySelectionClipboard` to be set to false within VSCode
     */
    static search() {
        this().__getHighlightState(&orig)
        if !ClipWait(0.1)
            {
                SendInput("^f")
                SendInput("{BackSpace}")
                A_Clipboard := orig
                return
            }
        SendInput("^f")
        A_Clipboard := orig
    }

    /**
     * This function is only REQUIRED because I have `editor.emptySelectionClipboard` set to false within VSCode because of `VSCode.search()`.
     *
     * It recreates the usual ability to completely remove a line by pressed ^x
     */
    static cut() {
        this().__getHighlightState(&orig, false, "^x")
        if !ClipWait(0.1)
            {
                amount := 1
                this().__getLine(&store, "cut")
                A_Clipboard := ""
                SendInput("{Shift Down}{Home}{Shift Up}" "^c")
                sleep 50
                if StrCompare(A_Clipboard, "", 1)
                    amount := "2"
                SendInput("{BackSpace " amount "}")
                A_Clipboard := orig ;restore the original clipboard - don't really know if this line makes a difference really
                A_Clipboard := store ;add the cut content to the clipboard
                return
            }
    }

    /**
     * This function is only REQUIRED because I have `editor.emptySelectionClipboard` set to false within VSCode because of `VSCode.search()`.
     *
     * It recreates the usual ability to copy a line by pressed ^c
     */
    static copy() {
        this().__getHighlightState(&orig, false)
        if !ClipWait(0.1)
            {
                this().__getLine(&store)
                A_Clipboard := orig ;restore the original clipboard - don't really know if this line makes a difference really
                A_Clipboard := store ;add the cut content to the clipboard
                tool.Cust("Current line copied to clipboard")
                return
            }
    }
}