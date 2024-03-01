/************************************************************************
 * @description a class to contain often used cmd functions
 * @file cmd.ahk
 * @author tomshi
 * @date 2024/02/30
 * @version 1.1.5
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\errorLog>
#Include <Other\pipeCommand>
; }

class cmd {
    /**
     * A wrapper function to quickly send custom commands to the command line
     * @param {Boolean} [admin=false] is whether you want the commandline to be run elevated
     * @param {Boolean} [wait=true] whether you want this function to use `RunWait()` or `Run()`. It will default to `RunWait()`
     * @param {Boolean} [keepWindow=false] whether you wish for the cmd window to remain once it has finished excecuting your command
     * @param {Varadic-String} runParams* the paramaters you wish to pass to run()
     * ```
     * runParams[1] ;// the command you wish to pass to run()
     * runParams[2] ;// the workingdir you wish run() to use
     * runParams[3] ;// any options you wish to pass to run()
     * ```
     */
    static run(admin := false, wait := true, keepWindow := false, runParams*) {
        if runParams.Length > 3 {
            ;// throw
            errorLog(ValueError("Too many Parameters passed to function", -1),,, 1)
        }
        elevation  := (admin = true) ? "*RunAs " : ""
        defaultDir := (admin = true) ? A_WinDir "\System32" : "C:\Users\" A_UserName
        Params := ["", defaultDir, ""]
        if IsSet(runParams) {
            for i, v in runParams {
                if IsSet(v)
                    {
                        Params.RemoveAt(i)
                        Params.InsertAt(i, v)
                    }
            }
        }
        commandOrKeep := (keepWindow = true) ? "/k" : "/c"
        try {
            switch wait {
                case false:
                    ;// replace /c with /k if user wants to keep cmd window open
                    Run(elevation A_ComSpec A_Space commandOrKeep A_Space Params[1], Params[2], Params[3], &returnPID)
                    return returnPID
                default:
                    var := RunWait(elevation A_ComSpec A_Space commandOrKeep A_Space Params[1], Params[2], Params[3], &returnPID)
                    return {exitCode: var, PID: returnPID}
            }
        }
    }

    /**
     * This function sends commands to the commandline and returns the result from either stOutput or erOutput.
     * @link `!hide` code orginally from [here](https://lexikos.github.io/v2/docs/commands/Run.htm#Examples)
     * @link `hide` code originally from [here](https://discord.com/channels/115993023636176902/1209347616513720342/1209485394270224406)
     * @author lexikos, DepthTrawler, g33k
     * @param {String} command is the command you wish to send to the commandline
     * @param {Boolean} [hide=true] whether you wish for the cmd window to launch hidden or not
     * @param {Boolean} [returnObj=false] whether you wish for the function to return a string containing the response or an object containing `StdOut`, `StdErr` & `ExitCode`
     * @param {String} [workingDir=""] the working dir that will be passed to `pipeCommand()` if `hide` is set to `true`
     * @returns {String/Object} either a string containing the response from the commandline or an object containing `StdOut`, `StdErr` & `ExitCode`
     */
    static result(command, hide := true, returnObj := false, workingDir := "") {
        if (hide != true && hide != false) || (returnObj != true && returnObj != false) || Type(command) != "string" {
            ;// throw
            errorLog(PropertyError("Incorrect value type in Parameter #1", -1),,, 1)
            return
        }
        __whichOutput(stOutput, erOutput) => ((stOutput != "") ? stOutput : erOutput)
        if !hide {
            shell := ComObject("WScript.Shell")
            exec := shell.Exec(A_ComSpec " /C " command)
            return __whichOutput(exec.StdOut.ReadAll(), exec.StdErr.ReadAll())
        }

        return pipeCommand(command, workingDir, returnObj)
    }

    static deleteMappedDrive(driveLocation) => this.run(,,, Format("net use {}: /delete", Chr(64+driveLocation)))

    /**
     * This function will unmap the desired mapped drive location, then remap your desired drive letter to the desired ip address.
     * @param {String} driveLocation the drive letter you wish to remap. Do **not** include `:`
     * @param {String} networkLocation the ip location of your network drive
     * @param {Boolean} [persistent=true] whether you wish for the drive mapping to remain after system events like `shutdown/restart`
     */
    static mapDrive(driveLocation, networkLocation, persistent := true) {
        this.deleteMappedDrive(driveLocation)
        ;// net use N: \\192.168.20.5\storage
        keepDrive := (persistent = true) ? "/persistent:yes" : ""
        this.run(,,, Format("net use {}: {} {}", Chr(64+driveLocation), networkLocation, keepDrive))
    }

    /**
     * This function determines any in use drive letters that are taken up by mapped network locations
     * @returns {Map} a map containing which drive letters are already mapped & what their mapped locations are
     */
    static inUseDrives() {
        drives := Map()
        driveList := this.result("net use")
        loop {
            if !colon := InStr(driveList, ":",,, A_Index)
                break
            letter := SubStr(driveList, colon-1, 1)
            path   := SubStr(driveList, backslash := InStr(driveList, "\\",, colon, 1), InStr(driveList, A_Space,, backslash, 1)-backslash)
            drives.Set(letter, path)
        }
        return drives
    }
}