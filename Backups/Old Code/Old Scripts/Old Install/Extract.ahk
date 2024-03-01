#Include *i SevenZip.ahk
;// all references to `yes (dot) value` get automatically replaced with the latest version number by `generateUpdate.ahk` - this saves me from needing to manually change it each release

;// doing some setup
SetWorkingDir(A_ScriptDir)
path := A_WorkingDir "\yes.value.zip"
SplitPath(path,, &dirDir)
inputNeeded := false

;// this function gets added to this script during `generateUpdate.ahk`
if unzip(path, A_WorkingDir)
    return

;// checking to see if the user has 7zip installed - if they do, we can use thqby's 7zip library to extract the zip folder
try {
    path   := RegRead("HKEY_CURRENT_USER\Software\7-Zip", "Path", 0)
    path64 := RegRead("HKEY_CURRENT_USER\Software\7-Zip", "Path64", 0)
    if path != 0 && path64 != 0
        {
            if (
                ;// checking to see if the user has 7zip installed
                (FileExist(path "7zG.exe") || FileExist(path64 "7zG.exe"))
                ;// checking to ensure the required 7zip lib is extracted alongside my scripts
                && FileExist(A_WorkingDir "\7-zip" (A_PtrSize * 8) ".dll")
                && FileExist(A_WorkingDir "\SevenZip.ahk")
        )
                {
                    DirCreate(A_WorkingDir "\yes.value")
                    zip := SevenZip(, A_WorkingDir '\7-zip' (A_PtrSize * 8) '.dll').Extract(A_WorkingDir '\yes.value.zip', A_WorkingDir '\')
                    WinWaitClose('Extracting')
                    if DirExist(A_WorkingDir '\yes.value') ;// checking to see if a trailing dir is left behind
                        {
                            ;// then we're checking to see if it's empty
                            size := 0
                            try {
                                loop files, A_WorkingDir '\yes.value\*.*', "R"
                                    {
                                        size += A_LoopFileSize
                                    }
                            }
                            if size = 0 ;// so that we can delete it if it is
                                DirDelete(A_WorkingDir '\yes.value')
                        }
                        found := false
                        loop files, A_WorkingDir '\*.*', "R"
                            {
                                if A_LoopFileName = "My Scripts.ahk"
                                    {
                                        found := true
                                        break
                                    }
                            }
                    if found = true
                        return
                }
        }
}

;// if the user doesn't have 7zip installed or the extraction failed then we need to do a more roundabout process
;// first we'll check to see if the user has powershell installed

;// powershell should come preinstalled on windows since windows 7 SP1 BUT to use the expand archive command we need v5+
;// chart can be found here: https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-7.3#upgrading-existing-windows-powershell
try {
    psver := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine", "PowerShellVersion", 0)
    if !VerCompare(psver, 5) >= 0
        psver := 0
}
;// then we check to see if the user has .Net4 installed
try {
    netver := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full", "Version", 0)
    if !VerCompare(netver, 4.5) >= 0
        netver := 0
}
;// if powershell and .net4.5 (or greater) is installed, we can instead use cmd to unzip the folder
if psver != 0 && netver != 0
    goto com

inputNeeded := true
;// if the user doesn't have .Net4.5 or above installed they will be prompted
if (VerCompare(netver, "4.5") < 0 || netver = 0) && psver != 0
    {
        check := MsgBox("A newer version of .Net4.5+ is required`nOn install, ensure you allow the option to add to path variable`n`nWould you like to install it now?", ".Net 4.5 or more required", "4 32 256 4096")
        if check = "No"
            return
        pick := FileSelect("D S 2",, "Save Location")
        TrayTip("Downloading .Net")
        Download("https://go.microsoft.com/fwlink/?LinkId=2085155", pick "\ndp48-web.exe")
        TrayTip()
        Run(pick "\ndp48-web.exe")
        if !WinWait("Microsoft .NET Framework",, 5)
            {
                MsgBox("Waiting for the .NET install timed out.`nFeel free to run the .NET installer manually or the installer for Tomshi's scripts again to proceed", "Timed Out")
                return
            }
        WinWaitClose("Microsoft .NET Framework")
        sleep 500
        goto com
    }

;// if the user doesn't have powershell installed they will be prompted to install powershell 7
if psver = 0
    {
        ;// setting the command type we'll need later
        psType := "pwsh.exe"
        ;// checking if the user has PowerShell 7 Installed
        downpwsh := FileExist(A_ProgramFiles "\PowerShell\7\pwsh.exe") ? false : true
        ;// setting the required exe type
        bit := (A_PtrSize = 8) ? 64 : 86

        if !downpwsh
            goto net7
        ;// alerting the user an install will be required
        check2 := MsgBox("PowerShell 5+ wasn't found on this system so PowerShell 7 is required for this install..`n`nWould you like to download and install it now?", "PowerShell required", "4 32 256 4096")
        if check2 = "No"
            return
        ;// download and installing
        pick2 := FileSelect("D S 2",, "Save Location")
        if pick2 = ""
            return
        TrayTip("Downloading PowerShell 7.3.0")
        Download("https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/PowerShell-7.3.0-win-x" bit ".msi", pick2 "\PowerShell-7.3.0-win-x" bit ".msi")
        TrayTip()
        Run(pick2 "\PowerShell-7.3.0-win-x" bit ".msi")
        if !WinWait("PowerShell 7-x" bit " Setup",, 5)
        {
            MsgBox("Waiting for the PowerShell install timed out.`nFeel free to run the PowerShell installer manually or the installer for Tomshi's scripts again to proceed", "Timed Out")
            return
        }
        WinWaitClose("PowerShell 7-x" bit " Setup")
        if !WinWait("PowerShell 7-x" bit " Setup",, 5) ;UAC prompt might cause this script to lose track of the window, so we'll give the user another 5s to dismiss it
            {
                if !FileExist(A_ProgramFiles "\PowerShell\7\pwsh.exe")
                    {
                        MsgBox("Something went wrong during the PowerShell 7 install process or UAC appeared and this script lost track of the install window`n`nTry installing PowerShell 7 manually or finish the PowerShell 7 install then rerun the Tomshi Script installer")
                        Run("https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#dotnet")
                        return
                    }
            }
        WinWaitClose("PowerShell 7-x" bit " Setup")
        sleep 500

        ;// .Net7
        net7:
        ;// retrieve installed versions of .net sdk
        dotnetvers := result("dotnet --list-sdks")
        loop {
            if !InStr(dotnetvers, "[",,, 1)
                break
            bracketOpen := InStr(dotnetvers, "[",,, 1)
            bracketClose := InStr(dotnetvers, "]",, bracketOpen, 1) + 1
            dotnetvers := StrReplace(dotnetvers, SubStr(dotnetvers, bracketOpen, bracketClose-bracketOpen), "")
        }
        ;// checking for .net7+
        installed := false
        loop parse dotnetvers, "`n`r", " `n`r"
            {
                if A_LoopField = ""
                    continue
                if VerCompare(A_LoopField, 7) >= 0
                    {
                        installed := true
                        break
                    }
            }
        if installed = true
            goto com2
        ;// if .net7+ isn't installed the user will be prompted to download and install it
        check7 := MsgBox(".Net7+ is required to continue`n`nWould you like to download and install it now?", ".Net7+ required", "4 32 256 4096")
        if check7 = "No"
            return
        pick3 := FileSelect("D S 2",, "Save Location")
        TrayTip("Downloading .Net7")
        Download("https://download.visualstudio.microsoft.com/download/pr/5b9d1f0d-9c56-4bef-b950-c1b439489b27/b4aa387715207faa618a99e9b2dd4e35/dotnet-sdk-7.0.100-win-x" bit ".exe", pick3 "\dotnet-sdk-7.0.100-win-x" bit ".exe")
        TrayTip()
        Run(pick3 "\dotnet-sdk-7.0.100-win-x" bit ".exe")
        if !WinWait("Microsoft .NET SDK 7.0.100 (x" bit ") Installer",, 5)
            {
                MsgBox("Waiting for the .NET install timed out.`nFeel free to run the .NET installer manually or the installer for Tomshi's scripts again to proceed", "Timed Out")
                return
            }
        WinWaitClose("Microsoft .NET SDK 7.0.100 (x" bit ") Installer")
        sleep 500
        goto com2
    }

com:
;powershell.exe -NoP -NonI -Command "Expand-Archive '.\file.zip' '.\unziped\'"
;pwsh.exe -NoP -NonI -Command "Expand-Archive '.\file.zip' '.\unziped\'"
psType := "powershell.exe"
com2:
command := psType " -NoP -NonI -Command `"Expand-Archive `'" path "`' `'" dirDir "\`'`""
TrayTip("Extracting...")
RunWait(A_ComSpec " /c " command, dirDir, "Hide")
TrayTip()
if inputNeeded = true
    MsgBox("Extraction complete!", "Install Complete")

;// `cmd.ahk` gets appended to the end of this file during `generateUpdate.ahk`