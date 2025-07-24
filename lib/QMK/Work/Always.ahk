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
.::unassigned()
Down::
{
	if WinExist(prem.winTitle) && WinActive(prem.winTitle) && !(WinExist("ahk_exe Adobe Premiere Pro.exe") && WinExist("ahk_exe Adobe Premiere Pro (Beta).exe")) {
        prem.swapPreviousSequence()
		return
	}
	switchTo.Premiere(, true)
}

i::unassigned()
k::unassigned()
,::unassigned()
Left::switchTo.AE()

u::unassigned()
j::unassigned()
Enter & m::switchTo.Disc(true)
m::switchTo.Disc()
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
b::switchTo.Photoshop()

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