;// this script requires ffmpeg to be installed correctly and to the system path

; { \\ #Includes
#Include <Classes\trim>
; }

trimAud := trimGUI("video", "-c:v copy -c:a copy")
trimAud.show()