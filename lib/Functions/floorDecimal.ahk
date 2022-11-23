/**
 * `Floor()` is a built in math function of ahk to round down to the nearest integer, but when you want a decimal place to round down, you don't really have that many options. This function will allow us to round down after a certain amount of decimal places. <https://www.autohotkey.com/board/topic/50826-solved-round-down-a-number-with-2-digits/>
 * @param {Integer} num is the number you want this function to evaluate
 * @param {Integer} dec is the amount of decimal places you wish the function to evaluate to
 */
floorDecimal(num,dec) => RegExReplace(num,"(?<=\.\d{" dec "}).*$")