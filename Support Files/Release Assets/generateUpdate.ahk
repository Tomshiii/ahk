; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Functions\getLocalVer>
#Include <Functions\delaySI>
#Include <Functions\getLocalVer>
#Include <Other\7zip\SevenZip>
#Include <Classes\winGet>
; }

; // This script is the script I use to generate new releases of this repo, it's mostly just an automation script that cleans up my working repo and prepares it for a public release
; // Then goes through the annoying process of generating the release
; // This script will not work, and is not designed to work for anyone else - it's simply placed in this folder so I can keep it tracked (and to keep its code open so you can make sure the install exe isn't too scary)

;// delete all adobe symlinks because they may break things for the user when trying to extract them
Run(A_ScriptDir "\Adobe SymVers\deleteAdobeSyms.ahk")

;// setting our working dir to the release folder
SetWorkingDir(ptf.rootDir "\releases") ;this folder isn't included in the public version of my repo as it simply acts as a backup place for all the releases

;// cleanup incase this script was interrupted
if DirExist(ptf.rootDir "\releases\release")
    DirDelete(ptf.rootDir "\releases\release", 1)

if WinExist("Ahk2Exe for AutoHotkey")
    WinClose("Ahk2Exe for AutoHotkey")

;=====================================================================
;// backup adobe stuff
;//! premiere

UserSettings := UserPref()

;//* PremiereRemote
RunWait(WinGet.pathU(A_WorkingDir "\..\Backups\Adobe Backups\Premiere\PremiereRemote\backupPremRemote.ahk"))

;//* KotET
try DirCopy(A_AppData "\Knights of the Editing Table\excalibur", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\excalibur", 1)
try DirCopy(A_AppData "\Knights of the Editing Table\Portal", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\Portal", 1)

;//* labels
FileCopy(A_MyDocuments "\Adobe\Common\Assets\Label Color Presets\Mine.prlabelpreset", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Labels\Mine.prlabelpreset", 1)

__backupPremFolders(ahkDir, pcDir, title) {
    files := FileSelect("M3", pcDir)
    if !files
        return
    for v in files {
        FileCopy(v, ahkDir "*.*", 1)
    }
}
;//* Layouts
layoutsBackup := "E:\Github\ahk\Backups\Adobe Backups\Premiere\Layouts\"
layoutsBeginningDir := (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true") ? A_MyDocuments "\Adobe\Premiere Pro (Beta)\" ptf.PremYearVer ".0\Profile-Tom\Layouts" : A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-Tom\Layouts"
__backupPremFolders(layoutsBackup, layoutsBeginningDir, "Select Premiere Layouts to Backup")

;//* Settings
settingsBackup := "E:\Github\ahk\Backups\Adobe Backups\Premiere\Settings\v" ptf.PremYearVer "\"
settingsBeginningDir := (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true") ? A_MyDocuments "\Adobe\Premiere Pro (Beta)\" ptf.PremYearVer ".0\Profile-Tom\" : A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-Tom\"
isBetaPrefs := (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true") ? "Adobe Premiere Pro (Beta) Prefs" : "Adobe Premiere Pro Prefs"
FileCopy(settingsBeginningDir "\" isBetaPrefs, settingsBackup "\" isBetaPrefs, 1)
FileCopy(settingsBeginningDir "\Effect Presets and Custom Items.prfpset", settingsBackup "\Effect Presets and Custom Items.prfpset", 1)
FileCopy(settingsBeginningDir "\LayoutsWorkspaceConfig.xml", settingsBackup "\LayoutsWorkspaceConfig.xml", 1)

;//* Win
winBackup := "E:\Github\ahk\Backups\Adobe Backups\Premiere\Win\v" ptf.PremYearVer
winBeginningDir := (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true") ? A_MyDocuments "\Adobe\Premiere Pro (Beta)\" ptf.PremYearVer ".0\Profile-Tom\Win" :  A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-Tom\Win"
FileCopy(winBeginningDir "\Mine.kys", winBackup "\*.*", 1)
; __backupPremFolders(winBackup, winBeginningDir)

;//! ae

aeVerNum := StrReplace(ptf.aeIMGver, "v", "")
aeVerNumTrim := InStr(aeVerNum, ".",,, 2) ? SubStr(aeVerNum, 1, InStr(aeVerNum, ".",,, 2)-1) : aeVerNum
aeDir := (UserSettings.aeIsBeta = true || UserSettings.aeIsBeta = "true") ? A_AppData "\Adobe\After Effects (Beta)\" aeVerNumTrim : A_AppData "\Adobe\After Effects\" aeVerNumTrim
ahkAEDir := "E:\Github\ahk\Backups\Adobe Backups\After Effects"
;//* aeks
ahkAEKBD := ahkAEDir "\aeks\Custom.txt"
pcAEKBD := aeDir "\aeks\Custom.txt"
if UserSettings.aeIsBeta != true && UserSettings.aeIsBeta != "true"
    FileCopy(pcAEKBD, ahkAEKBD, 1)

;//* workspace
workspaceBackup := ahkAEDir "\ModifiedWorkspaces\"
workspaceBeginningDir := aeDir "\ModifiedWorkspaces"
__backupPremFolders(workspaceBackup, workspaceBeginningDir, "Select After Effects Workspaces to Backup")

;//! media encoder

;//* presets
presetsBackup := "E:\Github\ahk\Backups\Adobe Backups\Media Encoder\Presets\"
presetsBeginningDir := A_MyDocuments "\Adobe\Adobe Media Encoder\" ptf.PremYearVer ".0\Presets"
__backupPremFolders(presetsBackup, presetsBeginningDir, "Select Preset files (and tree xml file) to Backup")
;=====================================================================


;// cleanup errorlog files
loop files ptf.rootDir "\Logs\*.txt", "R"
    FileDelete(A_LoopFileFullPath)

;// ask what version we're bumping to
currentVer := getLocalVer()
initialValue := InStr(currentVer, ".",,, 2) ? SubStr(currentVer, 1, InStr(currentVer, ".",,, -1)) "x" : currentVer ".x"
yes := InputBox("", "version", "W100 H80", initialValue)
if yes.Result = "Cancel"
    return
if !DirExist(A_WorkingDir "\release\" yes.Value)
    DirCreate(A_WorkingDir "\release\" yes.Value)

;// check for pre release tags
pre   := InStr(yes.value, "pre",, 1, 1), beta  := InStr(yes.value, "beta",, 1, 1), alpha := InStr(yes.value, "alpha",, 1, 1)

/**
 * This function will grab the release version from the `My Scripts.ahk` file itself.
 * This function makes it so I don't have to change this variable manually every release
 *
 * @param {VarRef} oldVer passes back the version the scripts are currently on
 */
getVer(&oldVer)
{
    ;// replace the old version number in My Scripts.ahk
    releaseString := FileRead(ptf.rootDir "\My Scripts.ahk")
    lastVer := getLocalVer()
    newFile := StrReplace(releaseString, lastVer, yes.value, 1,, 1)

    ;// update ahk_ver
    ahkVer := getLocalVer(newFile,, "@ahk_ver")
    if VerCompare(A_AhkVersion, ahkVer) > 0
        newFile := StrReplace(newFile, ahkVer, A_AhkVersion, 1,, 1)

    ;// update date
    date := getLocalVer(newFile,, "@date")
    newFile := StrReplace(newFile, date, A_YYYY "/" A_MM "/" A_DD, 1,, 1)

    FileAppend(newFile, A_WorkingDir "\My Scripts.ahk")
    FileMove(A_WorkingDir "\My Scripts.ahk", ptf.rootDir "\My Scripts.ahk", 1)

    ;replace old ver in other files
    search(file)
    {
        ReadFile := FileRead(ptf.rootDir "\" file ".ahk")
        startPos := InStr(ReadFile, ";\\CURRENT RELEASE VERSION", 1, 1, 1)
        verStart := InStr(ReadFile, "v2.", 1, startPos, 1)
        end := InStr(ReadFile, "`r",, verStart, 1)
        wholeString := SubStr(ReadFile, startPos, end - startPos)
        oldVer := SubStr(ReadFile, verStart, end - verStart)
        newValue := StrReplace(wholeString, oldVer, yes.value, 1,, 1)
        ReplacedFile := StrReplace(ReadFile, wholeString, newValue, 1,, 1)
        FileAppend(ReplacedFile, A_WorkingDir "\" file ".ahk")
        FileMove(A_WorkingDir "\" file ".ahk", ptf.rootDir "\" file ".ahk", 1)
    }
    search("QMK Keyboard")
    search("Resolve_Example")
}
getVer(&oldVer)

;// dealing with the changelog
changelog := FileRead(ptf.rootDir "\changelog.md")
loop files ptf.rootDir "\Backups\Changelogs\*", "F"
    {
        name := A_LoopFileName
        loopDir := A_LoopFileFullPath
        newFileDir := A_LoopFileDir
        /* MsgBox(Format("
        (
            name: {}
            loopDir: {}
            newFileDir: {}
            oldVer: {}

        )", name, loopDir, newFileDir, oldVer)) */
        if InStr(name, LTrim(oldVer, "v"), 1, 1, 1)
            break
    }

;// dealing with file names
if pre != false || beta != false || alpha != false
    {
        verNew := pre != 0   ? SubStr(yes.value, 1, pre-1)   : yes.value
        verNew := beta != 0  ? SubStr(yes.value, 1, beta-1)  : verNew
        verNew := alpha != 0 ? SubStr(yes.value, 1, alpha-1) : verNew
        verChangeLog := verNew
    }
else
    {
        removeFiletype := StrReplace(name, ".md", "")
        verChangeLog   := InStr(removeFiletype, "-",, 1, 1) ? SubStr(removeFiletype, 1, (InStr(removeFiletype, "-",, 1, 1)-1))    : removeFiletype
        verNew         := InStr(yes.value, ".",, 1, 2)      ? SubStr(yes.value, 1, InStr(yes.value, ".",, 1, 2)-1) : yes.value
        /* MsgBox(Format("
        (
            name: {}
            loopDir: {}
            newFileDir: {}
            oldVer: {}
            removeFiletype: {}
            verChangeLog: {}
            verNew: {}

        )", name, loopDir, newFileDir, oldVer, removeFiletype, verChangeLog, verNew)) */
    }

if !pre && !InStr(yes.value, "alpha") && !beta && !alpha && !InStr(name, Trim(yes.value, "v"), 1, 1, 1)
    {
        if IsSet(name) && (SubStr(name, 1, StrLen(name)-3) = yes.value) ;if inputbox ver is the same as the current changelog, ignore
            return
        if verChangeLog = verNew
            {
                FileAppend(changelog "`n`n.`n`n.`n`n.`n`n", loopDir)
                FileMove(loopDir, newFileDir "\" verChangeLog "-" LTrim(yes.value, "v") ".md")
            }
        else
            FileAppend(changelog "`n`n.`n`n.`n`n.`n`n", newFileDir "\" verNew ".md")
    }

sleep 100
;// checking values for testing
/*
versions := "verChangeLog: " verChangeLog "`n" "verNew: " verNew "`n" "name: " name "`n" "yes.value: " yes.value "`n"
MsgBox(versions)
*/

;// copying over the repo to a temp folder
loop files ptf.rootDir "\*", "D"
    {
        if A_LoopFileName = ".git"
            continue
        if A_LoopFileName = "releases"
            continue
        DirCreate(A_WorkingDir "\release\" yes.Value "\" A_LoopFileName)
        DirCopy(A_LoopFileFullPath, A_WorkingDir "\release\" yes.Value "\" A_LoopFileName, 1)
        ;MsgBox(A_LoopFileFullPath)
    }
loop files ptf.rootDir "\*", "F"
    {
        if A_LoopFileName = ".gitignore"
            continue
        if A_LoopFileName = ".gitmodules"
            continue
        FileCopy(A_LoopFileFullPath, A_WorkingDir "\release\" yes.Value, 1)
    }

;// this portion doesn't need to be a function, it just makes it easier to keep track of by encapsulating it in one
deleting() {
    ;// these files will still be stored in their respective repos and can be downloaded manually
    ;// deleting these files saves close to 10mb for the final release

    ;// these functions is simply a wrapper to save lines & visual clutter
    checkDirDelete(dir) {
        if DirExist(dir)
            DirDelete(dir, 1)
    }
    checkFileDelete(file) {
        if FileExist(file)
            FileDelete(file)
    }
    ;// deleting psd files
    loop files A_WorkingDir "\release\" yes.Value "\*", "F R" {
        if A_LoopFileExt = "psd" ;they're large and unnecessary to include
            FileDelete(A_LoopFileFullPath)
    }
    ;// deleting the repo banner image
    checkFileDelete(A_WorkingDir "\release\" yes.Value "\Support Files\images\repo_social.png")
    ;// deleting the `old` wiki folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Backups\Wiki\Old")
    ;// deleting qmk images folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Support Files\qmk keyboard images")
    ;// deleting the `RODECaster` backup folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Backups\RODECaster")
    ;// deleting the `GoXLR` backup folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Backups\GoXLR Backups")
    ;// deleting the `Old Code` backup folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Backups\Old Code")
    ;// deleting the `VSCode` backup folder
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Backups\VSCode")
    ;// deleting the full res images
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Support Files\images\og")
    ;// deleting folder I store in repo that isn't needed
    checkDirDelete(A_WorkingDir "\release\" yes.Value "\Stream\TomSongQueueue")
    ;// resetting `values.ini` file so it's empty for the user
    checkFileDelete(A_WorkingDir "\release\" yes.Value "\Support Files\UIA\values.ini")
    FileAppend("", A_WorkingDir "\release\" yes.Value "\Support Files\UIA\values.ini")
}
deleting()

;// zipping the temp repo
zip := SevenZip().AutoZip(A_WorkingDir "\release\" yes.value)

;// copying a file that will get compiled into the release exe
;// this copied script deals with extracting all the files from the exe itself
;// it will then run `releaseGUI.ahk` to provide the user with some install options
;//! checkout the code in this script if you're cautious/curious about the release.exe
FileCopy(ptf.SupportFiles "\Release Assets\installGUI.ahk", A_WorkingDir "\release\" yes.value ".ahk")

;// doing string manipulation to replace some values in the above script with the actual release ver
readFi := FileRead(A_WorkingDir "\release\" yes.value ".ahk")
replaceFileVer := StrReplace(readFi, "Version yes.value", "Version " Trim(yes.value, "v"))
replaceYes := StrReplace(replaceFileVer, "yes.value", yes.value, 1)
FileDelete(A_WorkingDir "\release\" yes.value ".ahk")
FileAppend(replaceYes, A_WorkingDir "\release\" yes.value ".ahk")

;// opening & using the compiler
if !FileExist(ptf.ProgFi "\AutoHotkey\Compiler\Ahk2Exe.exe") {
    if MsgBox("Ahk2exe is not installed.`nWould you like to install it?",, "YesNo") = "No"
        return
    RunWait(ptf.ProgFi "\AutoHotkey\UX\install-ahk2exe.ahk")
    if !WinWait("Ahk2Exe for AutoHotkey",, 10)
        return
}
releaseCompile := FileRead(A_ScriptDir "\release_Compile.ahk")
newCompile := Format(releaseCompile, yes.value, A_AhkVersion)
if !DirExist(A_Temp "\tomshi")
    DirCreate(A_Temp "\tomshi")
FileAppend(newCompile, A_Temp "\tomshi\newCompile.ahk")
RunWait(A_Temp "\tomshi\newCompile.ahk")
FileDelete(A_Temp "\tomshi\newCompile.ahk")

currentDir := ""
getverNum() {
    num := LTrim(yes.value, "v")
    dot := false
    finalNum := ""
    beta := InStr(num, "beta")
    alpha := InStr(num, "alpha")
    pre := InStr(num, "pre")
    if beta != false || alpha != false || pre != false {
        if beta != false
            return (SubStr(num, 1, beta-1))
        if alpha != false
            return (SubStr(num, 1, alpha-1))
        if pre != false
            return (SubStr(num, 1, pre-1))
    }
    loop StrLen(num) {
        loopField := SubStr(num, A_Index, 1)
        if IsNumber(loopField) || (loopField = ".") {
            if loopField = "." {
                switch dot {
                    case true:  break
                    case false: dot := true
                }
            }
            finalNum := finalNum loopField
        }
    }
    return finalNum
}
verNum := getverNum()

;// using logic to determine where to place this release
if !DirExist(A_WorkingDir "\" verNum ".x")
    DirCreate(A_WorkingDir "\" verNum ".x")
if (InStr(yes.value, "pre") || InStr(yes.value, "beta") || InStr(yes.value, "alpha")) && !DirExist(A_WorkingDir "\" verNum ".x\pre")
    DirCreate(A_WorkingDir "\" verNum ".x\pre")
preCheck := (pre != false || beta != false || alpha != false) ? true : false
switch preCheck {
    case 0:
        FileMove(A_WorkingDir "\release\" yes.value ".exe", A_WorkingDir "\" verNum ".x\" yes.value ".exe", 1)
        currentDir := A_WorkingDir "\" verNum ".x\"
    default:
        FileMove(A_WorkingDir "\release\" yes.value ".exe", A_WorkingDir "\" verNum ".x\pre\" yes.value ".exe", 1)
        currentDir := A_WorkingDir "\" verNum ".x\pre\"
}

;// closing any uneeded programs ready for completion
sleep 500
if WinExist(currentDir,, "ahk_group Browsers")
    WinActivate(currentDir,, "ahk_group Browsers")
else
    Run("explore " currentDir)
WinWait(verNum ".x",, 3)
if DirExist(A_WorkingDir "\release") && FileExist(currentDir yes.value ".exe")
    DirDelete(A_WorkingDir "\release", 1)
else
    {
        if WinExist(A_WorkingDir "\release")
            WinActivate(A_WorkingDir "\release")
        else
            Run("explore " A_WorkingDir "\release")
    }

if WinExist("Ahk2Exe for AutoHotkey")
    WinClose()
if WinExist(verNum ".x")
    WinActivate(verNum ".x")



;// backing up repo/wiki
;// these need to be hardcoded dirs, dirdelete/dircopy don't work with relative paths
ahkBackup     := "E:\Github\Non Github Backups\ahkBackup"
ahkWiki       := "E:\Github\ahk_wiki"
ahkWikiBackup := "E:\Github\Non Github Backups\ahkWikiBackup"

;// backup ahk folder
if MsgBox("Backup ahk folder?",, 0x3) = "Yes" {
    if DirExist(ahkBackup)
        DirDelete(ahkBackup, 1)
    ToolTip("Backing up ahk folder")
    sleep 1000
    DirCopy(ptf.rootDir, ahkBackup, 1)
    ToolTip("")
    tool.Cust("AHK folder backup complete")
}

;// backup wiki
tool.Wait()
if MsgBox("Backup wiki folder?",, 0x3) = "Yes" {
    if DirExist(ahkWikiBackup)
        DirDelete(ahkWikiBackup, 1)
    ToolTip("Backing up wiki")
    sleep 1000
    DirCopy(ahkWiki, ahkWikiBackup, 1)
    ToolTip("")
    tool.Cust("Backing up wiki folder complete")
}
Run(ptf.rootDir "\Support Files\Release Assets\Adobe SymVers\generateAdobeSym.ahk")