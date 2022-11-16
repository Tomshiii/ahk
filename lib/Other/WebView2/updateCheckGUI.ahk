#Include <\Other\WebView2\WebView2>
#SingleInstance Force
SetWorkingDir(ptf.lib)
#Include <\KSA\Keyboard Shortcut Adjustments> ;this is added because we need it
#Include <\Functions\Windows> ;this is only added to prevent errors
#Include <\Functions\switchTo> ;this is only added to prevent errors
#Include <\Functions\Startup> ;this is only added to prevent errors
#Include <\Functions\General> ;this is added because we need it

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