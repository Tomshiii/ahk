; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Functions\nItemsInDir>
#Include <Other\JSON>
#Include <Other\print>
#Include <Other\Notify\Notify>
; }

;// I wish to hopefully build a little gui for this eventually but for now I just need it working

#SingleInstance Force

Eval(Script) {
    shell := ComObject('WScript.Shell')
    exec := shell.Exec(A_AhkPath ' /ErrorStdOut *')
    exec.stdin.Write('#NoTrayIcon`nFileAppend(' script ', "*")')
    exec.StdIn.Close()
    return exec.StdOut.ReadAll()
}

activeWin := WinGet.ExplorerPath()
defaultDir := activeWin != false ? activeWin : ""
selectedDir := FileSelect("D3 M", defaultDir,  "Select Footage Directory")
if !selectedDir
    return

;// one day would like to add a GUI to add folders to a list - ie a queuing system
/* selectedDir := [] */

recurse := ""
files := []
names := []
renderScale := 0.125
normalCommand := 'ffmpeg -hwaccel none -i "{1}" -c:v prores -profile:v 0 -pix_fmt yuv422p10 -filter_complex "[0:v]scale={2}[out]" -map "[out]" -c:a copy -map a? {3} -sws_flags bicubic -vsync cfr -metadata:s "encoder=Apple ProRes Proxy" -vendor apl0 -flags bitexact -metadata creation_time="{4}" -y "{5}"'
;// watermark
watermarkDir := "W:\_Assets\Plugins & Presets\watermarks"
wCommand := 'ffmpeg -hwaccel none -i "{1}" -i "{6}" -c:v prores -profile:v 0 -pix_fmt yuv422p10 -filter_complex "[0:v]scale={2}[scaled];[1:v]scale={2},format=rgba,colorchannelmixer=aa=0.7[watermark];[scaled][watermark]overlay=0:H/2-h+30[out]" -map "[out]" -c:a copy -map a? {3} -sws_flags bicubic -vsync cfr -metadata:s "encoder=Apple ProRes Proxy" -vendor apl0 -flags bitexact -metadata creation_time="{4}" -y "{5}"'



if MsgBox("Would you like to recurse?", "Recurse?", "4132") = "Yes" {
	recurse := "R"
}
ffmpegInst := ffmpeg()

for v in selectedDir {
    recurse := "R"
    getFileCount := nItemsInDir(v, (recurse = "R" ? true : false))
    filecount := getFileCount.files

    check := Notify.Show('Checking files in chosen directory', , 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' filecount)

    loop files v "\*", recurse "F" {
        check["prog"].value += 1
        inputDir  := obj.SplitPath(A_LoopFileDir)
        inputPath := obj.SplitPath(A_LoopFileFullPath)
        if inputDir.name = "_proxy" || inputDir.name = "proxy"
            continue
        if !ffmpegInst.isVideo(A_LoopFileFullPath)
            continue
        if !DirExist(inputPath.dir "\proxy")
            DirCreate(inputPath.dir "\proxy")
        baseOutputPath := inputPath.dir "\proxy\" inputPath.NameNoExt "_proxy.mov"
        if FileExist(baseOutputPath)
            continue
        wMark := (FileExist(watermarkDir "\watermark_" inputDir.name ".png")) ? watermarkDir "\watermark_" inputDir.name ".png" : ""
        try {
            allMetaData := JSON.parse(cmd.result(Format('ffprobe -v error -print_format json -show_format -show_streams "{}"', A_LoopFileFullPath)))
            if allMetaData["streams"]["1"]["r_frame_rate"] = "0/0" || InStr(allMetaData["streams"]["1"]["r_frame_rate"], "/0")
                continue
            getfps := Round(Eval(allMetaData["streams"]["1"]["r_frame_rate"]), 2)
        } catch {
            continue
        }

        try timecode   := '-timecode "' allMetaData["streams"]["3"]["tags"]["timecode"] '"'
        catch {
            timecode   := ""
        }
        width          := allMetaData["streams"]["1"]["width"] * renderScale
        height         := allMetaData["streams"]["1"]["height"] * renderScale
        newDimensions  := Round(width, 0) ":" Round(height, 0)
        try metadataCreate := allMetaData["streams"]["1"]["tags"]["creation_time"]
        catch {
            ; cmmd := '$creationTime = [string]::Format("{0:yyyy-MM-ddTHH:mm:ss}.{1:D9}Z", (Get-Date).ToUniversalTime(), ((Get-Date).Ticks % 10000000) * 100); Write-Output $creationTime'
            ; to get encoded;
            /**
            $command = @'
            $ct = [string]::Format("{0:yyyy-MM-ddTHH:mm:ss}.{1:D9}Z", (Get-Date).ToUniversalTime(), ((Get-Date).Ticks % 10000000) * 100)
            Write-Output $ct
            '@
            $bytes = [Text.Encoding]::Unicode.GetBytes($command)
            $encodedCommand = [Convert]::ToBase64String($bytes)
            Write-Output $encodedCommand
            */
            encoded := "JABjAHQAIAA9ACAAWwBzAHQAcgBpAG4AZwBdADoAOgBGAG8AcgBtAGEAdAAoACIAewAwADoAeQB5AHkAeQAtAE0ATQAtAGQAZABUAEgASAA6AG0AbQA6AHMAcwB9AC4AewAxADoARAA5AH0AWgAiACwAIAAoAEcAZQB0AC0ARABhAHQAZQApAC4AVABvAFUAbgBpAHYAZQByAHMAYQBsAFQAaQBtAGUAKAApACwAIAAoACgARwBlAHQALQBEAGEAdABlACkALgBUAGkAYwBrAHMAIAAlACAAMQAwADAAMAAwADAAMAAwACkAIAAqACAAMQAwADAAKQAKAFcAcgBpAHQAZQAtAE8AdQB0AHAAdQB0ACAAJABjAHQA"
            metadataCreate := cmd.result(Format('powershell -NoProfile -EncodedCommand "{}"', encoded),,, "c:\")
        }
        files.Push({name: inputPath.NameNoExt "_proxy.mov", path: A_LoopFileFullPath, newDimensions: newDimensions, timecode: timecode, metadataCreate: metadataCreate, baseOutputPath: baseOutputPath, watermark: wMark })
    }
}

Notify.Destroy(check["hwnd"], true)
if files.Length = 0 {
    Notify.Show(, 'No proxies required', 'C:\Windows\System32\imageres.dll|icon179', 'Windows Battery Critical',, 'theme=Dark dur=4 ms=13 show=Fade@250 hide=Fade@250 maxW=400')
    return
}

rendering := Notify.Show('Rendering files...',, 'C:\Windows\System32\shell32.dll|icon323', 'Speech Misrecognition',, 'theme=Dark dur=0 ts=12 tfo=norm show=Fade@250 hide=Fade@250 maxW=400 prog=h15 w240 Range0-' files.length)
for v in files {
    currentFile := Notify.Show('current file (' A_Index '/' files.length '):', v.name, 'C:\Windows\System32\imageres.dll|icon361',,, 'theme=Dark dur=0 ts=12 tfo=norm mfo=norm Bold show=Fade@250 hide=Fade@250 maxW=400 pad=,,,,,,,1')
    command := (v.watermark != "") ? Format(wCommand, v.path, v.newDimensions, v.timecode, v.metadataCreate, v.baseOutputPath, v.watermark)
                            : Format(normalCommand, v.path, v.newDimensions, v.timecode, v.metadataCreate, v.baseOutputPath)
    cmd.run(,,, command,, "Min")
    rendering["prog"].value += 1
    Notify.Destroy(currentFile["hwnd"], true)
}
Notify.Destroy(rendering["hwnd"], true)
Notify.Show(, 'Rendering Complete', 'C:\Windows\System32\imageres.dll|icon233', 'Windows Print complete',, 'theme=Dark dur=4 show=Fade@250 hide=Fade@250 maxW=400')