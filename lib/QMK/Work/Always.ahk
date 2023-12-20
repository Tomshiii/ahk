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
Right & Up::switchTo.newWin("class", "CabinetWClass", "explorer.exe")

p::unassigned()
SC027::unassigned()
/::switchTo.adobeProject("..\") ;opens the directory back from the current premiere/ae project
Up::switchTo.Explorer()

o::unassigned()
l::unassigned()
.::switchTo.Photoshop()
Down::switchTo.Premiere()

i::unassigned()
k::unassigned()
,::unassigned()
Left::switchTo.AE()

u::unassigned()
j::unassigned()
Enter & m::switchTo.Disc(true)
m::
{
	/** because this macro always ends in discord being in focus, tapping the macro repeatedly will cycle through the programs but manually clicking on the program and then activating the macro will not force a cycle */
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
		switchTo.Disc(true, {x: discord.slackX, y: 669, width: discord.slackWidth, height: discord.slackHeight})
		return
	}
	if WinExist(discord.winTitle) {
		pos := obj.WinPos(discord.winTitle)
		switchTo.Disc(true, {x: pos.x, y: pos.y, width: pos.width, height: pos.height})
		return
	}
	switchTo.Disc(true)
}
SC149::switchTo.Firefox()
Enter & SC149::switchTo.closeOtherWindow(browser.firefox.class)
Right & PgUp::switchTo.newWin("exe", "firefox.exe", "firefox.exe")

y::unassigned()
h::unassigned()
n::switchTo.VSCode()
Space::switchTo.Chrome()
Right & Space::switchTo.newWin("exe", "chrome.exe", "chrome.exe")
Enter & Space::switchTo.closeOtherWindow(browser.edge.winTitle)

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::switchTo.Slack()
PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
End::unassigned()

w::unassigned()
s::unassigned()
x::unassigned()
F15::

q::unassigned()
a::unassigned()
Right & z::musicGUI()
z::switchTo.Music()
F16::switchTo.PhoneProgs(, true)

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()