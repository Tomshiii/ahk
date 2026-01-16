; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\errorLog.ahk
; }

/**
 * A function to execute functions that are staggered out with sleeps. The delay will occur after each function.
 * @param {Integer} [delay=50] The delay you wish to be between each function in `ms`. Defaults to `50`
 * @param {Func|BoundFunc|Variadic} funcs* All functions you wish to be execute. Must be a Func or BoundFunc
 */
delayFuncs(delay := 50, funcs*) {
    if !IsNumber(delay) {
        ;// throw
        errorLog(TypeError("Incorrect value type in Parameter #1", -1, delay),,, 1)
    }
    if funcs.Length < 1 {
        ;// throw
        errorLog(UnsetError("Parameter #2 has not been set", -1, funcs),,, 1)
    }
    for i in funcs {
        if Type(i) != "Func" && Type(i) != "BoundFunc" {
            ;// throw
            errorLog(ValueError("Incorrect value type in Parameter " A_Index+1, -1),,, 1)
        }
        i
        sleep delay
    }
}