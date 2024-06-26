/************************************************************************
 * @description handle options.ini file
 * @author tomshi
 * @date 2024/06/26
 * @version 1.1.0
 ***********************************************************************/
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
                this.currentCount++
            }
        }
    }
    optionsINI := ptf.SupportFiles "\Streamdeck Files\options.ini"

    currentCount := 0

    defaultsDirs := Map(
        ;// [dirs]
        "sfxFolder", "E:\_Editing stuff\sfx",         "vfxFolder", "E:\_Editing stuff\videos",
        "editingMusic", "E:\_Editing stuff\Music",    "commsFolder", "E:\comms",
        "editingRoot", "E:\_Editing stuff",
    )
    defaultsSett := Map(
        ;// [settings]
        "filenameLengthLimit", "50",
        "defaultNVENCencode", "--ppa `"VideoConvertor:-c:v h264_nvenc -preset 18 -cq 17`"",
    )

    /**
     * Checks the current options.ini file against default values to ensure all available settings exist. It is essential to check for this in the instance where the user clones the repo or otherwise doesn't use the repo by downloading each release
     */
    checkCount() {
        if this.currentCount == (this.defaultsDirs.count + this.defaultsSett.count)
            return

        __checkSec(defSectionMap, sectionName) {
            currINIRead := StrSplit(IniRead(this.optionsINI, sectionName), ["=", "`n", "`r"])
            currMap := Map()
            for i, v in currINIRead {
                if Mod(i, 2) = 0
                    continue
                currMap.Set(v, currINIRead.Get(i+1))
            }
            for k, v in defSectionMap {
                if !currMap.Has(k)
                    IniWrite(v, this.optionsINI, sectionName, k)
            }
        }
        __checkSec(this.defaultsDirs, "dirs")
        __checkSec(this.defaultsSett, "settings")
    }
}