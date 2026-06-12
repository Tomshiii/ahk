; { \\ #Includes
#Include shared functions\cleanUpInstall.ahk
#Include Install Packages\downloadNode.ahk

#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Settings.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Functions\getLocalVer.ahk
#Include Functions\delaySI.ahk
#Include Functions\getLocalVer.ahk
#Include Functions\formatPreReleaseTag.ahk
#Include Other\7zip\SevenZip.ahk
#Include Classes\winGet.ahk
#Include Classes\CLSID_Objs.ahk

; }

; // This script is the script I use to generate new releases of this repo, it's mostly just an automation script that cleans up my working repo and prepares it for a public release
; // Then goes through the annoying process of generating the release
; // This script will not work, and is not designed to work for anyone else - it's simply placed in this folder so I can keep it tracked (and to keep its code open so you can make sure the install exe isn't too scary)

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

UserSettings := CLSID_Objs.load("UserSettings")

;//* PremiereRemote
RunWait(WinGet.pathU(A_WorkingDir "\..\Backups\Adobe Backups\Premiere\PremiereRemote\backupPremRemote.ahk"))

;//* KotET
try DirCopy(A_AppData "\Knights of the Editing Table\excalibur", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\excalibur", 1)
if FileExist("E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\excalibur\license.json")
    FileDelete("E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\excalibur\license.json")
try DirCopy(A_AppData "\Knights of the Editing Table\Portal", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Knights of the Editing Table\Portal", 1)

;//* labels
FileCopy(A_MyDocuments "\Adobe\Common\Assets\Label Color Presets\Mine.prlabelpreset", "E:\Github\ahk\Backups\Adobe Backups\Premiere\Labels\Mine.prlabelpreset", 1)

__backupPremFolders(ahkDir, pcDir, title) {
    files := FileSelect("M3", pcDir, title)
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
/* hasPro := FileExist(settingsBeginningDir "\" isBetaPrefs) ? isBetaPrefs : (FileExist(settingsBeginningDir "\" StrReplace(isBetaPrefs, "Pro ", "")) ? StrReplace(isBetaPrefs, "Pro ", "") : false)
if !hasPro
    throw
*/
if !DirExist(settingsBackup "\" isBetaPrefs)
    DirCreate(settingsBackup "\" isBetaPrefs)
FileCopy(settingsBeginningDir "\" isBetaPrefs, settingsBackup "\" isBetaPrefs, 1)
FileCopy(settingsBeginningDir "\Effect Presets and Custom Items.prfpset", settingsBackup "\Effect Presets and Custom Items.prfpset", 1)
FileCopy(settingsBeginningDir "\LayoutsWorkspaceConfig.xml", settingsBackup "\LayoutsWorkspaceConfig.xml", 1)

;//* Win
winBackup := "E:\Github\ahk\Backups\Adobe Backups\Premiere\Win\v" ptf.PremYearVer
winBeginningDir := (UserSettings.premIsBeta = true || UserSettings.premIsBeta = "true") ? A_MyDocuments "\Adobe\Premiere Pro (Beta)\" ptf.PremYearVer ".0\Profile-Tom\Win" :  A_MyDocuments "\Adobe\Premiere Pro\" ptf.PremYearVer ".0\Profile-Tom\Win"
FileCopy(winBeginningDir "\Mine.kys", winBackup "\*.*", 1)
; __backupPremFolders(winBackup, winBeginningDir)

;//! ae

aeVerNum := StrReplace(ptf.aeSETver, "v", "")
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
currentVer := FileRead(A_AppData "\tomshi\version")
initialValue := InStr(currentVer, ".",,, 2) ? SubStr(currentVer, 1, InStr(currentVer, ".",,, -1)) "x" : currentVer ".x"
yes := InputBox("", "version", "W100 H80", initialValue)
if yes.Result = "Cancel"
    return
if !DirExist(A_WorkingDir "\release\" yes.Value)
    DirCreate(A_WorkingDir "\release\" yes.Value)
if FileExist(A_AppData "\tomshi\version")
    FileDelete(A_AppData "\tomshi\version")
FileAppend(formatPreReleaseTag(yes.value), A_AppData "\tomshi\version")
UserSettings.version := formatPreReleaseTag(yes.value)

;// check for pre release tags
pre   := InStr(yes.value, "pre",, 1, 1), beta  := InStr(yes.value, "beta",, 1, 1), alpha := InStr(yes.value, "alpha",, 1, 1)


getVer()
{
    ;// replace the old version number in My Scripts.ahk
    releaseString := FileRead(ptf.rootDir "\My Scripts.ahk")
    lastVer := getLocalVer(releaseString)
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
        currentVer := SubStr(ReadFile, verStart, end - verStart)
        newValue := StrReplace(wholeString, currentVer, yes.value, 1,, 1)
        ReplacedFile := StrReplace(ReadFile, wholeString, newValue, 1,, 1)
        FileAppend(ReplacedFile, A_WorkingDir "\" file ".ahk")
        FileMove(A_WorkingDir "\" file ".ahk", ptf.rootDir "\" file ".ahk", 1)
    }
    search("QMK Keyboard")
    search("Resolve_Example")
}
getVer()

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
            currentVer: {}

        )", name, loopDir, newFileDir, currentVer)) */
        if InStr(name, LTrim(currentVer, "v"), 1, 1, 1)
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
            currentVer: {}
            removeFiletype: {}
            verChangeLog: {}
            verNew: {}

        )", name, loopDir, newFileDir, currentVer, removeFiletype, verChangeLog, verNew)) */
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
loop files ptf.rootDir "\*", "DF" {
    ignore := Map(".vscode", true, ".git", true, "releases", true, ".gitignore", true, ".gitmodules", true)
    if ignore.Has(A_LoopFileName)
        continue
    switch FileExist(A_LoopFileFullPath) {
        case "D": DirCopy(A_LoopFileFullPath, A_WorkingDir "\release\" yes.Value "\" A_LoopFileName, 1)
        default: FileCopy(A_LoopFileFullPath, A_WorkingDir "\release\" yes.Value, 1)
    }
}
cleanUpInstall(A_WorkingDir "\release\" yes.Value)

;// removing favourites from ThioJoe .ini file
if FileExist(A_WorkingDir "\release\" yes.Value "\lib\Other\ThioJoe\ExplorerDialogPathSelector-Settings.ini")
    IniWrite("", A_WorkingDir "\release\" yes.Value "\lib\Other\ThioJoe\ExplorerDialogPathSelector-Settings.ini", "Settings", "favoritePaths")

;// wipe `My Scripts.ahk`
FileCopy(A_WorkingDir "\release\" yes.Value "\Support Files\Release Assets\Install Packages\My Scripts-template.ahk", A_WorkingDir "\release\" yes.Value "\My Scripts.ahk", true)

DirCopy(A_WorkingDir "\release\" yes.Value, A_WorkingDir "\release\" yes.Value "-patch")

downloadNode(A_WorkingDir "\release\" yes.Value "\nodejs.msi")
Download("https://github.com/sebinside/PremiereRemote/archive/refs/tags/v2.2.0.zip", A_WorkingDir "\release\" yes.Value "\premExtract.zip")
;// zipping the temp repo
zip := SevenZip().AutoZip(A_WorkingDir "\release\" yes.value)
sleep 1000
zip2 := SevenZip().AutoZip(A_WorkingDir "\release\" yes.value "-patch")

;// copying a file that will get compiled into the release exe
;// this copied script deals with extracting all the files from the exe itself
;// it will then run `releaseGUI.ahk` to provide the user with some install options
;//! checkout the code in this script if you're cautious/curious about the release.exe
FileCopy(ptf.SupportFiles "\Release Assets\installGUI.ahk", A_WorkingDir "\release\" yes.value ".ahk")
FileCopy(ptf.SupportFiles "\Release Assets\installGUI.ahk", A_WorkingDir "\release\" yes.value "-patch.ahk")

;// doing string manipulation to replace some values in the above script with the actual release ver
replaceVer(A_WorkingDir "\release\" yes.value ".ahk")
replaceVer(A_WorkingDir "\release\" yes.value "-patch.ahk")
replaceVer(filepath) {
    readFi := FileRead(filepath)
    if InStr(filepath, "-patch") {
        repValSearch := 'FileInstall("E:\Github\ahk\releases\release\yes.value.zip", A_Temp "\tomshi\yes.value.zip", 1)'
        repVal := 'FileInstall("E:\Github\ahk\releases\release\' yes.value '-patch.zip", A_Temp "\tomshi\yes.value.zip", 1)'
        delSearch := 'FileInstall("E:\Github\ahk\releases\release\yes.value.zip", A_WorkingDir "\yes.value.zip", 1)'
        patcherSearch := 'isPatcher := false'
        readFi := StrReplace(readFi, repValSearch, repVal)
        readFi := StrReplace(readFi, delSearch, "")
        readFi := StrReplace(readFi, patcherSearch, 'isPatcher := true')
    }
    replaceFileVer := StrReplace(readFi, "Version yes.value", "Version " Trim(yes.value, "v"))
    replaceYes := StrReplace(replaceFileVer, "yes.value", yes.value, 1)
    FileDelete(filepath)
    FileAppend(replaceYes, filepath)
}

;// opening & using the compiler
if !FileExist(ptf.ProgFi "\AutoHotkey\Compiler\Ahk2Exe.exe") {
    if MsgBox("Ahk2exe is not installed.`nWould you like to install it?",, "YesNo") = "No"
        return
    RunWait(ptf.ProgFi "\AutoHotkey\UX\install-ahk2exe.ahk")
    if !WinWait("Ahk2Exe for AutoHotkey",, 10)
        return
}
releaseCompile := FileRead(A_ScriptDir "\release_Compile.ahk")
doCompile(yes.value)
doCompile(yes.value "-patch")
doCompile(version) {
    newCompile := Format(releaseCompile, version)
    if !DirExist(A_Temp "\tomshi")
        DirCreate(A_Temp "\tomshi")
    FileAppend(newCompile, A_Temp "\tomshi\" version ".ahk")
    RunWait(A_Temp "\tomshi\" version ".ahk")
    FileDelete(A_Temp "\tomshi\" version ".ahk")
}

currentDir := ""
getverNum() {
    num := LTrim(yes.value, "v")
    dot := InStr(num, ".",,, 2)
    beta := InStr(num, "beta")
    alpha := InStr(num, "alpha")
    pre := InStr(num, "pre")
    if (beta != false || alpha != false || pre != false) && !dot {
        if beta != false
            return (SubStr(num, 1, beta-1))
        if alpha != false
            return (SubStr(num, 1, alpha-1))
        if pre != false
            return (SubStr(num, 1, pre-1))
    }
    return (dot != false ? SubStr(num, 1, (dot-1)) : num)
}
verNum := getverNum()

;// using logic to determine where to place this release
if !DirExist(A_WorkingDir "\" verNum ".x")
    DirCreate(A_WorkingDir "\" verNum ".x")
if (InStr(yes.value, "pre") || InStr(yes.value, "beta") || InStr(yes.value, "alpha")) {
    if !DirExist(A_WorkingDir "\" verNum ".x\pre")
        DirCreate(A_WorkingDir "\" verNum ".x\pre")
    FileMove(A_WorkingDir "\release\" yes.value ".exe", A_WorkingDir "\" verNum ".x\pre\" yes.value ".exe", 1)
    FileMove(A_WorkingDir "\release\" yes.value "-patch.exe", A_WorkingDir "\" verNum ".x\pre\" yes.value "-patch.exe", 1)
    currentDir := A_WorkingDir "\" verNum ".x\pre\"
} else {
    FileMove(A_WorkingDir "\release\" yes.value ".exe", A_WorkingDir "\" verNum ".x\" yes.value ".exe", 1)
    FileMove(A_WorkingDir "\release\" yes.value "-patch.exe", A_WorkingDir "\" verNum ".x\" yes.value "-patch.exe", 1)
    currentDir := A_WorkingDir "\" verNum ".x\"
}

;// closing any uneeded programs ready for completion
sleep 500
if WinExist(currentDir,, "ahk_group Browsers")
    WinActivate(currentDir,, "ahk_group Browsers")
else
    Run("explore " currentDir)
WinWait(verNum ".x",, 3)
if DirExist(A_WorkingDir "\release") && FileExist(currentDir yes.value ".exe") && FileExist(currentDir yes.value "-patch.exe")
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