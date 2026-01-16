; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\errorLog.ahk
; }

/**
 * A function to send a string of sendinput commands that are staggered out with sleeps. The delay will occur after each sendinput. Defaults to `50`
 * @param {Integer} [delay=50] The delay you wish to be between each input in `ms`
 * @param {String|Number|Variadic} inputs* All inputs you wish to be sent
 */
delaySI(delay := 50, inputs*) {
    if !IsNumber(delay) {
        ;// throw
        errorLog(TypeError("Incorrect value type in Parameter #1", -1, delay),,, 1)
    }
    if inputs.Length < 1 {
        ;// throw
        errorLog(UnsetError("Parameter #2 has not been set", -1, inputs),,, 1)
    }
    for i in inputs {
        if Type(i) != "String" && !IsNumber(i) {
            ;// throw
            errorLog(ValueError("Incorrect value type in Parameter " A_Index+1, -1, i),,, 1)
        }
        SendInput(i)
        sleep delay
    }
}