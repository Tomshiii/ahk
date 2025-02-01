;// this code simply adds all the game names to a group

SplitPath(A_LineFile,, &currDir)
list := FileRead(currDir "\games.txt")
splitList := StrSplit(list, ",")

for v in list {
    GroupAdd("games", v)
}