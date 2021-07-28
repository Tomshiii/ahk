IfWinNotActive ahk_exe Adobe Premiere Pro.exe
{
;F13::
Run, C:\Program Files\ahk\TomSongQueueue\Builds\ApplicationDj.exe ;runs the queue program incase it opened too late
if WinExist("ahk_exe ApplicationDj.exe") ;waits until ttp's program is open then brings it into focus
			WinActivate
		else
			WinWaitActive, ahk_exe ApplicationDj.exe
sleep 1000 ;waits since it's not responsive to input for a second even after it has opened
SendInput, y{enter}
}
else
    sleep 100