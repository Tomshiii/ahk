; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Functions\getLocalVer>
#Include <Other\7zip\SevenZip>
; }

; // This script is the script I use to generate new releases of this repo, it's mostly just an automation script that cleans up my working repo and prepares it for a public release
; // Then goes through the annoying process of generating the release
; // This script will not work, and is not designed to work for anyone else - it's simply placed in this folder so I can keep it tracked (and to keep it's code open so you can make sure the install exe isn't too scary)

;// setting our working dir to the release folder
SetWorkingDir("E:\Github\ahk\releases") ;this folder isn't included in the public version of my repo as it simply acts as a backup place for all the releases

;// cleanup incase this script was interrupted
if DirExist(ptf.rootDir "\releases\release")
    DirDelete(ptf.rootDir "\releases\release", 1)

if WinExist("Ahk2Exe for AutoHotkey")
    WinClose("Ahk2Exe for AutoHotkey")

;// cleanup errorlog files
loop files ptf.rootDir "\Error Logs\*.txt"
    FileDelete(A_LoopFileFullPath)

;// ask what version we're bumping to
yes := InputBox("", "version", "W100 H80", "v2.x.x")
if yes.Result = "Cancel"
    return
if !DirExist(A_WorkingDir "\release\" yes.Value)
    DirCreate(A_WorkingDir "\release\" yes.Value)

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
        if InStr(name, oldVer, 1, 1, 1)
            break
    }
verChangeLog := SubStr(name, 1, 4)
verNew := SubStr(yes.value, 1, 4)

if !InStr(yes.value, "pre")
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
/* versions := "verChangeLog: " verChangeLog "`n" "verNew: " verNew "`n" "name: " name "`n" "yes.value: " yes.value "`n"
MsgBox(versions)
ExitApp() */

;// copying over the repo to a temp folder
loop files ptf.rootDir "\*", "D"
    {
        if A_LoopFileName = ".git"
            continue
        if A_LoopFileName = "releases"
            continue
        if A_LoopFileName = "Sounds"
            continue
        if A_LoopFileName = "TomSongQueueue"
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
loop files A_WorkingDir "\release\" yes.Value "\*", "F R"
    {
        if A_LoopFileExt = "psd" ;they're large and unnecessary to include
            FileDelete(A_LoopFileFullPath)
    }

;// copying over a script that will be used to extract the .zip file
FileCopy(ptf.SupportFiles "\Release Assets\Extract.ahk", A_WorkingDir "\release")

;// copying over thqby's 7zip lib in case it's useful
FileCopy(ptf.lib "\Other\7zip\7-zip32.dll", A_WorkingDir "\release")
FileCopy(ptf.lib "\Other\7zip\7-zip64.dll", A_WorkingDir "\release")
FileCopy(ptf.lib "\Other\7zip\SevenZip.ahk", A_WorkingDir "\release")
;// zipping the temp repo
zip := SevenZip().AutoZip(A_WorkingDir "\release\" yes.value)

;// copying a file that will get compiled into the release exe
;// this copied script deals with extracting all the files from the exe itself
;// it will then run `releaseGUI.ahk` to provide the user with some install options
;//! checkout the code in this script if you're cautious/curious about the release.exe
FileCopy(ptf.SupportFiles "\Release Assets\install.ahk", A_WorkingDir "\release\" yes.value ".ahk")

;// doing string manipulation to replace some values in the above script with the actual release ver
readFi := FileRead(A_WorkingDir "\release\" yes.value ".ahk")
replaceYes := StrReplace(readFi, "yes.value", yes.value, 1)
FileDelete(A_WorkingDir "\release\" yes.value ".ahk")
FileAppend(replaceYes, A_WorkingDir "\release\" yes.value ".ahk")

;// doing the same as above but for extract.ahk
readFi2 := FileRead(A_WorkingDir "\release\Extract.ahk")
replaceYes2 := StrReplace(readFi2, "yes.value", yes.value, 1)
FileDelete(A_WorkingDir "\release\Extract.ahk")
FileAppend(replaceYes2, A_WorkingDir "\release\Extract.ahk")

;// opening & using the compiler
Run(ptf.ProgFi "\AutoHotkey\Compiler\Ahk2Exe.exe")
WinWait("Ahk2Exe for AutoHotkey")
if !WinActive("Ahk2Exe for AutoHotkey")
    {
        WinActivate("Ahk2Exe for AutoHotkey")
        WinWaitActive("Ahk2Exe for AutoHotkey")
    }
sleep 500
SendInput("{Tab 2}")
sleep 250
SendInput("{Space}")
WinWait("Open Script")
if !WinActive("Open Script")
    {
        WinActivate("Open Script")
        WinWaitActive("Open Script")
    }
sleep 250
SendInput("{F4}")
sleep 1000
SendInput("^a")
SendInput("{BackSpace}")
sleep 250
SendInput(A_WorkingDir "\release\")
sleep 250
SendInput("{Enter}")
sleep 250
SendInput("!n")
SendInput(yes.value ".ahk")
sleep 250
SendInput("!o")
sleep 250
if !WinWaitActive("Ahk2Exe for AutoHotkey",, 2)
    {
        WinActivate("Ahk2Exe for AutoHotkey")
        WinWaitActive("Ahk2Exe for AutoHotkey")
    }
SendInput("{Tab 2}")
SendInput("{Space}")
WinWait("Save Executable As")
if !WinActive("Save Executable As")
    {
        WinActivate("Save Executable As")
        WinWaitActive("Save Executable As")
    }
sleep 1000
SendInput("{F4}")
sleep 1000
SendInput("^a")
SendInput("{BackSpace}")
SendInput(A_WorkingDir "\release\")
sleep 1000
SendInput("{Enter}")
sleep 1000
SendInput("+{Tab 8}")
sleep 1000
SendInput("!n")
SendInput(yes.value ".exe")
sleep 250
SendInput("!s")
sleep 250
if !WinWaitActive("Ahk2Exe for AutoHotkey",, 2)
    {
        WinActivate("Ahk2Exe for AutoHotkey")
        WinWaitActive("Ahk2Exe for AutoHotkey")
    }
SendInput("{Tab 3}")
SendInput("{Space}")
WinWait("Open Custom Icon")
if !WinActive("Open Custom Icon")
    {
        WinActivate("Open Custom Icon")
        WinWaitActive("Open Custom Icon")
    }
sleep 1000
SendInput("{F4}")
sleep 1000
SendInput("^a")
SendInput("{BackSpace}")
SendInput(ptf.Icons)
sleep 1000
SendInput("{Enter}")
sleep 1000
SendInput("+{Tab 6}")
sleep 1000
SendInput("!n")
sleep 1000
SendInput("myscript.ico")
sleep 1000
SendInput("!o")
sleep 250
if !WinWaitActive("Ahk2Exe for AutoHotkey",, 2)
    {
        WinActivate("Ahk2Exe for AutoHotkey")
        WinWaitActive("Ahk2Exe for AutoHotkey")
    }
SendInput("{Tab 2}")
SendInput("{Down 20}" "{Up}")
SendInput("{Enter}")
WinWait("Ahk2Exe", "Successfully compiled as")
SendInput("{Enter}")

currentDir := ""
verNum := SubStr(yes.value, 2, 3)

;// using logic to determine where to place this release
if !DirExist(A_WorkingDir "\" verNum ".x")
    DirCreate(A_WorkingDir "\" verNum ".x")
if InStr(yes.value, "pre") && !DirExist(A_WorkingDir "\" verNum ".x\pre")
    DirCreate(A_WorkingDir "\" verNum ".x\pre")
preCheck := InStr(yes.value, "pre",)
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

if DirExist(ahkBackup)
    DirDelete(ahkBackup, 1)
ToolTip("Backing up ahk folder")
sleep 1000
DirCopy(ptf.rootDir, ahkBackup, 1)
ToolTip("")
tool.Cust("AHK folder backup complete")

tool.Wait()
if DirExist(ahkWikiBackup)
    DirDelete(ahkWikiBackup, 1)
ToolTip("Backing up wiki")
sleep 1000
DirCopy(ahkWiki, ahkWikiBackup, 1)
ToolTip("")
tool.Cust("Backing up wiki folder complete")