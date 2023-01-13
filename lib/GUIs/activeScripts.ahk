; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\dark>
#Include <Classes\ptf>
#Include <Functions\On_WM_MOUSEMOVE>
;

/**
 * This functions pulls up a GUI that shows which of my scripts are active and allows the user to suspend/close them or unsuspend/open them
 */
activeScripts(MyRelease)
{
    detect()
    if WinExist("Active Scripts " MyRelease)
        return

    buttonX := 482
    margX := 8

    MyGui := tomshiBasic(,, "-Resize AlwaysOnTop", "Active Scripts " MyRelease)

    ;active scripts
    text := MyGui.Add("Text", "X" margX " Y8 W300 H20", "Current active scripts are:")
    text.SetFont("S13 Bold")

    scripts := ["myscript", "error", "dismiss", "save", "fullscreen", "game", "M-I_C", "premkey", "keyboard", "text", "resolve"]
    names := Map(
        scripts[1],      "My Scripts.ahk",
        scripts[2],      "Alt_menu_acceleration_DISABLER.ahk",
        scripts[3],      "autodismiss error.ahk",
        scripts[4],      "autosave.ahk",
        scripts[5],      "adobe fullscreen check.ahk",
        scripts[6],      "gameCheck.ahk",
        scripts[7],      "Multi-Instance Close.ahk",
        scripts[8],      "premKeyCheck.ahk",
        scripts[9],      "QMK Keyboard.ahk",
        scripts[10],      "textreplace.ahk",
        scripts[11],     "Resolve_Example.ahk",
    )
    tooltiptext := Map(
        scripts[1],      "Clicking this checkbox will toggle suspend the script",
        scripts[2],      "Clicking this checkbox will open/close the script",
    )

    createCheck()
    {
        moveOver := 6
        loop scripts.Length {
            if A_Index = 1
                {
                    MyGui.Add("CheckBox", "Section Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    MyGui[scripts[1]].OnEvent("Click", myClick)
                    MyGui[scripts[1]].ToolTip := tooltiptext[scripts[1]]
                }
            else if A_Index != scripts.Length && A_Index < moveOver ;first row
                {
                    MyGui.Add("CheckBox", "xs Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    MyGui[scripts[A_Index]].OnEvent("Click", scriptClick)
                    MyGui[scripts[A_Index]].ToolTip := tooltiptext[scripts[2]]
                }
            else if A_Index >= moveOver ;second row
                {
                    if A_Index = scripts.Length ;for resolve (the last item)
                        {
                            MyGui[scripts[moveOver-1]].GetPos(, &firstRowLastY) ;get ypos of the last checkbox in the first row
                            resolveY := firstRowLastY + 35
                            MyGui.Add("CheckBox", "x" margX " Checked0 Y" resolveY " v" scripts[A_Index], names[scripts[A_Index]])
                            MyGui[scripts[A_Index]].OnEvent("Click", scriptClick)
                            MyGui[scripts[A_Index]].ToolTip := tooltiptext[scripts[2]]
                        }
                    ;second row
                    else if A_Index = moveOver
                        MyGui.Add("CheckBox", "x+120 ys Section Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    else ;everything else
                        MyGui.Add("CheckBox", "xs Checked0 v" scripts[A_Index], names[scripts[A_Index]])
                    MyGui[scripts[A_Index]].OnEvent("Click", scriptClick)
                    MyGui[scripts[A_Index]].ToolTip := tooltiptext[scripts[2]]
                }
        }
        loop scripts.Length {
            pictureX := 275
            if A_Index = 1
                MyGui.Add("Picture", "w18 h-1 X" pictureX " Ys", ptf.Icons "\" scripts[A_Index] ".png")
            else if A_Index < moveOver ;first row
                {
                    switch scripts[A_Index] {
                        case "dismiss":
                            y := "+5"
                        default:
                            type := ".ico"
                            y := "+7"
                    }
                    MyGui.Add("Picture", "w18 h-1 Y" y, ptf.Icons "\" scripts[A_Index] type)
                }
            else if A_Index >= moveOver ;second row
                {
                    switch scripts[A_Index] {
                        case "game":
                            type := ".png"
                        case "M-I_C" :
                            type := ".png"
                            y := "+5"
                        case "resolve":
                            type := ".png"
                            y := "+11"
                        case "text":
                            type := ".png"
                            y := "+4"
                        case "premkey":
                            type := ".png"
                            y := "+4"
                        default:
                            type := ".ico"
                            y := "+7"
                    }
                    if A_Index = scripts.Length ;for resolve (the last item)
                        MyGui.Add("Picture", "x" pictureX " w18 h-1 Y" resolveY, ptf.Icons "\" scripts[A_Index] type)
                    else if A_Index = moveOver ;second row
                        MyGui.Add("Picture", "xs+200 w18 h-1 Ys", ptf.Icons "\" scripts[A_Index] type)
                    else ;everything else
                        MyGui.Add("Picture", "w18 h-1 Y" y, ptf.Icons "\" scripts[A_Index] type)
                }
        }
    }
    createCheck()

    SetTimer(checkScripts, -100)

    ;close button
    MyGui[scripts[scripts.Length]].GetPos(, &resolveHeight) ;get ypos of resolve checkbox (the last item)
    buttonHeight := resolveHeight - 10
    closeButton := MyGui.Add("Button", "X" buttonX " Y" buttonHeight, "Close")
    closeButton.OnEvent("Click", escape)

    if IniRead(ptf["settings"], "Settings", "dark mode") = "true"
        goDark()

    goDark() => dark.button(closeButton.Hwnd)

    ;the below code allows for the tooltips on hover
    ;code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
    OnMessage(0x0200, On_WM_MOUSEMOVE)

    ;below is all of the callback functions
    myClick(*) => Suspend(-1)

    scriptClick(script, *) {
        detect()
        val := script.Value
        if val != 1
            {
                WinClose(script.text " - AutoHotkey")
                return
            }
        if script.text = "QMK Keyboard.ahk" || script.text = "Resolve_Example.ahk"
            Run(ptf.rootDir "\" script.text)
        else if script.text = "textreplace.ahk"
            {
                if ptf.rootDir = "E:\Github\ahk" && A_UserName = "Tom" && A_ComputerName = "TOM" && DirExist(ptf.SongQueue) ;I'm really just trying to make sure the stars don't align and this line fires for someone other than me
                    Run(ptf["textreplace"])
                else
                    Run(ptf["textreplaceUser"])
            }
        else
            Run(ptf.TimerScripts "\" script.text)
    }

    checkScripts(*)
    {
        detect()
        if WinExist("My Scripts.ahk is Suspended")
            WinWaitClose("My Scripts.ahk is Suspended")

        MyGui[scripts[1]].Value := (A_IsSuspended = 0) ? 1 : 0
        loop scripts.Length - 1 {
            MyGui[scripts[A_Index + 1]].Value := WinExist(names[scripts[A_Index + 1]] " - AutoHotkey") ? 1 : 0
        }
        SetTimer(, -100)
    }

    MyGui.OnEvent("Escape", escape)
    MyGui.OnEvent("Close", escape)
    escape(*) {
        SetTimer(checkScripts, 0)
        MyGui.Destroy()
    }

    MyGui.Show("Center AutoSize")
}