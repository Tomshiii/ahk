; { \\ #Includes
#Include <Classes\obj>
#Include <Functions\getScriptRelease>
#Include <Functions\checkInternet>
#Include <Classes\ptf>
; }

/**
 * A function designed to log errors in scripts if they occur. Simply pass in an error object and optionally pass a backup func/hotkey name. The output will also be send to `OutputDebug`
 * @param {Object} err The error object you want to report on
 * @param {String} backupfunc Sometimes the error object doesn't pass through what func/hotkey has the issue - just type `A_ThisFunc "()"` if it's a function or `A_ThisHotkey "::"` if it's a hotkey
 * @param {String} optMessage An optional message you wish to append alongside the error. This message will be tabbed in to visually distinguish it
 * @param {Boolean} toolCust Allows the user to determine if they wish for a tooltip of the current error to be automatically generated. This tooltip will last `1.5s`
 */
errorLog(err, backupfunc?, optMessage?, toolCust := false) {
    ;// this variable is only used on the first use of a day so we have to initialise it
    start := ""
    ;// throw if no error object is passed
    if !IsSet(err) || !IsObject(err)
        throw UnsetError("Parameter #1 is unset", -1, err)
    ;// if err.what has no value, possibly assign the backup var
    if err.what = "" && IsSet(backupfunc?)
        err.what := backupfunc
    ;// clean up the message string
    err.Message := StrReplace(err.Message, "`n`n", "- ")
    err.Message := StrReplace(err.Message, "`r`r", "- ")
    error := type(err) ": " Trim(err.Message, "`n`r`t`v")
    ;// IsSet requires a variable so we'll just assign err.Extra to a var
    extraVar := err.Extra
    beginning := (IsSet(extraVar) && err.Extra != "") ? "``" err.Extra "``-- " : ""
    ;// check the dir
    if !DirExist(ptf.ErrorLog)
        DirCreate(ptf.ErrorLog)
    ;// if a file for the day doesn't exist, create it and append the first start info
    if !FileExist(ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
        {
            try {
                ;These values can be found at the following link (and the other appropriate tabs) - https://docs.microsoft.com/en-gb/windows/win32/cimwin32prov/win32-process
                ;// get OS name
                For Process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
                    OSNameResult := Process.OSName
                removePathPos := InStr(OSNameResult, "|",,, 1)
                if removePathPos != 0
                    OSName := SubStr(OSNameResult, 1, removePathPos - 1)
                else
                    OSName := OSNameResult
                ;// get OS architecture
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    OSArch := OperatingSystem.OSArchitecture
                ;// get CPU
                For Processor in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Processor")
                    CPU := Processor.Name
                ;// get number of processors
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Logical := ComputerSystem.NumberOfLogicalProcessors
                ;// get total system ram
                For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem")
                    Response := ComputerSystem.TotalPhysicalMemory / "1073741824"
                ;// get remaining free ram
                For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
                    Response2 := OperatingSystem.FreePhysicalMemory / "1048576"
                Memory := Round(Response, 2)
                FreePhysMem := Round(Response2, 2)
                ;// check for the latest versions of these scripts
                InstalledVersion := IniRead(ptf["settings"], "Track", "version")
                LatestReleaseBeta := ""
                LatestReleaseMain := ""
                if checkInternet() {
                    try {
                        LatestReleaseBeta := getScriptRelease(True)
                        LatestReleaseMain := getScriptRelease()
                    }
                    if LatestReleaseBeta = LatestReleaseMain
                        LatestReleaseBeta := ""
                }
                time := Format("{}_{}_, {}:{}:{}.{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec, A_MSec)
                start := Format("
                (
                    \\ ErrorLogs
                    \\ AutoHotkey v{}
                    \\ Tomshi's Scripts
                        \\ Installed Version - {}
                        \\ Latest Version Released
                            \\ main - {}
                            \\ beta - {}
                    \\ OS
                        \\ {}
                        \\ {}
                        \\ {}
                    \\ CPU
                        \\ {}
                        \\ Logical Processors - {}
                    \\ RAM
                        \\ Total Physical Memory - {}GB
                        \\ Free Physical Memory - {}GB
                    \\ Current DateTime - {}
                    \\ Ahk Install Path - {}`n`n
                )"
                    , A_AhkVersion, InstalledVersion, LatestReleaseMain, LatestReleaseBeta, OSName, A_OSVersion, OSArch, RTrim(CPU), Logical, Memory, FreePhysMem, time, A_AhkPath
                )
            }
        }
    ;// getting the name of the script that called the function
    script := obj.SplitPath(err.File)
    ;// assigning the time to a var
    timeString := Format("{}:{}:{}.{} ", A_Hour, A_Min, A_Sec, A_MSec)
    ;// assigning the log error to a variable so we can reuse it
    append := Format("{}{}// ``{}`` encountered the following error: `"{}{}`" | Script: ``{}``, Line Number: {}`n"
                        , start, timeString, err.what, beginning, error, script.Name, err.Line
                )
    ;// append the error and send to the debug stream
    FileAppend(append, ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
    OutputDebug(append)
    ;// if optMessage has been set, append it as an error and send it to the debug stream
    if IsSet(optMessage)
        {
            optAppend := Format('`t`t`t// "{}"', optMessage)
            FileAppend(optAppend '`n', ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt")
            OutputDebug(LTrim(optAppend, '`t'))
        }
    ;// if toolCust has been set to true, generate a tooltip based off the passed in error object
    if toolCust {
        scndLine := IsSet(optMessage) ? "`n" optMessage : ""
        tool.Cust(err.Message scndLine, 1.5)
    }
}