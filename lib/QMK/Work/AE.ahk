; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\After Effects.ahk
#Include Classes\Editors\Premiere.ahk
#Include QMK\unassigned.ahk
; }
/* ,::
.::

w:: */
BackSpace::unassigned()
SC028::unassigned()
Enter::unassigned()
Right::unassigned()

p::unassigned()
SC027::unassigned()
; /:unassigned()
;Up::unassigned()


o::unassigned()
l::unassigned()
.::ae.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Transform")
;Down::unassigned()

i::unassigned()
k::unassigned()
,::ae.anchorToPosition()
;Left::unassigned()

u::unassigned()
j::unassigned()
; m::unassigned()
;PgUp::unassigned()

; y::unassigned()
;h::unassigned()
; n::unassigned()
;Space::unassigned()

t::ae.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Gaussian Blur")
g::unassigned()
; b:unassigned()

r::unassigned()
f::unassigned()
; v::unassigned()
PgDn::unassigned()


e::unassigned()
d::unassigned()
c::unassigned()
End::unassigned()

w::ae.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Drop Shadow")
s::ae.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Tint")
x::unassigned()
F15::unassigned()

q::ae.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=S_Shake")
a::unassigned()
; z::unassigned()
;F16::unassigned()

;Tab::unassigned()
Esc::unassigned()
F13::unassigned()
Home::unassigned()
