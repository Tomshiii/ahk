#Include <QMK\unassigned>
#Include <Classes\switchTo>
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\obj>
#Include <Functions\errorLog>
#Include <Functions\detect>
#Include <GUIs\musicGUI>

BackSpace::unassigned()
SC028::unassigned() ; ' key
Enter::unassigned()
Enter & Up::switchTo.closeOtherWindow("ahk_class CabinetWClass")
Right::unassigned()
Right & Up::switchTo.newWin("class", "CabinetWClass", "explorer.exe")

p::unassigned()
SC027::unassigned()
/::unassigned()
Up::switchTo.Explorer()

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
SC149::firefoxTap()
Enter & SC149::switchTo.closeOtherWindow(browser.firefox.class)
Right & PgUp::switchTo.newWin("exe", "firefox.exe", "firefox.exe")

y::unassigned()
h:: ;opens the directory for the current premiere/ae project
{
	;// if an editor isn't open
	if !WinExist("Adobe Premiere Pro") && !WinExist("Adobe After Effects")
		{
			;// check for commissions folder
			if DirExist(ptf.comms)
				{
					tool.Cust("A Premiere/AE isn't open, opening the comms folder")
					Run(ptf.comms)
					WinWait("ahk_class CabinetWClass", "comms")
					WinActivate("ahk_class CabinetWClass", "comms")
					return
				}
			;// if the folder doesn't exist
			errorLog(Error("Couldn't determine a Premiere/After Effects window & backup directory doesn't exist", -1, ptf.comms),, 1)
			return
		}
	path := WinGet.ProjPath()
	;// checking if a win explorer window for the path is open (this might not work if you have win explorer show the entire path in the title)
	if WinExist("ahk_class CabinetWClass", path.NameNoExt, "Adobe" "Editing Checklist", "Adobe")
		{
			WinActivate("ahk_class CabinetWClass", path.NameNoExt, "Adobe")
			return
		}
	;// run the path
	RunWait(path.dir)
	WinWait("ahk_class CabinetWClass", path.NameNoExt,, "Adobe")
	WinActivate("ahk_class CabinetWClass", path.NameNoExt, "Adobe")
}
n::unassigned()
Space::
{
	;// if slack isn't open, simply call function
	if !WinExist("ahk_exe slack.exe") || (WinGetMinMax("ahk_exe slack.exe") = -1) {
		switchTo.Disc()
		return
	}
	;// if slack is open I want them both in a different position
	WinMove(discord.slackX, -219, discord.slackWidth, 840, "ahk_exe slack.exe")
	switchTo.Disc(discord.slackX, discord.slackY, discord.slackWidth, discord.slackHeight)
}
Right & Space::switchTo.newWin("exe", "msedge.exe", "msedge.exe")
Enter & Space::switchTo.closeOtherWindow(browser.edge.winTitle)

t::unassigned()
g::unassigned()
b:: ;this macro is to find the difference between 2 24h timecodes
{
	calculateTime(number) ;first we create a function that will return the results the user inputs
	{
		if number = 1
			startorend := "Start"
		else
			startorend := "End"
		start1:
		time := InputBox("Write the " startorend " hhmm time here`nDon't use ':'", "Input " startorend " Time", "w200 h110")
		if time.Result = "Cancel"
			return 0
		Length1 := StrLen(time.Value)
		if Length1 != 4 || time.Value > 2359
			{
				MsgBox("You didn't write in hhmm format`nTry again", startorend " Time", "16")
				goto start1
			}
		else
			return time.Value
	}
	time1 := calculateTime("1") ;then we call it twice
	if time1 = 0
		return
	time2 := calculateTime("2")
	if time2 = 0
		return
	diff := DateDiff("20220101" time2, "20220101" time1, "seconds")/3600 ;do the math to determine the time difference
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
		WinMove(-345, -191,,, "Editing Checklist -")
}

w::unassigned()
s::unassigned()
x::unassigned()
F15::switchTo.Photo()

q::unassigned()
a::unassigned()
z::unassigned()
F16::switchTo.Edge()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()