; { \\ #Includes
#Include <Classes\Settings>
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

    aimpObj := {
        path: ptf.ProgFi32 "\AIMP\AIMP.exe",                   image: ptf.guiIMG "\aimp.png",
        opts: "x12 w25 h-1 Y9",                                 title: "AIMP",
        buttonSize: "X40 Y7"
    }
    foobarObj := {
        path: ptf.ProgFi32 "\foobar2000\foobar2000.exe",        image: ptf.guiIMG "\foobar.png",
        opts: "w20 h-1 X14 Y40",                                 title: "Foobar",
        buttonSize: "X40 Y40"
    }
    wmpObj := {
        path: ptf.ProgFi32 "\Windows Media Player\wmplayer.exe", image: ptf.guiIMG "\wmp.png",
        opts: "w25 h-1 X140 Y9",                                 title: "WMP",
        buttonSize: "X170 Y7"
    }
    vlcObj := {
        path: ptf.ProgFi "\VideoLAN\VLC\vlc.exe",                image: ptf.guiIMG "\vlc.png",
        opts: "w28 h-1 X138 Y42",                                title: "VLC",
        buttonSize: "X170 Y40"
    }

    objArr := [aimpObj, foobarObj, wmpObj, vlcObj]

    ;// if there is no music player open, a custom GUI window will open asking which program you'd like to open
    MyGui := tomshiBasic(10, 600, "AlwaysOnTop -Resize +MinSize260x120 +MaxSize260x120", "Music to open?") ;creates our GUI window

    ;// now we define the elements of the GUI window
    for musicObj in objArr {
        MyGui.AddPicture(musicObj.opts, musicObj.image)
        MyGui.AddButton(musicObj.buttonSize, musicObj.title).OnEvent("Click", musicRun)
    }

    ;defining music folder
    folderlogo := MyGui.AddPicture("w25 h-1  X14 Y86", ptf.guiIMG "\explorer.png")
    FOLDERGUI := MyGui.Add("Button", "X42 Y85", "MUSIC FOLDER")
    FOLDERGUI.OnEvent("Click", MUSICFOLDER)

    ;#finished with definitions

    MyGui.Show()
    ;below is what happens when you click on each button
    musicRun(button, *)
    {
        text := button.Text
        try {
            switch button.Text {
                case "AIMP": Run(aimpObj.path)
                case "Foobar":
                    Run(foobarObj.path)
                    text := "foobar2000"
                case "WMP":
                    Run(wmpObj.path)
                    text := "wmplayer"
                case "VLC": Run(vlcObj.path)
            }
            WinWait("ahk_exe " text ".exe")
            WinActivate("ahk_exe " text ".exe")
        } catch {
            MyGui.Destroy()
            MsgBox("Desired application not found!",, "16")
            return
        }
        MyGui.Destroy()
    }

    MUSICFOLDER(*) {
        if !DirExist(ptf.musicDir) {
            scriptPath :=  A_LineFile ;this is taking the path given from A_LineFile
            script := obj.SplitPath(scriptPath) ;and splitting it out into just the .ahk filename
            MsgBox("The requested music folder doesn't exist`n`nDesired Dir should be defined in ``ptf {``")
            MyGui.Destroy()
            return
        }
        Run(ptf.musicDir)
        if !WinWait("Music",, 2)
            return
        WinActivate("Music")
        MyGui.Destroy()
    }
}