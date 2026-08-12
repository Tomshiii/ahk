;// New-Item -ItemType Junction -Path $path -Target $target

;// New-Item -ItemType Junction -Path "$env:APPDATA\tomshi" -Target "C:\Users\Tom\Desktop\git\ahk\lib"
path := "C:\Users\Tom\Desktop\ahk\ahk\lib"
; target := A_AppData "\tomshi\"
; MsgBox(Format('New-Item -ItemType Junction -Path "$env:APPDATA\tomshi" -Target "{1}"', path))
Run('powershell.exe -c "' Format('New-Item -ItemType Junction -Path "$env:APPDATA\tomshi\lib" -Target "{1}"', path) '"')
