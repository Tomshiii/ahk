; { \\ #Includes
#Include <Classes\settings>
#Include <Classes\Startup>
; }

UserSettings := UserPref()
SplitPath(A_LineFile,, &currentDir)
SetWorkingDir(currentDir "\..\..\..\")
if UserSettings.working_dir != A_WorkingDir
    UserSettings.working_dir := A_WorkingDir
UserSettings := ""

start := Startup()
start.generate()
start.__Delete()