/************************************************************************
 * @description my version of the `HotkeylessAHK` file
 * @link https://github.com/sebinside/HotkeylessAHK
 * @author sebinside
 * @date 2025/08/12
 * @version 1.1.0
 ***********************************************************************/

#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
A_IconTip := "HotkeylessAHK"
#SingleInstance Force
#Include files\lib.ahk
#Include <Classes\Editors\Premiere>
#Include <Functions\detect>
#NoTrayIcon

; HotkeylessAHK by sebinside
; ALL INFORMATION: https://github.com/sebinside/HotkeylessAHK
; Make sure that you have downloaded everything, especially the "/files" folder.
; Make sure that you have Node.js installed and available in the PATH variable.

serverPort := 42800 ; The port that the server will listen on. Make sure that this port is not blocked by your firewall or used by another application.

functionClassNames := ["CustomFunctions"] ; this can be expanded to allow for other function classes, i.e., PersonalFunctions, WorkFunctions and so on. Note that duplicate function names may hide each other as there is no handling for scopes!
; These classes can (of course) be defined in other AHK files and imported using #Include "<path to AHK file>".

debug := false ; set to true to see the console output of the Node.js server. This will also show the console window, which is hidden by default.

SetupServer(serverPort, debug)
RunClient(serverPort, functionClassNames)

; Your custom functions go into the 'CustomFunctions' class.
; You can then call them by using the URL "localhost:<serverPort>/send/<functionName>"
; The function name "kill" is reserved.

Class CustomFunctions {
    changeLabel(label)       => (prem.changeLabel(label))
    changeDupe(toggleHotkey) => (prem.changeDupeFrameMarkers(toggleHotkey))
    organiseProj()           => (prem.__remoteFunc('organiseProj'))
}