GetMondaysAndFridays(year := "") {
    if year = ""
        year := A_YYYY

    dates := []

    ; Start and end of the year
    date := Format("{}0101000000", year)
    endDate := Format("{}1231235959", year)

    ; Check every day of the year
    while date <= endDate {
        dow := FormatTime(date, "WDay") ; 1 = Sunday, 2 = Monday, ..., 6 = Friday

        if dow = 2 || dow = 6
            dates.Push(FormatTime(date, "dd/MM/yyyy"))
        date := DateAdd(date, 1, "Days")
    }
    return dates
}

dates := GetMondaysAndFridays(2026)
if !WinActive("ahk_exe EXCEL.EXE")
    WinActivate("ahk_exe EXCEL.EXE")

; Get the Excel COM object
try {
    xl := ComObjActive("Excel.Application")
} catch {
    return
}

startCell := xl.ActiveCell
for i, v in dates {
    targetCell := startCell.Offset(i-1, 0)
    targetCell.Formula := v
}

startCell.Select()