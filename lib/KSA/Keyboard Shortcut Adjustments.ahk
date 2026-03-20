/************************************************************************
 * @description A class to generate variables based off a combo ini file
 * @author tomshi
 * @date 2026/03/23
 * @version 1.2.3
 ***********************************************************************/

;{ \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\Mip.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\checkINI.ahk
; #Include Other\print.ahk
; }

class KeyShortAdjust {
    __New(doCheck := false) {
        if !FileExist(this.iniLocation)
            FileCopy(ptf.lib "\KSA\Keyboard Shortcuts.ini", this.iniLocation)

        templateINI := ptf.lib "\KSA\Keyboard Shortcuts.ini"
        currentINI  := this.iniLocation
        if doCheck = true
          checkINI(templateINI, currentINI)
        this.__SetSections()
    }
    iniLocation => ptf["KSAini"]

    /**
     * Turns the section of an ini file into an array
     * @param {String} section the name of the ini section
     * @return returns a Map of all key names with their values in the ini section that was passed to the function
     */
    __CreateMap(section, iniLocation := this.iniLocation) {
        getSection := IniRead(iniLocation, section)
        arr := StrSplit(getSection, ["`n", "`r"])
        newMap := Mip()
        for v in arr {
            key := SubStr(v, 1, (equals := InStr(v, "=",,, 1))-1)
            value := SubStr(v, equals+1)
            if InStr(key, A_Space)
                key := StrReplace(key, A_Space, "_")
            if newMap.Has(key)
                throw ValueError("Variable Already Exists. Try a new name.", -1, key)
            newMap.Set(key, value)
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
    __SetSections(iniLocation := this.iniLocation) {
        if !FileExist(iniLocation) ;// a standalone app might attempt to call this function and the user may not have my whole repo installed
            return
        readSections := IniRead(iniLocation)
        allSections := StrSplit(readSections, ["`n", "`r"])
        for v in allSections {
            sectionArr := this.__CreateMap(v, iniLocation)
            for k, v2 in sectionArr {
                this.%k% := this.__SetType(v2)
                ; print("Index: " k "`nvariablename: " v2 "`nvalue: " this.__SetType(v2) "`n-------`n") ;// debugging
            }
        }
    }
}
if A_ScriptName != "Core Functionality.ahk"
    KSA := CLSID_Objs.clone("KSA")