;// this script is my own tinkerings to help with a thing
;// not really useful for anyone else sorryyyyyyyyyyy
#SingleInstance Force

arr1 := ["Food & Bev", "Gym", "Travel", "Shopping", "Others", "Entertainment", "Fuel", "Car", "Utilities", "Health"]
arr2 := ["Gift", "Salary", "Loan Repayments", "Other Repayments"]

getValExpenses := InputBox("Enter Coordinates for Expenses PivotTable`n`nExample: $L$323", "Expenses PivotTable Coords", "H130")
if getValExpenses.result = "Cancel"
    return

getValIncome := InputBox("Enter Coordinates for Income PivotTable`n`nExample: $L$323", "Income PivotTable Coords", "H130")
if getValIncome.result = "Cancel"
    return

WinWaitClose("Income PivotTable Coords")

if !WinActive("ahk_exe EXCEL.EXE")
    WinActivate("ahk_exe EXCEL.EXE")

for v in arr1 {
    SendInput(Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValExpenses.value, v))
    SendInput("{Tab}")
}

SendInput("+{Tab}" "{Right}{Tab}")

for v in arr2 {
    SendInput(Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValIncome.value, v))
    SendInput("{Tab}")
}