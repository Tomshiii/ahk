; { \\ #Includes
#Include <Classes\obj>
#Include <Classes\winget>
#Include <Classes\errorLog>
; }

;// this function was an attempt to support multiple versions of adobe products at once
;// the idea was that each version folder would update with new images
;// but if an image cannot be found in the version folder it would default back to a fallback folder
;// I thought this made sense at first but then I realised that as soon as I updated once the whole system would
;// fall apart and I'd need to perpetually store multiple versions of the same file because new images wouldn't be
;// in the fallback folder

imgAdobe(&x, &y, x1, y1, x2, y2, path) {
    if InStr(path, "*") {
        asterisk := SubStr(path, 1, firstSpace := InStr(path, A_Space,, 1, 1)-1)
        path     := SubStr(path, firstSpace + 2)
    }
    if !FileExist(path) {
        split := obj.SplitPath(path)
        path  := WinGet.pathU(split.dir "\..\") "fallback\" split.name
        if !FileExist(path) {
            ;// throw
            errorLog(ValueError("File does not exist", -1, path),,, 1)
            return
        }
    }
    if !ImageSearch(&x, &y, x1, y1, x2, y2, asterisk " " path)
        return false
    return true
}