; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Functions\validateTypes.ahk
; }

/**
 * A function to more easily pass multiple paramaters to the built in `Run`/`RunWait` function
 * @author geekdude, tomshi
 * @link https://discord.com/channels/115993023636176902/482610538350903309/1463685295839908046
 * @param {Array} [Params] an array of paramaters you wish to pass. They should remain in order.
 * @param {String} [WorkinDir=""] The desired working directory to pass to `Run`
 * @param {String} [options=""] `Max`/`Min`/`Hide`
 * @param {Boolean} [wait=false] determine whether to use `Run` or `RunWait`
 * @param {ByRef} [OutpudVarPID]
 */
runExt(Params, WorkingDir := "", Options := "", wait := false, &OutputVarPID?) {
    ValidateTypes(["array", "string", "String", "integer"], Params, WorkingDir, Options, wait)
    for Param in Params {
        Param := RegExReplace(Param, '(\\*)""', '$1$1\""')
        RunStr .= '""' Param '"" '
    }
    (wait = false) ? Run(RunStr, WorkingDir, Options, &OutputVarPID) : RunWait(RunStr, WorkingDir, Options, &OutputVarPID)
}