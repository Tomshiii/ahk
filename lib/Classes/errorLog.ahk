/************************************************************************
 * @description A class to help debug errors by offering an easy solution to log any errors as they come in.
 * @author tomshi
 * @date 2025/01/01
 * @version 2.1.4
 ***********************************************************************/
; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\obj>
#Include <Classes\ptf>
#Include <Classes\log>
#Include <Other\print>
#Include <Functions\getScriptRelease>
#Include <Functions\checkInternet>
; }

/**
 * A class designed to log errors in scripts if they occur. Simply pass in an error object. The output will also be send to `OutputDebug`.
 *
 * ##### It is recommended you run this function like; `errorlog({state:"empty"})` once per day before anything else to generate the initial file - while not mandatory it will avoid instances of the intro block being generated two or more times if errorlog happens to get called back to back
 * @param {Object} err The error object you want to report on. Within an error object is `err.What` which states what threw the error - it should be noted this function manually checks for, and strips that string of `Prototype.` to make it less confusing to read in the log. This means that if you have a function with that exact string its name may be stripped.
 * @param {String} optMessage An optional message you wish to append alongside the error. This message will be tabbed in to visually distinguish it
 * @param {Boolean/Object} toolCust Allows the user to determine if they wish for a tooltip of the current error to be automatically generated. This parameter can either be a passed as a `true` boolean, or an object to determine a custom tooltip. If you wish to pass an object, follow the naming below:
 * ```
 * {x: 0, y: 0, time: 3.0, ttip: 2}
 * ```
 * @param {Boolean} doThrow Determines whether you want for errorLog to throw for you. This is simply to save the need to manually throw
 */
class errorLog extends log {
    __New(err, optMessage := "", toolCust := false, doThrow := false) {
        this.err         := err,       this.optMessage := optMessage,
        this.toolCust    := toolCust,  this.doThrow    := doThrow,
        this.logLocation := ptf.ErrorLog "\" A_YYYY "_" A_MM "_" A_DD "_ErrorLog.txt"

        ;// initialise `log {` instance
        this.logger := log(Format("{}:{}:{}.{} ", A_Hour, A_Min, A_Sec, A_MSec),, this.logLocation)

        ;// append log
        this.__logError()
    }

    __logError() {
        ;// throw if no error object is passed
        setVar := this.err
        if !IsSet(setVar) || !IsObject(setVar)
            throw UnsetError("Parameter #1 is unset", -1, this.err)

        if FileExist(this.logLocation) && this.err.HasOwnProp('state') && this.err.state = "empty"
            return

        ;// stops errors in the event `{}` is passed as `err`
        errors := Map('Message', "", 'what', "", 'Extra', "", 'File', A_LineFile, 'Line', "~error")
        for k, v in errors {
            if !this.err.HasOwnProp(k)
                this.err.%k% := v
        }

        ;// clean up the message string
        this.err.Message := StrReplace(this.err.Message, "`n`n", "- ")
        this.err.Message := StrReplace(this.err.Message, "`r`r", "- ")
        error := type(this.err) ": " Trim(this.err.Message, "`n`r`t`v")

        ;// check for and remove `Prototype.` from `err.what` string
        whatErrored := InStr(this.err.what, "Prototype.", 1, 1, 1) ? StrReplace(this.err.what, "Prototype.", '', 1,, 1) : this.err.what

        ;// IsSet requires a variable so we'll just assign this.err.Extra to a var
        extraVar := this.err.Extra
        beginning := (IsSet(extraVar) && this.err.Extra != "") ? "``" this.err.Extra "``-- " : ""

        ;// check the dir
        if !DirExist(ptf.ErrorLog)
            DirCreate(ptf.ErrorLog)

        ;// if a file for the day doesn't exist, create it and append the first start info
        if !FileExist(this.logLocation) {
            this.__firstError()
            ;// if errorlog is initialised with an empty param list, it's to generate the inital file then exit
            ;// so here we check to see if that's the case
            different := false
            if this.err.HasOwnProp('state') && this.err.state = "empty"
                return
        }

        ;// getting the name of the script that called the function
        script := obj.SplitPath(this.err.File)

        ;// assigning the log error to a variable so we can reuse it
        append := Format("// ``{}`` encountered the following error: `"{}{}`" | Script: ``{}``, Line Number: {}"
                            , whatErrored, beginning, error, script.Name, this.err.Line
                    )

        ;// append the error and send to the debug stream
        this.logger.append(append)

        ;// if optMessage has been set, append it as an error and send it to the debug stream
        if this.optMessage != ""
            this.logger.append(Format('`t`t`t// "{}"', this.optMessage))

        ;// if toolCust has been set to true, generate a tooltip based off the passed in error object
        if this.toolCust != false
            this.__doTooltip()

        ;//? insert any new additions here OR above. Not below the throw

        ;//! -----------------------------------------------
        ;//! This part of the function should ALWAYS be last
        if this.doThrow
            throw this.err
    }


    /** This function is called if it's the first time `errorLog()` has been called in the current day and handles generating an inital file */
    __firstError() {
        try {
            ;These values can be found at the following link (and the other appropriate tabs) - https://docs.microsoft.com/en-gb/windows/win32/cimwin32prov/win32-process
            ;// get OS name
            For Process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process")
                OSNameResult := Process.OSName
            removePathPos := InStr(OSNameResult, "|",,, 1)
            OSName := (removePathPos != 0) ? SubStr(OSNameResult, 1, removePathPos - 1) : OSNameResult

            ;// get OS architecture & remaining free ram
            For OperatingSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem") {
                OSArch    := OperatingSystem.OSArchitecture
                Response2 := OperatingSystem.FreePhysicalMemory / "1048576"
            }
            ;// get CPU
            For Processor in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Processor")
                CPU := Processor.Name
            ;// get number of processors & total system ram
            For ComputerSystem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_ComputerSystem") {
                Logical  := ComputerSystem.NumberOfLogicalProcessors
                Response := ComputerSystem.TotalPhysicalMemory / "1073741824"

            }

            Memory      := Round(Response, 2)
            FreePhysMem := Round(Response2, 2)

            ;// check for the latest versions of these scripts
            UserSettings := UserPref()
            InstalledVersion := UserSettings.version
            UserSettings := ""
            LatestReleaseBeta := ""
            LatestReleaseMain := ""
            if checkInternet() {
                try {
                    LatestReleaseBeta := getScriptRelease(True)
                    LatestReleaseMain := getScriptRelease()
                    if LatestReleaseBeta = LatestReleaseMain
                        LatestReleaseBeta := "[No Current Beta Release]"
                }
            }

            ;// remove date/time from being at the beginning of file
            this.logger := log("",, this.logLocation)
            this.logger.append(Format("
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
                , A_AhkVersion, InstalledVersion, LatestReleaseMain, LatestReleaseBeta,
                OSName, A_OSVersion, OSArch, RTrim(CPU), Logical, Memory, FreePhysMem,
                Format("{}_{}_{}, {}:{}:{}.{}", A_YYYY, A_MM, A_DD, A_Hour, A_Min, A_Sec, A_MSec), A_AhkPath
            ))
        }
    }

    /** This function is to simply help the flow of errorLog and make it more logical to follow */
    __doTooltip() {
        scndLine := (this.optMessage != "") ? "`n" this.optMessage : ""

        ;// if an object has been passed we'll create a custom tooltip
        if IsObject(this.toolCust) {
                ;// defaults
                defaults := {ttip: 1, time: 1.5, x: "null", y: "null"}

                ;// override any values passed into function
                for key, value in this.toolCust.OwnProps() {
                    defaults.%key% := value
                }

                ;// checking if either the x/y values have been overridden
                x := defaults.x = "null" ? unset : defaults.x
                y := defaults.y = "null" ? unset : defaults.y

                ;// generate tooltip
                tool.Cust(this.err.Message scndLine, defaults.time, x?, y?, defaults.ttip)
                return
            }

        ;// if only a boolean value has been passed we'll generate a standard tooltip
        tool.Cust(this.err.Message scndLine, 1.5)
    }
}