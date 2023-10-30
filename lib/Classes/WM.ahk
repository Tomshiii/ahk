/************************************************************************
 * @description A collection of WM scripts found scattered through the web/ahk docs
 * @author lexikos, tomshi
 * @date 2023/10/30
 * @version 1.1.3
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\Editors\Premiere>
#Include <Functions\detect>
; }

class WM {
    /**
     * This is a function designed to allow tooltips to appear while hovering over certain GUI elements. Use the example listed below & `GuiCtrl.ToolTip := "desired tooltip"` to make this function work
     *
     * @link code can be found on the ahk website : https://lexikos.github.io/v2/docs/objects/Gui.htm#ExToolTip
     * ```
     * ;// This function needs to be called differenctly to other functions in this class
     * move := WM()
     * mv := ObjBindMethod(move, "On_WM_MOUSEMOVE")
     * OnMessage(0x0200, mv)
     *
     * ;// or the below as a one liner
     * OnMessage(0x0200, ObjBindMethod(WM(), "On_WM_MOUSEMOVE"))
     * ```
     */
    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
        ListLines(0)
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd)
        {
            Text := "", ToolTip() ; Turn off any previous tooltip.
            CurrControl := GuiCtrlFromHwnd(Hwnd)
            if CurrControl
            {
                if !CurrControl.HasProp("ToolTip")
                    return ; No tooltip for this control.
                Text := CurrControl.ToolTip
                SetTimer () => ToolTip(Text), -1000
                SetTimer () => ToolTip(), -4000 ; Remove the tooltip.
            }
            PrevHwnd := Hwnd
        }
    }

    /**
     * Sends the specified string to the specified window and returns the reply.
     * The reply is 1 if the target window processed the message, or 0 if it ignored it.
     * @param {String} str is the string you wish to send
     * @param {String} scriptTitle the title of the script you wish to target. The passed string must be the entire filename (including the `.ahk` extension)
     * @param {Integer} timeout time in `ms` you want the function to wait before timing out
     * @return the response from the target window
     */
    static Send_WM_COPYDATA(str, scriptTitle, timeout := 4000) {
        CopyDataStruct := Buffer(3*A_PtrSize)  ; Set up the structure's memory area.
        ; First set the structure's cbData member to the size of the string, including its zero terminator:
        SizeInBytes := (StrLen(str) + 1) * 2
        NumPut( "Ptr", SizeInBytes  ; OS requires that this be done.
            , "Ptr", StrPtr(str)  ; Set lpData to point to the string itself.
            , CopyDataStruct, A_PtrSize)
        dct := detect()
        returnDct() => (DetectHiddenWindows(dct.windows), SetTitleMatchMode(dct.title))
        ; Must use SendMessage not PostMessage.
        try {
            RetValue := SendMessage(0x004A, 0, CopyDataStruct,, scriptTitle " ahk_class AutoHotkey",,,, timeout) ; 0x004A is WM_COPYDATA.
        } catch {
            tool.Cust("SendMessage timed out")
            returnDct()
            return false
        }
        returnDct()
        return RetValue  ; Return SendMessage's reply back to our caller.
    }

    /**
     * Recieves a custom string sent by `WM.Send_WM_COPYDATA()`
     * @param {} wParam
     * @param {} lParam
     * @param {} msg
     * @param {} hwnd
     * @return {String}
     * ```
     * OnMessage(0x004A, test)  ; 0x004A is WM_COPYDATA
     * test(wParam, lParam, msg, hwnd) {
     *    res := WM.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
     *    MsgBox("smelly" res)
     * }
     * ```
     */
    static Receive_WM_COPYDATA(wParam, lParam, msg, hwnd) {
        StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
        CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
        return CopyOfData
    }

    /**
     * This function is to help allow for scripts to pass messages to and from the main script
     */
    static __recieveMessage(wParam, lParam, msg, hwnd) {
        res := this.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
        splitMsg := StrSplit(res, ",")
        switch splitMsg[1] {
            case "__premTimelineCoords":
                detect()
                if !prem.__checkTimelineValues()
                    return
                response := Format("__thisTimelineCoords,timelineRawX,{},timelineRawY,{},timelineXValue,{},timelineYValue,{},timelineXControl,{},timelineYControl,{},timelineVals,{}", prem.timelineRawX, prem.timelineRawY, prem.timelineXValue, prem.timelineYValue, prem.timelineXControl, prem.timelineYControl, true)
                this.Send_WM_COPYDATA(response, splitMsg[2])
            case "Premiere_RightClick":
                response := (prem.RClickIsActive = true) ? "Premiere_RightClick,true" : "Premiere_RightClick,false"
                this.Send_WM_COPYDATA(response, splitMsg[2])
            case "Premiere_scMully", "Premiere_scJosh", "Premiere_scJuicy", "Premiere_scEddie", "Premiere_scNarrator":
                getName := SubStr(splitMsg[1], InStr(splitMsg[1], "_",, 1, 1)+1)
                response := "Premiere_" getName "," String(prem.%getName%)
                prem.%getName%++
                this.Send_WM_COPYDATA(response, splitMsg[2])
        }
    }

    /**
     * This function is to help allow for scripts to pass messages back and forth
     */
    static __parseMessageResponse(wParam, lParam, msg, hwnd) {
        res := this.Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
        res := StrSplit(res, ",")
        determineWhich := res[1]
        res.RemoveAt(1)
        switch determineWhich {
            case "__premTimelineCoords", "__thisTimelineCoords":
                for k, v in res {
                    if Mod(k, 2) = 0
                        continue
                    prem.%v% := res[k+1]
                }
            case "Premiere_RightClick":
                bool := (res[1]) = "true" ? true : false
                prem.RClickIsActive := bool
            case "adobe_FS", "autosave_MIN":
                %res[2]%.__changeVar(res[1]*1000)
            case "autosave_beep":
                %res[2]%.beep := res[1]
            case "autosave_save_override":
                %res[2]%.saveOverride := res[1]
            case "autosave_check_mouse":
                %res[2]%.checkMouse := res[1]
            case "Premiere_scMully", "Premiere_scJosh", "Premiere_scJuicy", "Premiere_scEddie", "Premiere_scNarrator":
                getName := SubStr(determineWhich, InStr(determineWhich, "_",, 1, 1)+1)
                prem.%getName% := res[1]
            default:
                MsgBox("A message attempt was made but a declaration for its contents hasn't been defined. This means that Tomshi has made a mistake somewhere. Please open an issue on github explaining how to reproduce this message to alert him of his mistake!`n`nFor debug purposes;`ndetermineWhich: " determineWhich)
        }
    }
}