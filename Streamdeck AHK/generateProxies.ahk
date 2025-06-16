; { \\ #Includes
#Include <Classes\ffmpeg>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Other\JSON>
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


if !selectedDir := FileSelect("D3",, "Select Footage Directory") {
    return
}
recurse := ""
files := []
names := []
baseFrameRate := "29.97"
pal := ["25", "50", "100", "200"]
ntsc := ["23.97", "24", "29.97", "30", "59.94", "60", "119.88", "120", "239.76", "240"]
renderScale := 0.5
normalCommand := 'ffmpeg -hwaccel none -i "{1}" -c:v prores -profile:v 0 -pix_fmt yuv422p10 -filter_complex "[0:v]scale={2}[out]" -map "[out]" -c:a copy -map a? -timecode "{3}" -sws_flags bicubic -vsync cfr -metadata:s "encoder=Apple ProRes Proxy" -vendor apl0 -flags bitexact -metadata creation_time="{4}" -y "{5}"'


if MsgBox("Would you like to recurse?", "Recurse?", "4132") = "Yes" {
	recurse := "R"
}
if !DirExist(selectedDir "\proxy")
    DirCreate(selectedDir "\proxy")

filecount := 0
loop files selectedDir "\*", recurse " F"
    filecount+=1
check := Notify.Show('Checking files in chosen directory', , 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' filecount)

loop files selectedDir "\*", recurse {
    check["prog"].value += 1
    inputPath      := obj.SplitPath(A_LoopFileFullPath)
    baseOutputPath := inputPath.dir "\proxy\" inputPath.NameNoExt "_proxy.mov"
    if FileExist(baseOutputPath)
        continue

    try {
        allMetaData := JSON.parse(cmd.result(Format('ffprobe -v error -print_format json -show_format -show_streams "{}"', A_LoopFileFullPath)))
        if allMetaData["streams"]["1"]["r_frame_rate"] = "0/0" || InStr(allMetaData["streams"]["1"]["r_frame_rate"], "/0")
            continue
        getfps := Round(Eval(allMetaData["streams"]["1"]["r_frame_rate"]), 2)
    } catch {
        continue
    }

    try {
        timecode       := allMetaData["streams"]["3"]["tags"]["timecode"]
        width          := allMetaData["streams"]["1"]["width"] * renderScale
        height         := allMetaData["streams"]["1"]["height"] * renderScale
        newDemensions  := Round(width, 0) ":" Round(height, 0)
        metadataCreate := allMetaData["streams"]["1"]["tags"]["creation_time"]
    } catch {
        continue
    }

    files.Push({name: inputPath.NameNoExt "_proxy.mov", path: A_LoopFileFullPath, newDemensions: newDemensions, timecode: timecode, metadataCreate: metadataCreate, baseOutputPath: baseOutputPath})
}
Notify.Destroy(check["hwnd"], true)
if files.Length = 0 {
    Notify.Show(, 'No proxies required', 'C:\Windows\System32\imageres.dll|icon179', 'Windows Battery Critical',, 'theme=Dark dur=4 ms=13 show=Fade@250 hide=Fade@250 maxW=400')
    return
}

rendering := Notify.Show('Rendering files...',, 'C:\Windows\System32\shell32.dll|icon323', 'Speech Misrecognition',, 'theme=Dark dur=0 ts=12 tfo=norm show=Fade@250 hide=Fade@250 maxW=400 prog=h15 w240 Range0-' files.length)
for v in files {
    currentFile := Notify.Show('current file (' A_Index '/' files.length '):', v.name, 'C:\Windows\System32\imageres.dll|icon361',,, 'theme=Dark dur=0 ts=12 tfo=norm mfo=norm Bold show=Fade@250 hide=Fade@250 maxW=400 pad=,,,,,,,1')
    command := Format(normalCommand, v.path, v.newDemensions, v.timecode, v.metadataCreate, v.baseOutputPath)
    cmd.run(,,, command,, "Min")
    rendering["prog"].value += 1
    Notify.Destroy(currentFile["hwnd"], true)
}
Notify.Destroy(rendering["hwnd"], true)
Notify.Show(, 'Rendering Complete', 'C:\Windows\System32\imageres.dll|icon233', 'Windows Print complete',, 'theme=Dark dur=4 show=Fade@250 hide=Fade@250 maxW=400')