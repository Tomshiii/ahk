#SingleInstance Force

BlockInput(true)
ToolTip("now we wait for windows")
RunWait("ms-settings:sound")
sleep 1200 ;windows is slow as hell, you may need to adjust this sleep if it's not long enough
SendInput("{Tab 10}" "{Enter}")
BlockInput(false)
ToolTip("")