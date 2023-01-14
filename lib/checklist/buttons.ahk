;// defining all buttons
buttonHeights := Map(
    "lessthan11",       "Y+45",
    "morethan11",       "x+100 Y152",
)

;// everything is relative to this group box, simply move it to move the entire group
if morethan11 = false
    checklistGUI.AddGroupBox("w137 h100 " buttonHeights["lessthan11"], "Time Adjust (min)")
else
    checklistGUI.AddGroupBox("w137 h100 x+100 " buttonHeights["morethan11"], "Time Adjust (min)")

;// binding methods to an object so the buttons can properly call them
butPlusFive := ObjBindMethod(timer, "plusFive")
butMinusFive := ObjBindMethod(timer, "minusFive")
butStart := ObjBindMethod(timer, "start")
butStop := ObjBindMethod(timer, "stop")

listArr := []
loop 10 {
    listArr.Push(A_Index)
}
List := checklistGUI.Add("ComboBox", "r10 Choose5 xp+12 Yp+30 w113 h30", listArr)
;// buttons
minusButton := checklistGUI.AddButton("Y+7 w50 h30", "-sub")
minusButton.OnEvent("Click", butMinusFive)
plusButton := checklistGUI.AddButton("X+15 w50 h30", "+add")
plusButton.OnEvent("Click", butPlusFive)

startButton := checklistGUI.AddButton("X+-185 w50 h30", "start")
startButton.OnEvent("Click", butStart)
stopButton := checklistGUI.AddButton( "y+-30 w0 h0", "stop")
stopButton.OnEvent("Click", butStop)