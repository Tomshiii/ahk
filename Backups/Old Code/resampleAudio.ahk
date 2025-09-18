; { \\ #Includes
#Include <Classes\cmd>
#Include <Classes\ffmpeg>
#Include <Functions\nItemsInDir>
#Include <Other\Notify\Notify>
; }

dir := "W:\_Assets\sfx"
sampleRate := "48000"
totalFIles := nItemsInDir(dir)
ffmp := ffmpeg()
ffmp.doAlert := false

check := Notify.Show('Checking files in chosen directory', , 'C:\Windows\System32\imageres.dll|icon244', 'Speech Misrecognition',, 'theme=Dark dur=0 show=Fade@250 ts=12 tfo=norm hide=Fade@250 maxW=400 prog=h15 w240 Range0-' totalFIles.files)
loop files dir "\*.*", "F" {
    SplitPath(A_LoopFileFullPath, &outname, &outDir, &ext, &nameNoExt)
    check["prog"].value += 1
    try Hz := ffmp.__getFrequency(A_LoopFileFullPath)
    catch {
        continue
    }
    if !Hz.hzArr.Has(1) || Hz.hzArr[1] = sampleRate
        continue
    command := Format('ffmpeg -i "{1}" -ar 48000 "{3}" && move "{3}" "{1}" || del -f "{3}"', A_LoopFilePath, sampleRate, outDir "\" nameNoExt "_temp." ext)
    cmd.run(,,, command)
}
Notify.Destroy(check["hwnd"], true)
ffmp.__Delete()
ffmp := ""