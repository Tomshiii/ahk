/************************************************************************
 * @description A class to generate variables based off a combo ini file
 * @author tomshi
 * @date 2023/01/19
 * @version 1.0.0b2
 ***********************************************************************/

;{ \\ #Includes
#Include <Classes\ptf>
; #Include <Other\print>
; }

class KeyShortAdjust {
    __New() {
        this.__SetSections()
    }
    iniLocation => ptf["KSAini"]

    /**
     * Turns the section of an ini file into an array
     * @param {String} section the name of the ini section
     * @return returns a Map of all key names with their values in the ini section that was passed to the function
     */
    __CreateMap(section) {
        getSection := IniRead(this.iniLocation, section)
        ;// checking to see if `=` is between any of the ""
        loop {
            if !var := InStr(getSection, '="',,, A_Index)
                break
            if InStr(SubStr(getSection, var+1, InStr(getSection, '"',, var, 2) - var)
                        , "=")
                throw ValueError("An = sign was used in an ini value. Please remove this entry.", -1, section)
            ; print(SubStr(getSection, var+1, InStr(getSection, '"',, var, 2) - var))
        }
        ;// splitting the section into an array
        arr := StrSplit(getSection, ["=", "`n", "`r"])
        newMap := Map()
        newMap.CaseSense := "Off"
        for i, v in arr {
            if Mod(i, 2) = 0
                continue
            if i+1 > arr.Length
                break
            if newMap.Has(v)
                throw ValueError("Variable Already Exists. Try a new name.", -1, v)
            newMap.Set(v, arr.Get(i+1))
        }
        return newMap
    }

    /**
     * removes any quote marks from the string
     * @param {Any} input the ini value being sent to have '"' removed
     * @return returns the input variable without any quote marks
     */
    __SetType(input) => StrReplace(input, '"', "")

    /**
     * generate all variables based off ini file
     */
    __SetSections() {
        readSections := IniRead(this.iniLocation)
        allSections := StrSplit(readSections, ["`n", "`r"])
        for v in allSections {
            sectionArr := this.__CreateMap(v)
            for k, v2 in sectionArr {
                this.%k% := this.__SetType(v2)
                ; print("Index: " k "`nvariablename: " v2 "`nvalue: " this.__SetType(v2) "`n-------`n") ;// debugging
            }
        }
    }
}
KSA := KeyShortAdjust()