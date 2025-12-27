/************************************************************************
 * @description A collection of file & directory paths. Stands for Point to File.
 * @author tomshi
 * @date 2025/12/27
 * @version 1.3.1
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Settings.ahk
#Include *i Other\JSON.ahk
; }

class ptf {
    UserSettings := UserPref()
    ;general
    static rootDir           := this().UserSettings.working_dir
    static SupportFiles      := this.rootDir "\Support Files"
    static Backups           := this.rootDir "\Backups"
    static Stream            := this.rootDir "\Backups\Old Code\Stream"
    static SongQueue         := this.Stream "\TomSongQueueue"
    static Logs              := this.rootDir "\Logs"
    static ErrorLog          := this.Logs "\Error Logs"
    static lib               := A_AppData "\tomshi\lib"
    static TimerScripts      := this.rootDir "\Timer Scripts"
    static Shortcuts         := this.SupportFiles "\shortcuts"
    static textreplace       := this.SupportFiles "\textreplace"
    static Wiki              := this.Backups "\Wiki"
    static Checklist         := this.lib "\checklist"

    ;My Stuff
    static MyDir             := SubStr(this.rootDir, 1, 2)
    static EditingStuff      := this.MyDir "\_Editing Stuff"
    static comms             := this.MyDir "\comms"
    static LioranBoardDir    := "F:\Twitch\lioranboard\LioranBoard Receiver(PC)"
    static musicDir          := "C:\Users\" A_UserName "\Music\"

    ;Other Programs
    static mpvWintitle       := "ahk_class mpv"
    static obsidianWintitle  := "ahk_exe Obsidian.exe"

    ;ImageSearch
    static premSETver        := this().UserSettings.premVer
    static aeSETver          := this().UserSettings.aeVer
    static psSETver          := this().UserSettings.psVer
    static resolveSETver     := this().UserSettings.resolveVer
    static ImgSearch         := this.SupportFiles "\ImageSearch"
    static Discord           := this.ImgSearch "\Discord\"
    static Slack             := this.ImgSearch "\Slack\"
    static Premiere          := this.ImgSearch "\Premiere\" this.__imgVer(this.premSETver, "Prem") "\"
    static AE                := this.ImgSearch "\AE\" this.__imgVer(this.aeSETver, "AE") "\"
    static Photoshop         := this.ImgSearch "\Photoshop\" this.__imgVer(this.psSETver, "Ps") "\"
    static Resolve           := this.ImgSearch "\Resolve\" this.resolveSETver "\"
    static VSCodeImage       := this.ImgSearch "\VSCode\"
    static Explorer          := this.ImgSearch "\Windows\Win11\Explorer\"
    static Firefox           := this.ImgSearch "\Firefox\"
    static Windows           := this.ImgSearch "\Windows\Win11\Settings\"
	static Chatterino        := this.ImgSearch "\Chatterino\"

    ;Icons
    static Icons             := this.SupportFiles "\Icons"
    static guiIMG            := this.SupportFiles "\images"

    ;System
    static LocalAppData      := "C:\Users\" A_UserName "\AppData\Local"
    static ProgFi            := "C:\Program Files"
    static ProgFi32          := "C:\Program Files (x86)"

    /**
     * determines the imagesearch version for an adobe app to use. Uses my json list
     * @param {String} ver the current set version within settings.ini (ie. `premSETver`)
     * @param {String} which which adobe folder to use as the basis for the json files. Must be `Prem`, `AE`, or `Ps`
     */
    static __imgVer(ver, which) {
        if !IsSet(JSON)
            return false
        currYearVer := SubStr(ver, 1, InStr(ver, ".")-1)
        jsonFile := this.SupportFiles "\Release Assets\Adobe SymVers\Vers\" which "\" currYearVer ".json"
        if !FileExist(jsonFile) {
            if !DirExist(this.SupportFiles "\Release Assets\Adobe SymVers\Vers\" which "\")
                return false
            files := Map()
            filesArr := []
            loop files this.SupportFiles "\Release Assets\Adobe SymVers\Vers\" which "\*", "F" {
                files.Set(A_LoopFileName, true)
            }
            for v in files
                filesArr.Push(v)
            jsonFile := this.SupportFiles "\Release Assets\Adobe SymVers\Vers\" which "\" filesArr[-1]
            yearObj := JSON.parse(FileRead(jsonFile))
            for v in yearObj
                return v
        }
        yearObj := JSON.parse(FileRead(jsonFile))
        if !yearObj.Has(ver) {
            for v in yearObj
                return v
        }
        return yearObj[ver]
    }

    ;variables
    /**
     * This function converts the version number into its year value
     * ie; `v22.3.1` => `22`
     * @param {String} version is the version number of desired adobe program
     */
    __adobeYear(version) => SubStr(version, 2, 2)

    static PremYearVer          := this().__adobeYear(this.premSETver)
    static AEYearVer            := this().__adobeYear(this.aeSETver)

    /**
     * A little function to return the proper folder for the version of premiere/ae the user is using.
     * @param {String} which is which editor the function is operating on
     */
    static trimAdobeYear(which) {
        switch which {
            case "premiere": return SubStr(this.PremYearVer, -2) ".0"
            case "ae":       return LTrim(this.aeSETver, "v")
        }
    }

    ;complete file links
    static __Item := Map(
        "settings",        this().UserSettings.SettingsFile,
        "monitorsINI",     this().UserSettings.SettingsDir "\monitors.ini",
        "KSAini",          this.SupportFiles "\KSA\Keyboard Shortcuts.ini",
        "SDdirsINI",       this.SupportFiles "\Streamdeck Files\dirs.ini",
        "updateCheckGUI",  this.lib "\Other\WebView2\updateCheckGUI.ahk",
        "checklist",       this.rootDir "\checklist.ahk",
        "Game List",       this.lib "\gameCheck\games.txt",
        "textreplace",     this.rootDir "\..\textreplace\textreplace.ahk",
        "textreplaceUser", this.SupportFiles "\textreplace\textreplace.ahk",
        "HotkeylessAHK",   this.rootDir "\..\HotkeylessAHK-3.0.0\HotkeylessAHK.ahk",

        ;adobe stuff
        "premTemp",        this.Backups "\Adobe Backups\Premiere\Template\",
        "PremProfile",     A_MyDocuments "\Adobe\Premiere Pro\" this.trimAdobeYear("premiere") "\Profile-" A_UserName "\",
        "PremPresets",     A_MyDocuments "\Adobe\Premiere Pro\" this.trimAdobeYear("premiere") "\Profile-" A_UserName "\Effect Presets and Custom Items.prfpset", ;this could be named different for you depending on what your adobe username is!!
        "AdobeCC",         A_ProgramFiles "\Adobe\Adobe Creative Cloud\ACC\Creative Cloud.exe",

        ;shortcuts
        "Premiere",        this.Shortcuts "\Adobe Premiere Pro.exe.lnk",
        "AE",              this.Shortcuts "\AfterFX.exe.lnk",
        "DiscordTS",       this.Shortcuts "\DiscordTimeStamper.exe.lnk",
        "OBS",             this.Shortcuts "\obs64.lnk",
        "Photoshop",       this.Shortcuts "\Photoshop.exe.lnk",
        "SL_Chatbot",      this.Shortcuts "\Streamlabs Chatbot.lnk",
        "Phone Link",      this.Shortcuts "\Your Phone.lnk",
        "scriptStartup",   A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\Initialise.ahk - Shortcut.lnk",

        ;programs
        "LiveSplit",       "F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe",
        "LioranBoard",     this.LioranBoardDir "\LioranBoard Receiver.exe",

        ;stream
        "StreamINI",       this.Stream "\Streaming.ini",
        "StreamAHK",       this.Stream "\Streaming.ahk",
        "SongQUEUE",       this.Stream "\TomSongQueueue\Builds\SongQueuer.exe",
        "SongDJ",          this.Stream "\TomSongQueueue\Builds\ApplicationDj.exe",
        "Wii Music",       this.Stream "\TomSongQueueue\Sounds\Wii Music.mp3"
    )
}

class browser {
    static VSCode := {
        winTitle: "ahk_exe Code.exe",   class: "ahk_class Chrome_WidgetWin_1"
    }
    static Firefox := {
        winTitle: "ahk_exe firefox.exe",   class: "ahk_class MozillaWindowClass"
    }
    static Chrome := {
        winTitle: "ahk_exe chrome.exe",   class: "ahk_class Chrome_WidgetWin_1"
    }
    static Edge := {
        winTitle: "ahk_exe msedge.exe",   class: "ahk_class Chrome_WidgetWin_1"
    }
}

class Editors {
    static __setWinTitle(which, exe) {
        wintitle := (ptf().UserSettings.%which%IsBeta = true || ptf().UserSettings.%which%IsBeta = "true") ? "ahk_exe " exe " (Beta).exe" : "ahk_exe " exe ".exe"
        return wintitle
    }
    static __determinePremName(fullOrPro := true) {
        switch fullOrPro {
            case true: return (VerCompare(SubStr(ptf().UserSettings.premVer, 2), "26.1") >= 0) ? "Adobe Premiere" : "Adobe Premiere Pro"
            case false: return (VerCompare(SubStr(ptf().UserSettings.premVer, 2), "26.1") >= 0) ? "" : " Pro"
        }
    }
    static Premiere := {
        winTitle: this.__setWinTitle("prem", "Adobe Premiere Pro"),   class: "ahk_class Premiere Pro"
    }
    static AE := {
        winTitle: this.__setWinTitle("ae", "AfterFX"),              class: "ahk_class AE_CApplication_" SubStr(ptf().UserSettings.aeVer, 2, 4)
    }
    static Photoshop := {
        winTitle: "ahk_exe Photoshop.exe",            class: "ahk_class Photoshop"
    }
    static Resolve := {
        winTitle: "ahk_exe Resolve.exe",              class: "ahk_class Qt5152QWindowIcon"
    }
}

;define browsers
GroupAdd("Browsers", browser.firefox.winTitle)
GroupAdd("Browsers", browser.chrome.winTitle)
GroupAdd("Browsers", browser.VSCode.winTitle)

;define editors
GroupAdd("Editors", editors.Premiere.winTitle)
GroupAdd("Editors", editors.AE.winTitle)
GroupAdd("Editors", editors.Resolve.winTitle)
GroupAdd("Editors", editors.Photoshop.winTitle)
GroupAdd("Editors", "ahk_exe Lightroom.exe")