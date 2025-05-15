#Include <Classes\ptf>

RunWait '"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"'
  . ' /in ' ptf.rootDir '"\Streamdeck AHK\download\mult-dl.ahk"'
  . ' /icon ' ptf.rootDir '"\Support Files\Icons\myscript.ico"'
  . ' /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"'
  . ' /compress 0'

