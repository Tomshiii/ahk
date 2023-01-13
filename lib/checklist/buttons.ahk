;// defining all buttons
buttonHeights := Map(
    "lessthan11",       "Y+45",
    "morethan11",       "x+100 Y152",
)

;// everything is relative to this group box, simply move it to move the entire group
if !IsSet(morethan11)
    checklistGUI.AddGroupBox("w137 h100 " buttonHeights["lessthan11"], "Time Adjust (min)")
else
    checklistGUI.AddGroupBox("w137 h100 x+100 " buttonHeights["morethan11"], "Time Adjust (min)")

;// binding methods to an object so the buttons can properly call them
butPlusFive := ObjBindMethod(timer, "plusFive")
butMinusFive := ObjBindMethod(timer, "minusFive")
butStart := ObjBindMethod(timer, "start")
butStop := ObjBindMethod(timer, "stop")

List := checklistGUI.Add("ComboBox", "r10 Choose5 xp+12 Yp+30 w113 h30", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
minusButton := checklistGUI.Add("Button"," Y+7 w50 h30", "-sub") ;defining the - button
minusButton.OnEvent("Click", butMinusFive) ;what happens when you click the - button
plusButton := checklistGUI.Add("Button","X+15 w50 h30", "+add") ;defining the + button
plusButton.OnEvent("Click", butPlusFive) ;what happens when you click the + button

startButton := checklistGUI.Add("Button","X+-185 w50 h30", "start") ;defining the start button
startButton.OnEvent("Click", butStart) ;what happens when you click the start button
stopButton := checklistGUI.Add("Button", "y+-30 w0 h0", "stop") ;defining the stop button and making it invisible for now
stopButton.OnEvent("Click", butStop) ;what happens when you click the stop button