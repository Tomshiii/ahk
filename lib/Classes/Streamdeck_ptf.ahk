; { \\ #Includes
#Include <Classes\ptf>
; }

class SD_ptf {
    __New() {
        splitINI := StrSplit(IniRead(this.dirINI, "dirs"), ["=", "`n", "`r"])
        for k, v in splitINI {
            if Mod(k, 2) = 0
                continue
            noSpace := StrReplace(v, A_Space, "_")
            this.%noSpace% := splitINI.Get(k+1)
        }
    }
    dirINI := ptf.SupportFiles "\Streamdeck Files\dirs.ini"
}