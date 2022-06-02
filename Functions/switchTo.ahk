;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9.14
#Include General.ahk

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToExplorer()
{
    if not WinExist("ahk_class CabinetWClass")
        {
            Run "explorer.exe"
            WinWait("ahk_class CabinetWClass")
            WinActivate "ahk_class CabinetWClass" ;in win11 running explorer won't always activate it, so it'll open in the backround
        }
    GroupAdd "explorers", "ahk_class CabinetWClass"
    if WinActive("ahk_exe explorer.exe")
        GroupActivate "explorers", "r"
    else
        if WinExist("ahk_class CabinetWClass")
            WinActivate "ahk_class CabinetWClass" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This function when called will close all windows of the desired program EXCEPT the active one. Helpful when you accidentally have way too many windows open.
 @param program is the ahk_class or ahk_exe of the program you want this function to close
 */
closeOtherWindow(program)
{
    value := WinGetList(%&program%) ;gets a list of all open windows
    toolCust(value.length - 1 " other window(s) closed", "1000") ;tooltip to display how many explorer windows are being closed
    for this_value in value
        {
            if A_Index > 1 ;closes all windows that AREN'T the last active window
                WinClose this_value
        }
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToPremiere()
{
    if not WinExist("ahk_class Premiere Pro")
        {
        Run A_ScriptDir "\shortcuts\Adobe Premiere Pro.exe.lnk"
        }
    else
        if WinExist("ahk_class Premiere Pro")
            WinActivate "ahk_class Premiere Pro"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToAE()
{
    if not WinExist("ahk_exe AfterFX.exe")
        {
        Run A_ScriptDir "\shortcuts\AfterFX.exe.lnk"
        WinWait("ahk_exe AfterFX.exe")
        WinActivate("ahk_exe AfterFX.exe")
        }
    else
        if WinExist("ahk_exe AfterFX.exe")
            WinActivate "ahk_exe AfterFX.exe"
}

/*
 This switchTo function will quickly switch to the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToDisc()
{
    move() { ;creating a function out of the winmove so you can easily adjust the value
        WinMove(-1080, -274, 1080, 1600, "ahk_exe Discord.exe")
    }
    if not WinExist("ahk_exe Discord.exe")
        {
            Run("C:\Users\Tom\AppData\Local\Discord\Update.exe --processStart Discord.exe")
            WinWait("ahk_exe Discord.exe")
            if WinGetMinMax("ahk_exe Discord.exe") = 1 ;a return value of 1 means it is maximised
                WinRestore() ;winrestore will unmaximise it
            move() ;moves it into position after opening
        }
    else
        {
            WinActivate("ahk_exe Discord.exe")
            if WinGetMinMax("ahk_exe Discord.exe") = 1 ;a return value of 1 means it is maximised
                WinRestore() ;winrestore will unmaximise it
            move() ; just incase it isn't in the right spot/fullscreened for some reason
            toolCust("Discord is now active", "500") ;this is simply because it's difficult to tell when discord has focus if it was already open
        }
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToPhoto()
{
    if not WinExist("ahk_exe Photoshop.exe")
        {
        Run A_ScriptDir "\shortcuts\Photoshop.exe.lnk"
        WinWait("ahk_exe Photoshop.exe")
        WinActivate("ahk_exe Photoshop.exe")
        }
    else
        if WinExist("ahk_exe Photoshop.exe")
            WinActivate "ahk_exe Photoshop.exe"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToFirefox()
{
    if not WinExist("ahk_class MozillaWindowClass")
        Run "firefox.exe"
    if WinActive("ahk_exe firefox.exe")
        {
        Class := WinGetClass("A")
        ;WinGetClass class, A
        if (class = "Mozillawindowclass1")
            msgbox "this is a notification"
        }
    if WinActive("ahk_exe firefox.exe")
        Send "^{tab}"
    else
        {
            if WinExist("ahk_exe firefox.exe")
                ;WinRestore ahk_exe firefox.exe
                    WinActivate "ahk_exe firefox.exe"
        }
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToOtherFirefoxWindow() ;I use this as a nested function below in firefoxTap(), you can just use this separately
{
    if WinExist("ahk_exe firefox.exe")
        {
            if WinActive("ahk_class MozillaWindowClass")
                {
                    GroupAdd "firefoxes", "ahk_class MozillaWindowClass"
                    GroupActivate "firefoxes", "r"
                }
            else
                WinActivate "ahk_class MozillaWindowClass"
        }
    else
        Run "firefox.exe"
}

/*
 This function will do different things depending on how many times you press the activation hotkey.
 1 press = switchToFirefox()
 2 press = switchToOtherFirefoxWindow()
 */
firefoxTap()
{
    static winc_presses := 0
    if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
    {
        winc_presses += 1
        return
    }
    ; Otherwise, this is the first press of a new series. Set count to 1 and start
    ; the timer:
    winc_presses := 1
    SetTimer After400, -180 ; Wait for more presses within a 300 millisecond window.

    After400()  ; This is a nested function.
    {
        if winc_presses = 1 ; The key was pressed once.
        {
            switchToFirefox()
        }
        else if winc_presses = 2 ; The key was pressed twice.
        {
            switchToOtherFirefoxWindow()
        }
        else if winc_presses > 2
        {
            ;
        }
        ; Regardless of which action above was triggered, reset the count to
        ; prepare for the next series of presses:
        winc_presses := 0
    }
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToVSC()
{
    if not WinExist("ahk_exe Code.exe")
        Run "C:\Program Files\Microsoft VS Code\Code.exe"
        GroupAdd "Code", "ahk_class Chrome_WidgetWin_1"
    if WinActive("ahk_exe Code.exe")
        GroupActivate "Code", "r"
    else
        if WinExist("ahk_exe Code.exe")
            WinActivate "ahk_exe Code.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToGithub()
{
    if not WinExist("ahk_exe GitHubDesktop.exe")
        Run "C:\Users\" A_UserName "\AppData\Local\GitHubDesktop\GitHubDesktop.exe"
        GroupAdd "git", "ahk_class Chrome_WidgetWin_1"
    if WinActive("ahk_exe GitHubDesktop.exe")
        GroupActivate "git", "r"
    else
        if WinExist("ahk_exe GitHubDesktop.exe")
            WinActivate "ahk_exe GitHubDesktop.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToStreamdeck()
{
    if not WinExist("ahk_exe StreamDeck.exe")
        Run A_ProgramFiles "\Elgato\StreamDeck\StreamDeck.exe"
        GroupAdd "stream", "ahk_class Qt5152QWindowIcon"
    if WinActive("ahk_exe StreamDeck.exe")
        GroupActivate "stream", "r"
    else
        if WinExist("ahk_exe Streamdeck.exe")
            WinActivate "ahk_exe StreamDeck.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToExcel()
{
    if not WinExist("ahk_exe EXCEL.EXE")
        {
            Run A_ProgramFiles "\Microsoft Office\root\Office16\EXCEL.EXE"
            WinWait("ahk_exe EXCEL.EXE")
            WinActivate("ahk_exe EXCEL.EXE")
        }
    GroupAdd "xlmain", "ahk_class XLMAIN"
    if WinActive("ahk_exe EXCEL.EXE")
        GroupActivate "xlmain", "r"
    else
        if WinExist("ahk_exe EXCEL.EXE")
            WinActivate "ahk_exe EXCEL.EXE"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToWord()
{
    if not WinExist("ahk_exe WINWORD.EXE")
        {
            Run A_ProgramFiles "\Microsoft Office\root\Office16\WINWORD.EXE"
            WinWait("ahk_exe WINWORD.EXE")
            WinActivate("ahk_exe WINWORD.EXE")
        }
    GroupAdd "wordgroup", "ahk_class wordgroup"
    if WinActive("ahk_exe WINWORD.EXE")
        GroupActivate "wordgroup", "r"
    else
        if WinExist("ahk_exe WINWORD.EXE")
            WinActivate "ahk_exe WINWORD.EXE"
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToWindowSpy()
{
    if not WinExist("WindowSpy.ahk")
        Run A_ProgramFiles "\AutoHotkey\WindowSpy.ahk"
    GroupAdd "winspy", "ahk_class AutoHotkeyGUI"
    if WinActive("WindowSpy.ahk")
        GroupActivate "winspy", "r"
    else
        if WinExist("WindowSpy.ahk")
            WinActivate "WindowSpy.ahk" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToYourPhone()
{
    if not WinExist("ahk_pid 13884") ;this process id may need to be changed for you. I also have no idea if it will stay the same
        Run A_ProgramFiles "\ahk\ahk\shortcuts\Your Phone.lnk"
    GroupAdd "yourphone", "ahk_class ApplicationFrameWindow"
    if WinActive("Your Phone")
        GroupActivate "yourphone", "r"
    else
        if WinExist("Your Phone")
            WinActivate "Your Phone" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToEdge()
{
    if not WinExist("ahk_exe msedge.exe")
        {
            Run "msedge.exe"
            WinWait("ahk_exe msedge.exe")
            WinActivate("ahk_exe msedge.exe")
        }
    GroupAdd "git", "ahk_exe msedge.exe"
    if WinActive("ahk_exe msedge.exe")
        GroupActivate "git", "r"
    else
        if WinExist("ahk_exe msedge.exe")
            WinActivate "ahk_exe msedge.exe" ;you have to use WinActivatebottom if you didn't create a window group.
}

/*
 This switchTo function will quickly switch to & cycle between windows of the specified program. If there isn't an open window of the desired program, this function will open one
 */
switchToMusic()
{
    GroupAdd("MusicPlayers", "ahk_exe wmplayer.exe")
    GroupAdd("MusicPlayers", "ahk_exe vlc.exe")
    GroupAdd("MusicPlayers", "ahk_exe AIMP.exe") 
    GroupAdd("MusicPlayers", "ahk_exe foobar2000.exe")
    if not WinExist("ahk_group MusicPlayers")
        musicGUI()
    if WinActive("ahk_group MusicPlayers")
        {
            GroupActivate "MusicPlayers", "r"
            loop {
                IME := WinGetTitle("A")
                if IME = "Default IME"
                    GroupActivate "MusicPlayers", "r"
                if IME != "Default IME"
                    break
            }
        }
    else
        if WinExist("ahk_group MusicPlayers")
            {
                WinActivate
                loop {
                    IME := WinGetTitle("A")
                    if IME = "Default IME"
                        WinActivate("ahk_group MusicPlayers")
                    if IME != "Default IME"
                        break
                }
            }
    ;window := WinGetTitle("A") ;debugging
    ;toolCust(window, "1000") ;debugging
}

/*
 This function creates a GUI for the user to select which media player they wish to open.
 Currently offers AIMP, Foobar, WMP & VLC.
 This function is also used within switchToMusic()
*/
musicGUI()
{
    if WinExist("Music to open?")
        return
    ;if there is no music player open, a custom GUI window will open asking which program you'd like to open
    MyGui := Gui("AlwaysOnTop", "Music to open?") ;creates our GUI window
    MyGui.SetFont("S10") ;Sets the size of the font
    MyGui.SetFont("W600") ;Sets the weight of the font (thickness)
    MyGui.Opt("-Resize +MinSize260x120 +MaxSize260x120") ;Sets a minimum size for the window
    ;#now we define the elements of the GUI window
    ;defining AIMP
    aimplogo := MyGui.Add("Picture", "w25 h-1 Y9", A_WorkingDir "\Support Files\images\aimp.png")
    AIMPGUI := MyGui.Add("Button", "X40 Y7", "AIMP")
    AIMPGUI.OnEvent("Click", AIMP)
    ;defining Foobar
    foobarlogo := MyGui.Add("Picture", "w20 h-1 X14 Y40", A_WorkingDir "\Support Files\images\foobar.png")
    FoobarGUI := MyGui.Add("Button", "X40 Y40", "Foobar")
    FoobarGUI.OnEvent("Click", Foobar)
    ;defining Windows Media Player
    wmplogo := MyGui.Add("Picture", "w25 h-1 X140 Y9", A_WorkingDir "\Support Files\images\wmp.png")
    WMPGUI := MyGui.Add("Button", "X170 Y7", "WMP")
    WMPGUI.OnEvent("Click", WMP)
    ;defining VLC
    vlclogo := MyGui.Add("Picture", "w28 h-1 X138 Y42", A_WorkingDir "\Support Files\images\vlc.png")
    VLCGUI := MyGui.Add("Button", "X170 Y40", "VLC")
    VLCGUI.OnEvent("Click", VLC)
    ;defining music folder
    folderlogo := MyGui.Add("Picture", "w25 h-1  X14 Y86", A_WorkingDir "\Support Files\images\explorer.png")
    FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
    FOLDERGUI.OnEvent("Click", MUSICFOLDER)
    ;add an invisible button since removing the default off all the others did nothing
    removedefault := MyGui.Add("Button", "Default X0 Y0 W0 H0", "_")
    ;#finished with definitions
    MyGui.Show()
    ;below is what happens when you click on each name
    AIMP(*) {
        Run("C:\Program Files (x86)\AIMP3\AIMP.exe")
        WinWait("ahk_exe AIMP.exe")
        WinActivate("ahk_exe AIMP.exe")
        MyGui.Destroy()
    }
    Foobar(*) {
        Run("C:\Program Files (x86)\foobar2000\foobar2000.exe")
        WinWait("ahk_exe foobar2000.exe")
        WinActivate("ahk_exe foobar2000.exe")
        MyGui.Destroy()
    }
    WMP(*) {
        Run("C:\Program Files (x86)\Windows Media Player\wmplayer.exe")
        WinWait("ahk_exe wmplayer.exe")
        WinActivate("ahk_exe wmplayer.exe")
        MyGui.Destroy()
    }
    VLC(*) {
        Run("C:\Program Files (x86)\VideoLAN\VLC\vlc.exe")
        WinWait("ahk_exe vlc.exe")
        WinActivate("ahk_exe vlc.exe")
        MyGui.Destroy()
    }
    MUSICFOLDER(*) {
        Run("S:\Program Files\User\Music\")
        WinWait("Music")
        WinActivate("Music")
        MyGui.Destroy()
    }
}

/* hotkeysGUI()
 This function calls a GUI to showcase some useful hotkeys available to the user while running my scripts. This function is also called during firstCheck()
 */
hotkeysGUI() {
    if WinExist("Handy Hotkeys - Tomshi Scripts")
        return
    hotGUI := Gui("", "Handy Hotkeys - Tomshi Scripts")
	hotGUI.SetFont("S11")
	hotGUI.Opt("-Resize AlwaysOnTop")
	Title := hotGUI.Add("Text", "H30 X8 W300", "Handy Hotkeys!")
	Title.SetFont("S15")

    ;all hotkeys
    selection := hotGUI.Add("ListBox", "r3 Choose1", ["#F1","#+r","#h"])
    selection.OnEvent("Change", text)

    selectionText := hotGUI.Add("Text", "W200 X180 Y42 H100", "Pulls up an informational window regarding the currently active scripts, as well as a quick and easy way to close/open any of them. Try it now!")
    text(*) {
        if selection.Value = 1
            {
                selectionText.Move(,, "200", "100")
                selectionText.Text := "Pulls up an informational window regarding the currently active scripts, as well as a quick and easy way to close/open any of them. Try it now!"
                hotGUI.Move(,, "410", "189")
            }
        if selection.Value = 2
            {
                selectionText.Move(,, "380", "220")
                selectionText.Text := "Will refresh all scripts! At anytime if you get stuck in a script press this hotkey to regain control.`n(note: refreshing will not stop scripts run separately ie. from a streamdeck as they are their own process and not included in the refresh hotkey).`nAlternatively you can also press ^!{del} (ctrl + alt + del) to access task manager, even if inputs are blocked"
                hotGUI.Move(,, "590", "220")
            }
        if selection.Value = 3
            {
                selectionText.Move(,, "200", "100")
                selectionText.Text := "Will call this GUI so you can reference these hotkeys at any time!"
                hotGUI.Move(,, "410", "189")
            }      
    }

    ;buttons
    ;remove the default
	noDefault := hotGUI.Add("Button", "X0 Y0 W0 H0", "")
    ;close button
	closeButton := hotGUI.Add("Button", "X8 Y110", "Close")
	closeButton.OnEvent("Click", close)
    ;what happens when you close the GUI
    hotGUI.OnEvent("Escape", close)
    hotGUI.OnEvent("Close", close)
    ;onEvent Functions
	close(*) {
		hotGUI.Destroy()
	}
    ;Show the GUI
	hotGUI.Show("AutoSize")
}