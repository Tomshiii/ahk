/**
 * returns the date of a desired day this week
 * @param {String} [desiredDay=6] the desired day you wish to retrieve the date for (`Sunday` is 1 - `Saturday` is 6)
 * @param {Integer} [returnNextWeek=true] whether you wish for the function to return next week's date if the desired day in the current week has already passed. If this parameter is set to `false` and the day has already passed, the function will return boolean `false`
 * @returns {String/boolean} returns `yyyy-mm-dd` on success or boolean `false` on failure
 */
FormatWeekDay(desiredDay := 6, returnNextWeek := true, weeksFromNow := 0) {
    today := A_Now
    ;// get day of the week (1=Sunday, 7=Saturday)
    dayOfWeek := FormatTime(today, "WDay")
    ;// calculate how many days to add to reach desired day
    daysToAdd := (desiredDay - dayOfWeek)+(weeksFromNow*7)
    ;// if today is Saturday (7) or Sunday (1), adjust to stay in this week
    if (daysToAdd < 0) {
        if returnNextWeek = true
            daysToAdd += 7
        else
            return false
    }
    ;// add the days to today
    desiredDate := DateAdd(today, daysToAdd, "Days")
    return FormatTime(desiredDate, "yyyy-MM-dd")
}