#SingleInstance Force
; { \\ #Includes
#Include <Functions\SD Functions\convert2>
; }

convert2("for %i in (*.mp4) do ffmpeg -i " '"' "%i" '" ' '"' "%~ni.mp3" '"' "{Enter}")
;for %i in (*.mp4) do ffmpeg -i "%i" "%~ni.mp3"