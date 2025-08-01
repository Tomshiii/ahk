#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

;// idk why but something on my pc will randomly change my mic's output volume
;// sometimes it's 10db lower than it should be, sometimes it's like 20db over
;// this is a simple time to check it every 15min to ensure I'm not getting bamboozled

minutes := 15
frequency := 1000*60*minutes

SetTimer(__doCheck, frequency)
__doCheck() {
    mic := "Microphone (RODECaster Pro II Chat)"
    try getVol := SoundGetVolume(, mic)
    catch {
        return
    }
    if Round(getVol, 1) != 53.5 ;// 53.5% is 0.00db for my mic for whatever reason
        SoundSetVolume(53.5,, mic)
}