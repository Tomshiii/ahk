/************************************************************************
 * @description A collection of file & directory paths. Stands for Point to File.
 * @author tomshi
 * @date 2023/01/02
 * @version 1.0.8
 ***********************************************************************/

class ptf {
    ;general
    static SettingsLoc       := A_MyDocuments "\tomshi"
    static rootDir           := IniRead(this.SettingsLoc "\settings.ini", "Track", "working dir", "E:\Github\ahk")
    static SupportFiles      := this.rootDir "\Support Files"
    static Backups           := this.rootDir "\Backups"
    static Stream            := this.rootDir "\Stream"
    static SongQueue         := this.Stream "\TomSongQueueue"
    static ErrorLog          := this.rootDir "\Error Logs"
    static lib               := this.rootDir "\lib"
    static TimerScripts      := this.rootDir "\Timer Scripts"
    static Shortcuts         := this.SupportFiles "\shortcuts"
    static textreplace       := this.SupportFiles "\textreplace"
    static Wiki              := this.Backups "\Wiki"
    static Checklist         := this.lib "\checklist"

    ;My Stuff
    static MyDir             := "E:"
    static EditingStuff      := this.MyDir "\_Editing Stuff"
    static comms             := this.MyDir "\comms"
    static LioranBoardDir    := "F:\Twitch\lioranboard\LioranBoard Receiver(PC)"
    static musicDir          := "S:\Program Files\User\Music\"

    ;ImageSearch
    static premIMGver        := IniRead(this.SettingsLoc "\settings.ini", "Adjust", "premVer", "v22.3.1")
    static aeIMGver          := IniRead(this.SettingsLoc "\settings.ini", "Adjust", "aeVer", "v22.6")
    static psIMGver          := IniRead(this.SettingsLoc "\settings.ini", "Adjust", "psVer", "v24.0.1")
    static resolveIMGver     := IniRead(this.SettingsLoc "\settings.ini", "Adjust", "resolveVer", "v18.0.4")
    static ImgSearch         := this.SupportFiles "\ImageSearch"
    static Discord           := this.ImgSearch "\Discord\"
    static Premiere          := this.ImgSearch "\Premiere\" this.premIMGver "\"
    static AE                := this.ImgSearch "\AE\" this.aeIMGver "\"
    static Photoshop         := this.ImgSearch "\Photoshop\" this.psIMGver "\"
    static Resolve           := this.ImgSearch "\Resolve\" this.resolveIMGver "\"
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

    ;variables
    static adobeYear(version) {
        return SubStr(version, 2, 2)
    }
    static PremYearVer          := this.adobeYear(this.premIMGver)
    static AEYearVer            := this.adobeYear(this.aeIMGver)

    /**
     * A little function to return the proper folder for the version of premiere/ae the user is using.
     */
    static trimAdobeYear(which) {
        switch which {
            case "premiere":
                return subVer := SubStr(this.PremYearVer, -2) ".0"
            case "ae":
                return trimVer := LTrim(this.aeIMGver, "v")
        }
    }

    ;complete file links
    static __Item := Map(
        "settings",        this.SettingsLoc "\settings.ini",
        "KSAini",          this.lib "\KSA\Keyboard Shortcuts.ini",
        "updateCheckGUI",  this.lib "\Other\WebView2\updateCheckGUI.ahk",
        "checklist",       this.rootDir "\checklist.ahk",
        "Game List",       this.lib "\gameCheck\Game List.ahk",
        "textreplace",     this.rootDir "\..\textreplace\textreplace.ahk",
        "textreplaceUser", this.SupportFiles "\textreplace\textreplace.ahk",

        ;adobe stuff
        "premTemp",        this.Backups "\Adobe Backups\Premiere\Template\temp.prproj",
        "PremPresets",     A_MyDocuments "\Adobe\Premiere Pro\" this.trimAdobeYear("premiere") "\Profile-" A_UserName "\Effect Presets and Custom Items.prfpset", ;this could be named different for you depending on what your adobe username is!!

        ;shortcuts
        "Premiere",        this.Shortcuts "\Adobe Premiere Pro.exe.lnk",
        "AE",              this.Shortcuts "\AfterFX.exe.lnk",
        "DiscordTS",       this.Shortcuts "\DiscordTimeStamper.exe.lnk",
        "OBS",             this.Shortcuts "\obs64.lnk",
        "Photoshop",       this.Shortcuts "\Photoshop.exe.lnk",
        "SL_Chatbot",      this.Shortcuts "\Streamlabs Chatbot.lnk",
        "YourPhone",       this.Shortcuts "\Your Phone.lnk",
        "scriptStartup",   A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\PC Startup.ahk - Shortcut.lnk",

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
    static Premiere := {
        winTitle: "ahk_exe Adobe Premiere Pro.exe",   class: "ahk_class Premiere Pro"
    }
    static AE := {
        winTitle: "ahk_exe AfterFX.exe",              class: "ahk_class AE_CApplication_22.6"
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