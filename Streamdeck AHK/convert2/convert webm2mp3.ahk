#SingleInstance Force
#Include "..\SD_functions.ahk"
convert2("for %i in (*.webm) do ffmpeg -i " '"' "%i" '" ' '"' "%~ni.mp3" '"' "{Enter}")
;for %i in (*.webm) do ffmpeg -i "%i" "%~ni.mp3"