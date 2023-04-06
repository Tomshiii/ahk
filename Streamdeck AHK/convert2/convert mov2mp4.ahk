#SingleInstance Force
; { \\ #Includes
#Include <Functions\SD Functions\convert2>
; }

convert2('for /R %f IN (*.mov) DO ffmpeg -i "%f" -map 0 -c copy "%~nf.mp4"')
;for /R %f IN (*.mov) DO ffmpeg -i "%f" -map 0 -c copy "%~nf.mp4"

