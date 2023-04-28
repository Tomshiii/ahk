;// this script requires ffmpeg to be installed correctly and to the system path

; { \\ #Includes
#Include <GUIs\trim>
; }

trimGUI("video", "-c:v copy -c:a copy -crf 17")