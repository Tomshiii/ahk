#Requires AutoHotkey v2.0
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\ffmpeg.ahk
#Include Classes\explorer.ahk
#Include Other\print.ahk
#Include Other\Notify\Notify.ahk

sampleRate := "48000"
ffmp := ffmpeg()
ffmp.doAlert := false

;// resample footage to 48KHz without video reencode
if !rootDir := FileSelect("D2",, "Select Folder to Resample (this process will recurse to all subdirs)")
    ExitApp()
cmnd := 'ffmpeg -y -i "{1}" -c:v copy -c:a pcm_s16le -ar {3} -b:a 192k "{2}" && move /Y "{2}" "{1}"'

totalFIles := explorer.nItemsInDir(rootDir, true)
ignore := DirExist(rootDir "\orig") ? explorer.nItemsInDir(rootDir "\orig", true) : {files: 0}

check := Notify.Show('Resampling files in chosen directory', , 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' totalFIles.files-ignore.files)
completed := Map()
ignore := Map("orig", true)
loop files rootDir "\*", "FR" {
    SplitPath(A_LoopFileFullPath,, &outdir, &origext, &noext)
    SplitPath(outdir, &dirName)
    check["prog"].value += 1
    if completed.Has(A_LoopFileFullPath)
        continue
    doCont := false
    for v in ignore {
        if InStr(A_LoopFileFullPath, "\" v "\") {
            doCont := true
            break
        }
    }
    if doCont= true
        continue
    try Hz := ffmp.__getFrequency(A_LoopFileFullPath)
    catch {
        continue
    }
    if !Hz.hzArr.Has(1) || Hz.hzArr[1] = sampleRate
        continue
    print("File: " A_LoopFileName)
    print("orig Hz: " Hz.hzArr[1] " || doing command: " A_LoopFileFullPath)
    cmd.run(,,, Format(cmnd, A_LoopFileFullPath, outdir "\" noext "_temp.wav", sampleRate),, "Hide")
    if origext != "wav" {
        completed.Set(outdir "\" noext "." origext, true)
        completed.Set(outdir "\" noext ".wav", true)
        if FileExist(outdir "\" noext "." origext) && FileExist(outdir "\" noext ".wav")
            FileDelete(outdir "\" noext "." origext)
    }
}
Notify.Destroy(check["hwnd"], true)
ffmp.__Delete()
ffmp := ""