/************************************************************************
 * @description A collection of WM scripts found scattered through the web/ahk docs
 * @author lexikos
 * @date 2023/03/17
 * @version 1.0.1
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
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
    static Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
    {
        StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
        CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
        return CopyOfData
    }
}