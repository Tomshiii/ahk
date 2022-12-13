#Include <Classes\Editors\After Effects>
#Include <QMK\unassigned>

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::ae.motionBlur()
SC027::unassigned()
/::unassigned()
;Up::unassigned()

o::unassigned()
l::
{
	CaretGetPos(&findx)
	if findx = ""
		{
			tool.Cust("the caret which indicates you aren't ready to type something`nTo prevent any unintended inputs being sent to AE none will be sent", 3.0, 1)
			errorLog(, A_ThisHotkey "::", "User wasn't in a typing field, caret couldn't be found", A_LineFile, A_LineNumber)
			return
		}
	SendInput("^a" "{BackSpace}")
	SendInput("
		(
			w = wiggle(1,10);
			[w[0],w[0]]
		)"
	)
	sleep 500
	SendInput("{Del}" "{NumpadEnter}")
}
.::unassigned()
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::unassigned()
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
;h::unassigned()
n::ae.scaleAndPos()
;Space::unassigned()

t::unassigned()
g::unassigned()
b::unassigned()

r::unassigned()
f::unassigned()
v::unassigned()
;PgDn::unassigned()

e::unassigned()
d::unassigned()
c::unassigned()
;End::unassigned()

w::ae.preset("Drop Shadow")
s::unassigned()
x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()