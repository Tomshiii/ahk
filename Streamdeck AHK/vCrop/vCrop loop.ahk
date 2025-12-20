#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ffmpeg.ahk
; }

ffmpeg().all_Crop(, {horizontalVertical: "vertical"})