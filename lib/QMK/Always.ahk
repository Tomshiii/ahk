#Include <QMK\unassigned>
#Include <Classes\Apps\Discord>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\obj>
#Include <Classes\errorLog>
#Include <Functions\detect>
#Include <GUIs\musicGUI>

BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
Enter & Up::switchTo.closeOtherWindow("ahk_class CabinetWClass")
Right::unassigned()
Right & Up::switchTo.newWin("class", "CabinetWClass", "explorer.exe", true)

p::unassigned()
SC027::unassigned()
/::switchTo.adobeProject("..\") ;opens the directory back from the current premiere/ae project
Up::switchTo.Explorer(true)

o::unassigned()
l::unassigned()
.::unassigned()
Down::switchTo.Premiere()

i::unassigned()
k::unassigned()
,::unassigned()
Left::switchTo.AE()

u::unassigned()
j::unassigned()
m::unassigned()
SC149::switchTo.Firefox()
Enter & SC149::switchTo.closeOtherWindow(browser.firefox.class)
Right & PgUp::switchTo.newWin("exe", "firefox.exe", "firefox.exe")

y::unassigned()
h::unassigned()
n::unassigned()
/** because this macro always ends in discord being in focus, tapping the macro repeatedly will cycle through the programs but manually clicking on the program and then activating the macro will not force a cycle */
Space::
{
	GroupAdd("phoneStuffDisc", "ahk_exe slack.exe")
	store := (WinActive("ahk_group phoneStuffDisc") || WinActive(discord.winTitle)) ? true : false

	;// if slack/phone link isn't open, simply call function
	if (!WinExist("ahk_group phoneStuffDisc")) {
		switchTo.Disc(true)
		return
	}
	;// if a phonestuff application OR discord was active when this hotkey was activated, we will activate that group and ensure that it and discord are placed in the correct position on the screen
	if store = true {
		GroupActivate("phoneStuffDisc", "r")
		GroupActivate("phoneStuffDisc", "r")
		WinMove(discord.slackX, discord.slackY, discord.slackWidth, discord.slackHeight, WinGetTitle("A") A_Space "ahk_exe " WinGetProcessName("A"))
		switchTo.Disc(true, {x: discord.slackX, y: 869, width: discord.slackWidth, height: discord.slackHeight+150})
		return
	}
	if WinExist(discord.winTitle) {
		pos := obj.WinPos(discord.winTitle)
		switchTo.Disc(true, {x: pos.x, y: pos.y, width: pos.width, height: pos.height})
		return
	}
	switchTo.Disc(true)
}
Enter & Space::switchTo.Disc(true)

t::unassigned()
g::unassigned()
b:: ;this macro is to find the difference between 2 24h timecodes
{
	calculateTime(startorend) ;first we create a function that will return the results the user inputs
	{
		getInput() {
			/** check to ensure only numbers are passed */
			__checkValue(value) {
				loop StrLen(value) {
					char := SubStr(value, A_Index, 1)
					if !IsNumber(char)
						return false
				}
				return true
			}
			time := InputBox("Write the " startorend " hhmm time here`nDon't use ':'", "Input " startorend " Time", "w200 h110")
			if time.Result = "Cancel"
				Exit()
			if StrLen(time.Value) != 4 || time.Value > 2359 || time.value < 0 || !__checkValue(time.value) {
				MsgBox("You didn't write in hhmm format`nTry again", startorend " Time", "16")
				return {number: 0, value: 0}
			}
			return {number: StrLen(time.Value), value: time.value}
		}
		loop {
			time := getInput()
		} until time.number = 4 && time.Value <= 2359
		return time.value
	}
	startTime := calculateTime("Start"), endTime := calculateTime("End")
	diff  := DateDiff("20220101" endTime, "20220101" startTime, "seconds")/3600 ;do the math to determine the time difference
	value := Round(diff, 2) ;round the result to 2dp
	A_Clipboard := value ;copy it to the clipboard
	tool.Cust(diff "`nor " value, 2000) ;and create a tooltip to show the user both the complete answer and the rounded answer
}

r::unassigned()
f::unassigned()
v::unassigned()
PgDn::switchTo.Music()
Right & PgDn::musicGUI()

e::unassigned()
d::unassigned()
c::unassigned()
End:: ;search for checklist file
{
	detect()
	if !WinExist("Editing Checklist") && !WinExist("Select commission folder") && !WinExist("checklist.ahk - AutoHotkey")
		Run(ptf["checklist"])
	else if WinExist("Editing Checklist")
		WinMove(-345, 0,,, "Editing Checklist -")
}

w::unassigned()
s::unassigned()
x::unassigned()
F15::switchTo.Photoshop()

q::unassigned()
a::unassigned()
z::unassigned()
F16::switchTo.Chrome()
Right & F16::switchTo.newWin("exe", "chrome.exe", "chrome.exe")
Enter & F16::switchTo.closeOtherWindow(browser.edge.winTitle)

;Tab::unassigned()
Esc::unassigned()
F13::switchTo.Slack()
Home::unassigned() ;switchTo.PhoneProgs(, true)