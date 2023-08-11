/************************************************************************
 * @description A class to contain UIA variables for various versions of premiere
 * @author tomshi
 * @date 2023/07/19
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
; }

;// 19/07/2023;
;// Make NO assumptions that I will maintain this list for all versions of premiere if it
;// continues to grow as time goes on
;// if you use a version other than the one listed at the top of `Premiere.ahk` (@premVer)
;// there may be values missing. Follow the instructions in the repos wiki to fill them out

;// [Table of Contents]
;//!
;// timeline              - The timeline panel
;// effectsControl        - The effects control panel
;// tools                 - The tools panel

class v22_base {
    timeline              := "YvYY"
    effectsControl        := "YYY"
    tools                 := "YuYY"
    programMon            := "YtYY"
}

class v23_base {
    timeline              := "YwYY"
    effectsControl        := "YYY"
    tools                 := "YtYY"
    programMon            := "YtYY"
}

;// if a specific version breaks anything from the base, create a new clase like;
;// class v23_6 extends v23_base {
;// and then setting the correct version within `settingsGUI()` ill priorities that class
;// if it isn't set correctly/a specific class doesn't exist we fall back to the base class
try {
    premClassVer := StrReplace(ptf.premIMGver, ".", "_")
    premUIA := %premClassVer%()
} catch {
    premGetVer := StrReplace(ptf.premIMGver, ".", "_")
    premClassVer := SubStr(premGetVer, 1, InStr(premGetVer, "_",,, 1)-1)
    premUIA := %premClassVer%_base()
}