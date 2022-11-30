; { \\ #Includes
#Include <Functions\SplitPathObj>
#Include <Functions\getScriptRelease>
#Include <Classes\ptf>
; }

/**
 * A function designed to log errors in scripts if they occur. Simply pass in an error object and optionally pass a backup func/hotkey name.
 *
 * If you wish to log an error without passing in a errorObj, you can pass manual information in as well.
 * @param {Object} err The error object you can simply pass in
 * @param {String} backupfunc Sometimes the error object doesn't pass through what func/hotkey has the issue - just type `A_ThisFunc "()"` if it's a function or `A_ThisHotkey "::"` if it's a hotkey
 * @param {String} backupErr is what text you want logged to explain the error
 * @param {String} backupLineFile just type `A_LineFile`
 * @param {Integer} backupLineNumber just type `A_LineNumber`
 */
errorLog(err?, backupfunc?, backupErr?, backupLineFile?, backupLineNumber?) {
    start := ""
    text := ""
    beginning := ""
    if !IsSet(err) || !IsObject(err)
        {
            func := backupfunc
            error := backupErr
            lineFile := backupLineFile
            lineNumber := backupLineNumber
            goto start
        }
    func := err.what
    if func = "" && IsSet(backupfunc?)
        func := backupfunc
    error := type(err) ": " err.Message
    lineFile := err.File
    lineNumber := err.Line
    extra := err.Extra
    if IsSet(extra) && extra != ""
        beginning := "``" extra "``-- "
    start:
    if !DirExist(ptf.ErrorLog)
        DirCreate(ptf.ErrorLog)
    if !FileExist(ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
        {
            try {
                ;These values can be found at the following link (and the other appropriate tabs) - https://docs.microsoft.com/en-gb/windows/win32/cimwin32prov/win32-process
                For Process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
                    OSNameResult := Process.OSName
                removePathPos := InStr(OSNameResult, "|",,, 1)
                if removePathPos != 0
                    OSName := SubStr(OSNameResult, 1, removePathPos - 1)
                else
                    OSName := OSNameResult
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    OSArch := OperatingSystem.OSArchitecture
                For Processor in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Processor")
                    CPU := Processor.Name
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Logical := ComputerSystem.NumberOfLogicalProcessors
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Response := ComputerSystem.TotalPhysicalMemory / "1073741824"
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    Response2 := OperatingSystem.FreePhysicalMemory / "1048576"
                Memory := Round(Response, 2)
                FreePhysMem := Round(Response2, 2)
                InstalledVersion := IniRead(ptf["settings"], "Track", "version")
                LatestReleaseBeta := getScriptRelease(True)
                LatestReleaseMain := getScriptRelease()
                if LatestReleaseBeta = LatestReleaseMain
                    LatestReleaseBeta := ""
                time := A_YYYY "_" A_MM "_" A_DD ", " A_Hour ":" A_Min ":" A_Sec "." A_MSec
                start := "\\ ErrorLogs`n\\ AutoHotkey v" A_AhkVersion "`n\\ Tomshi's Scripts" "`n`t\\ Installed Version - " InstalledVersion "`n`t\\ Latest Version Released`n`t`t\\ main - " LatestReleaseMain "`n`t`t\\ beta - " LatestReleaseBeta "`n\\ OS`n`t\\ " OSName "`n`t\\ " A_OSVersion "`n`t\\ " OSArch "`n\\ CPU`n`t\\ " RTrim(CPU) "`n`t\\ Logical Processors - " Logical "`n\\ RAM`n`t\\ Total Physical Memory - " Memory "GB`n`t\\ Free Physical Memory - " FreePhysMem "GB`n\\ Current DateTime - " time "`n\\ Ahk Install Path - " A_AhkPath "`n`n"
            }
        }
    scriptPath := lineFile ;this is taking the path given from A_LineFile
    script := SplitPathObj(scriptPath) ;and splitting it out into just the .ahk filename
    FileAppend(start A_Hour ":" A_Min ":" A_Sec "." A_MSec " // ``" func "`` encountered the following error: " beginning '"' error '"' " // Script: ``" script.Name "``, Line Number: " lineNumber "`n", ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
}