; { \\ #Includes
#Include <Classes\settings>
; }

SplitPath(A_LineFile,, &currentDir)
SetWorkingDir(currentDir "\..\..\..\")
UserSettings := UserPref()
if UserSettings.working_dir != A_WorkingDir
    UserSettings.working_dir := A_WorkingDir
UserSettings.__delAll()