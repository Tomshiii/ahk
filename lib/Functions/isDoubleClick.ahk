/**
 * A function to determine whether the current press of the key is due to a double click
 * @param {Integer} [delay=250] how many ms between presses you want the function to allow
 * @param {String} [priorKeyOrHotkey="hotkey"] whether you wish for the function to check A_PriorHotkey or A_PriorKey
 * @returns {Boolean}
 */
isDoubleClick(delay := 250, priorKeyOrHotkey := "hotkey") {
    priorKeyOrHotkey := (priorKeyOrHotkey != "hotkey" && priorKeyOrHotkey != "key") ? "hotkey" : priorKeyOrHotkey
    priorKeyOrHotkey := (priorKeyOrHotkey = "hotkey") ? A_PriorHotkey ?? A_ThisHotkey : A_PriorHotkey ?? A_ThisHotkey
    if priorKeyOrHotkey = A_ThisHotkey && A_TimeSincePriorHotkey <= delay
		  return true
    return false
}