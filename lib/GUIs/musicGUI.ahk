; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\ptf>
#Include <Classes\dark>
#Include <Classes\obj>
; }

/**
 * This function creates a GUI for the user to select which media player they wish to open.
 *
 * Currently offers AIMP, Foobar, WMP & VLC.
 *
 * This function is also used within switchTo.Music()
*/
musicGUI()
{
    if WinExist("Music to open?")
        return

    aimpPath := ptf.ProgFi32 "\AIMP3\AIMP.exe"
    foobarPath := ptf.ProgFi32 "\foobar2000\foobar2000.exe"
    wmpPath := ptf.ProgFi32 "\Windows Media Player\wmplayer.exe"
    vlcPath := ptf.ProgFi "\VideoLAN\VLC\vlc.exe"

    ;if there is no music player open, a custom GUI window will open asking which program you'd like to open
    MyGui := tomshiBasic(10, 600, "AlwaysOnTop -Resize +MinSize260x120 +MaxSize260x120", "Music to open?") ;creates our GUI window
    ;#now we define the elements of the GUI window
    ;defining AIMP
    aimplogo := MyGui.AddPicture("x12 w25 h-1 Y9", ptf.guiIMG "\aimp.png")
    AIMP := MyGui.Add("Button", "X40 Y7", "AIMP")
    AIMP.OnEvent("Click", musicRun)
    ;defining Foobar
    foobarlogo := MyGui.AddPicture("w20 h-1 X14 Y40", ptf.guiIMG "\foobar.png")
    foobar := MyGui.Add("Button", "X40 Y40", "Foobar")
    foobar.OnEvent("Click", musicRun)
    ;defining Windows Media Player
    wmplogo := MyGui.AddPicture("w25 h-1 X140 Y9", ptf.guiIMG "\wmp.png")
    WMP := MyGui.Add("Button", "X170 Y7", "WMP")
    WMP.OnEvent("Click", musicRun)
    ;defining VLC
    vlclogo := MyGui.AddPicture("w28 h-1 X138 Y42", ptf.guiIMG "\vlc.png")
    VLC := MyGui.Add("Button", "X170 Y40", "VLC")
    VLC.OnEvent("Click", musicRun)
    ;defining music folder
    folderlogo := MyGui.AddPicture("w25 h-1  X14 Y86", ptf.guiIMG "\explorer.png")
    FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
    FOLDERGUI.OnEvent("Click", MUSICFOLDER)

    ;#finished with definitions

    if IniRead(ptf["settings"], "Settings", "dark mode") = "true"
        goDark()
    goDark()
    {
        dark.titleBar(MyGui.Hwnd)
        dark.button(AIMP.Hwnd)
        dark.button(foobar.Hwnd)
        dark.button(WMP.Hwnd)
        dark.button(VLC.Hwnd)
        dark.button(FOLDERGUI.Hwnd)
    }

    MyGui.Show()
    ;below is what happens when you click on each button
    musicRun(button, *)
    {
        text := button.Text
        switch button.Text {
            case "AIMP":
                Run(aimpPath)
            case "Foobar":
                Run(foobarPath)
                text := "foobar2000"
            case "WMP":
                Run(wmpPath)
                text := "wmplayer"
            case "VLC":
                Run(vlcPath)
        }
        WinWait("ahk_exe " text ".exe")
        WinActivate("ahk_exe " text ".exe")
        MyGui.Destroy()
    }

    MUSICFOLDER(*) {
        if DirExist(ptf.musicDir)
            {
                Run(ptf.musicDir)
                WinWait("Music")
                WinActivate("Music")
            }
        else
            {
                scriptPath :=  A_LineFile ;this is taking the path given from A_LineFile
                script := obj.SplitPath(scriptPath) ;and splitting it out into just the .ahk filename
                MsgBox("The requested music folder doesn't exist`n`nWritten dir: " ptf.musicDir "`nScript: " script.Name "`nLine: " A_LineNumber-11)
            }
        MyGui.Destroy()
    }
}