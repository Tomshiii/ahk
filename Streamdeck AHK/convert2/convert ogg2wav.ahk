#SingleInstance Force
; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\ffmpeg.ahk
; }

ffmpeg().all_XtoY("W:\REPO_Sounds-20251014T012517Z-1-001\REPO_Sounds", "ogg", "wav")