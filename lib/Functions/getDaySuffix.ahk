/**
 * returns the correct suffix for the input day of the week
 * @param {Integer} [day] the day of the month you wish to retrieve the suffix for
 * @returns {string} returns the suffix
 */
GetDaySuffix(day) {
    day := Integer(day)
    if (day >= 11 && day <= 13)
        return "th"
    lastDigit := Mod(day, 10)
    switch lastDigit {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
    }
}