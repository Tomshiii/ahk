; { \\ #Includes
#Include <checklist\menubar>
#Include <checklist\checkboxes>
; }

;// MyGui will be the actual Gui instance.
MyGui := tomshiBasic(12,, "AlwaysOnTop +MinSize300x300", "Editing Checklist - " name ".proj")
MyGui.MenuBar := bar

;// defining title
titleText := MyGui.Add("Text", "X8 Y2 w215 H23", "Checklist - " name)
titleText.SetFont("bold")

;// creating checkboxes
checkboxes.gatherCheckboxes()

;// initiate timer
timer  := checklistTimer()
timer.reminder.start()

;// creating buttons
#Include <checklist\buttons>

;// creating timer text
#Include <checklist\timerText>
MyGui.AddButton("Default X0 Y0 W0 H0", ".")

;// set startvalue
timer.Count := timer.Count + startValue