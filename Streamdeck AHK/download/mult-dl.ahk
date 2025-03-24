/************************************************************************
 * @description a small gui to quickly download multiple videos at once
 * @author tomshi
 * @date 2025/03/24
 ***********************************************************************/
global currentVer := "1.0.6.1"
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
        ffmpeg := cmd.result('powershell -c "Get-Command -Name ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        ytdlp  := cmd.result('powershell -c "Get-Command -Name yt-dlp -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')

        ffmpeg := (!InStr(ffmpeg, "is not recognized") && ffmpeg != "")  ? true : false
        ytdlp := (!InStr(ytdlp, "is not recognized")   && ytdlp != "")   ? true : false

        if !ffmpeg || !ytdlp {
            choco := cmd.result('powershell -c "Get-Command -Name choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
            choco := (!InStr(choco, "is not recognized") && choco != "") ? true : false
            super.__New(,,, "Prerequisites Required")
            this.AddText(, "Installing these prerequisites will require admin permissions.")
            for v in this.arr {
                this.AddText("x5", v ":")
                this.AddButton("xm+70 yp-7 w100 h30 v" v, "Install " v)
                this[v].OnEvent("Click", this.__install_tool.Bind(this, v))
                if %v% != false {
                    this[v].Opt("Disabled")
                    this[v].text := "done"
                }
            }

            this.OnEvent("Escape", __checkInstalled.Bind(this))
            this.OnEvent("Close", __checkInstalled.Bind(this))
            this.show()
            __checkInstalled(*) {
                if this["choco"].text != "done" || this["ffmpeg"].text != "done" || this["yt-dlp"].text != "done"
                    ExitApp()
                Reload()
            }
            WinWaitClose(this.Title)
        }
        if !this.__selectFile(this)
            ExitApp()
        super.__New(,,, "Multi Download")

        this.AddEdit("x9 y50 r10 vlist w320 Multi Wrap", "Paste all desired URLs here separated by commas and they will be downloaded one by one.`nThis process may additionally need to reencode most files.")
        this.AddButton("vDL", "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise", " Avoid reencode`n (may result in lower quality)")
        this["DL"].GetPos(&x, &y, &wid, &height)
        this.AddButton("x" x " y+7 w" wid, "Download Audio").OnEvent("Click", this.__download.Bind(this, "aud"))

        this["list"].GetPos(&listx, &listy, &listwid, &listheight)
        this.AddText("Right y32 x" listx " w" listwid, "v" currentVer)
        this.AddButton("vupdates x" listx " y7", "Check for updates").OnEvent("Click", this.__checkUpdates.Bind(this))
        this["updates"].Opt("Disabled")
        this.AddCheckbox("vcheckDev x+10 yp+7", "check dev branch")
        this.show()

        ;// attempt check package updates
        choco  := cmd.result('powershell -c "Get-Command -Name choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        this.chkDevObj := this.__getPosObj("checkDev")
        this.updObj    := this.__getPosObj("updates")
        this.__checkingButton("move")

        if (!InStr(choco, "is not recognized") && choco != "") {
            buildStr := this.__buildUpdateCmd()
            if buildStr != "" {
                if MsgBox("Updates for installed packages are available, would you like to install them now?",, 0x4) = "No" {
                    this["updates"].Opt("-Disabled")
                    this.__checkingButton("reset")
                    return
                }
                this.Opt("Disabled")
                cmd.run(true,,, buildStr)
                this.Opt("-Disabled")
            }
        }
        this["updates"].Opt("-Disabled")
        this.__checkingButton("reset")
    }

    getFile := ""
    arr := ["choco", "ffmpeg", "yt-dlp"]
    chkDevObj := unset
    updObj    := unset

    __getPosObj(ctrl) {
        this[ctrl].GetPos(&x, &y, &width, &height)
        return {x: x, y: y, width: width, height: height}
    }

    /** Allows the user to change the file to operate on */
    __selectFile(*) {
        if !newFile := FileSelect("D2",, "Select download location")
            return false
        this.getFile := newFile
        return true
    }

    __buildUpdateCmd() {
        buildStr := ""
        newArr := this.arr.Clone()
        newArr.RemoveAt(1, 1)
        for v in newArr {
            cmnd := Format('choco outdated | Select-String "{1}"', v)
            getres := cmd.result("powershell -c " cmnd)
            if getres != ""
                buildStr := (buildStr = "") ? Format("choco upgrade chocolatey --yes && choco upgrade {1} --yes ", v) : Format("{1} && choco upgrade {2} --yes ", buildStr, v)
        }
        return buildStr
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
                    altCommand := '-N 8 -o "{1}" -f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --verbose --windows-filenames --merge-output-format mp4 --cookies-from-browser firefox'
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
        if (InStr(chkChoco, "is not recognized") || chkChoco = "") {
            MsgBox("Choco is required to install this tool, please install choco first")
            return false
        }
        return true
    }

    __install_tool(val, *) {
        if !this.__checkChoco()
            return
        cmd.run(true,,, "choco install " val " --yes")
        this[val].text := "done"
        this[val].Opt("Disabled")
    }

    __checkingButton(which, *) {
        switch which {
            case "move":
                this["updates"].text := "Checking for Updates..."
                this["updates"].Move(this.updObj.x, this.updObj.y, this.updObj.width+24, this.updObj.height)
                this["checkDev"].Move(this.chkDevObj.x+24, this.chkDevObj.y, this.chkDevObj.width, this.chkDevObj.height)
            case "reset":
                this["updates"].text := "Check for updates"
                this["updates"].Move(this.updObj.x, this.updObj.y, this.updObj.width, this.updObj.height)
                this["checkDev"].Move(this.chkDevObj.x, this.chkDevObj.y, this.chkDevObj.width, this.chkDevObj.height)
        }
    }

    __checkUpdates(*) {
        this.Opt("Disabled")
        this.__checkingButton("move")
        choco  := cmd.result('powershell -c "Get-Command -Name choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
        if (InStr(choco, "is not recognized") || choco = "") {
            MsgBox("Checking for updates for ffmpeg or yt-dlp requires the package manager chocolatey to be installed.")
            __checkExeUpdate()
            this.__checkingButton("reset")
            this.Opt("-Disabled")
            return
        }

        buildStr := this.__buildUpdateCmd()
        updates := false
        if buildStr != "" {
            updates := true
            cmd.run(true,,, buildStr)
        }
        WinActivate(this.Title)
        __checkExeUpdate()
        if updates = false {
            MsgBox("No updates available.")
        }
        WinActivate(this.Title)
        this.Opt("-Disabled")
        this.__checkingButton("reset")

        __checkExeUpdate() {
            if !A_IsCompiled {
                this.Opt("-Disabled")
                return
            }
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
                    updates := true
                    if MsgBox("New version of mult-dl.exe available, would you like to download it?",, 0x4) = "No"
                        return
                    if !dlLoc := FileSelect("D3",, "Download mult-dl.exe")
                        return
                    Download("https://github.com/Tomshiii/ahk/raw/refs/heads/" mainOrDev "/Streamdeck%20AHK/download/mult-dl.exe", dlLoc "\mult-dl_v" dlVer ".exe")
                    MsgBox("Download Complete, please run the new file")
                    ExitApp()
                }
            }
        }
    }
}

multiDL()