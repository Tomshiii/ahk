; { \\ #Includes
#Include <Classes\ptf>
; }

class SD_Opt {
    __New() {
        sections := StrSplit(IniRead(this.optionsINI), ["`n", "`r"])
        for sec in sections {
            splitINI := StrSplit(IniRead(this.optionsINI, sec), ["=", "`n", "`r"])
            for k, v in splitINI {
                if Mod(k, 2) = 0
                    continue
                noSpace := StrReplace(v, A_Space, "_")
                this.%noSpace% := splitINI.Get(k+1)
            }
        }
    }
    optionsINI := ptf.SupportFiles "\Streamdeck Files\options.ini"
}