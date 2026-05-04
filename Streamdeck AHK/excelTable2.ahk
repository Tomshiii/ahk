;// this script is my own tinkerings to help with a thing
;// not really useful for anyone else sorryyyyyyyyyyy
#SingleInstance Force

if !WinExist("ahk_exe EXCEL.EXE")
    return

rowNum := InputBox("Enter row number for the ``Total Remaining`` row.", "Total Remaining Row #", "H100")

if rowNum.result = "Cancel"
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
column := ["C", "H", "C", "H"]
for i, v in column {
    targetCell := startCell.Offset(0, i-1)
    targetCell.Formula := Format("='{1}'!${2}${3}", A_YYYY, v, (A_Index=1||A_Index=4) ? rowNum.value : rowNum.value-2)
}