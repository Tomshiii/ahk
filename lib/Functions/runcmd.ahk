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
runcmd(admin := false, wait := true, runParams*) {
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


#Include <Functions\errorLog>