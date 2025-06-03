; { \\ #Includes
#Include <Functions\getDaySuffix>
; }

/**
 * returns a date range for the current week.
 *
 * ie. `2nd June-8th June`
 * @param {String} [weekStart="M"] determine whether to start date range on `Sunday` or `Monday`. Parameter *MUST* be either `"M"` or `"S"`
 * @param {Integer} [weeksFromNow=0] how many weeks to offset from the current week
 * @returns {String}
 */
FormatWeekRange(weekStart := "M", weeksFromNow := 0) {
    now := A_Now
    dow := FormatTime(now, "WDay")
    switch weekStart {
        case "M": offset := (dow = 1) ? -6  : (2 - dow)
        case "S": offset := (dow = 1) ? dow : (1 - dow)
    }


    ; Move to this week's Monday, then add 7 days to get next week's Monday
    monday := DateAdd(now, offset, "Days")
    if weeksFromNow != 0 && IsInteger(weeksFromNow) {
        monday := DateAdd(monday, weeksFromNow*7, "Days")
    }
    sunday := DateAdd(monday, 6, "Days")

    ;// extract day and month for Monday
    mDay := FormatTime(monday, "d")
    mMonth := FormatTime(monday, "MMMM")
    ;// extract day and month for Sunday
    sDay := FormatTime(sunday, "d")
    sMonth := FormatTime(sunday, "MMMM")

    ;// build final string
    return Format("{}{} {}-{}{} {}", mDay, GetDaySuffix(mDay), mMonth, sDay, GetDaySuffix(sDay), sMonth)
}