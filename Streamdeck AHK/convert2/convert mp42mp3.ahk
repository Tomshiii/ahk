#SingleInstance Force
#Include "..\SD_functions.ahk"
convert2("for %i in (*.mp4) do ffmpeg -i " '"' "%i" '" ' '"' "%~ni.mp3" '"' "{Enter}")
;for %i in (*.mp4) do ffmpeg -i "%i" "%~ni.mp3"