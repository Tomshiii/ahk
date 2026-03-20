/**
 * Checks an ini file against a template to ensure no values are missing
 */
checkINI(tempLoc, currentLoc) {
    templateINI := tempLoc
    currentINI  := currentLoc
    SplitPath(currentINI, &filename)

    templateArr := __createArr(templateINI)
    currentArr  := __createArr(currentINI)

    for section in templateArr.OwnProps() {
        for k, v in templateArr.%section% {
            if !currentArr.%section%.has(k) {
                IniWrite(v, currentINI, section, k)
            }
        }
    }

    __createArr(path) {
        try read := IniRead(path)
        catch {
            throw TargetError("Could not determine " filename " file")
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