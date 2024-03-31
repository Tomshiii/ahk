/************************************************************************
 * @description a class to hook the mouse actions.
 * @author nperovic
 * @date 2024/03/26
 * @link https://discord.com/channels/115993023636176902/1207794506095923350/1207794506095923350
 ***********************************************************************/

class MouseHook
{
    /** @prop {Map} MsgList A list of actions and message codes. */
    MsgList := Map(
        512, "Move",
        513, "LButton Down",
        514, "LButton Up",
        516, "RButton Down",
        517, "RButton Up",
        519, "MButton Down",
        520, "MButton Up",
        522, "Wheel",
        523, "XButton{:d} Down",
        524, "XButton{:d} Up"
    )

    /** @prop {integer} Hook SetWindowsHookEx */
    Hook := 0

    /** @prop {integer} Count Count how many times an action happens in a short time (`Interval`). */
    Count := 0

    /** @prop {string} ThisKeyTime The time when this key was pressed. */
    ThisKeyTime := 0

    PriorKeyTime := Map()

    /** @prop {string} ThisKey This key. */
    ThisKey := ""

    /** @prop {string} Action The current action. */
    Action := ""

    /** @prop {integer} Interval The time between two actions (milliseconds). */
    Interval := 250

    /** @prop {integer} TimeSinceThisAct The time elapsed since this key was pressed. */
    TimeSinceThisAct => (this.ThisKeyTime ? A_TickCount - this.ThisKeyTime : 0)

    /**
     * @param {string} [action="All"] Move, LButton Up, RButton, etc. Default is All.
     * @param {(eventObj, wParam, lParam) => Integer} callback
     * @param {integer} [criticalOn=false] Critical On/ Off. If on, this parameter will be used in the `Critical` function as well.
     */
    __New(action := "All", callback := unset, criticalOn := 0)
    {
        this.OnEvent := callback ?? (*) => false
        this.cb      := CallbackCreate(LowLevelMouseProc,, 3)
        this.keep    := false

        LowLevelMouseProc(nCode, wParam, lParam)
        {
            if criticalOn
                Critical(criticalOn)

            switch wParam {
            case    522     : this.Action := "Wheel" (NumGet(lParam, 8, "Int") > 0 ? "Up" : "Down")
            case    523, 524: this.Action := Format(this.MsgList[wParam], NumGet(lParam, 8, "Int") >> 16)
            default         : this.Action := this.MsgList.Has(wParam) ? this.MsgList[wParam] : ""
            }

            if (nCode < 0) || (action != "All" && !InStr(action, this.Action))
                return CallNextHookEx(nCode, wParam, lParam)

            if this.Action && this.Action != "Move"
            {
                isUp := false
                switch wParam {
                case 514, 517, 520, 524: isUp := true
                }

                if (this.Action != this.ThisKey)
                    this.ThisKey := this.Action

                if !this.PriorKeyTime.Has(this.Action)
                    this.PriorKeyTime[this.Action] := {t:A_TickCount,c:0}

                pK   := this.PriorKeyTime[this.Action]
                pK.c += ((A_TickCount - pK.t) < this.Interval) ? 1 : -pK.c+1
                pK.t := this.ThisKeyTime := A_TickCount

                this.Count := pK.c

                if isUp || (wParam == 522)
                      this.keep := false
                else {
                    this.keep := true
                    SetTimer((*) => (this.Hook && this.keep ? this.OnEvent(wParam, 0) : SetTimer(, 0)), 50)
                }
            }
            else   {
                this.ThisKey     := ""
                this.Count       := 1
                this.ThisKeyTime := 0
                this.keep        := false
            }

            this.x := NumGet(lParam, 0, "Int")
            this.y := NumGet(lParam, 4, "Int")

            return (nCode >= 0) && this.OnEvent(wParam, lParam) ? true : CallNextHookEx(nCode, wParam, lParam)
        }

        CallNextHookEx(nCode, wParam, lParam) => DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
    }

    Start() => (!this.Hook && (this.Hook := DllCall("SetWindowsHookEx", "Int", 14, "Ptr", this.cb, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr"), "UInt", 0, "Ptr")))

    Stop() => (this.Hook && (DllCall("UnhookWindowsHookEx", "Ptr", this.Hook), this.Hook := 0))

    /**
     * Wait for an action happens. (Not movement)
     * @param {string} Key One key. e.g. RButton Up/ LButton
     * @param {number} Timeout
     * @returns {number|integer}
     */
    Wait(Key, Timeout := 0)
    {
        k   := ((isUp := InStr(Key, " Up")) ? StrReplace(Key, " Up") : Key)
        ; opt := ((Timeout ? ("T" Round(Timeout / 1000, 2)) : ""))
        if !KeyWait(k, "D " (Timeout ? ("T" Round(Timeout / 1000, 2)) : ""))
            return false
        if isUp
            return KeyWait(k)
        return true
    }

    __Delete() => (this.cb && (this.Stop(), CallbackFree(this.cb), this.cb := 0))
}