;defining all buttons
;everything is relative to this group box, simply move it to move the entire group

buttonHeights := Map(
    "lessthan11",       "Y+45",
    "morethan11",       "x+100 Y152",
)

if !IsSet(morethan11)
    MyGui.AddGroupBox("w137 h100 " buttonHeights["lessthan11"], "Time Adjust (min)")
else
    MyGui.AddGroupBox("w137 h100 x+100 " buttonHeights["morethan11"], "Time Adjust (min)")

List := MyGui.Add("ComboBox", "r10 Choose5 xp+12 Yp+30 w113 h30", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
minusButton := MyGui.Add("Button"," Y+7 w50 h30", "-sub") ;defining the - button
minusButton.OnEvent("Click", minusFive) ;what happens when you click the - button
plusButton := MyGui.Add("Button","X+15 w50 h30", "+add") ;defining the + button
plusButton.OnEvent("Click", plusFive) ;what happens when you click the + button

startButton := MyGui.Add("Button","X+-185 w50 h30", "start") ;defining the start button
;//! I don't these will work, might have to do the objbind thing from timer class
startButton.OnEvent("Click", timer.start()) ;what happens when you click the start button
stopButton := MyGui.Add("Button", "y+-30 w0 h0", "stop") ;defining the stop button and making it invisible for now
stopButton.OnEvent("Click", timer.stop()) ;what happens when you click the stop button