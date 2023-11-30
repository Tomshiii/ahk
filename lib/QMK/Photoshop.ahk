#Include <Classes\Editors\Photoshop>
#Include <QMK\unassigned>

BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
;Right::unassigned()

p::SendInput("!t" "b{Right}g") ;open gaussian blur (should really just use the inbuilt hotkey but uh. photoshop is smelly don't @ me)
SC027::ps.Prop("x.png")
/::ps.Prop("y.png")

o::unassigned()
l::ps.Prop("scale.png") ;this assumes you have h/w linked. You'll need more logic if you want separate values
.::unassigned()
;Down::unassigned()

i::unassigned()
k::unassigned()
,::unassigned()
;Left::unassigned()

u::ps.Prop("rotate.png")
j::unassigned()
m::unassigned()
;PgUp::unassigned()

y::unassigned()
;h::unassigned()
n::unassigned()
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

w::unassigned()
s::unassigned()
x::unassigned()
;F15::unassigned()

q::unassigned()
a::unassigned()
z::unassigned()
;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
; F13::unassigned()
; Home::unassigned()