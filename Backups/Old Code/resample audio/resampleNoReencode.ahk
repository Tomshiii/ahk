#Requires AutoHotkey v2.0
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Classes\explorer>
#Include <Other\print>
#Include <Other\Notify\Notify>

sampleRate := "48000"
ffmp := ffmpeg()
ffmp.doAlert := false

;// resample footage to 48KHz without video reencode
if !rootDir := FileSelect("D2",, "Select Folder to Resample (this process will recurse to all subdirs)")
    ExitApp()
cmnd := 'ffmpeg -i "{1}" -c:v copy -c:a aac -ar {3} -b:a 192k "{2}"'
totalFIles := explorer.nItemsInDir(rootDir, true)

check := Notify.Show('Resampling files in chosen directory', , 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' totalFIles.files)
loop files rootDir "\*", "FR" {
    SplitPath(A_LoopFileFullPath,, &outdir)
    SplitPath(outdir, &dirName)
    if dirName = "resample"
        continue
    check["prog"].value += 1
    print("File: " A_LoopFileName)
    if !DirExist(A_LoopFileDir "\resample")
        DirCreate(A_LoopFileDir "\resample")
    if FileExist(A_LoopFileDir "\resample\" A_LoopFileName) {
        continue
    }
    try Hz := ffmp.__getFrequency(A_LoopFileFullPath)
    catch {
        continue
    }
    if !Hz.hzArr.Has(1) || Hz.hzArr[1] = sampleRate
        continue
    print("doing command: " A_LoopFileFullPath)
    cmd.run(,,, Format(cmnd, A_LoopFileFullPath, A_LoopFileDir "\resample\" A_LoopFileName, sampleRate),, "Hide")
}
Notify.Destroy(check["hwnd"], true)
ffmp.__Delete()
ffmp := ""