/************************************************************************
 * @description A class to generate variables based off a combo ini file
 * @author tomshi
 * @date 2026/03/20
 * @version 1.2.0
 ***********************************************************************/

;{ \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ptf.ahk
#Include Classes\Mip.ahk
; #Include Other\print.ahk
; }

class KeyShortAdjust {
    __New() {
        if !FileExist(this.iniLocation)
            FileCopy(ptf.lib "\KSA\Keyboard Shortcuts.ini", this.iniLocation)
        this.checkINI()
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
     * Checks the user's active ksa.ini file against the template within the lib directory to ensure they aren't missing any values
     */
    checkINI() {
        templateINI := ptf.lib "\KSA\Keyboard Shortcuts.ini"
        currentINI  := this.iniLocation

        templateArr := __createArr(templateINI)
        currentArr  := __createArr(currentINI)

        for section in templateArr.OwnProps() {
            for k, v in templateArr.%section% {
                ; MsgBox(currentArr.%section%.has(k) "`n" section "`n" k)
                if !currentArr.%section%.has(k) {
                    ; MsgBox(k "`n" v "`n" section)
                    IniWrite(v, currentINI, section, k)
                }
            }
        }

        __createArr(path) {
            try read := IniRead(path)
            catch {
                throw TargetError("Could not determine KSA ini file")
            }
            iniObj := {}
            splitRead := StrSplit(read, "`n")
            for section in splitRead {
                iniObj.%section% := Map()
                currSection := IniRead(path, section)
                secSplit := StrSplit(currSection, "`n")
                for v in secSplit {
                    mid := InStr(v, "=",, 1, 1)
                    key   := SubStr(v, 1, mid-1)
                    value := SubStr(v, mid+1)
                    ; obj := {section: section, key: key, value: value}
                    iniObj.%section%.set(key, value)
                }
            }
            return iniObj
        }
    }

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
KSA := KeyShortAdjust()