; { \\ #Includes
#Include <checklist\generateIni>
; }

/**
 * Getting the path of the project using the title of Premiere Pro/After Effects
 * @param {String} name is the title of the program you have to pass into the funtion
 * @param {Integer} dashPos is the position of the - that you have to pass into the function
 * @param {VarRef} checklist is a variable we have to pass back out of the function, it MUST be called checklist
 * @param {VarRef} logs is a variable we have to pass back out of the function, it MUST be called logs
 * @param {VarRef} path is a variable we have to pass back out of the function, it MUST be called path
 */
getPath(name, dashPos, &checklist, &logs, &path)
{
    length := StrLen(name) - dashPos
    entirePath := SubStr(name, dashPos + "2", length)
    pathlength := StrLen(entirePath)
    finalSlash := InStr(entirePath, "\",, -1)
    path := SubStr(entirePath, 1, finalSlash - "1")
    checklist := path "\checklist.ini"
    logs := path "\checklist_logs.txt"
    if !FileExist(checklist)
        generateINI(checklist)
}