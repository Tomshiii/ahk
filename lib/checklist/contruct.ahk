; { \\ #Includes
#Include <checklist\menubar>
#Include <checklist\checkboxes>
; }

;// checklistGUI will be the actual Gui instance.
checklistGUI := tomshiBasic(12,, "AlwaysOnTop +MinSize300x300", "Editing Checklist - " name ".proj")
checklistGUI.MenuBar := bar

;// defining title
titleText := checklistGUI.Add("Text", "X8 Y2 w215 H23", "Checklist - " name)
titleText.SetFont("bold")

;// creating checkboxes
checkboxes.gatherCheckboxes(&morethannine, &morethan11)

;// set some values
;// the amount of minutes the user wants the reminder timer to fire at
minutes := 1
ms := minutes * 60000
;// the amount of minutes the user wants inbetween each log the script makes to indicate time has passed (mostly for backup purposes)
minutes2 := 10
ms10 := minutes2 * 60000
;// initial starting value
startValue := IniRead(checklist, "Info", "time")
;// initiate timer
timer := checklistTimer(startValue, ms, ms10)
timer.reminder.start()

;// creating buttons
#Include <checklist\buttons>

;// creating timer text
#Include <checklist\timerText>