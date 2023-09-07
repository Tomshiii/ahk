;// this script is my own tinkerings to help with a thing
;// not really useful for anyone else sorryyyyyyyyyyy

arr1 := ["Food & Bev", "Phone", "Gym", "Travel", "Shopping", "Others", "Entertainment", "Fuel", "Car", "Utilities", "Twitch", "Health"]
arr2 := ["Gift", "Salary", "Loan Repayments", "Other Repayments"]

if !getValExpenses := InputBox("Enter Expenses Coords", "Expenses PivotTable Coords")
    return

if !getValIncome := InputBox("Enter Income Coords", "Income PivotTable Coords")
    return

WinWaitClose("Income PivotTable Coords")

if !WinActive("ahk_exe EXCEL.EXE")
    WinActivate("ahk_exe EXCEL.EXE")

for v in arr1 {
    SendInput(Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValExpenses.value, v))
    SendInput("{Tab}")
}

SendInput("{Tab}")

for v in arr2 {
    SendInput(Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValIncome.value, v))
    SendInput("{Tab}")
}