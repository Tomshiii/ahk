/**
 * A function to determine whether the current press of the key is due to a double click
 * @param {Integer} delay how many ms between presses you want the function to allow
 */
isDoubleClick(delay := 250) {
    if A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < delay
		  return true
    return false
}