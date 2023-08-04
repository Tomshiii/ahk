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

class v22_3_1 {
    timeline              := "YvYY"
    effectsControl        := "YYY"
    tools                 := "YuYY"
    programMon            := "YtYY"
}
class v23_5 {
    timeline              := "YwYY"
    effectsControl        := "YYY"
    tools                 := "YtYY"
    programMon            := "YtYY"
}

premClassVer := StrReplace(ptf.premIMGver, ".", "_")
premUIA := %premClassVer%()