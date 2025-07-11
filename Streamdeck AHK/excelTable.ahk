;// this script is my own tinkerings to help with a thing
;// not really useful for anyone else sorryyyyyyyyyyy
#SingleInstance Force

#Include <Classes\clip>
#Include <Functions\delaySI>

arr1 := ["Eating Out", "Groceries", "Gym", "Travel", "Shopping", "Others", "Entertainment", "Fuel", "Car", "Utilities", "Health", "Amazon", "Friends/lover"]
arr2 := ["Salary", "Loan Repayments", "Other Repayments"]

;// this will assume the second pivot table is 3 cells to the right of the first pivot table
getValExpenses := InputBox("Enter Coordinates for Expenses PivotTable`n`nExample: $N$323`n`nThis script assumes the second pivot table to be 3 cells to the right of this first one.", "Expenses PivotTable Coords", "H130", "$N$")
if getValExpenses.result = "Cancel"
    return

response := StrSplit(getValExpenses.Value, "$")
getValIncome := {}
getValIncome.value := String("$" chr(ord(response[2])+3) "$" response[3])

WinWaitClose("Income PivotTable Coords")

if !WinActive("ahk_exe EXCEL.EXE")
    WinActivate("ahk_exe EXCEL.EXE")

clipb := clip.clear()
for v in arr1 {
    clip.clear()
    A_Clipboard := Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValExpenses.value, v)
    if !ClipWait(2)
        return
    sleep 50
    delaySI(50, "^v", "{Tab}")
}

delaySI(25, "+{Tab}", "{Right}", "{Tab}")

for v in arr2 {
    clip.clear()
    A_Clipboard := Format('=IFERROR(GETPIVOTDATA("Amount",{1},"Type","{2}"), 0)', getValIncome.value, v)
    if !ClipWait(2)
        return
    delaySI(50, "^v", "{Tab}")
}

clip.clear()
A_Clipboard := clipb.storedClip