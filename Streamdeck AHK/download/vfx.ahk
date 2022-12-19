; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

vfxFolder := "E:\_Editing stuff\videos"
;yt-dlp -P "link\to\path" "URL"

ytDownload("-S vcodec:h264", vfxFolder)