#SingleInstance Force

;; This part makes you select the folder you wish to move
SelectedFolder := DirSelect("*E:\", 3, "Pick the folder you wish to move.`nTake note of the folder name as you'll need`nto type it out in the next dialogue box")
if SelectedFolder = ""
    return

;;this part takes that folder directory and splits it out to just grab the final folder in the path as we need it below
FullFileName := SelectedFolder
SplitPath FullFileName, &name

;;this part makes you select the destination folder
Move := DirSelect("*A:\_RC\Tomshi\2021", 3, "Pick the destination folder you wish everything to move to.")
if Move = ""
    return

;;this part deletes the proxies folder if it exists and then moves your selected folder to the selected destination
if DirExist(SelectedFolder "\proxies")
    DirDelete(SelectedFolder "\proxies", 1)
DirMove(SelectedFolder, Move "\" %&name%)

;;this part just opens the final directory
Run(Move "\" %&name%)