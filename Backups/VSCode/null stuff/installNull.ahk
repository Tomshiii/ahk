; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Apps\VSCode.ahk
; }

SplitPath(A_LineFile,, &dir)
SetWorkingDir(dir)

if !VSCode.__isInstalled() || !DirExist("C:\Users\" A_UserName "\.vscode")
    throw TargetError("vscode is not installed", -1)

if !thqbyExt := cmd.result('code --list-extensions --show-versions | findstr /i "thqby.vscode-autohotkey2-lsp"')
    throw TargetError("thqby extension is not installed")

thqbyExt := StrReplace(thqbyExt, "@", "-",,, 1)
DirCreate("C:\Users\" A_UserName "\.vscode\extensions\")
DirCopy(dir "\local.ahk2-null-highlight-1.0.1", "C:\Users\" A_UserName "\.vscode\extensions\local.ahk2-null-highlight-1.0.1", true)
FileCopy(dir "\ahk2.tmLanguage.json", "C:\Users\" A_UserName "\.vscode\extensions\" thqbyExt "\syntaxes\ahk2.tmLanguage.json", true)