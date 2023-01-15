#Include "..\..\lib\Functions\createIni.ahk"
SetWorkingDir("..\..\")

;// if your installation failed, or you've chosen to clone my repo instead, this script will help you generate a baseline settings.ini file to stop errors
createIni(A_MyDocuments "\tomshi", "true", "false", "", "false", "true", "true", "true", "false", 45, 5, 5, 2.5, 5, "2022", "2022", "v22.3.1", "v22.6", "v24.0.1", "v18.0.4", 0, A_WorkingDir, "false", "false", 0, 0)