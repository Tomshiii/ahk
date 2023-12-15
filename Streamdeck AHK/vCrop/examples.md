# A few examples
## > crop video - Returns top half
`ffmpeg -i "[INPUT FILEPATH]" -c:v libx264 [COMMANDS] "crop=in_w:in_h/2:0:0" "[OUTPUT FILEPATH]"`

## > crop video - Returns bottom half
`ffmpeg -i "[INPUT FILEPATH]" -c:v libx264 [COMMANDS] "crop=in_w:in_h/2:in_w:in_h" "[OUTPUT FILEPATH]"`

## > crop video - Splits in half and returns two files
`ffmpeg -i "[INPUT FILEPATH]" [COMMANDS] -filter_complex "[0]crop=iw:ih/2:0:0[left];[0]crop=iw:ih/2:0:oh[right]" -map "[left]" "[LEFT OUTPUT FILEPATH]" -map "[right]" "[RIGHT OUTPUT FILEPATH]"`

## > crop video - loops directory - returns two files
#### Windows
`for %f in (*.mkv) do ffmpeg -i "%f" [COMMANDS] -filter_complex "[0]crop=iw:ih/2:0:0[left];[0]crop=iw:ih/2:0:oh[right]" -map "[left]" "%~nf_c1.mp4" -map "[right]" [COMMANDS] "%~nf_c2.mp4"`
#### macOS
`for f in *.mkv; do ffmpeg -i "$f" [COMMANDS] -filter_complex "[0]crop=iw:ih/2:0:0[left];[0]crop=iw:ih/2:0:oh[right]" -map "[left]" "%~nf_c1.mp4" -map "[right]" [COMMANDS] "${f%.mkv}.mp4"; done`

### > example commands -
`-c:v libx264 -preset veryfast -b:v 30000k -c:a copy`