; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

commsFolder := "E:\comms"
;yt-dlp -P "link\to\path" "URL"

ytDownload("-S res,ext:mp4:m4a --recode mp4", commsFolder)