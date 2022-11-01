#Include menubar.ahk

; MyGui will be the actual Gui instance.
MyGui := tomshiBasic("AlwaysOnTop +MinSize300x300", "Editing Checklist - " name ".proj")
MyGui.SetFont("S12")
MyGui.MenuBar := bar

;defining title
titleText := MyGui.Add("Text", "X8 Y2 w215 H23", "Checklist - " name)
titleText.SetFont("bold")

;creating checkboxes
#Include checkboxes.ahk

;creating buttons
#Include buttons.ahk

;creating timer text
#Include timerText.ahk
noDefault := MyGui.Add("Button", "Default X0 Y0 W0 H0", ".")