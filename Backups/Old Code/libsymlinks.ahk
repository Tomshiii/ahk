;// New-Item -ItemType Junction -Path $path -Target $target
;// New-Item -ItemType Junction -Path "$env:APPDATA\tomshi" -Target "C:\Users\Tom\Desktop\git\ahk\lib"
; target := A_AppData "\tomshi\"
; MsgBox(Format('New-Item -ItemType Junction -Path "$env:APPDATA\tomshi" -Target "{1}"', path))
__createSym(origPath) {
    SplitPath(origPath, &targetDir)
    try DirCreate(A_AppData "\tomshi\" targetDir)
    Run('powershell.exe -c "' Format('New-Item -ItemType Junction -Path "$env:APPDATA\tomshi\' targetDir '" -Target "{1}"', origPath) '"')
}

; __createSym("C:\Users\Tom\Desktop\ahk\ahk\lib")