#SingleInstance Force
; { \\ #Includes
#Include <Functions\SD Functions\convert2>
; }

convert2('for /R %f IN (*.mkv) DO ffmpeg -i "%f" -codec copy -map 0:a -map 0:v "%~nf.mp4"')
;for /R %f IN (*.mkv) DO ffmpeg -i "%f" -codec copy -map 0:a -map 0:v "%~nf.mp4"


