/************************************************************************
 * @description A class to contain UIA variables for various versions of premiere
 * @author tomshi
 * @date 2023/10/30
 * @version 1.0.3
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
; }

;// 19/07/2023;
;// Do not expect any of these values to work out of the box, they are incredibly tempremental
;// and change constantly as you adjust your workspace. You will need to adjust them any time you do.
;// you can quickly access this script by right clicking on `My Scripts.ahk` in the windows taskbar tray

;// if you use a version other than the one listed at the top of `Premiere.ahk` (@premVer)
;// there may be values missing. Follow the instructions in the repos wiki to fill them out

;// [Table of Contents]
;//!
/**
timeline              - The timeline panel
effectsControl        - The effects control panel
tools                 - The tools panel
programMon            - The Program monitor panel
effectsPanel          - The Effects panel
*/

class premUIA_Values {
    __New(ver) {
        for _, v in this.arr {
            if !this.%ver%.Has(v) {
                baseVer := SubStr(ver, 1, InStr(ver, "_",,, 1)-1)
                this.%v% := this.%baseVer%.Get(v)
                continue
            }
            this.%v% := this.%ver%.Get(v)
        }
    }

    v22 := Map(
        "timeline"    , "YvY",    "effectsControl", "YYY",
        "tools"       , "YuYY",   "programMon", "Yq",
        "effectsPanel", ""
    )
    v23 := Map(
        "timeline"    , "YyY",    "effectsControl", "YY",
        "tools"       , "YuYYq",  "programMon", "YtY",
        "effectsPanel", "YwY"
    )
    v24 := Map(
        "timeline"    , "YwY",    "effectsControl", "YY",
        "tools"       , "YsY",    "programMon", "YrY",
        "effectsPanel", "YtY"
    )
    v24_3 := Map(
        "timeline"    , "YwY",    "effectsControl", "YY",
        "tools"       , "YtY",    "programMon", "YrY",
        "effectsPanel", "YuY"
    )

    arr := ["timeline", "effectsControl", "tools", "programMon", "effectsPanel"]
}

;// if a specific version breaks anything from the base, create a new object like;
;// v23_6 := Map()
;// and then setting the correct version within `settingsGUI()` will prioritise that version
;// if it isn't set correctly/a specific version object doesn't exist we fall back to the base version
try {
    premClassVer := StrReplace(ptf.premIMGver, ".", "_")
    premUIA := premUIA_Values(premClassVer)
} catch {
    try {
        premGetVer := StrReplace(ptf.premIMGver, ".", "_")
        premClassVer := SubStr(premGetVer, 1, InStr(premGetVer, "_",,, 1)-1)
        premUIA := premUIA_Values(premClassVer)
    } catch {
        throw ValueError("The set version of Premiere does not have a UIA object attached to it.`nPlease add an object to the below script to return functionality.`nCurrent Set Premiere Version: " ptf.premIMGver "`nFile: " A_LineFile, -1)
    }
}