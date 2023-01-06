; { \\ #Includes
#Include <Functions\SD Functions\ytDownload>
; }

commsFolder := "E:\comms"
;yt-dlp -P "link\to\path" "URL"

;// I use these scripts to quickly download videos to use for editing within Premiere Pro.
;// Premiere Pro doesn't accept vp9 files so I download the highest quality mp4 as youtube only uses vp9 for webm files
ytDownload("-S ext:mp4:m4a", commsFolder)