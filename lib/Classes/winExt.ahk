/************************************************************************
 * @description A class of extended functions to built in ahk functions. Designed to use as little external functions/classes as possible.
 * @author tomshi
 * @date 2026/01/23
 * @version 1.0.0
 ***********************************************************************/


; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Functions\detect.ahk
; }

class winExt {
    /** A wrapper function for `WinGetTitle()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static TitleRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Title", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetClass()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ClassRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Class", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetActive()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ActiveRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Active", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinActivate()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ActivateRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Activate", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinClose()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static CloseRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Close", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinExist()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ExistRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Exist", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetCount()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static CountRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Count", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetPID()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static PIDRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("PID", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetProcessName()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ProcessNameRegex(WinTitle := "A", WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("ProcessName", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinGetList()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static ListRegex(WinTitle?, WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("List", WinTitle?, WinText, ExcludeTitle, ExcludeText, dctHidWin)
    }
    /** A wrapper function for `WinWaitClose()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static WaitCloseRegex(WinTitle := "A", WinText:="", Timeout := 0, ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("WaitClose", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin, Timeout)
    }
    /** A wrapper function for `WinWait()` with `regex` as the `TitleMatchMode` and (optionally) `DetectHiddenWindows` set */
    static WaitRegex(WinTitle := "A", WinText:="", Timeout := 0, ExcludeTitle:="", ExcludeText:="", dctHidWin := false) {
        return this.regexFunc("Wait", WinTitle, WinText, ExcludeTitle, ExcludeText, dctHidWin, Timeout)
    }

    static regexFunc(func, WinTitle?, WinText:="", ExcludeTitle:="", ExcludeText:="", dctHidWin := false, Timeout := 0) {
        Critical(), orig := detect(dctHidWin, "RegEx")
        try {
            switch func {
                case "Title": returnVal        := WinGetTitle(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "Class": returnVal        := WinGetClass(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "Active": returnVal       := WinActive(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "Activate":
                    WinActivate(WinTitle, WinText, ExcludeTitle, ExcludeText)
                    return true
                case "Exist": returnVal        := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "Count": returnVal        := WinGetCount(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "PID": returnVal          := WinGetPID(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "ProcessName": returnVal  := WinGetProcessName(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "List": returnVal         := WinGetList(WinTitle, WinText, ExcludeTitle, ExcludeText)
                case "WaitClose": returnVal    := WinWaitClose(WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText)
                case "Close":
                    WinClose(WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText)
                    return true
                case "Wait": returnVal         := WinWait(WinTitle, WinText, Timeout, ExcludeTitle, ExcludeText)
             }
        } catch {
            resetOrigDetect(orig), Critical("Off")
            return false
        }
        resetOrigDetect(orig), Critical("Off")
        return returnVal
    }
}