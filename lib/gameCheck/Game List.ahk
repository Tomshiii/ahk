;// this code simply adds all the game names to a group

SplitPath(A_LineFile,, &currDir)
list := FileRead(currDir "\games.txt")
splitList := StrSplit(list, [","], "`n`r")

for v in splitList {
    GroupAdd("games", v)
}