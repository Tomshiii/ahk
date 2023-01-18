/************************************************************************
 * @description A class to generate variables based off a combo ini file
 * @author tomshi
 * @date 2023/01/19
 * @version 1.0.0b1
 ***********************************************************************/

;{ \\ #Includes
#Include <Classes\ptf>
; }

class KeyShortAdjust {
    __New() {
        this.__SetSections()
    }
    iniLocation => ptf["KSAini"]

    /**
     * Turns the section of an ini file into an array
     */
    __CreateArr(section) {
      newArr := []
      getSection := IniRead(this.iniLocation, section)
      return StrSplit(getSection, ["=", "`n", "`r"])
    }

    /**
     * removes any quote marks from the string
     */
    __SetType(input) => StrReplace(input, '"', "")

    /**
     * generate all variables based off ini file
     */
    __SetSections() {
        readSections := IniRead(this.iniLocation)
        allSections := StrSplit(readSections, ["`n", "`r"])
        for v in allSections {
            sectionArr := this.__CreateArr(v)
            for k, v2 in sectionArr {
                if Mod(k, 2) = 0
                  continue
                if k+1 <= sectionArr.Length
                  this.%v2% := this.__SetType(sectionArr.Get(k+1))
            }
        }
    }
}
KSA := KeyShortAdjust()