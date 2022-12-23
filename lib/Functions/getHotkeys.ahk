/**
 * This function will return the name of the first & second hotkeys pressed when two are required for a macro to fire.
 *
 * If the hotkey used with this function is only 2 characters long, it will assign each of those to &first & &second respectively. If one of those characters is a special key (ie. ! or ^) it will return the virtual key so `KeyWait` will still work as expected
 * @param {VarRef} first is the variable that will be filled with the first activation hotkey. Must be written as `&var`
 * @param {VarRef} second is the variable that will be filled with the second activation hotkey. Must be written as `&var`
 * @return {Object} optionally this function returns `var.first` & `var.second` containing the two hotkeys respectively
*/
getHotkeys(&first?, &second?) {
    getHotkey := A_ThisHotkey
    length := StrLen(getHotkey)
    if length = 2
        {
            first := SubStr(getHotkey, 1, 1)
            second := SubStr(getHotkey, 2, 1)
            vk(variable)
            {
                switch variable {
                    case "#":
                        variable := "Win"
                    case "!":
                        variable := "Alt"
                    case "^":
                        variable := "Ctrl"
                    case "+":
                        variable := "Shift"
                    case "<^>!":
                        variable := "AltGr"
                    default:
                        return false
                }
                check := GetKeyVK(variable)
                vkReturn := Format("vk{:X}", check)
                return vkReturn
            }
            check1 := vk(first)
            check2 := vk(second)
            if check1 != false
                first := check1
            if check2 != false
                second := check2
            return {first: first, second: second}
        }
    andValue := InStr(getHotkey, "&",, 1, 1)
    first := SubStr(getHotkey, 1, length - (length - andValue) - 2)
    second := SubStr(getHotkey, andValue + 2, length - andValue + 2)
    return {first: first, second: second}
}