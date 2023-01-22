#SingleInstance Force

; { \\ #Includes
#Include <GUIs\tomshiBasic>
; }

shtDwnWin := tomshiBasic(,,, "When do you want to shutdown?")
shtDwnWin.AddEdit("w70 Number limit4")
editVal := shtDwnWin.AddUpDown("r1 Range0-9999")
drpdwn := shtDwnWin.AddDropDownList("x+10 w100 Choose1", ["sec", "min", "hours"])

cancel :=  shtDwnWin.AddButton("x8", "Cancel Timer")
cancel.OnEvent("Click", cancelTimer)
shut := shtDwnWin.AddButton("x+6", "Shutdown")
shut.OnEvent("Click", delay)

shtDwnWin.Show()

delay(*) {
    switch drpdwn.Text {
        case "sec":  timer := editVal.Value
        case "min":  timer := editVal.Value*60
        case "hours": timer := (editVal.Value*60)*60
    }
    Run("shutdown -s -t " timer)
}

cancelTimer(*) => Run("shutdown -a")