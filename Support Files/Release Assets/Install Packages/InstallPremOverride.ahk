; { \\ #Includes
#Include <Classes\Startup>
; }

;// attempt to set current adobe versions for the first time
SplitPath(A_LineFile,, &currentDir)
SetWorkingDir(currentDir "\..\..\..\")

start := Startup()
start.adobeVerOverride()
start.__Delete()