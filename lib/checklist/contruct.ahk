#Include menubar.ahk

class ChecklistGui extends Gui {
    __new(options?, title:="Editing Checklist - " name ".proj") {
        ; Any of the constructor parameters can be modified below.
        ; In particular, pass 'this' as the third parameter (the event sink).
        super.__new(options?, title, this)
        this.BackColor := 0xF0F0F0
        this.SetFont("S12") ;Sets the size of the font
        this.SetFont("W500") ;Sets the weight of the font (thickness)
        this.Opt("+MinSize300x300")
        this.MenuBar := bar

        ;defining title
        title := this.Add("Text", "X8 Y2 w215 H23", "Checklist - " name)
        title.SetFont("bold")
    }
}

; MyGui will be the actual Gui instance.
MyGui := ChecklistGui("AlwaysOnTop")

;creating checkboxes
#Include checkboxes.ahk

;creating buttons
#Include buttons.ahk

;creating timer text
#Include timerText.ahk