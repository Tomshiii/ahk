; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Dark>
#Include <GUIs\tomshiBasic>
#Include <Functions\detect>
; }

/**
 * @param {String} version if called from `settingsGUI()` this value needs to be passed in so the function can return proper functionality to that window
 * @param {String} winTitle the wintitle of the active window that will be auto filled into the respective edit box
 * @param {String} process the process name of the active window that will be auto filled into the respective edit box
 */
class gameCheckGUI extends tomshiBasic {
    __New(version := "", winTitle := WinGetTitle("A"), process := WinGetProcessName("A")) {
        super.__New(,, "+MinSize450x320 +MaxSize450x AlwaysOnTop", "Add game to gameCheck.ahk")
        this.winTitle := winTitle, this.process := process, this.version := version
        this.__generate()
    }

    winTitle := ""
    process := ""
    version := ""

    __generate() {
        this.Add("Text", "W440 Center", "Format: ``GameTitle ahk_exe game.exe```nExample: ``Minecraft ahk_exe javaw.exe")
        this.Add("Text", "Y+4 W440 Center", "*try to remove any information from the title that is likely to change, eg. version numbers or extra text that isn't a part of the game title (Terraria for example adds little quotes to the title that changes everytime you run the game)").SetFont("S9 italic")
        this.Add("Text", "Y+-8 W440", "This function attempted to grab the correct information from the active window before you pulled up the settings GUI and then prefilled the input boxes with that information. If it's correct hit OK, if not enter in the correct information.`n`n*If not, this info can be found using WindowSpy which comes alongside AHK")

        this.Add("Text", "Section", "Game Title: ")
        this.gameTitle := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameTitle w300", this.wintitle)

        this.Add("Text", "xs ys+25 Section", "Process Name: ")
        this.gameProcess := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameProcess w300", "ahk_exe " this.process)

        addButton := this.Add("Button", "xs+187 ys+30 Section", "add to ``gameCheck.ahk``").OnEvent("Click", this.__addButton_Click.Bind(this, this.gameTitle.Text, this.gameProcess.Text))
        cancelButton := this.Add("Button", "xs+175 ys", "cancel").OnEvent("Click", this.__cancelButton_Click.Bind(this))
    }

    /**
     * check for game list file
     */
    __checkGameList() {
        if !FileExist(ptf["Game List"])
            {
                MsgBox("``Game List.ahk`` not found in the proper directory")
                this.Hide()
                this.__settingsGUIontop()
            }
    }

    /**
     * searching for the input value in the list to check for dupes
     * @param {String} readGameCheck the game list
     * @param {String} listFormat the input value
     */
    __checkForInput(readGameCheck, listFormat) {
        if InStr(readGameCheck, listFormat, 1,, 1)
            {
                this.Hide()
                setWinExist := WinExist("Settings " this.version) ? 1 : 0
                if setWinExist
                    WinActivate("Settings " this.version)
                return false
            }
        return true
    }

    /**
     * append the user input into the gamelist file
     * @param {String} readGameCheck the game list
     * @param {String} listFormat the input value
     */
    __appendInput(readGameCheck, listFormat) {
        detect()
        FileAppend(",`n" listFormat, ptf["Game List"])

        ;// reloading the script
        if WinExist("gameCheck.ahk - AutoHotkey")
            PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"

        ;// checking if it worked
        readAgain := FileRead(ptf["Game List"])
        if !InStr(readAgain, listFormat, 1,, 1)
            {
                this.Hide()
                setWinExist := WinExist("Settings " this.version) ? 1 : 0
                if setWinExist
                    WinActivate("Settings " this.version)
                MsgBox("Game added unsuccesfully :(")
                if setWinExist
                    this.__settingsGUIontop()
                return
            }
    }

    /**
     * if the settingsGUI() window exists, it will set it back to be always on top & will activate it
     */
    __settingsGUIontop() {
        if WinExist("Settings " this.version)
            {
                WinSetAlwaysOnTop(1, "Settings " this.version)
                WinActivate("Settings " this.version)
            }
    }

    /**
     * This function handles the logic behind the add button
     * @param {any} version is the version number that gets passed into the class
     * @param {any} titleVal is the original title name that gets passed into the class
     * @param {any} procVal is the process name that gets passed into the class
     */
    __addButton_Click(titleVal, procVal, *) {
        titleVal := this.gameTitle.Value
        procVal := this.gameProcess.Value

        this.__checkGameList()
        readGameCheck := FileRead(ptf["Game List"])
        ;//! what to search for
        listFormat := Format('"{} {}"', titleVal, procVal)
        ;// check list for input value
        if !this.__checkForInput(readGameCheck, listFormat) {
            MsgBox("The desired window is already in the list!", "Game already added! - gameCheck")
            this.__settingsGUIontop()
            return
        }
        ;// append input
        this.__appendInput(readGameCheck, listFormat)

        this.Hide()
        setWinExist := WinExist("Settings " this.version) ? 1 : 0
        if setWinExist && !WinActive("Settings " this.version)
            WinActivate("Settings " this.version)
        MsgBox("Game added succesfully!")
        this.__settingsGUIontop()
    }

    /**
     * Handles the logic behind the cancel button
     */
    __cancelButton_Click(*) {
        this.__settingsGUIontop()
        this.wintitle := ""
        this.process := ""
        this.Hide()
    }
}