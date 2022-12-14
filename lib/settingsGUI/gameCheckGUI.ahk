; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Dark>
#Include <Functions\detect>
; }

/**
 * A class to define the gameCheck add GUI window
 *
 * @param dark is passing in whether dark mode is enabled or not
 * @param version is passing in the current version number
 * @param wintitle is passing in the originally active winTitle when `settingsGUI()` was called
 * @param process is passing in the originally active winProcess when `settingsGUI()` was called
 * @param options is defining any GUI options
 * @param title is to set a title for the GUI
 */
 class gameCheckGUI extends Gui {
    __new(darkmode, version, wintitle, process, options?, title:="") {
        super.__new(options?, title, this)
        this.BackColor := 0xF0F0F0
        this.SetFont("S11") ;Sets the size of the font
        this.SetFont("W500") ;Sets the weight of the font (thickness)
        this.Opt("+MinSize450x320 +MaxSize450x")

        ;setting up
        detect()

        ;defining text
        text1 := this.Add("Text", "W440 Center", "Format: ``GameTitle ahk_exe game.exe```nExample: ``Minecraft ahk_exe javaw.exe")
        text2 := this.Add("Text", "Y+4 W440 Center", "*try to remove any information from the title that is likely to change, eg. version numbers or extra text that isn't a part of the game title (Terraria for example adds little quotes to the title that changes everytime you run the game)")
        text2.SetFont("S9 italic")
        text3 := this.Add("Text", "Y+-8 W440", "This function attempted to grab the correct information from the active window before you pulled up the settings GUI and then prefilled the input boxes with that information. If it's correct hit OK, if not enter in the correct information.`n`n*If not, this info can be found using WindowSpy which comes alongside AHK")

        ;defining edit boxes
        gameTitleTitle := this.Add("Text", "Section", "Game Title: ")
        gameTitle := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameTitle w300", wintitle)

        gameProcessText := this.Add("Text", "xs ys+25 Section", "Process Name: ")
        gameProcess := this.Add("Edit", "xs+120 ys-5 r1 -WantReturn vgameProcess w300", "ahk_exe " process)

        ;defining buttons
        addButton := this.Add("Button", "xs+187 ys+30 Section", "add to ``gameCheck.ahk``")
        addButton.OnEvent("Click", addButton_Click.Bind(version, gameTitle.Text, gameProcess.Text))
        cancelButton := this.Add("Button", "xs+175 ys", "cancel")
        cancelButton.OnEvent("Click", cancelButton_Click)

        if darkmode = "true"
            {
                dark.titleBar(this.Hwnd)
                dark.button(addButton.Hwnd)
                dark.button(cancelButton.Hwnd)
            }

        /**
         * This function handles the logic behind the add button
         * @param {any} version is the version number that gets passed into the class
         * @param {any} titleVal is the original title name that gets passed into the class
         * @param {any} procVal is the process name that gets passed into the class
         * @param {any} testButton is a default paramater
         * @param {any} unusedInfo is a default paramater
         */
        addButton_Click(version, titleVal, procVal, testButton, unusedInfo) {
            if titleVal != gameTitle.Value
                titleVal := gameTitle.Value
            if procVal != gameProcess.Value
                procVal := gameProcess.Value
            ;check for game list file
            if !FileExist(ptf["Game List"])
                {
                    MsgBox("``Game List.ahk`` not found in the proper directory")
                    this.Hide()
                    WinSetAlwaysOnTop(1, "Settings " version)
                    WinActivate("Settings " version)
                }
            ;create temp folders
            if !DirExist(A_Temp "\tomshi")
                DirCreate(A_Temp "\tomshi")
            readGameCheck := FileRead(ptf["Game List"])
            if InStr(readGameCheck, "GroupAdd(" '"' "games" '"' ", " '"' titleVal " " procVal '"' ")`n; --", 1,, 1)
                {
                    this.Hide()
                    setWinExist := WinExist("Settings " version) ? 1 : 0
                    if setWinExist
                        WinActivate("Settings " version)
                    MsgBox("The desired window is already in the list!")
                    if setWinExist
                        {
                            WinSetAlwaysOnTop(1, "Settings " version)
                            if !WinActive("Settings " version)
                                WinActivate("Settings " version)
                        }
                    return
                }
            findEnd := InStr(readGameCheck, "; --", 1,, 1)
            addUserInput := StrReplace(readGameCheck, "; --", "GroupAdd(" '"' "games" '"' ", " '"' titleVal " " procVal '"' ")`n; --", 1,, 1)
            FileAppend(addUserInput, A_Temp "\tomshi\Game List.ahk")
            FileMove(A_Temp "\tomshi\Game List.ahk", ptf["Game List"], 1)
            if WinExist("gameCheck.ahk - AutoHotkey")
                PostMessage 0x0111, 65303,,, "gameCheck.ahk - AutoHotkey"

            ;check if worked
            readAgain := FileRead(ptf["Game List"])
            if InStr(readAgain, "GroupAdd(" '"' "games" '"' ", " '"' titleVal " " procVal '"' ")`n; --", 1,, 1)
                {
                    this.Hide()
                    setWinExist := WinExist("Settings " version) ? 1 : 0
                    if setWinExist && !WinActive("Settings " version)
                        WinActivate("Settings " version)
                    MsgBox("Game added succesfully!")
                    if setWinExist
                        {
                            WinSetAlwaysOnTop(1, "Settings " version)
                            if !WinActive("Settings " version)
                                WinActivate("Settings " version)
                        }
                }
            else
                {
                    this.Hide()
                    setWinExist := WinExist("Settings " version) ? 1 : 0
                    if setWinExist
                        WinActivate("Settings " version)
                    MsgBox("Game added unsuccesfully :(")
                    if setWinExist
                        {
                            WinSetAlwaysOnTop(1, "Settings " version)
                            if !WinActive("Settings " version)
                                WinActivate("Settings " version)
                        }
                }
        }

        /**
         * Handles the logic behind the cancel button
         * @param {any} testButton is a default paramater
         * @param {any} unusedInfo is a default paramater
         */
        cancelButton_Click(testButton, unusedInfo) {
            if WinExist("Settings " version)
                {
                    WinSetAlwaysOnTop(1, "Settings " version)
                    WinActivate("Settings " version)
                }
            this.Hide()
        }
    }
}