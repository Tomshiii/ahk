; { \\ #Includes
#Include <Classes\Editors\Premiere>
; }

;// these are any hotkeys that are for anything but need to be placed at the top of the stack for any given reason
;// do note that doing things this way means you lose the ability to use the below hotkeys in any application unless you specify
;// something for it to do. If the hotkey doesn't rely on multiple inputs like prem.toggleEnabled() then you can likely use
;// some combination of ~ or $ instead. That function is quirky in its setup


;// these toggleEnabled() scripts need to be here because for whatever reason if they're under a
;// #HotIf then the InputHook just doesn't seem to do its job and any keys fire off their own
;// instance of the function. Maybe there's a way to mess with the keyboard hook to stop it from doing that
;// but I already ripped my hair out enough getting this to work, I don't want to spend another 4 hours troubleshooting
!1::
!2::
!3::
!4::
!5::
!6::
!7::
!8::
!9::prem.toggleEnabled(, "aud", 1)