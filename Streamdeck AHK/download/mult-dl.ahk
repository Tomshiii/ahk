/************************************************************************
 * @description a small gui to quickly download videos in multiple different ways
 * @author tomshi
 * @date 2026/11/05
 ***********************************************************************/
global currentVer := "1.5.0"
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
    if !A_IsCompiled && FileExist(ptf.Icons "\multDL.ico")
        TraySetIcon(ptf.Icons "\multDL.ico")
}

class multiDL extends tomshiBasic {
    __New() {
        ffmpeg := this.__onPath("ffmpeg")
        ytdlp  := this.__onPath("yt-dlp")
        deno   := this.__onPath("deno")
        choco  := this.__onPath("choco")
        if ytdlp {
            ;// nightly builds have a 4-part version (2026.11.04.123456), stable has 3. No network needed
            ver := Trim(cmd.result("yt-dlp --version"), " `t`r`n")
            if ver != "" && !RegExMatch(ver, "^\d{4}\.\d{2}\.\d{2}\.\d+$") {
                if MsgBox("yt-dlp is installed but isn't on the nightly track.`nThis is recommended to ensure quick fixes.`n`nWould you like to update to the nightly track?", "Upgrade to Nightly?", "0x4 0x20 0x1000") = "No"
                    ExitApp()
                cmd.run(true,,, "choco uninstall yt-dlp && choco feature enable -n=useRememberedArgumentsForUpgrades && choco install yt-dlp --pre")
            }
        }

        if !ffmpeg || !ytdlp || !deno {
            choco := this.__onPath("choco")
            if choco {
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
        defCookies := (FileExist(this.requiredFilesDir "\useCookies")) ? FileRead(this.requiredFilesDir "\useCookies") : __createDefault(this.requiredFilesDir "\useCookies", "1")
        __createDefault(filename, defaultReturn) {
            FileAppend("1", filename)
            return defaultReturn
        }
        this.getFile := dlFolder
        super.__New(,,, A_ScriptName)

        startY := 110
        but_width := 150
        this.tabs := this.AddTab3("+Theme -Background x9 y" startY, ["Multi", "Part"])

        ;// multi
        ;// ================================================================
        this.tabs.UseTab("Multi")

        this.AddText("Section x25 y" startY+35, "URL: ")
        this.AddEdit("x+12 y+-20 r1 vlistURL w165 -Wrap", checkClipboard)
        this.AddButton("x+10 y+-27", "Add").OnEvent("Click", this.__addListURL.Bind(this))
        this.AddListView("x25 y+5 r5 vlist w340 Grid -Multi NoSort -ReadOnly -Hdr", ["Title", "Progress", "URL"])
        this["list"].ModifyCol(1, 215)
        this["list"].ModifyCol(2, 105)
        this["list"].ModifyCol(3, 0) ; hidden: holds the real URL
        this["list"].OnNotify(-12, this.__customDraw.Bind(this))   ; NM_CUSTOMDRAW
        this["list"].OnEvent("ContextMenu", listContextMenu.Bind(this))
        ContextMenu := Menu()
        ContextMenu.Add("Remove", listRemove)
        listContextMenu(self, LV, Item, IsRightClick, X, Y) {
            if item = 0
                return
            ContextMenu.Show(X, Y)
        }
        listRemove(*) {
            if this.downloading
                return
            this["list"].Delete(this["list"].GetNext(, "F"))
        }
        this.AddButton("vDL w" but_width, "Download Video").OnEvent("Click", this.__download.Bind(this, "vid"))
        this.AddCheckbox("x+10 yp-1 vdeprioritise", " Avoid reencode`n (may result in lower quality)")
        this.AddCheckbox("yp+40 vdlPlay_multi Checked0", " Download Playlist")
        this.AddCheckbox("yp+25 vcookies_multi  Checked" defCookies, " Use cookies (firefox)").OnEvent("Click", (ctrl, *) => (FileDelete(this.requiredFilesDir "\useCookies"), FileAppend(ctrl.value, this.requiredFilesDir "\useCookies")))
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
        this.AddCheckbox("yp+40 vcookies_part  Checked" defCookies, " Use cookies (firefox)").OnEvent("Click", (ctrl, *) => (FileDelete(this.requiredFilesDir "\useCookies"), FileAppend(ctrl.value, this.requiredFilesDir "\useCookies")))
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
        this.AddButton("vDirChange x+15 w60 h25 y+-18", "change").OnEvent("Click", this.__changeDlDir.bind(this))
        this.AddButton("x+6 w60 h25 y+-25", "show").OnEvent("Click", (*) => (Run(this.getFile)))
        showDir := this.__cullDirectory(this.getFile)
        this.AddText("vCurrDir BackgroundTrans x9 y+5 h50 r1 w" listwid+10, showDir)
        this["currDir"].SetFont("Bold s10")

        this.show(, {DarkColour: "F0F0F0"})
        this.OnEvent("Close", this.__onClose.Bind(this), -1)
        OnExit((*) => this.__killDownloads())

        this.lvice := LVICE_XXS(this["list"])
        ;// swap the lib's NM_DBLCLK handler for a wrapper that ignores the progress column
        this["list"].OnNotify(-3, this.lvice.DoubleClickFunc, 0)
        this["list"].OnNotify(-3, this.__listDblClick.Bind(this))

        ;// attempt check package updates
        ;// ================================================================
        this.chkDevObj := this.__getPosObj("checkDev")
        this.updObj    := this.__getPosObj("updates")
        this.__checkingButton("move")
        this["checkDev"].Opt("Disabled")

        if choco {
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

    downloading := false
    activeProc  := 0
    lvice := unset
    job := 0

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
        yt := ytdlp()
        yt.doAlert := false
        this["listURL"].Enabled := false
        if InStr(this["listURL"].text, ",") {
            urls := StrSplit(this["listURL"].text, ",", " `t")
            for v in urls {
                if SubStr(v, 1, 1) = '"' && SubStr(v, -1, 1) = '"'
                    v := SubStr(v, 2, StrLen(v)-2)
                if !isURL(v)
                    continue
                this.__addRow(v, yt)
            }
        } else if isURL(this["listURL"].text) {
            this.__addRow(this["listURL"].text, yt)
        } else {
            this["listURL"].Enabled := true
            MsgBox("Value is not a valid URL string",, "4112")
            return
        }
        this["listURL"].Enabled := true
        this["listURL"].text := ""
        this["listURL"].Focus()
    }

    /** adds a row showing the video title (falls back to the URL), with the real URL stored in the hidden column 3 */
    __addRow(url, yt) {
        title := ""
        try title := Trim(yt.__getTitle(url), " `t`r`n")
        this["list"].Add("", title != "" ? title : url, "", url)
    }

    __buildUpdateCmd() {
        outdated := cmd.result("choco outdated -r")
        buildStr := ""
        for v in ["ffmpeg", "yt-dlp", "deno"] {
            if !RegExMatch(outdated, "im)^" v "\|")
                continue
            if v = "yt-dlp"
                v := "yt-dlp --pre"
            buildStr := (buildStr = "") ? Format("choco upgrade chocolatey --yes && choco upgrade {1} --yes ", v) : Format("{1} && choco upgrade {2} --yes ", buildStr, v)
        }
        return buildStr
    }

    __cullDirectory(Path) {
        return cull := (stringLen := StrLen(Path) > 37) ? SubStr(Path, 1, 3) ".." SubStr(Path, InStr(Path, "\",, -1, -1)) : Path
    }

    __download(vidOrAud, *) {
        this["DL"].Enabled := false, this["Aud"].Enabled := false, this["thumb"].Enabled := false
        this["DL_part"].Enabled := false, this["Aud_part"].Enabled := false
        this["DirChange"].Enabled := false
        cookiesMulti   := ((this["cookies_multi"].value = 1)  ? "--cookies-from-browser firefox" : "")
        cookiesPart    := ((this["cookies_part"].value = 1)   ? "--cookies-from-browser firefox" : "")
        dlPlayMulti    := ((this["dlPlay_multi"].value = 1) ? true : false)
        custFilePart   := (this["custFilePart"].value = "")   ? "" : this["custFilePart"].value
        yt := ytdlp()
        showDir := true
        switch this.tabs.value {
            case 1: ;// multi
                rows := this["list"].GetCount()
                if rows = 0 {
                    yt.doAlert := false
                    goto break
                }
                this.downloading := true
                urls := [], titles := []
                loop rows {
                    urls.Push(this["list"].GetText(A_Index, 3))
                    titles.Push(this["list"].GetText(A_Index, 1))
                }
                for url in urls {
                    this.__multiDownload(A_Index, url, titles[A_Index], vidOrAud, cookiesMulti, dlPlayMulti, yt)
                    if A_Index < urls.Length {
                        ;// reduce the risk of youtube thinking you're a bot
                        this["list"].Modify(A_Index + 1, "Col2", "Queued")
                        Sleep(Random(18, 26) * 1000)
                    }
                }
                ;// remove finished rows, leave failed ones visible
                loop (n := this["list"].GetCount()) {
                    if this["list"].GetText(n - A_Index + 1, 2) = "100"
                        this["list"].Delete(n - A_Index + 1)
                }
                this.downloading := false
            case 2: ;// part
                this.timecodeValue := (Format("{:02}", this["H1"].value) ":" Format("{:02}", this["M1"].value) ":" Format("{:02}", this["S1"].value) "-" Format("{:02}", this["H2"].value) ":" Format("{:02}", this["M2"].value) ":" Format("{:02}", this["S2"].value))
                if this.timecodeValue == "00:00:00-00:00:00" || this["partURL"].value = "" {
                    showDir := false
                    yt.doAlert := false
                    goto break
                }
                this.Hide()
                partCommand := Format('-N 8 -o "{1}" --sleep-interval 3 --max-sleep-interval 13 --download-sections "*{2}" -f "bestvideo+bestaudio/best" --verbose --windows-filenames --merge-output-format mp4 --recode-video mp4 ' cookiesPart, "{}", this.timecodeValue)
                switch {
                        case (vidOrAud = "vid" && this["deprioritise_part"].value = false): yt.download(partCommand, this.getFile, this["partURL"].value, custFilePart, showDir)
                        case (vidOrAud = "vid" && this["deprioritise_part"].value = true):
                            altCommand := Format('-N 8 -o "{1}" --sleep-interval 3 --max-sleep-interval 13 --download-sections "*{2}" -f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --verbose --windows-filenames --merge-output-format mp4 ' cookiesPart, "{}", this.timecodeValue)
                            yt.download(altCommand, this.getFile, this["partURL"].value, custFilePart, showDir)
                        case (vidOrAud = "aud"): yt.download(Format('-N 8 -o "{1}" --sleep-interval 3 --max-sleep-interval 13 --download-sections "*{2}" --verbose --windows-filenames --extract-audio --audio-format wav ' cookiesPart, "{}", this.timecodeValue), this.getFile, this["partURL"].value, custFilePart, showDir)
                    }
        }
        break:
        this["DL"].Enabled := true, this["Aud"].Enabled := true, this["thumb"].Enabled := true
        this["DL_part"].Enabled := true, this["Aud_part"].Enabled := true
        this["DirChange"].Enabled := true

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
        if !this.__onPath("choco") {
            MsgBox("Choco is required to install this tool, please install choco first")
            return false
        }
        return true
    }

    __install_tool(val, *) {
        if !this.__checkChoco()
            return
        dlVal := (val = "ytdlp") ? "yt-dlp --pre" : val
        cmd.run(true,,, "choco feature enable -n=useRememberedArgumentsForUpgrades && choco install " dlVal " --yes")
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
        choco := this.__onPath("choco")
        if !choco {
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
            if FileExist(A_Temp "\tomshi\mult-dl.ahk")
                FileDelete(A_Temp "\tomshi\mult-dl.ahk")
            if VerCompare(dlVer, currentVer) > 0 {
                updates := true
                if MsgBox("New version of mult-dl.exe available, would you like to download it?",, 0x4) = "No"
                    return
                if !dlLoc := FileSelect("D3", A_ScriptDir, "Download mult-dl.exe")
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

    /** ==== The below functions are AI written/assisted for the progress bar functionality ==== */
    __getJob() {
        if this.job
            return this.job
        this.job := DllCall("CreateJobObject", "Ptr", 0, "Ptr", 0, "Ptr")
        info := Buffer(A_PtrSize = 8 ? 144 : 112, 0)          ; JOBOBJECT_EXTENDED_LIMIT_INFORMATION
        NumPut("UInt", 0x2000, info, 16)                       ; JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        DllCall("SetInformationJobObject", "Ptr", this.job, "Int", 9, "Ptr", info, "UInt", info.Size)
        return this.job
    }

    __killDownloads(*) {
        if this.job
            DllCall("TerminateJobObject", "Ptr", this.job, "UInt", 1)
    }

    __listDblClick(LV, lParam) {
        subItem := NumGet(lParam + A_PtrSize * 3, 4, "Int")   ; 0-based column
        if subItem != 0
            return
        this.lvice.DoubleClick(LV, lParam)
    }

    __multiDownload(row, url, title, vidOrAud, cookies, playlist, yt) {
        LV := this["list"]
        folder := RTrim(this.getFile, "\")
        if !DirExist(folder)
            DirCreate(folder)

        ;// use the list title as the filename, unless it's just the URL fallback or this is a playlist
        outName := yt.defaultFilename
        if !playlist && title != "" && title != url && !isURL(title) {
            clean := RegExReplace(title, '[<>:"/\\|?*\x00-\x1F]')
            clean := Trim(SubStr(StrReplace(clean, "%", "%%"), 1, 150), " .")
            if clean != ""
                outName := clean ".%(ext)s"
        }

        extra := cookies (playlist ? "" : " --no-playlist")
        base  := '-N 8 -o "' outName '" --windows-filenames --no-overwrites --encoding utf-8 --newline --progress '
            . '--progress-template "download:PROG|%(info.playlist_index)s|%(info.n_entries)s|%(info.format_id)s|%(progress._percent_str)s" '
            . '--print "after_move:FINAL %(filepath)s" '
        switch {
            case vidOrAud = "vid" && !this["deprioritise"].value:
                args := base '-f "bestvideo+bestaudio/best" --merge-output-format mp4 ' extra
                expected := 2   ;// video + audio streams
            case vidOrAud = "vid":
                args := base '-f "bv*[vcodec*=hevc]+ba/bv*[vcodec*=avc1]+ba" --merge-output-format mp4 ' extra
                expected := 2
            case vidOrAud = "aud":
                args := base '--extract-audio --audio-format wav ' extra
                expected := 1
            case vidOrAud = "thumb":
                args := base '--write-thumbnail --skip-download ' extra
                expected := 1
        }

        finalPaths := [], item := 1, total := 1, fmt := "", stream := 1, shown := -1
        LV.Modify(row, "Col2", 0)

        onLine(line) {
            if RegExMatch(line, "PROG\|([^|]*)\|([^|]*)\|([^|]*)\|\s*([\d.]+)%", &m) {
                idx   := IsInteger(m[1]) ? Integer(m[1]) : 1      ; "NA" when it isn't a playlist
                total := IsInteger(m[2]) ? Integer(m[2]) : 1
                if idx != item {
                    item := idx, stream := 1, fmt := m[3]          ; new playlist item
                } else if m[3] != fmt {
                    if fmt != ""
                        stream++                                   ; second stream (audio) of the same item
                    fmt := m[3]
                }
                within  := Min(1, ((stream - 1) + Float(m[4]) / 100) / expected)
                overall := Min(99, Floor(((item - 1) + within) / total * 100))
                if overall != shown {
                    shown := overall
                    LV.Modify(row, "Col2", overall)
                }
            } else if RegExMatch(line, "^FINAL\s+(.+)$", &m)
                finalPaths.Push(Trim(m[1]))
        }

        exitCode := this.__runStream(Format('yt-dlp {1} -P "{2}" "{3}"', args, folder, url), onLine)
        partial := (exitCode != 0 && finalPaths.Length > 0)
        if exitCode != 0 && !partial {
            LV.Modify(row, "Col2", "Failed")
            return false
        }

        ;// reencode to h264 if needed
        if vidOrAud = "vid" {
            for finalPath in finalPaths {
                if !FileExist(finalPath)
                    continue
                LV.Modify(row, "Col2", "Checking codec...")
                codec := Trim(cmd.result(Format('ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "{1}"', finalPath)), " `t`r`n")
                if codec != "h264" && codec != "h265"
                    this.__reencode(finalPath, row, A_Index, finalPaths.Length, yt)
            }
        }
        LV.Modify(row, "Col2", 100)
        return true
    }

    /** reencodes a file to h264 in place, driving the blue bar from ffmpeg's -progress output */
    __reencode(path, row, idx, count, yt) {
        LV := this["list"]
        SplitPath(path, &name, &dir)
        temp := dir "\temp_" name
        label := "Reencode" (count > 1 ? " " idx "/" count : "")

        durTxt := Trim(cmd.result(Format('ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "{1}"', path)), " `t`r`n")
        duration := IsNumber(durTxt) ? Float(durTxt) : 0

        LV.Modify(row, "Col2", "E0|" label)
        shown := -1
        onLine(line) {
            if duration > 0 && RegExMatch(line, "^out_time_us=(\d+)", &m) {
                pct := Min(99, Floor(Integer(m[1]) / (duration * 1000000) * 100))
                if pct != shown {
                    shown := pct
                    LV.Modify(row, "Col2", "E" pct "|" label)
                }
            }
        }

        enc := (useNVENC() = true) ? yt.defaultGPU : yt.defaultCPU
        ffCmd := Format('ffmpeg -y -nostdin -loglevel error -nostats -progress pipe:1 -i "{1}" {2} -c:a aac -b:a 192k "{3}"', path, enc, temp)
        exitCode := this.__runStream(ffCmd, onLine)

        if exitCode = 0 && FileExist(temp)
            FileMove(temp, path, 1)
        else if FileExist(temp)
            FileDelete(temp)
    }

    /** runs a command hidden and feeds each line of its output to onLine through an in-memory pipe (nothing touches disk). Messages keep pumping, so the GUI stays responsive. Returns the exit code */
    __runStream(cmdLine, onLine) {
        hRead := 0, hWrite := 0, code := 0, avail := 0, got := 0
        sa := Buffer(A_PtrSize * 3, 0)
        NumPut("UInt", sa.Size, sa, 0)
        NumPut("Int", 1, sa, A_PtrSize * 2)                      ; bInheritHandle
        if !DllCall("CreatePipe", "Ptr*", &hRead, "Ptr*", &hWrite, "Ptr", sa, "UInt", 0)
            return -1
        DllCall("SetHandleInformation", "Ptr", hRead, "UInt", 1, "UInt", 0)   ; read end not inherited

        x64 := (A_PtrSize = 8)
        si := Buffer(x64 ? 104 : 68, 0)
        NumPut("UInt", si.Size, si, 0)
        NumPut("UInt", 0x100, si, x64 ? 60 : 44)                 ; STARTF_USESTDHANDLES
        NumPut("Ptr", hWrite, si, x64 ? 88 : 60)                 ; hStdOutput
        NumPut("Ptr", hWrite, si, x64 ? 96 : 64)                 ; hStdError
        pi := Buffer(A_PtrSize * 2 + 8, 0)
        cmdBuf := Buffer((StrLen(cmdLine) + 1) * 2, 0)
        StrPut(cmdLine, cmdBuf)

        ok := DllCall("CreateProcess", "Ptr", 0, "Ptr", cmdBuf, "Ptr", 0, "Ptr", 0, "Int", true
            , "UInt", 0x08000004, "Ptr", 0, "Ptr", 0, "Ptr", si, "Ptr", pi)
        DllCall("CloseHandle", "Ptr", hWrite)
        if !ok {
            DllCall("CloseHandle", "Ptr", hRead)
            return -1
        }
        hProc   := NumGet(pi, 0, "Ptr")
        hThread := NumGet(pi, A_PtrSize, "Ptr")
        DllCall("AssignProcessToJobObject", "Ptr", this.__getJob(), "Ptr", hProc)
        DllCall("ResumeThread", "Ptr", hThread)
        DllCall("CloseHandle", "Ptr", hThread)
        this.activeProc := hProc

        buf := Buffer(4096)
        acc := Buffer(8192), accLen := 0
        loop {
            DllCall("PeekNamedPipe", "Ptr", hRead, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", &avail, "Ptr", 0)
            if avail {
                DllCall("ReadFile", "Ptr", hRead, "Ptr", buf, "UInt", Min(avail, buf.Size), "UInt*", &got, "Ptr", 0)
                if accLen + got > acc.Size
                    acc.Size := Max(acc.Size * 2, accLen + got)
                DllCall("RtlMoveMemory", "Ptr", acc.Ptr + accLen, "Ptr", buf, "UPtr", got)
                accLen += got

                start := 0
                loop accLen {
                    i := A_Index - 1
                    if NumGet(acc, i, "UChar") != 10
                        continue
                    if i > start
                        onLine(RTrim(StrGet(acc.Ptr + start, i - start, "UTF-8"), "`r"))
                    start := i + 1
                }
                if start > 0 {
                    accLen -= start
                    if accLen > 0
                        DllCall("RtlMoveMemory", "Ptr", acc.Ptr, "Ptr", acc.Ptr + start, "UPtr", accLen)
                }
                continue
            }
            if DllCall("WaitForSingleObject", "Ptr", hProc, "UInt", 0) = 0 {
                DllCall("PeekNamedPipe", "Ptr", hRead, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", &avail, "Ptr", 0)
                if !avail
                    break
                continue
            }
            Sleep(40)
        }
        if accLen > 0
            onLine(RTrim(StrGet(acc.Ptr, accLen, "UTF-8"), "`r`n"))
        DllCall("GetExitCodeProcess", "Ptr", hProc, "UInt*", &code)
        DllCall("CloseHandle", "Ptr", hProc)
        DllCall("CloseHandle", "Ptr", hRead)
        this.activeProc := 0
        return code
    }

    /** paints a bar when column 2 holds a number, otherwise leaves the text (Queued / Failed / Reencoding...) alone */
    __customDraw(LV, lParam) {
        static CDDS_PREPAINT := 0x1, CDDS_ITEMPREPAINT := 0x10001, CDDS_SUBITEM := 0x30001
            , CDRF_NOTIFYITEMDRAW := 0x20, CDRF_NOTIFYSUBITEMDRAW := 0x20, CDRF_SKIPDEFAULT := 0x4
        stage := NumGet(lParam, A_PtrSize * 3, "UInt")
        if stage = CDDS_PREPAINT
            return CDRF_NOTIFYITEMDRAW
        if stage = CDDS_ITEMPREPAINT
            return CDRF_NOTIFYSUBITEMDRAW
        if stage != CDDS_SUBITEM
            return 0

        rcOff := A_PtrSize * 5
        if NumGet(lParam, (A_PtrSize = 8) ? 88 : 56, "Int") + 1 != 2
            return 0
        row := NumGet(lParam, rcOff + 16, "UPtr") + 1
        txt := LV.GetText(row, 2)
        if IsInteger(txt) {
            pct := Integer(txt), fillCol := 0x50C850, label := pct "%"            ; green (BGR)
        } else if RegExMatch(txt, "^E(\d+)\|(.*)$", &m) {
            pct := Integer(m[1]), fillCol := 0xE68232, label := m[2] " " pct "%"  ; blue (BGR)
        } else
            return 0
        hdc := NumGet(lParam, A_PtrSize * 4, "Ptr")

        L := NumGet(lParam, rcOff,      "Int") + 2
        T := NumGet(lParam, rcOff + 4,  "Int") + 2
        R := NumGet(lParam, rcOff + 8,  "Int") - 2
        B := NumGet(lParam, rcOff + 12, "Int") - 2

        rc := Buffer(16)
        bgBrush   := DllCall("gdi32\CreateSolidBrush", "UInt", 0xE0E0E0, "Ptr")
        fillBrush := DllCall("gdi32\CreateSolidBrush", "UInt", fillCol, "Ptr")
        NumPut("Int", L, "Int", T, "Int", R, "Int", B, rc)
        DllCall("user32\FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", bgBrush)
        NumPut("Int", L, "Int", T, "Int", L + (R - L) * pct // 100, "Int", B, rc)
        DllCall("user32\FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", fillBrush)
        NumPut("Int", L, "Int", T, "Int", R, "Int", B, rc)
        DllCall("gdi32\SetBkMode", "Ptr", hdc, "Int", 1)
        DllCall("user32\DrawText", "Ptr", hdc, "Str", label, "Int", -1, "Ptr", rc, "UInt", 0x25)
        DllCall("gdi32\DeleteObject", "Ptr", bgBrush)
        DllCall("gdi32\DeleteObject", "Ptr", fillBrush)
        return CDRF_SKIPDEFAULT
    }

    __onPath(name) {
        static exts := ["", ".exe", ".cmd", ".bat"]
        paths := ""
        try paths .= RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path") ";"
        try paths .= RegRead("HKCU\Environment", "Path")
        len := DllCall("ExpandEnvironmentStrings", "Str", paths, "Ptr", 0, "UInt", 0)
        buf := Buffer(len * 2)
        DllCall("ExpandEnvironmentStrings", "Str", paths, "Ptr", buf, "UInt", len)
        for dir in StrSplit(StrGet(buf), ";", " `t`"") {
            if dir = ""
                continue
            for ext in exts {
                p := dir "\" name ext
                if (a := FileExist(p)) && !InStr(a, "D")
                    return true
            }
        }
        return false
    }

    __onClose(*) {
        if !this.downloading
            ExitApp()
        if MsgBox("A download is in progress. Closing will cancel it.`n`nExit anyway?", "Cancel downloads?", "0x4 0x30 0x1000") = "No"
            return true ; non-empty return blocks the library's handler and the close
        this.__killDownloads()
        ExitApp()
    }
}

multiDL()