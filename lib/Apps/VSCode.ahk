#Include <\Functions\General>

class VSCode {
    /**
      * A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
      * @param {Integer} script is the amount of down inputs the script needs to input to get to the required script. Will default to 0
     */
    static script(script := 0)
    {
        getHotkeys(&first, &second)
        KeyWait(first)
        block.On()
        sleep 50
        SendInput(focusExplorerWin) ;highlight the explorer window
        sleep 50
        SendInput(focusWork)
        SendInput(collapseFold collapseFold) ;close all repos
        sleep 50
        SendInput("{Up 2}{Enter}") ;this highlights the top repo in the workspace
        sleep 50
        if A_ThisHotkey = functionHotkey ;this opens my \functions folder
            {
                SendInput("{Down 4}{Enter}")
                sleep 50
                SendInput("{Down 3}{Enter}")
                sleep 50
                block.Off()
                tool.Wait()
                tool.Cust("The function folder has been expanded", 2.0)
                return
            }
        SendInput("{Down " script "}")
        sleep 25
        SendInput("{Enter}")
        SendInput(focusCode)
        block.Off()
        tool.Wait()
        tool.Cust("The proper file should now be focused", 2.0)
    }

    /**
     * A function to cut repeat code amongst functions below
     */
    static getHighlightState(&orig) {
        SendInput(focusCode)
        orig := ClipboardAll()
        A_Clipboard := ""
        SendInput("^c")
    }

    /**
     * A function to cut repeat code amongst functions below
     */
    static getLine(&store) {
        SendInput("{End}")
        SendInput("{Shift Down}{Home}{Shift Up}" "^c" "{End}")
        sleep 50
        store := A_Clipboard
        sleep 50
    }

    /**
     * I have a habit of always trying to ^f in the explorer window instead of the code window
     *
     * This macro REQUIRES `editor.emptySelectionClipboard` to be set to false within VSCode (if you use vscode)
     */
    static search() {
        this.getHighlightState(&orig)
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
     * This function is only REQUIRED because I have `editor.emptySelectionClipboard` set to false within VSCode because of the above function.
     *
     * It recreates the usual ability to completely remove a line by pressed ^x
     */
    static cut() {
        this.getHighlightState(&orig)
        if !ClipWait(0.1)
            {
                amount := 1
                this.getLine(&store)
                A_Clipboard := ""
                SendInput("{Shift Down}{Home}{Shift Up}" "^c")
                sleep 50
                if StrCompare(A_Clipboard, "", 1)
                    amount := "2"
                SendInput("{BackSpace " amount "}")
                A_Clipboard := orig ;restore the original clipboard
                A_Clipboard := store ;add the cut content to the clipboard
                return
            }
        A_Clipboard := orig
        SendInput("^x")
    }

    /**
     * This function is only REQUIRED because I have `editor.emptySelectionClipboard` set to false within VSCode because of the above function.
     *
     * It recreates the usual ability to copy a line by pressed ^c
     */
    static copy() {
        this.getHighlightState(&orig)
        if !ClipWait(0.1)
            {
                this.getLine(&store)
                A_Clipboard := orig ;restore the original clipboard
                A_Clipboard := store ;add the cut content to the clipboard
                tool.Cust("Current line copied to clipboard")
                return
            }
        A_Clipboard := orig
        SendInput("^c")
    }
}