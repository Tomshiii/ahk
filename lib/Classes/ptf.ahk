/************************************************************************
 * @description A collection of file & directory paths. Stands for Point to File.
 * @author tomshi
 * @date 2022/12/14
 * @version 1.0.4
 ***********************************************************************/

class ptf {
    ;general
    static SettingsLoc       := A_MyDocuments "\tomshi"
    static rootDir           := IniRead(this.SettingsLoc "\settings.ini", "Track", "working dir", "E:\Github\ahk")
    static SupportFiles      := this.rootDir "\Support Files"
    static Backups           := this.rootDir "\Backups"
    static Stream            := this.rootDir "\Stream"
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
    static ImgSearch         := this.SupportFiles "\ImageSearch"
    static Discord           := this.ImgSearch "\Discord\"
    static Premiere          := this.ImgSearch "\Premiere\"
    static AE                := this.ImgSearch "\AE\"
    static Photoshop         := this.ImgSearch "\Photoshop\"
    static Resolve           := this.ImgSearch "\Resolve\"
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
    static PremYear          := IniRead(this.SettingsLoc "\settings.ini", "adjust", "prem year", A_Year)
    static AEYear            := IniRead(this.SettingsLoc "\settings.ini", "adjust", "ae year", A_Year)

    ;complete file links
    static __Item := Map(
        "settings",        this.SettingsLoc "\settings.ini",
        "KSAini",          this.lib "\KSA\Keyboard Shortcuts.ini",
        "updateCheckGUI",  this.lib "\Other\WebView2\updateCheckGUI.ahk",
        "checklist",       this.rootDir "\checklist.ahk",
        "Game List",       this.lib "\gameCheck\Game List.ahk",
        "textreplace",     this.rootDir "\..\textreplace\textreplace.ahk",
        "textreplaceUser", this.SupportFiles "\textreplace\textreplace.ahk",

        ;shortcuts
        "Premiere",        this.Shortcuts "\Adobe Premiere Pro.exe.lnk",
        "AE",              this.Shortcuts "\AfterFX.exe.lnk",
        "DiscordTS",       this.Shortcuts "\DiscordTimeStamper.exe.lnk",
        "OBS",             this.Shortcuts "\obs64.lnk",
        "Photoshop",       this.Shortcuts "\Photoshop.exe.lnk",
        "SL_Chatbot",      this.Shortcuts "\Streamlabs Chatbot.lnk",
        "YourPhone",       this.Shortcuts "\Your Phone.lnk",

        ;programs
        "LiveSplit",       "F:\Twitch\Splits\Splits\LiveSplit_1.7.6\LiveSplit.exe",
        "LioranBoard",     this.LioranBoardDir "\LioranBoard Receiver.exe",

        ;stream
        "StreamINI",       this.Stream "\Streaming.ini",
        "StreamAHK",       this.Stream "\Streaming.ahk",
        "SongQUEUE",       this.rootDir "\TomSongQueueue\Builds\SongQueuer.exe",
        "SongDJ",          this.rootDir "\TomSongQueueue\Builds\ApplicationDj.exe",
        "Wii Music",       this.rootDir "\Sounds\Wii Music.mp3"
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