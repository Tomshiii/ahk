;// I download all fonts into a single folder, but if you attempt to drag and drop folders into the "fonts" folder, it won't add the fonts, so it's better to drag all of the
;// individual files.
;// this function is to simply pull all font files out of folders and place them in the main folder
;// nothing special

; { \\ #Includes
#Include <Other\print>
; }

baseFolder := "C:\Users\Tom\Downloads\Fonts"
loop files baseFolder "\*", "F R" {
   if A_LoopFileDir = baseFolder
      continue
   if A_LoopFileExt != "ttf"
      continue
   try FileCopy(A_LoopFileFullPath, baseFolder "\*.*")
   catch
      continue
   print(A_LoopFileName)
}