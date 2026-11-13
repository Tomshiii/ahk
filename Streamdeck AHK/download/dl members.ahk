; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }


;// requires `bgutil-ytdlp-pot-provider` : https://github.com/Brainicism/bgutil-ytdlp-pot-provider
;// tldr;
/**
 * - use docker
 * - run `docker run --name bgutil-provider -d --init -p 127.0.0.1:4416:4416 brainicism/bgutil-ytdlp-pot-provider`
 * - download `https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases`
 * - place `.zip` here: %APPDATA%\yt-dlp\plugins\
 *     - Use `mkdir "%APPDATA%\yt-dlp\plugins"` if necessary
 * - adjust values below and you're done
 * - turn off docker container when not needed
 */

outputDir := "N:\memb\dl"
list := Map(
    "https://youtu.be/NcVi2iw0ufA", "333. haunted asylum 3"
)
command := 'yt-dlp -N 8 -o "{2}" -S "res,br" -f "bv*+ba/b" --extractor-args "youtube:player_client=web_creator" --windows-filenames --no-overwrites --merge-output-format mkv --cookies-from-browser firefox --no-playlist -P "{3}" "{1}"'

for k, v in list {
    cmd.run(,,, Format(command, k, v, outputDir))
}