; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

vfxFolder := "E:\_Editing stuff\videos"
;yt-dlp -P "link\to\path" "URL"

ytDownload("-S res,ext:mp4:m4a --recode mp4", vfxFolder)