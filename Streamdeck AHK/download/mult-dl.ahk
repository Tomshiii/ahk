/************************************************************************
 * @description a small gui to quickly download multiple videos at once
 * @author tomshi
 * @date 2025/03/22
 ***********************************************************************/
global currentVer := "1.0.2"
A_ScriptName := "multi-dl"
;@Ahk2Exe-SetMainIcon E:\Github\ahk\Support Files\Icons\myscript.ico
;@Ahk2Exe-SetCompanyName Tomshi
;@Ahk2Exe-SetCopyright Copyright (C) 2025
;@Ahk2Exe-SetDescription GUI to download multiple video files at once

#Requires AutoHotkey v2.0
#Include <Functions\useNVENC>
#Include <Classes\ytdlp>
#Include <GUIs\tomshiBasic>
#Include <Functions\getLocalVer>

class multiDL extends tomshiBasic {
    __New() {
        choco  := cmd.result('powershell -c "Get-Command -Name choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        ffmpeg := cmd.result('powershell -c "Get-Command -Name ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        ytdlp  := cmd.result('powershell -c "Get-Command -Name yt-dlp -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')

        choco := (!InStr(choco, "is not recognized")   && choco != "")   ? true : false
        ffmpeg := (!InStr(ffmpeg, "is not recognized") && ffmpeg != "")  ? true : false
        ytdlp := (!InStr(ytdlp, "is not recognized")   && ytdlp != "")   ? true : false

        if !choco || !ffmpeg || !ytdlp {
            super.__New(,,, "Prerequisites Required")
            this.AddText(, "Installing these prerequisites will require admin permissions.")
            arr := ["choco", "ffmpeg", "ytdlp"]
            for v in arr {
                this.AddText("x5", v ":")
                this.AddButton("xm+70 yp-7 w100 h30 v" v, "Install " v)
                this[v].OnEvent("Click", this.__install_tool.Bind(this, v))
                if %v% != false {
                    this[v].Opt("Disabled")
                    this[v].text := "done"
                }
            }

            this.show()
            WinWaitClose(this.Title)
            this.Destroy()
        }
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Multi Download")

        this.AddEdit("y45 r10 vlist w320 Multi Wrap", "Paste all desired URLs here separated by commas and they will be downloaded one by one.`nThis process may additionally need to reencode most files.")
        this.AddButton("vDL", "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise", " Avoid reencode`n (may result in lower quality)")
        this["DL"].GetPos(&x, &y, &wid, &height)
        this.AddButton("x" x " y+7 w" wid, "Download Audio").OnEvent("Click", this.__download.Bind(this, "aud"))

        this["list"].GetPos(&listx, &listy, &listwid, &listheight)
        this.AddText("Right y28 x" listx " w" listwid, "v" currentVer)
        this.AddButton("vupdates x" listx " y7", "Check for updates").OnEvent("Click", this.__checkUpdates.Bind(this))
        this.AddCheckbox("vcheckDev x+10 yp+7", "check dev branch")
        this.show()
    }

    getFile := ""

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        if !newFile := FileSelect("D2",, "Select download location")
            return false
        this.getFile := newFile
        return true
    }

    __download(vidOrAud, *) {
        list := StrSplit(this["list"].value, [","], " `r`n")
        this["DL"].Enabled := false
        this.Hide()
        yt := ytdlp()
        for v in list {
            switch {
                case (vidOrAud = "vid" && this["deprioritise"].value = false): yt.download(yt.defaultVideoCommand, this.getFile, v, false)
                case (vidOrAud = "vid" && this["deprioritise"].value = true):
                    altCommand := '-N 8 -o "{1}" -f "bv*[vcodec!*=av01][vcodec!=av1][vcodec!*=vp9]+ba" --verbose --windows-filenames --merge-output-format mp4 --cookies-from-browser firefox'
                    yt.download(altCommand, this.getFile, v, false)
                case (vidOrAud = "aud"): yt.download(yt.defaultAudioCommand, this.getFile, v, false)
            }
        }
        this.show()
        this["DL"].Enabled := True
        yt.__activateDir(this.getFile)
        yt := ""
    }

    __install_choco(*) {
        command := 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(`'https://community.chocolatey.org/install.ps1`'))'
        cmd.run(true,,, "powershell -c " command)
        this["choco"].text := "done"
        this["choco"].Opt("Disabled")
    }

    __checkChoco(*) {
        chkChoco := cmd.result('powershell -c "Get-Command -Name choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        if (InStr(chkChoco, "is not recognized") || chkChoco != "") {
            MsgBox("Choco is required to install this tool, please install choco first")
            return false
        }
        return true
    }

    __install_tool(val, *) {
        if !this.__checkChoco()
            return
        installVal := (val = "ytdlp") ? "yt-dlp" : val
        cmd.run(true,,, "choco install " installVal)
        this[val].text := "done"
        this[val].Opt("Disabled")
    }

    __checkUpdates(*) {
        cmd.run(true,, true, 'choco upgrade chocolatey --yes && choco upgrade ffmpeg --yes && choco upgrade yt-dlp --yes && echo. && echo. && echo Updates Complete. You may now close this window')
        if !A_IsCompiled
            return
        if !DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        try {
            if FileExist(A_Temp "\tomshi\mult-dl.ahk")
                FileDelete(A_Temp "\tomshi\mult-dl.ahk")
            mainOrDev := (this["checkDev"].value = true) ? "dev" : "main"
            Download("https://raw.githubusercontent.com/Tomshiii/ahk/refs/heads/" mainOrDev "/Streamdeck%20AHK/download/mult-dl.ahk", A_Temp "\tomshi\mult-dl.ahk")
            readDl := FileRead(A_Temp "\tomshi\mult-dl.ahk")
            dlVer := getLocalVer(readDl,, "currentVer := ", '"')
            if VerCompare(dlVer, currentVer) > 0 {
                if MsgBox("New version of mult-dl.exe available, would you like to download it?",, 0x4) = "No"
                    return
                if !dlLoc := FileSelect("D3",, "Download mult-dl.exe")
                    return
                Download("https://github.com/Tomshiii/ahk/raw/refs/heads/" mainOrDev "/Streamdeck%20AHK/download/mult-dl.exe", dlLoc "\mult-dl.exe")
                MsgBox("Download Complete, please run the new file")
                ExitApp()
            }
        }
    }
}

multiDL()