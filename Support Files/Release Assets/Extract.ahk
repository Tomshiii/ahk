#Include SevenZip.ahk

path := A_ScriptDir "\yes.value.zip"
SplitPath(path,, &dirDir)

;// checking to see if the user has 7zip installed - if they do, we can use thqby's 7zip library to extract the zip folder
try {
    path   := RegRead("HKEY_CURRENT_USER\Software\7-Zip", "Path", 0)
    path64 := RegRead("HKEY_CURRENT_USER\Software\7-Zip", "Path64", 0)
    if path != 0 && path64 != 0
        {
            if FileExist(path "7zG.exe") || FileExist(path64 "7zG.exe")
                {
                    DirCreate(A_ScriptDir "\yes.value")
                    zip := SevenZip(, A_WorkingDir '\7-zip' (A_PtrSize * 8) '.dll').Extract(A_WorkingDir '\yes.value.zip', A_WorkingDir '\')
                    WinWaitClose('Extracting')
                    if DirExist(A_WorkingDir '\yes.value') ;// checking to see if a trailing dir is left behind
                        {
                            ;// then we're checking to see if it's empty
                            size := 0
                            loop files, A_WorkingDir '\yes.value\*.*', "R"
                                {
                                    size += A_LoopFileSize
                                }
                            if size = 0 ;// so that we can delete it if it is
                                DirDelete(A_WorkingDir '\yes.value')
                        }
                    return
                }
        }
}

;// if the user doesn't have 7zip installed then we need to do a more roundabout process
;// first we'll check to see if the user has powershell installed
try {
    psver := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine", "PowerShellVersion", 0)
}
;// then we check to see if the user has .Net4 installed
try {
    ver := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full", "Version", 0)
}
;// if powershell and .net4.5 (or greater) is installed, we can instead use cmd to unzip the folder
if psver != 0 && ver != 0
    goto com

;// if the user doesn't have powershell installed they will be prompted
if psver = 0
    {
        check2 := MsgBox("PowerShell is required for this install..`n`nWould you like to install it now?", "PowerShell required", "4 32 256 4096")
        if check2 = "No"
            return
        bit := (A_PtrSize = 8) ? 64 : 32
        pick2 := FileSelect("D S 2",, "Save Location")
        Download("https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/PowerShell-7.3.0-win-x" bit ".msi", pick2 "\PowerShell-7.3.0-win-x" bit ".msi")
        Run(pick2 "\PowerShell-7.3.0-win-x" bit ".msi")
        WinWait("PowerShell 7-x" bit " Setup")
        WinWaitClose("PowerShell 7-x" bit " Setup")
        sleep 500
    }
;// if the user doesn't have .Net4.5 or above installed they will be prompted
if VerCompare(ver, "4.5") < 0 || ver = 0
    {
        check := MsgBox("A newer version of .Net 4.x is required`nOn install, ensure you allow the option to add to path variable`n`nWould you like to install it now?", ".Net 4.5 or more required", "4 32 256 4096")
        if check = "No"
            return
        pick := FileSelect("D S 2",, "Save Location")
        Download("https://go.microsoft.com/fwlink/?LinkId=2085155", pick "\ndp48-web.exe")
        Run(pick "\ndp48-web.exe")
        WinWait("Microsoft .NET Framework")
        WinWaitClose("Microsoft .NET Framework")
        sleep 500
    }

com:
;powershell.exe -NoP -NonI -Command "Expand-Archive '.\file.zip' '.\unziped\'"
command := "powershell.exe -NoP -NonI -Command `"Expand-Archive `'" path "`' `'" dirDir "\`'`""
TrayTip("Extracting...")
RunWait(A_ComSpec " /c " command, dirDir, "Hide")
TrayTip()