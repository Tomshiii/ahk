/************************************************************************
 * @description a class to contain often used cmd functions
 * @file cmd.ahk
 * @author tomshi
 * @date 2023/02/15
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\errorLog>
; }

class cmd {
    /**
     * A wrapper function to quickly send custom commands to the command line
     * @param {Boolean} admin is whether you want the commandline to be run elevated
     * @param {Boolean} wait whether you want this function to use `RunWait` or `Run`. It will default to `RunWait`
     * @param {Varadic - String} runParams* the paramaters you wish to pass to run
     * ```
     * runParams[1] ;// the command you wish to pass to run
     * runParams[2] ;// the workind dir you wish run to use
     * runParams[3] ;// any options you wish to pass to run
     * ```
     */
    static run(admin := false, wait := true, runParams*) {
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
        try {
            switch wait {
                case false:
                    Run(elevation A_ComSpec " /c " Params[1], Params[2], Params[3], &returnPID)
                    return returnPID
                default:
                    var := RunWait(elevation A_ComSpec " /c " Params[1], Params[2], Params[3], &returnPID)
                    return {exitCode: var, PID: returnPID}
            }
        }
    }

    /**
     * This function sends commands to the commandline and returns the result
     * func found here: https://lexikos.github.io/v2/docs/commands/Run.htm#Examples
     * @param command is the command you wish to send to the commandline
     */
    static result(command) {
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_ComSpec " /C " command)
        return exec.StdOut.ReadAll()
    }
}