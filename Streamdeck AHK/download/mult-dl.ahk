/************************************************************************
 * @description a small gui to quickly download videos in multiple different ways
 * @author tomshi
 * @date 2026/03/10
 ***********************************************************************/
global currentVer := "1.3.6"
A_ScriptName := "Multi Download"
preReqTitle := "Prerequisites Required"
;@Ahk2Exe-SetMainIcon E:\Github\ahk\Support Files\Icons\myscript.ico
;@Ahk2Exe-SetCompanyName Tomshi
;@Ahk2Exe-SetCopyright Copyright (C) 2025
;@Ahk2Exe-SetDescription GUI to interact with yt-dlp in different ways

#Requires AutoHotkey v2.0
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ytdlp.ahk
#Include Classes\switchTo.ahk
#Include Classes\explorer.ahk
#Include Classes\cmd.ahk
#Include GUIs\tomshiBasic.ahk
#Include Functions\useNVENC.ahk
#Include Functions\getLocalVer.ahk
#Include Functions\isURL.ahk
#Include Other\LVICE_XXS.ahk
; }

#SingleInstance Off
if win := WinExist(A_ScriptName) || win := WinExist(preReqTitle) {
    WinActivate(win)
    ExitApp()
}

try {
    if !A_IsCompiled && FileExist(ptf.Icons "\myscript.ico")
        TraySetIcon(ptf.Icons "\multDL.ico")
}

class multiDL extends tomshiBasic {
    __New() {
        __checkInstalls(&ffmpeg, &ytdlp, &deno) {
            ffmpeg := cmd.result(Format(this.checkCommand, "ffmpeg"))
            ytdlp  := cmd.result(Format(this.checkCommand, "yt-dlp"))
            deno   := cmd.result(Format(this.checkCommand, "deno"))
        }
        __checkInstalls(&ffmpeg, &ytdlp, &deno)
        ffmpeg := (!InStr(ffmpeg, "is not recognized") && ffmpeg != "")  ? true : false
        ytdlp  := (!InStr(ytdlp, "is not recognized")  && ytdlp != "")   ? true : false
        deno   := (!InStr(deno, "is not recognized")   && deno != "")    ? true : false

        if !ffmpeg || !ytdlp || !deno {
            choco := cmd.result(Format(this.checkCommand, "choco"))
            choco := (!InStr(choco, "is not recognized") && choco != "") ? true : false
            if choco = true {
                super.__New(,,, preReqTitle)
                this.AddText(, "Installing these prerequisites will require admin permissions. `nYou may also need to reboot after installation.")
                for v in this.arr {
                    if v = "yt-dlp"
                        v := "ytdlp"
                    this.AddText("x5", v ":")
                    this.AddButton("xm+70 yp-7 w100 h30 v" v, "Install " v)
                    this[v].OnEvent("Click", this.__install_tool.Bind(this, v))
                    if v = "deno"
                        this.AddText("x+10 y+-23", "(yt-dlp requirement)")
                    if %v% != false {
                        this[v].Opt("Disabled")
                        this[v].text := "done"
                    }
                }

                this.OnEvent("Escape", __checkInstalled.Bind(this))
                this.OnEvent("Close", __checkInstalled.Bind(this))
                this.show()
                __checkInstalled(*) {
                    if this["choco"].text != "done" || this["ffmpeg"].text != "done" || this["ytdlp"].text != "done" || this["deno"].text != "done"
                        ExitApp()
                    Reload()
                }
                WinWaitClose(this.Title)
            }
        }
        checkClipboard := isURL(A_Clipboard) ? A_Clipboard : ""
        this.requiredFilesDir := A_MyDocuments "\tomshi\multDL"
        if !DirExist(this.requiredFilesDir)
            DirCreate(this.requiredFilesDir)
        defaulDlFodler := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "{374DE290-123F-4565-9164-39C4925E467B}", EnvGet("USERPROFILE") "\Downloads") "\tomshi"
        dlFolder  := (FileExist(this.requiredFilesDir "\defaultDLLocation")) ? (DirExist(prevFile := FileRead(this.requiredFilesDir "\defaultDLLocation")) ? prevFile : defaulDlFodler) : __createDefault(this.requiredFilesDir "\defaultDLLocation", defaulDlFodler)
        devBranch := (FileExist(this.requiredFilesDir "\devBranch")) ? FileRead(this.requiredFilesDir "\devBranch") : __createDefault(this.requiredFilesDir "\devBranch", "1")
        __createDefault(filename, defaultReturn) {
            FileAppend("1", filename)
            return defaultReturn
        }
        this.getFile := dlFolder
        super.__New(,,, A_ScriptName)

        startY := 110
        this.tabs := this.AddTab3("+Theme -Background x9 y" startY, ["Single", "Multi", "Part"])

        ;// single
        ;// ================================================================
        but_width := 150
        this.AddText("Section x25 y" startY+35, "URL: ")
        this.AddEdit("x+82 y+-20 r1 vsingleURL w220 -Wrap", checkClipboard)
        this.AddText("xs", "Custom Filename: ")
        this.AddEdit("x+5 y+-20 r1 vcustFileSingle w220 -Wrap")
        this.AddButton("vDL_single xs w" but_width, "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise_single", " Avoid reencode`n (may result in lower quality)")
        this.AddCheckbox("yp+40 vdlPlay_single Checked0", " Download Playlist")
        this.AddCheckbox("yp+25 vcookies_single Checked0", " Use cookies (firefox)")
        this["DL_single"].GetPos(&x, &y, &wid, &height)
        this.AddButton("vAud_single x" x " y" y+37 " w" but_width, "Download Audio").OnEvent("Click", this.__download.Bind(this, "aud"))
        this.AddButton("vthumb_single x" x " -Wrap y+7 w" but_width, "Download Thumbnail").OnEvent("Click", this.__download.Bind(this, "thumb"))
        ;// ================================================================

        ;// multi
        ;// ================================================================
        this.tabs.UseTab("Multi")

        this.AddText("Section x25 y" startY+35, "URL: ")
        this.AddEdit("x+12 y+-20 r1 vlistURL w165 -Wrap", checkClipboard)
        this.AddButton("x+10 y+-27", "Add").OnEvent("Click", this.__addListURL.Bind(this))
        this.AddListView("x25 y+5 r5 vlist w340 Grid -Multi NoSort -ReadOnly -Hdr", ["URL"])
        this["list"].OnEvent("ContextMenu", listContextMenu.Bind(this))
        ContextMenu := Menu()
        ContextMenu.Add("Remove", listRemove)
        listContextMenu(self, LV, Item, IsRightClick, X, Y) {
            if item = 0
                return
            ContextMenu.Show(X, Y)
        }
        listRemove(*) {
            this["list"].Delete(this["list"].GetNext(, "F"))
        }
        this.AddButton("vDL w" but_width, "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise", " Avoid reencode`n (may result in lower quality)")
        this.AddCheckbox("yp+40 vdlPlay_multi Checked0", " Download Playlist")
        this.AddCheckbox("yp+25 vcookies_multi Checked0", " Use cookies (firefox)")
        this["DL"].GetPos(&x, &y, &wid, &height)
        this.AddButton("vAud x" x " y" y+37 " w" but_width, "Download Audio").OnEvent("Click", this.__download.Bind(this, "aud"))
        this.AddButton("vthumb x" x " y+7 w" but_width, "Download Thumbnail").OnEvent("Click", this.__download.Bind(this, "thumb"))
        ;// ================================================================

        ;// Part
        ;// ================================================================
        this.tabs.UseTab("Part")
        this.AddText("Section x25 y" startY+35, "URL: ")
        this.AddEdit("x+82 y+-20 r1 vpartURL w220 -Wrap", checkClipboard)
        this.AddText("xs", "Custom Filename: ")
        this.AddEdit("x+5 y+-20 r1 vcustFilePart w220 -Wrap")
        this.AddText("xs Wrap w280", "Please provide the timecode that all content you wish to download sits within.")

        loop 2 {
            this.AddText(((A_Index = 1) ? "" : "xs y+15 ") "Section", (A_Index = 1) ? "Start Timecode:   H" : "End Timecode:    H")
            this.AddEdit("xs+120 ys-3 w50 Number Limit2")
            this.AddUpDown("vH" A_Index " Range0-11 ", 0)

            this.AddText("x+10 ys", "M")
            this.AddEdit("x+5 ys-3 w50 Number Limit2")
            this.AddUpDown("vM" A_Index " Range0-59 ", 0)

            this.AddText("x+10 ys", "S")
            this.AddEdit("x+5 ys-3 w50 Number Limit2")
            this.AddUpDown("vS" A_Index " Range0-59 ", 0)
        }
        this.AddButton("vDL_part xs", "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise_part", " Avoid reencode`n (may result in lower quality)")
        this.AddCheckbox("yp+40 vcookies_part Checked0", " Use cookies (firefox)")
        this["DL_part"].GetPos(&x, &y, &wid, &height)
        this.AddButton("vAud_part x" x " y" y+37 " w" wid, "Download Audio").OnEvent("Click", this.__download.Bind(this, "aud"))
        ;// ================================================================

        this["list"].GetPos(&listx, &listy, &listwid, &listheight)
        this.tabs.UseTab(0)

        ;// Setting version text & Update Button to the top of the window
        this.AddText("vVerText Right BackgroundTrans y" startY+5 " x" listx " w" listwid, "v" currentVer)
        this["VerText"].GetPos(&verx, &very, &verwid, &verheight)
        this["VerText"].Move(verx+(verwid*0.725), very, verwid/3, verheight)
        this.AddButton("vupdates x9 y7", "Check for updates").OnEvent("Click", this.__checkUpdates.Bind(this))
        this["updates"].Opt("Disabled")
        this.AddCheckbox("vcheckDev x+10 yp+7 Checked" devBranch, "check dev branch").OnEvent("Click", (ctrl, *) => (FileDelete(this.requiredFilesDir "\devBranch"), FileAppend(ctrl.value, this.requiredFilesDir "\devBranch")))

        ;// adding current folder path
        this.AddText("BackgroundTrans x9 yp+35", "Current Download Path").SetFont("underline")
        this.AddButton("x+15 w60 h25 y+-18", "change").OnEvent("Click", this.__changeDlDir.bind(this))
        this.AddButton("x+6 w60 h25 y+-25", "show").OnEvent("Click", (*) => (Run(this.getFile)))
        showDir := this.__cullDirectory(this.getFile)
        this.AddText("vCurrDir BackgroundTrans x9 y+5 h50 r1 w" listwid+10, showDir)
        this["currDir"].SetFont("Bold s10")

        this.show(, {DarkColour: "F0F0F0"})
        LVICE := LVICE_XXS(this["list"])

        ;// attempt check package updates
        ;// ================================================================
        choco  := cmd.result(Format(this.checkCommand, "choco"))
        this.chkDevObj := this.__getPosObj("checkDev")
        this.updObj    := this.__getPosObj("updates")
        this.__checkingButton("move")
        this["checkDev"].Opt("Disabled")

        if (!InStr(choco, "is not recognized") && choco != "") {
            buildStr := this.__buildUpdateCmd()
            if buildStr != "" {
                if MsgBox("Updates for installed packages are available, would you like to install them now?",, 0x4) = "No" {
                    this["updates"].Opt("-Disabled")
                    this["checkDev"].Opt("-Disabled")
                    this.__checkingButton("reset")
                    return
                }
                this.Opt("Disabled")
                cmd.run(true,,, buildStr)
                this.Opt("-Disabled")
                try WinActivate(this.title)
            }
            this.__checkExeUpdate()
        }
        this["updates"].Opt("-Disabled")
        this["checkDev"].Opt("-Disabled")
        this.__checkingButton("reset")
        ;// ================================================================
    }

    requiredFilesDir := ""
    getFile := ""
    arr := ["choco", "ffmpeg", "yt-dlp", "deno"]
    chkDevObj := unset
    updObj := unset
    tabs := unset
    timecodeValue := ""
    defaultListText := "Paste all desired URLs here separated by commas and they will be downloaded one by one.`nThis process may additionally need to reencode most files."
    checkCommand := 'powershell -c "$env:Path = [System.Environment]::GetEnvironmentVariable(`'Path`',`'Machine`') + `';`' + [System.Environment]::GetEnvironmentVariable(`'Path`',`'User`'); Get-Command -Name {1} -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"'

    __getPosObj(ctrl) {
        this[ctrl].GetPos(&x, &y, &width, &height)
        return {x: x, y: y, width: width, height: height}
    }

    __changeDlDir(*) {
        if !newFile := FileSelect("D2",, "Select download location")
            return false
        this.getFile := newFile
        this["currDir"].text := this.__cullDirectory(this.getFile)
        if FileExist(this.requiredFilesDir "\defaultDLLocation")
            FileDelete(this.requiredFilesDir "\defaultDLLocation")
        FileAppend(this.getFile, this.requiredFilesDir "\defaultDLLocation")
    }

    __addListURL(*) {
        if this["listURL"].text = ""
            return
        if !isURL(this["listURL"].text) {
            MsgBox("Value is not a valid URL string",, "4112")
            return
        }
        this["list"].Add("", this["listURL"].text)
        this["listURL"].text := ""
        this["listURL"].Focus()
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

    __cullDirectory(Path) {
        return cull := (stringLen := StrLen(Path) > 37) ? SubStr(Path, 1, 3) ".." SubStr(Path, InStr(Path, "\",, -1, -1)) : Path
    }

    __download(vidOrAud, *) {
        this["DL"].Enabled := false, this["Aud"].Enabled := false, this["thumb"].Enabled := false
        this["DL_single"].Enabled := false, this["Aud_single"].Enabled := false, this["thumb_single"].Enabled := false
        this["DL_part"].Enabled := false, this["Aud_part"].Enabled := false
        cookiesSingle  := ((this["cookies_single"].value = 1) ? "--cookies-from-browser firefox" : "")
        cookiesMulti   := ((this["cookies_multi"].value = 1)  ? "--cookies-from-browser firefox" : "")
        cookiesPart    := ((this["cookies_part"].value = 1)   ? "--cookies-from-browser firefox" : "")
        dlPlaySingle   := ((this["dlPlay_single"].value = 1) ? true : false)
        dlPlayMulti    := ((this["dlPlay_multi"].value = 1) ? true : false)
        custFileSingle := (this["custFileSingle"].value = "") ? "" : this["custFileSingle"].value
        custFilePart   := (this["custFilePart"].value = "")   ? "" : this["custFilePart"].value
        yt := ytdlp()
        showDir := true
        switch this.tabs.value {
            case 1: ;// single
                if this["singleURL"].value = "" {
                    showDir := false
                    yt.doAlert := false
                    goto break
                }
                this.Hide()
                switch {
                        case (vidOrAud = "vid" && this["deprioritise_single"].value = false): yt.download(yt.defaultVideoCommand, this.getFile, this["singleURL"].value, custFileSingle, showDir,, cookiesSingle, dlPlaySingle)
                        case (vidOrAud = "vid" && this["deprioritise_single"].value = true):
                            altCommand := '-N 8 -o "{1}" -f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --verbose --windows-filenames --merge-output-format mp4 ' cookiesSingle
                            yt.download(altCommand, this.getFile, this["singleURL"].value, custFileSingle, showDir,, "", dlPlaySingle)
                        case (vidOrAud = "aud"): yt.download(yt.defaultAudioCommand, this.getFile, this["singleURL"].value, custFileSingle, showDir,, cookiesSingle, dlPlaySingle)
                        case (vidOrAud = "thumb"): yt.download("--write-thumbnail --skip-download", this.getFile, this["singleURL"].value, custFileSingle, showDir,, cookiesSingle, dlPlaySingle)
                    }
            case 2: ;// multi
                values := this["list"].GetCount()
                if values = 0 {
                    yt.doAlert := false
                    goto break
                }
                this.Hide()
                list := []
                loop values {
                    list.Push(this["list"].GetText(A_Index))
                }
                for v in list {
                    switch {
                        case (vidOrAud = "vid" && this["deprioritise"].value = false): yt.download(yt.defaultVideoCommand, this.getFile, v,, false,, cookiesMulti, dlPlayMulti)
                        case (vidOrAud = "vid" && this["deprioritise"].value = true):
                            altCommand := '-N 8 -o "{1}" -f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --verbose --windows-filenames --merge-output-format mp4 ' cookiesMulti
                            yt.download(altCommand, this.getFile, v,, false,, "", dlPlayMulti)
                        case (vidOrAud = "aud"): yt.download(yt.defaultAudioCommand, this.getFile, v,, false,, cookiesMulti, dlPlayMulti)
                        case (vidOrAud = "thumb"): yt.download("--write-thumbnail --skip-download", this.getFile, v,, false,, cookiesMulti, dlPlayMulti)
                    }
                    ;// reduce the risk of youtube thinking you're a bot
                    pickDelay := Random(18, 26) "000"
                    sleep(pickDelay)
                }
            case 3: ;// part
                this.timecodeValue := (Format("{:02}", this["H1"].value) ":" Format("{:02}", this["M1"].value) ":" Format("{:02}", this["S1"].value) "-" Format("{:02}", this["H2"].value) ":" Format("{:02}", this["M2"].value) ":" Format("{:02}", this["S2"].value))
                if this.timecodeValue == "00:00:00-00:00:00" || this["partURL"].value = "" {
                    showDir := false
                    yt.doAlert := false
                    goto break
                }
                this.Hide()
                partCommand := Format('-N 8 -o "{1}" --download-sections "*{2}" -f "bestvideo+bestaudio/best" --verbose --windows-filenames --merge-output-format mp4 --recode-video mp4 ' cookiesPart, "{}", this.timecodeValue)
                switch {
                        case (vidOrAud = "vid" && this["deprioritise_part"].value = false): yt.download(partCommand, this.getFile, this["partURL"].value, custFilePart, showDir)
                        case (vidOrAud = "vid" && this["deprioritise_part"].value = true):
                            altCommand := Format('-N 8 -o "{1}" --download-sections "*{2}" -f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --verbose --windows-filenames --merge-output-format mp4 ' cookiesPart, "{}", this.timecodeValue)
                            yt.download(altCommand, this.getFile, this["partURL"].value, custFilePart, showDir)
                        case (vidOrAud = "aud"): yt.download(Format('-N 8 -o "{1}" --download-sections "*{2}" --verbose --windows-filenames --extract-audio --audio-format wav ' cookiesPart, "{}", this.timecodeValue), this.getFile, this["partURL"].value, custFilePart, showDir)
                    }
        }
        break:
        this["DL"].Enabled := true, this["Aud"].Enabled := true, this["thumb"].Enabled := true
        this["DL_single"].Enabled := true, this["Aud_single"].Enabled := true, this["thumb_single"].Enabled := true
        this["DL_part"].Enabled := true, this["Aud_part"].Enabled := true

        this.show(, {DarkColour: "F0F0F0"})
        yt := ""
    }

    __install_choco(*) {
        command := 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(`'https://community.chocolatey.org/install.ps1`'))'
        cmd.run(true,,, "powershell -c " command)
        this["choco"].text := "done"
        this["choco"].Opt("Disabled")
    }

    __checkChoco(*) {
        chkChoco := cmd.result(Format(this.checkCommand, "choco"))
        if (InStr(chkChoco, "is not recognized") || chkChoco = "") {
            MsgBox("Choco is required to install this tool, please install choco first")
            return false
        }
        return true
    }

    __install_tool(val, *) {
        if !this.__checkChoco()
            return
        dlVal := (val = "ytdlp") ? "yt-dlp" : val
        cmd.run(true,,, "choco install " dlVal " --yes")
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
        choco  := cmd.result(Format(this.checkCommand, "choco"))
        if (InStr(choco, "is not recognized") || choco = "") {
            MsgBox("Checking for updates for ffmpeg or yt-dlp requires the package manager chocolatey to be installed.")
            this.__checkExeUpdate()
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
        this.__checkExeUpdate()
        if updates = false {
            MsgBox("No updates available.")
        }
        WinActivate(this.Title)
        this.Opt("-Disabled")
        this.__checkingButton("reset")
    }

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
        } catch {
            MsgBox("An error occurred while attempting to update the exe. Please try again later")
            return
        }
    }
}

multiDL()