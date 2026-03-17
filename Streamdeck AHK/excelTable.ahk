;// this script is my own tinkerings to help with a thing
;// not really useful for anyone else sorryyyyyyyyyyy
#SingleInstance Force

if !WinExist("ahk_exe EXCEL.EXE")
    return

arr1 := ["Eating Out", "Groceries", "Gym", "Travel", "Shopping", "Others", "Entertainment", "Fuel", "Car", "Utilities", "Rent", "Health", "Amazon", "Friends/lover"]

SetTimer(MoveCaret, -10)
MoveCaret() {
    if !WinWait("Expenses PivotTable Coords",, 2)
        return
    SendInput("{End}")
}
getValExpenses := InputBox("Enter Coordinates for Expenses PivotTable`n`nExample: $N$323`n`nThis script assumes the second pivot table to be 3 cells to the right of this first one.", "Expenses PivotTable Coords", "H130", "$N$")
if getValExpenses.result = "Cancel"
    return

if !WinActive("ahk_exe EXCEL.EXE")
    WinActivate("ahk_exe EXCEL.EXE")

; Get the Excel COM object
try {
    xl := ComObjActive("Excel.Application")
} catch {
    return
}

startCell := xl.ActiveCell
for i, v in arr1 {
    targetCell := startCell.Offset(0, i-1)
    targetCell.Formula := Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValExpenses.value, v)
}

startCell.Select()