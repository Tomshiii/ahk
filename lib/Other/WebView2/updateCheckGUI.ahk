#Include WebView2.ahk
#SingleInstance Force
SetWorkingDir("..\..\..\")
#Include "..\..\..\lib\KSA\Keyboard Shortcut Adjustments.ahk" ;this is added because we need it
#Include "..\..\..\lib\Functions\Windows.ahk" ;this is only added to prevent errors
#Include "..\..\..\lib\Functions\switchTo.ahk" ;this is only added to prevent errors
#Include "..\..\..\lib\Functions\Startup.ahk" ;this is only added to prevent errors
#Include "..\..\..\lib\Functions\General.ahk" ;this is added because we need it

TraySetIcon(ptf.Icons "\update.png")

if IniRead(ptf.files["settings"], "Settings", "beta update check", "false") = "true"
	{ ;if the user wants to check for beta updates instead, this block will fire
		global version := getScriptRelease(true, &changeVer)
		betaprep := 1
	}
else
	global version := getScriptRelease(, &changeVer) ;getting non beta latest release

main := tomshiBasic(,, "-Resize", "Latest Update - " version)
main.OnEvent("Close", closeit)
main.Show(Format("w{} h{}", A_ScreenWidth * 0.5, A_ScreenHeight * 0.65))

wvc := WebView2.create(main.Hwnd)
wv := wvc.CoreWebView2
nwr := wv.NewWindowRequested(NewWindowRequestedHandler)
wv.Navigate('https://github.com/Tomshiii/ahk/releases/tag/' version)

NewWindowRequestedHandler(handler, wv2, arg) {
	argp := WebView2.NewWindowRequestedEventArgs(arg)
	deferral := argp.GetDeferral()
	argp.NewWindow := wv2
	deferral.Complete()
}


closeit(*) {
	WinSetAlwaysOnTop(1, "Scripts Release " version)
	ProcessClose(WinGetPID(main.Hwnd))
}