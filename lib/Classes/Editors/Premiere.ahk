/************************************************************************
 * @description A library of useful Premiere functions to speed up common tasks. Most functions within this class use `KSA` values - if these values aren't set correctly you may run into confusing behaviour from Premiere
 * Originally designed for v22.3.1 of Premiere. As of 2023/06/30 slowly began moving workflow to v23.5+
 * Any code after that date is no longer guaranteed to function on previous versions of Premiere. Please see the version number below to know which version of Premiere I am currently using for testing.
 * See the version number listed below for the version of Premiere I am currently using
 * @premVer 24.3
 * @author tomshi
 * @date 2024/05/13
 * @version 2.1.7
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\winget>
#Include <Classes\obj>
#Include <Classes\keys>
#Include <Classes\switchTo>
#Include <Classes\clip>
#Include <Classes\errorLog>
#Include <Classes\block>
#Include <Classes\WM>
#Include <Classes\cmd>
#Include <Classes\Editors\Premiere_UIA>
#Include <Other\UIA\UIA>
#Include <Functions\getHotkeys>
#Include <Functions\delaySI>
#Include <Functions\detect>
; }

class Prem {

    static exeTitle := Editors.Premiere.winTitle
    static winTitle := this.exeTitle
    static class    := Editors.Premiere.class
    static path     := ptf["Premiere"]

    ;// variables used in functions
    static timer      := false
    static isWaiting  := true
    static presses    := 0
    static zoomToggle := 0
    static zToolX     := 0
    static zToolY     := 0

    ;// colour of playhead
    static playhead := 0x2D8CEB

    ;// variable for prem.thumbScroll()
    static scrollSpeed := 5

    ;// variables for `getTimeline()`
    static timelineVals     := false
    static timelineRawX     := 0
    static timelineRawY     := 0
    static timelineXValue   := 0
    static timelineYValue   := 0
    static timelineXControl := 0
    static timelineYControl := 0
    static focusColour      := 0x2D8CEB

    ;// rbuttonPrem
    static focusTimelineStatus := true
    static RClickIsActive      := false

    ;// variables for `delayPlayback()` && `rippleTrim()`
    static defaultDelay := 325
    static delayTime    := 0

    ;// screenshots
    static scEddie        := "1"
    static scNarrator     := "1"
    static scJuicy        := "1"
    static scMully        := "1"
    static scJosh         := "1"
    static scDesktop      := "1"
    static scEnvironment  := "1"
    static scGuest1  := "1"
    static scGuest2  := "1"

    ;// PremiereRemote variables
    static remoteDir := A_AppData "\Adobe\CEP\extensions\PremiereRemote"
    static indexFile := this.remoteDir "\host\src\index.tsx"

    class ClientInfo {
        ;//! these values are numbered so that the automatic toggles in `zoom()` enumerate in the proper order (as it goes alphabetically)

        alex := {
            1: [2064, -26, 215, 960, 540],
            2: [3467, 339, 390, 960, 540]
        }
        d0yle := {
            1: [1925, 1085, 210, 1916.8, 1082],
            2: [1917.5, 1077.5, 288, 1915, 1074.6]
        }
        chloe := {
            1: [-426, -238, 267, 960, 540],
            2: [-1776, -932, 495, 960, 540],
            3: [632, 278, 292, 960, 540]
        }
        emerldd := {
            1: [1913, 67, 200, 960, 540],
            2: [2873, -436, 300, 960, 540]
        }
    }

    /**
     * This variable contains a map of all relevant colour values for audioDrag() to work correctly
     */
    static dragColour := Map(
        ;// colours for a green audio track
        0x156B4C, 1, 0x1B8D64, 1, 0x1c7d5a, 1, 0x1D7E5B, 1, 0x1D986C, 1, 0x1E7F5C, 1, 0x1F805D, 1, 0x1FA072, 1, 0x1FA373, 1, 0x20815E, 1, 0x21825F, 1, 0x23AB83, 1, 0x248562, 1, 0x258663, 1, 0x268764, 1,  0x298A67, 1, 0x29D698, 1, 0x2A8B68, 1, 0x2A8D87, 1, 0x2B8C69, 1, 0x3A9B78, 1, 0x3DFFE4, 1, 0x44A582, 1, 0x457855, 1, 0x47A582, 1, 0x4AAB88, 1, 0x5C67F9, 1, 0x5D68FB, 1, 0x5D68FC, 1, 0xD0E1DB, 1, 0xD4F7EA, 1, 0xFDFDFD, 1, 0xFEFEFE, 1, 0xFFFFFF, 1, 0x3AAA59, 1,
        ;// colours for the red box
        0xE40000, 1, 0xEEE1E1, 1,
        ;// colours for the fx symbol box
        0x292929, 1, 0x2D2D2D, 1, 0x3B3B3B, 1, 0x404040, 1, 0x454545, 1, 0x4A4A4A, 1, 0x585858, 1, 0x606060, 1, 0x646464, 1, 0xA7ADAB, 1, 0xB1B1B1, 1, 0xCCCCCC, 1, 0xD2D2D2, 1, 0xEFEFEF, 1
    )

    __fxPanel() => (SendInput(KSA.effectControls), SendInput(KSA.effectControls))

    /**
     * This function cuts repeat code. It activates the findbox and waits for the carot to appear.
     */
    __findBox() {
        SendInput(KSA.findBox)
        tool.Cust("if you hear windows, blame premiere")
        coord.c("screen")
        CaretGetPos(&findx)
        if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
            {
                loop {
                        if A_Index > 5
                            {
                                SendInput(KSA.findBox) ;adjust this in the ini file
                                tool.Cust("if you hear windows, blame adobe", 2000)
                            }
                        sleep 30
                        CaretGetPos(&findx)
                        if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                            {
                                block.Off()
                                errorLog(IndexError("Couldn't find the findbox", -1),, 1)
                                return false
                            }
                    } until findx != "" ; as soon as premiere has found the find box, this will populate and break the loop
            }
        return findx
    }

    /**
     * A function to create a UIA element for Premiere Pro
     * @param {Boolean} [getActive=true] determines whether this function will check the currently active panel. Note; leaving this as true can add anywhere from `60-1000ms` of delay depending on how busy Premiere currently is and is best left as `false` if performance is the goal or the active element isn't needed
     * @returns {Object}
     * ```
     * createEl := this.__createUIAelement()
     * createEl.AdobeEl       ;// the UIA element created from the Premiere Pro window
     * createEl.activeElement ;// the UIA string of the currently active element
     * ```
     */
    static __createUIAelement(getActive := true) {
        premName := WinGet.PremName()
        AdobeEl  := UIA.ElementFromHandle(premName.winTitle A_Space this.winTitle,, false)
        currentEl := (getActive = true) ? AdobeEl.GetUIAPath(UIA.GetFocusedElement()) : ""
        return {AdobeEl: AdobeEl, activeElement: currentEl}
    }

    /**
     * A function to cut repeat code when attempting to retrieve coordinates of a Control. This function will use the UIA class to determine all coordinates of the passed in UIA element.
     * @param {String} UIA_Element the UIA string to isolate the premiere panel you wish to operate on. Can be passed in manually as a string such as `"YwY"` or as a pre-set variable via the `premUIA` class
     * @param {Boolean} [tooltip=true] whether or not this function should provide a tooltip to alert the user on failure. Defaults to `true`
     * @param {Object} passIn pass in your own UIA element so this function doesn't need to create another one
     * @param {Boolean} [getActive=true] determine whether you wish for `__createUIAelement()` to also retrieve the active panel. Note: doing so can add anywhere from `100ms` to `1s` of latency depending on Premiere
     * @returns {Object/false} returns an object containing all values recieved via `ControlGetPos` as well as the UIA object that can continue to be operated on. If the function cannot determine the controls position, it will return boolean `false`
     * ```
     * effCtrl := this.__uiaCtrlPos(premUIA.effectsControl)
     * effCtrl.x
     * effCtrl.y
     * effCtrl.width
     * effCtrl.height
     * effCtrl.classNN
     * effCtrl.uiaVar ;// returns -> uiaVar := ControlGetClassNN(AdobeEl.ElementFromPath(premUIA.effectsControl).GetControlId())
     * ```
     */
    static __uiaCtrlPos(UIA_Element, tooltip := true, passIn?, getActive := true) {
        try {
            if !IsSet(passIn)
                UIAel := this.__createUIAelement(getActive)
            else
                UIAel := passIn
            ClassNN  := ControlGetClassNN(UIAel.AdobeEl.ElementFromPath(UIA_Element).GetControlId())
            ControlGetPos(&toolx, &tooly, &width, &height, ClassNN)
        } catch {
            errorLog(UnsetError("Couldn't get the ClassNN of the desired panel", -1),, tooltip)
            return false
        }
        return {x: toolx, y: tooly, width: width, height: height, classNN: ClassNN, uiaVar: UIAel.AdobeEl}
    }

    /**
     * This function checks for the existence of [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main). Can also check for the existence of a specific function within the `index.tsx` file
     * @param {String} [checkFunc=""] the name of the function you wish to check for
     * @returns {Boolean}
     */
    static __checkPremRemoteDir(checkFunc := "") {
        return (DirExist(this.remoteDir) && FileExist(this.indexFile) && this.__checkPremRemoteFunc(checkFunc) ? true : false)
    }

    /**
     * This function checks the [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main) `index` file for the desired function
     * @param {String} checkFunc the function name you wish to search for. ie `projPath`
     * @returns {Boolean}
     */
    static __checkPremRemoteFunc(checkFunc) {
        return ((InStr(readFile := FileRead(this.indexFile), Format("{}: function (", checkFunc)) ||
                    InStr(readFile, Format("{}: function(", checkFunc)))
                    ? true : false)
    }

    /**
     * This function is syntatic sugar to activate a [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main) function
     * @param {String} whichFunc the function you wish to call
     * @param {Boolean} [needResult=false] determines whether the user needs this function to return a result back from the cmd window.
     * @param {Varadic/String} params any additional paramaters you need to pass to your function. do **not** add the `&` that goes between paramaters, this function will add that itself
     * @returns {String} if the user sets `needResult` to `true` this function will return a string containing the response.
     */
    static __remoteFunc(whichFunc, needResult := false, params*) {
        paramsString := ""
        if params.Length >= 1 {
            for k, v in params {
                if params.Length == 1 {
                    paramsString := params[A_Index]
                    break ;// happens anyway but for readability
                }
                if k = 1 {
                    paramsString := params[A_Index]
                    continue
                }
                paramsString := paramsString "&" params[A_Index]
            }
        }
        sendcommand := Format('curl "http://localhost:8081/{1}?{2}"', whichFunc, String(paramsString))
        if !needResult
            Run(sendcommand,, "Hide")
        else {
            if InStr(getResp := cmd.result(sendcommand), "Failed to connect to localhost") {
                tool.cust("Unable to connect to localhost server. PremiereRemote Extension may not be running.")
                return false
            }
            parse := JSON.parse(getResp)
            return parse["result"]
        }
    }

    /**
     * Calls a `PremiereRemote` function to directly save the current project. This function will also double check to ensure the active sequence does not change after the save attempt
     * @param {Boolean} [andWait=true] determines whether you wish for the function to wait for the `Save Project` window to open/close
     *
     * @returns {Boolean/String}
     * - `true`: successful
     * - `false`: `PremiereRemote`/`saveProj` func/`projPath` func not found
     * - `"timeout"`: waiting for the save project window to open/close timed out
     * - `"noseq"` : `focusSequence`/`getActiveSequence` func not found
     */
    static save(andWait := true, checkSeqTime := 1000, checkAmount := 1) {
        if !this.__checkPremRemoteDir("saveProj") || !this.__checkPremRemoteFunc("projPath")
            return false
        origSeq := this.__remoteFunc("getActiveSequence")
        this.__remoteFunc("saveProj")

        if !andWait
            return true

        ;// waiting for save dialogue to open & close
        if !WinWait("Save Project",, 3)
            return "timeout"
        if !WinWaitClose("Save Project",, 3)
            return "timeout"

        if !this.__checkPremRemoteFunc("focusSequence") || !this.__checkPremRemoteFunc("getActiveSequence")
            return "noseq"

        sleep checkSeqTime
        loop checkAmount {
            currentSeq := this.__remoteFunc("getActiveSequence")
            if currentSeq != origSeq {
                this.__remoteFunc("focusSequence")
                break
            }
            sleep checkSeqTime
        }

        return true
    }

    /**
     * This function is to reduce repeat code and is designed to save the current project, then wait for premiere to catch up refocusing the timeline.
     * This function will never *always* work perfectly due to Premiere being Premiere and ranging quite wildly how it performs at any given time.
     * If you notice any issues you may need to slow this function down even further.
     *
     * This function is mostly designed to be used in scripts like `render and replace.ahk` and the `render previews` scripts where **speed** isn't *super* important.
     * @returns {Boolean|String} returns boolean or `"active"` if timeline was the active window
     */
    static saveAndFocusTimeline() {
        premUIA := this.__createUIAelement()
        uiaVals := premUIA_Values()
        if this.save() = (false || "timeout") {
            SendEvent("^s")
            if !WinWait("Save Project",, 3) {
                tool.Cust("Function timed out waiting for save prompt")
                return false
            }
            if !WinWaitClose("Save Project",, 5) {
                tool.Cust("Function timed out waiting for save prompt to close")
                return false
            }
        }
        if premUIA.activeElement == uiaVals.timeline {
            tool.Cust("Premiere should automatically refocus the timeline")
            sleep 1000
            return "active"
        }
        tool.Cust("Checking if timeline is in focus", 500, -180,, 16)
        sleep 500
        if this.__checkTimelineValues() {
            if !this.__waitForTimeline()
                return false
        }
        tool.Cust("Letting Premiere catch up...", 500, -180,, 16)
        sleep 500
        return true
    }

    /**
     * This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
     * @param {String} item in this function defines what it will type into the search box (the name of your preset within premiere)
     */
    static preset(item)
    {
        if Type(item) != "string" {
            ;// throw
            errorLog(TypeError("Incorrect value type in Parameter #1", -1, item),,, 1)
        }
        keys.allWait()
        ToolTip("Your Preset is being dragged")
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        if item = "loremipsum" ;YOUR PRESET MUST BE CALLED "loremipsum" FOR THIS TO WORK - IF YOU WANT TO RENAME YOUR PRESET, CHANGE THIS VALUE TOO - this if statement is code specific to text presets
            this().__loremipsum({x: effCtrlNN.x, y: effCtrlNN.y}, {width: effCtrlNN.width, height: effCtrlNN.height}, &eyeX, &eyeY)
        /** this is simply to cut needing to repeat this code below */
        effectbox() {
            effCtrlNN.uiaVar.ElementFromPath(premUIA.effectsPanel).SetFocus()
            if !this().__findBox()
                return
            SendInput("^a" "+{BackSpace}")
            SetTimer(delete, -250)
            /** this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job */
            delete() {
                if WinExist("Delete Item") {
                    SendInput("{Esc}")
                    sleep 100
                    effCtrlNN.uiaVar.ElementFromPath(premUIA.effectsPanel).SetFocus()
                    if !this().__findBox()
                        return
                    SendInput("^a" "+{BackSpace}")
                    sleep 60
                    if WinExist("Delete Item") {
                        SendInput("{Esc}")
                        sleep 50
                    }
                }
            }
        }
        effectbox()
        coord.c("screen") ;change caret coord mode to window
        CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
        MouseMove(carx-5, cary+5) ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
        SendInput(item) ;create a preset of any effect, must be in a folder as well
        sleep 50
        MouseMove(0, 65,, "R") ;move down to the saved preset (must be in an additional folder)
        SendInput("{Click Down}")
        if item = "loremipsum" ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
            {
                MouseMove(eyeX, eyeY - "5")
                SendInput("{Click Up}")
                effectbox()
                this.__checkTimelineFocus()
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        MouseMove(xpos, ypos) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
        SendInput("{Click Up}")
        effectbox() ;this will delete whatever preset it had typed into the find box
        this.__checkTimelineFocus()
        block.Off()
        ToolTip("")
    }

    /**
     * this function is called within `preset()` and is pulled out simply to make that function more readable
     * @param {Object} classObj an object `{x: , y: }` to pass in the classNN variables
     * @param {Object} widHeiObj an object `{width: , height: }` to pass in the classNN variables
     * @param {VarRef} returnXY passing variables back to the function
     */
    __loremipsum(classObj, widHeiObj, &returnX, &returnY) {
        sleep 100
        delaySI(150, KSA.timelineWindow, KSA.timelineWindow, KSA.newText)
        sleep 150
        ;// premiere can slow down depending on the size of your project so it's best
        ;// to build in multiple checks for most things
        loop {
            if A_Index > 30 { ;// 3s
                block.Off()
                errorLog(Error("Couldn't find the graphics tab", -1),, 1)
                return
            }
            if ImageSearch(&x2, &y2, classObj.x, classObj.y, classObj.x + (widHeiObj.width/KSA.ECDivide), classObj.y + widHeiObj.height, "*2 " ptf.Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
                break
            sleep 100
        }
        loop {
            if A_Index > 30 { ;// 3s
                block.Off()
                errorLog(Error("Couldn't find the eye icon", -1),, 1)
                return
            }
            if A_Index > 1 && y2 < 900 ;// the y value it searches will increase as the loop index increases
                y2 += 100
            if ImageSearch(&xeye, &yeye, x2, y2, x2 + 200, y2 + 100, "*2 " ptf.Premiere "eye.png") ;searches for the eye icon for the original text
                break
            sleep 100
        }
        MouseMove(xeye, yeye)
        SendInput("{Click}")
        MouseGetPos(&returnX, &returnY)
        sleep 50
    }

    /**
     * This function is to move to the effects window and highlight the search box to allow manual typing
     */
    static fxSearch()
    {
        coord.s()
        block.On()
        this().__fxPanel()
        if !this().__findBox()
            return
        this().__fxPanel()
        SendInput("^a" "+{BackSpace}")
        SetTimer(delete, -250)
        /** This function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job */
        delete() {
            if WinExist("Delete Item") {
                SendInput("{Esc}")
                sleep 100
                this().__fxPanel()
                if !this().__findBox()
                    return
                this().__fxPanel()
                SendInput("^a" "+{BackSpace}")
                sleep 60
                if WinExist("Delete Item") {
                    SendInput("{Esc}")
                    sleep 50
                }
            }
        }
        block.Off()
    }

    /**
     * This function on first run will ask you to select a clip with the exact zoom you wish to use for the current session. Any subsequent activations of the script will simply zoom the current clip to that zoom amount. You can reset this zoom by refreshing the script.
     *
     * If a specified client name is in the title of the window (usually in the url project path) this function will set predefined zooms. These clients can be defined within the neseted class `Prem.ClientInfo`
     *
     * > This function contains code that will check for `PremiereRemote` and use it if detected. This code will make the function faster to excecute.
     */
    static zoom()
    {
        keys.allWait()
        CoordMode("ToolTip", "Screen")

        UserSettings := UserPref()
        mainScript := UserSettings.MainScriptName
        UserSettings := ""

        ;// ensure timeline coords are set
        detect()
        __fallback() {
            if !this.__checkTimeline(false)
                return
            tool.Cust("This function had to retrieve the coordinates of the timeline and was stopped from`ncontinuing incase you had multiple sequences open and need to go back.`nThis will not happen again.", 4.0,, -20, 14)
        }
        if !this.__checkTimelineValues() {
            if !(A_ScriptName != mainScript ".ahk" && WinExist(mainScript ".ahk")) {
                __fallback()
                return
            }
            WM.Send_WM_COPYDATA("__premTimelineCoords," A_ScriptName, mainScript ".ahk")
            if !this.__waitForTimeline() {
                __fallback()
                return
            }
        }

        premUIA := premUIA_Values()
        ;// get coordinates for a tooltip that appears to alert the user that toggles have reset
        if this.zToolX = 0 || this.zToolY = 0
            {
                this.__checkTimelineFocus()
                sleep 50
                if !progMonNN := this.__uiaCtrlPos(premUIA.programMon,,, false) {
                    block.Off()
                    return
                }
                this.zToolX := (progMonNN.x+70) ;// adjust this value if your tooltips appear in the wrong position. I had it at +15 before swapping to an ultrawide monitor
                this.zToolY := (progMonNN.y+progMonNN.height+13)
                ToolTip("",,, 4)
                tool.Cust("Some tooltips for this function will appear here",, this.zToolX, this.zToolY, 4)
            }

        ;// start bulk of function
        this.presses++

        ;// giving the user 250ms to increment the zoom
        waitms := 250
        startTime := A_TickCount
        SetTimer(waitTimer.Bind(startTime), 16)
        waitTimer(time) {
            CoordMode("ToolTip", "Screen")
            if A_ThisHotkey != "" {
                if GetKeyState(A_ThisHotkey, "P")
                    {
                        ToolTip("")
                        SetTimer(, 0)
                        return
                    }
            }
            ToolTip("Presses: " this.presses "`nWill reset in: " waitms - (A_TickCount - time) "ms", this.zToolX, this.zToolY-10, 4)
            if (A_TickCount - time) < waitms
                return
            this.isWaiting := false
            ToolTip("",,, 4)
            SetTimer(, 0)
        }

        resetTime := 5 * 1000 ;convert ms to s
        /**
         * This function is for a timer we activate anytime a client's zoom has a toggle
         * @param {Integer} time the current tick count that gets passed in as `A_TickCount`
         */
        reset(time) {
            ListLines(0)
            ;// if the user activates this function before the timer finishes, due to some code below
            ;// this variable will be set to false. The timer will then see this change and cancel
            ;// itself so it can be later reset
            if !this.timer
                {
                    SetTimer(, 0)
                    return
                }
            if ((A_TickCount - time) >= resetTime) || GetKeyState("Esc", "P")
                {
                    tool.Cust("zoom toggle reset",, this.zToolX, this.zToolY, 2)
                    this.timer := false, this.presses := 0, this.zoomToggle := 0
                    Tog := 1
                    SetTimer(, 0)
                    return
                }
        }

        ;// assign the nested class to an object
        clientList := this.ClientInfo()
        ;// then we'll define the values that will allow us to change things depending on the project
        static x := 0, y := 0, scale := 0, anchorX := "false", anchorY := "false"

        coord.s()
        if !WinActive(this.winTitle) {
            block.Off()
            errorLog(Error("Premiere is not the active window", -1),, 1)
            return
        }
        sleep 50
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        try effCtrlNN.uiaVar.ElementFromPath(premUIA.effectsControl).SetFocus()

        ;//get client name
        ClientName := WinGet.ProjClient()
        if !ClientName {
            block.Off()
            tool.Wait()
            tool.Cust("Couldn't get the client name")
            return
        }
        ;// check to see if the clientlist contains the current client name
        if clientList.HasOwnProp(ClientName) {
            block.On()
            MouseGetPos(&xpos, &ypos)
            loop {
                if A_ThisHotkey != "" {
                    if GetKeyState(A_ThisHotkey, "P") {
                        block.Off()
                        return
                    }
                }
                if this.isWaiting = false
                    break
            }
            this.isWaiting := true
            count := ObjOwnPropCount(clientList.%ClientName%)

            ;// logic for the toggle using a class variable
            loop this.presses {
                this.zoomToggle++
                if this.zoomToggle > count
                    this.zoomToggle := 1
            }

            this.presses := 0
            if clientList.%ClientName%.HasOwnProp("1") && count = 1
                {
                    x     := clientList.%ClientName%.punchIn[1]
                    y     := clientList.%ClientName%.punchIn[2]
                    scale := clientList.%ClientName%.punchIn[3]
                    anchorX := clientList.%ClientName%.punchIn[4]
                    anchorY := clientList.%ClientName%.punchIn[5]
                }
            else if count > 1
                {
                    if !this.timer
                        {
                            this.timer := true
                            SetTimer(reset.bind(A_TickCount), 15) ;reset toggle values after x seconds
                        }
                    else
                        {
                            ;// if the timer is already active, we first have to stop it before restarting it
                            ;// since the timer checks the state of `this.timer` which is a variable at the top of this class, we simply set that variable to false
                            ;// sleep for a fraction of a second so the timer has time to notice the change
                            ;// then reset the value and reset the timer
                            ;// otherwise you end up with multiple tooltip stating that toggles have been reset
                            this.timer := false
                            sleep 50
                            this.timer := true
                            SetTimer(reset.bind(A_TickCount), 15) ;reset toggle values after x seconds
                        }
                    tool.Cust("zoom " this.zoomToggle "/" count, 2.0, this.zToolX, this.zToolY)
                    ;// this for loop stops the need to hard code each potential toggle
                    ;// as long as the object contains '1' & more than 1 property, this will function correctly
                    for Name in clientList.%ClientName%.OwnProps() {
                        if A_Index != this.zoomToggle
                            continue
                        x := clientList.%ClientName%.%Name%[1]
                        y := clientList.%ClientName%.%Name%[2]
                        scale := clientList.%ClientName%.%Name%[3]
                        anchorX := clientList.%ClientName%.%Name%[4]
                        anchorY := clientList.%ClientName%.%Name%[5]
                    }
                }
        }
        if scale = 0 {
            setValue := MsgBox("You haven't set the zoom amount/position for this session yet.`nIs the current track your desired zoom?", "Set Zoom", "4 32 4096")
            if setValue = "No" {
                block.Off()
                return
            }
        }
        block.On()
        MouseGetPos(&xpos, &ypos)
        this.__checkTimelineFocus()
        sleep 50

        ;// if the user is using premiereremote we can excecute now and terminate early
        if x != 0 && this.__checkPremRemoteDir("setZoomOfCurrentClip") {
            this.__remoteFunc("setZoomOfCurrentClip", true, "zoomLevel=" String(scale), "xPos=" String(x), "yPos=" String(y), "anchorX=" String(anchorX), "anchorY=" String(anchorY))
            block.Off()
            return
        }

        ;// searches to check if no clips are selected
        if ImageSearch(&clipX, &clipY, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") {
            SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            ;// checks for no clips again incase it has attempted to select 2 separate audio/video tracks
            if ImageSearch(&clipX, &clipY, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") {
                errorLog(Error("No clips were selected", -1),, 1)
                block.Off()
                return
            }
        }
        if !obj.imgSrchMulti({x1: effCtrlNN.x, y1: effCtrlNN.y, x2: effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), y2: effCtrlNN.y + effCtrlNN.height},, &motionX, &motionY
            , ptf.Premiere "motion2.png"
            , ptf.Premiere "motion3.png")
        {
            MouseMove(xpos, ypos)
            block.Off()
            errorLog(Error("Couldn't find the video section", -1),, 1)
            return
        }
        MouseMove(motionX + 10, motionY + 10)
        SendInput("{Click}")
        MouseMove(xpos, ypos)
        SendInput("{Tab 2}")
        ;// the user hasn't set a zoom for the current client
        if x = 0 {
            cleanCopy()
            {
                A_Clipboard := ""
                SendInput("^c")
                ClipWait()
            }
            previousClipboard := A_Clipboard
            cleanCopy()
            x := A_Clipboard
            SendInput("{Tab}")
            cleanCopy()
            y := A_Clipboard
            SendInput("{Tab}")
            cleanCopy()
            scale := A_Clipboard
            SendInput("{Tab 3}")
            cleanCopy()
            anchorX := A_Clipboard
            SendInput("{Tab}")
            cleanCopy()
            anchorY := A_Clipboard
            SendInput("{Enter}")
            block.Off()
            tool.Cust("Setting up your zoom has completed")
            return
        }
        ;// the user HAS set up zooms for the current client
        delaySI(1, x, "{Tab}", y, "{Tab}", scale)
        if anchorX != "false" && anchorY != "false" {
            delaySI(1, "{Tab 3}", anchorX, "{Tab}", anchorY)
            anchorX := "false", anchorY := "false"
        }
        SendInput("{Enter}")
        sleep 50
        block.Off()
    }

    /**
     * This function defines what `valuehold()` should do if the user wishes to adjust the `level` property.
     * @param {Object} classCoords an object containing the classNN information
     */
    __vholdLevels(classCoords) {
        ;// don't add WheelDown's, they suck in hotkeys, idk why, they lag everything out and stop Click's from working properly
        if ImageSearch(&vidx, &vidy, classCoords.classX, classCoords.classY, classCoords.classX + (classCoords.width/KSA.ECDivide), classCoords.classY + classCoords.height, "*2 " ptf.Premiere "video.png") {
            block.Off()
            errorLog(Error("The user wasn't scrolled down", -1),, 1)
            keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            return false
        }
    }

    /**
     * This function defines what `valuehold()` should do if the `blendMode` param is passed
     * @param {String} filepath the passed in `filepath` param
     * @param {String} blendmode the passed in `blendmode` param
     * @param {Object} xy an object containing the x/y coordinates to search
     * @param {Object} origCoords an object containing the original mouse x/y coordinates
     */
    __vholdBlend(filepath, blendmode, xy, origCoords) {
        if !ImageSearch(&arrX, &arrY, xy.x, xy.y, xy.x+400, xy.y+40, "*2 " ptf.Premiere filepath "arrow.png") {
            errorLog(Error("Couldn't find the arrow to open the blend mode menu", -1),, 1)
            MouseMove(origCoords.xpos, origCoords.ypos)
            block.Off()
            return
        }
        MouseMove(arrx, arrY)
        SendInput("{Click}")
        sleep 500
        if (
            ;// if the "drop down" menu goes up
            !obj.imgSrchMulti({x1: arrx-400, y1: arrY-700, x2: arrx, y2: arrY},, &modeX, &modeY
                , ptf.Premiere "blend\" blendmode ".png"
                , ptf.Premiere "blend\" blendmode "2.png") &&
            ;// if the "drop down" menu goes down
            !obj.imgSrchMulti({x1: arrx-400, y1:arrY, x2: arrx, y2: arrY+700},, &modeX, &modeY
                , ptf.Premiere "blend\" blendmode ".png"
                , ptf.Premiere "blend\" blendmode "2.png")
        )
            {
                errorLog(Error("Couldn't find the desired blend mode", -1),, 1)
                MouseMove(origCoords.xpos, origCoords.ypos)
                block.Off()
                return
            }
        MouseMove(modeX, modeY)
        SendInput("{Click}")
        MouseMove(origCoords.xpos, origCoords.ypos)
        block.Off()
    }


    /**
     * A function to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed). If you wish to adjust the blendmode, this string needs to be `blend\blendmode`.
     * @param {Integer} optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
     * @param {String} blendMode the filename of the blend mode you wish to change the current track to.
     */
    static valuehold(filepath, optional := 0, blendMode := "")
    {
        ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
        ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
        ;You can plug your own x distance in by changing the value below
        xdist := 210
        coord.client()
        MouseGetPos(&xpos, &ypos)
        block.On()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            { ;any imagesearches on the effect controls window includes a division variable (KSA.ECDivide) as I have my effect controls quite wide and there's no point in searching the entire width as it slows down the script
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips are selected", -1),, 1)
                        return
                    }
            }
        if filepath = "levels" {
            if !this().__vholdLevels({classX: effCtrlNN.x, classY: effCtrlNN.y, width: effCtrlNN.width, height: effCtrlNN.height})
                return
        }
        loop {
            if A_Index > 1 {
                ToolTip(A_Index)
                this().__fxPanel()
            }
            checkImg(checkfilepath) {
                blendheight := (filepath = "blend\blendmode") ? 50 : 0
                if FileExist(checkfilepath) && ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height + blendheight, "*2 " checkfilepath)
                    return true
                return false
            }
            if ( ;finds the value you want to adjust, then finds the value adjustment to the right of it
                checkImg(ptf.Premiere filepath ".png") ||
                checkImg(ptf.Premiere filepath "2.png") ||
                checkImg(ptf.Premiere filepath "3.png") ||
                checkImg(ptf.Premiere filepath "4.png")
            )
                break
            if A_Index > 3 {
                block.Off()
                errorLog(IndexError("Failed to find the requested property", -1, filepath),, 1)
                keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
            sleep 50
        }
        if filepath = "blend\blendmode" {
            this().__vholdBlend(filepath, blendMode, {x: x, y:y}, {xpos: xpos, ypos: ypos})
            return
        }
        if !PixelSearch(&xcol, &ycol, x, y+5, x + xdist, y + 40, 0x205cce, 2) {
            block.Off()
            errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
            keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            MouseMove(xpos, ypos)
            return
        }
        MouseMove(xcol + optional, ycol)
        sleep 50 ;required, otherwise it can't know if you're trying to tap to reset
        ToolTip("")
        if !GetKeyState(A_ThisHotkey, "P") {
            ;// searches for the reset button to the right of the value you want to adjust. if it can't find it, the below block will happen
            if !ImageSearch(&x2, &y2, x, y - 10, x + 1500, y + 20, "*2 " ptf.Premiere "reset.png") {
                ;// this block is for adjusting the "level" property, change in the KSA.ini file
                if filepath = "levels" {
                    SendInput("{Click}" "0" "{Enter}")
                    MouseMove(xpos, ypos)
                    block.Off()
                    return
                }
                MouseMove(xpos, ypos)
                block.Off()
                errorLog(Error("Couldn't find the reset button", -1),, 1)
                return
            }
            MouseMove(x2, y2)
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            block.Off()
            return
        }
        ;// waiting for the user to release the key
        SendInput("{Click Down}")
        block.Off()
        keys.allWait()
        SendInput("{Click Up}" "{Enter}")
        sleep 200 ;was experiencing times where ahk would just fail to excecute the below mousemove. no idea why. This sleep seems to stop that from happening and is practically unnoticable
        MouseMove(xpos, ypos)
    }

    /**
     * This function is to turn off keyframing for a given property within premiere pro
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     */
    static keyreset(filepath) ;I think this function is broken atm, I need to do something about it... soon
    {
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        this().__fxPanel()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") { ;searches to check if no clips are selected
            SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
            sleep 50
            if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                {
                    errorLog(Error("No clips were selected", -1),, 1)
                    block.Off()
                    return
                }
        }
        if !ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere filepath "2.png") && !ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere filepath "4.png")
            {
                errorLog(Error("The user was already keyframing", -1),, 1)
                block.Off()
                return
            }
        MouseMove(x + 7, y + 4)
        click
        block.Off()
        MouseMove(xpos, ypos)
    }

    /**
     * This function is to either turn on keyframing, or create a new keyframe at the cursor for a given property within premiere pro
     * @param {String} filepath is the png name of the image ImageSearch is going to use to find what value you want to adjust (either with/without the keyframe button pressed)
     */
    static keyframe(filepath)
    {
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        this().__fxPanel()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        if !obj.imgSrchMulti({x1: effCtrlNN.x, y1: effCtrlNN.y, x2: effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), y2: effCtrlNN.y + effCtrlNN.height},, &x, &y
                , ptf.Premiere filepath ".png"
                , ptf.Premiere filepath "2.png"
                , ptf.Premiere filepath "3.png"
                , ptf.Premiere filepath "4.png")
            {
                block.Off()
                errorLog(Error("Couldn't find the desired value", -1),, 1)
                return
            }
        if ImageSearch(&keyx, &keyy, x, y, x + 500, y + 20, "*2 " ptf.Premiere "keyframeButton.png") || ImageSearch(&keyx, &keyy, x, y, x + 500, y + 20, "*2 " ptf.Premiere "keyframeButton2.png")
            MouseMove(keyx + 3, keyy)
        else
            MouseMove(x + 5, y + 5)
        SendInput("{Click}")
        this.__checkTimelineFocus() ;focuses the timeline
        MouseMove(xpos, ypos)
        block.Off()
    }

    /**
     * This function pulls an audio file out of a separate bin from the project window and back to the cursor (premiere pro)
     *
     * If `sfxName` is "bleep" there is extra code that automatically moves it to your track of choice.
     *
     * This function uses hard coded position values for where it expects the sfx bin to be. You may need to change these values.
     * @param {String} sfxName is the name of whatever sound you want the function to pull onto the timeline
     */
    static audioDrag(sfxName)
    {
        ;I wanted to use a method similar to other premiere functions above, that grabs the classNN value of the panel to do all imagesearches that way instead of needing to define coords, but because I'm using a separate bin which is essentially just a second project window, things get messy, premiere gets slow, and the performance of this function dropped drastically so for this one we're going to stick with coords defined in KSA.ini/ahk & additional hard coded values

        /**
         * A function to cut repeat code. Checks the state of the cursor
         */
        cursorCheck() {
            if A_Cursor != "Arrow"
                loop 12 {
                    MouseMove(5, 0, 2, "R")
                    if A_Cursor = "Arrow"
                        {
                            MouseMove(5, 0, 2, "R")
                            sleep 25
                            break
                        }
                    sleep 50
                }
        }
        coord.s()
        SendInput(KSA.selectionPrem)
        if !ImageSearch(&sfxxx, &sfxyy, 3021, 664, 3589, 1261, "*2 " ptf.Premiere "binsfx.png") ;checks to make sure you have the sfx bin open as a separate project window
            {
                errorLog(Error("User hasn't opened the required bin", -1),, 1)
                return
            }
        block.On()
        coord.s()
        MouseGetPos(&xpos, &ypos)
        if ImageSearch(&listx, &listy, 3082, 664, 3591, 1265, "*2 " ptf.Premiere "list view.png") ;checks to make sure you're in the list view
            {
                MouseMove(listx, listy)
                SendInput("{Click}")
                sleep 100
            }
        loop {
            SendInput(KSA.projectsWindow) ;highlights the project window ~ check the keyboard shortcut ini file to adjust hotkeys
            SendInput(KSA.projectsWindow) ;highlights the sfx bin that I have ~ check the keyboard shortcut ini file to adjust hotkeys
            ;keys.allWait() ;I have this set to remapped mouse buttons which instantly "fire" when pressed so can cause errors
            if !this().__findBox()
                return
            SendInput("^a" "+{BackSpace}")
            SendInput(sfxName)
            sleep 250 ;the project search is pretty slow so you might need to adjust this
            coord.w()
            if !ImageSearch(&vlx, &vly, KSA.sfxX1, KSA.sfxY1, KSA.sfxX2, KSA.sfxY2, "*2 " ptf.Premiere "audio.png") && !ImageSearch(&vlx, &vly, KSA.sfxX1, KSA.sfxY1, KSA.sfxX2, KSA.sfxY2, "*2 " ptf.Premiere "audio2.png") ;searches for the audio image next to an audio file
                {
                    block.Off()
                    errorLog(Error("Couldn't find the audio image", -1),, 1)
                    coord.s()
                    MouseMove(xpos, ypos)
                    return
                }
            MouseMove(vlx, vly)
            sleep 100
            SendInput("{Click Down}")
            sleep 100
            coord.s()
            MouseMove(xpos, ypos)
            if GetKeyState("Ctrl") || GetKeyState("Ctrl", "P")
                SendInput("{Ctrl Up}") ;// a check to make sure premiere doesn't `insert` the clip
            SendInput("{Click Up}")
            sleep 500
            ; this.__checkTimelineFocus() ;// the timeline regains focus once the audio clip is dropped on the timeline
            colour := PixelGetColor(xpos + 10, ypos)
            if !this.dragColour.Has(colour)
                break
            if A_Index > 2
                {
                    block.Off()
                    errorLog(IndexError("Couldn't drag the file to the timeline because colour was " colour " A_Index was: " A_Index, -1),, 1)
                    return
                }
        }
        ;// out of loop
        block.Off()
        if sfxName = "bleep"
            {
                sleep 50
                SendInput(KSA.selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(10, 0,, "R")
                sleep 50
                cursorCheck()
                SendInput("{Click}")
                sleep 50
                SendInput(KSA.gainAdjust)
                SendInput("-20")
                SendInput("{Enter}")
                WinWaitClose("Audio Gain")
                MouseMove(xpos, ypos)
                trackNumber := 2
                sleep 100
                SendInput(KSA.cutPrem)
                start := A_TickCount
                sec := 0
                clear() {
                    ToolTip("")
                    ToolTip("",,, 2)
                    ToolTip("",,, 3)
                }
                loop {
                    ;check to see if the user wants the bleep on a track between 1-9
                    getlastHotkey := A_PriorKey
                    if getlastHotkey != "" {
                        if IsDigit(getlastHotkey) ;checks to see if the last pressed key is a number between 1-9
                            trackNumber := getlastHotkey
                        if (GetKeyState("Esc", "P") || getlastHotkey = "Escape")
                            {
                                clear()
                                return
                            }
                    }
                    sleep 50
                    if A_Index > 160 ;built in timeout
                        {
                            block.Off()
                            clear()
                            errorLog(IndexError(A_ThisFunc "() timed out due to no user interaction", -1),, 1)
                            return
                        }
                    if ((A_TickCount - start) >= 1000)
                        {
                            start += 1000
                            sec += 1
                        }
                    secRemain := 8 - sec
                    mousegetpos(, &ypos)
                    ToolTip("This function will attempt to drag your bleep to:`n" A_Tab A_Tab "Track " trackNumber)
                    ToolTip("Press another number key to move to a different track`nThe function will continue once you've cut the track`n" secRemain "s remaining",, ypos+15, 2)
                    ToolTip("Cancel with: Esc",, ypos-50, 3)
                } until GetKeyState("LButton", "P")
                ;// out of loop
                clear()
                block.On()
                sleep 50
                SendInput(KSA.selectionPrem)
                MouseGetPos(&delx, &dely)
                MouseMove(xpos + 10, ypos)
                sleep 500
                SendInput("{Click Down}")
                MouseGetPos(&refx, &refy)
                if !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_1.png") && !ImageSearch(&trackX, &trackY, 0, 0, 200, A_ScreenHeight, "*2 " ptf.Premiere "track " trackNumber "_2.png")
                    {
                        block.Off()
                        errorLog(Error("Couldn't determine the Y value of desired track", -1, trackNumber),, 1)
                        return
                    }
                MouseMove(refx, trackY, 2)
                SendInput("{Click Up}")
                sleep 50
                MouseMove(delx + 10, dely, 2)
                sleep 200
                cursorCheck()
                SendInput("{Click}")
                SendInput("{BackSpace}")
                MouseMove(xpos + 10, ypos)
                Sleep(25)
                cursorCheck()
                block.Off()
                ToolTip("")
                return
            }
    }

    /**
     * Move back and forth between edit points from anywhere in premiere
     * @param {String} window the hotkey required to focus the desired window within premiere
     * @param {String} direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
     * @param {String} keyswait a string you wish to pass to `keys.allWait()`'s first parameter
     */
    static wheelEditPoint(window, direction, keyswait := "all")
    {
        switch window {
            ;// If you ever use the multi camera view, the current method of doing things is required as otherwise there is a potential for premiere to get stuck within a nulticam nest for whatever reason. Doing it this way however, is unfortunately slower.
            ;// if you do not use the multiview window simply replace the below line with `this.__checkTimelineFocus()`
            case ksa.timelineWindow: delaySI(50, ksa.effectControls, window)
            case ksa.effectControls: delaySI(20, window, ksa.programMonitor, window, "^a", ksa.deselectAll) ;// indicates the user is trying to use `Select previous/next Keyframe`
            default: SendInput(window) ;focuses the timeline/desired window
        }
        SendInput(direction)
        switch keyswait {
            case "second": keys.allWait("second")
            case "first":  keys.allWait("first")
            default:       keys.allWait() ;prevents hotkey spam
        }
    }

    /**
     * This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
     */
    static movepreview()
    {
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        sleep 25
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        loop {
            if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "motion.png") ;moves to the motion tab
                    {
                        MouseMove(x + "25", y)
                        SendInput("{Click}")
                        break
                    }
            if A_Index > 3
                {
                    block.Off()
                    errorLog(IndexError("Couldn't find the requested property."),, {ttip: 2, y:30})
                    keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                    MouseMove(xpos, ypos)
                    return
                }
            sleep 50
        }
        sleep 50
        ToolTip("")
        ;// gets the state of the hotkey, enough time now has passed that if the user just presses the button, you can assume they want to reset the paramater instead of edit it
        if !GetKeyState(A_ThisHotkey, "P")
            {
                if !ImageSearch(&xcol, &ycol, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "reset.png")
                    {
                        block.Off()
                        MouseMove(xpos, ypos)
                        errorLog(Error("Couldn't find the reset button", -1)
                                    ,, 1)
                        return
                    }
                MouseMove(xcol, ycol)
                SendInput("{Click}")
                sleep 50
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        ;//* you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
        /**
         * This codeblock is potentially used below if the first loop fails
         */
        fallback() {
            tool.Cust("fallback")
            origX := previewWin.x + 10, origY := previewWin.height
            previewWin.y += 30
            previewWin.x += 15
            loop {
                previewWin.x += 5, previewWin.y += 10
                if previewWin.x > previewWin.x + previewWin.width
                    previewWin.x := origX
                if previewWin.y > origY
                    {
                        MouseMove(xpos, ypos)
                        block.Off()
                        keys.allWait()
                        return false
                    }
                check := PixelGetColor(previewWin.x, previewWin.y)
                ;// debugging
                /* FileAppend(Format("
                (
                    Index: {}
                    x: {}
                    y: {}
                    width: {}
                    height: {}
                    origX: {}
                    origY: {}
                    ________________

                )", A_Index, previewWin.x, previewWin.y, previewWin.width, previewWin.height, origX, origY), "test.txt") */
                if check != 0x232323 && check != 0x000000
                    {
                        MouseMove(previewWin.x, previewWin.y)
                        break
                    }
            }
            return true
        }

        progClassNN := ControlGetClassNN(effCtrlNN.uiaVar.ElementFromPath(premUIA.programMon).GetControlId()) ;gets the ClassNN value of the effects control window
        previewWin := obj.CtrlPos(progClassNN)
        if !IsObject(previewWin)
            return
        startX := (previewWin.x + (previewWin.width/2)) - 20
        startY := (previewWin.y + (previewWin.height/2)) - 10
        MouseMove(startX, startY) ;move to the preview window
        loop {
            MouseGetPos(&colX, &colY)
            if PixelGetColor(colX, colY) != 0x000000
                break
            if A_Index > 4
                {
                    if !fallback()
                        {
                            errorLog(IndexError("Couldn't find the video in the Program Monitor.", -1)
                                        , "Or the function kept finding pure black at each checking coordinate", 1)
                            return
                        }
                    break
                }
            switch A_Index {
                case 1: MouseMove(startX + 150, startY + 100)
                case 2: MouseMove(startX - 150, startY + 100)
                case 3: MouseMove(startX - 150, startY - 100)
                case 4: MouseMove(startX + 150, startY - 100)
            }
        }
        SendInput("{Click Down}")
        sleep 50
        block.Off()
        keys.allWait()
        SendInput("{Click Up}")
        ;!MouseMove(xpos, ypos) ; // moving the mouse position back to origin after doing this is incredibly disorienting
    }

    /**
     * This function moves the cursor to the reset button to reset the "motion" effects
     */
    static reset()
    {
        keys.allWait()
        coord.client()
        block.On()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        MouseGetPos(&xpos, &ypos)
        loop {
            if ImageSearch(&x2, &y2, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "motion2.png") || ImageSearch(&x2, &y2, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "motion3.png") ;checks if the "motion" value is in view
                break
            if A_Index > 5
                {
                    block.Off()
                    errorLog(IndexError("Couldn't find the motion image", -1),, 1)
                    return
                }
        }
        this.__checkTimelineFocus() ;~ check the keyboard shortcut ini file to adjust hotkeys
        if ImageSearch(&xcol, &ycol, x2, y2 - "20", x2 + "700", y2 + "20", "*2 " ptf.Premiere "reset.png") ;this will look for the reset button directly next to the "motion" value
            MouseMove(xcol, ycol)
        SendInput("{Click}")
        MouseMove(xpos, ypos)
        block.Off()
    }

    /**
     * This function will warp to and press any value in premiere to manually input a number
     * @param {String} property is the value you want to adjust. ie "scale"
     * @param {Integer} optional is the optional pixels to move the mouse to grab the Y axis value instead of the X axis
     */
    static manInput(property, optional := 0)
    {
        getHotkeys(&first, &waitHotkey)
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus()
        if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;searches to check if no clips are selected
            {
                SendInput(KSA.selectAtPlayhead) ;adjust this in the keyboard shortcuts ini file
                sleep 50
                if ImageSearch(&x, &y, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png") ;checks for no clips again incase it has attempted to select 2 separate audio/video tracks
                    {
                        block.Off()
                        errorLog(Error("No clips were selected", -1),, 1)
                        return
                    }
            }
        ;// finds the scale value you want to adjust, then finds the value adjustment to the right of it
        if !obj.imgSrchMulti({x1: effCtrlNN.x, y1: effCtrlNN.y, x2: effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), y2: effCtrlNN.y + effCtrlNN.height},, &x, &y
            , ptf.Premiere property ".png"
            , ptf.Premiere property "2.png"
            , ptf.Premiere property "3.png"
            , ptf.Premiere property "4.png"
        )
            {
                block.Off()
                errorLog(Error("Couldn't find the property requested.", -1, property),, 1)
                return
            }
        if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", 0x205cce, 2) ;searches for the blue text to the right of the scale value
            {
                block.Off()
                errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
                return
            }
        MouseMove(xcol + optional, ycol)
        keywait(waitHotkey)
        SendInput("{Click}")
        ToolTip("manInput() is waiting for the " "'" KSA.manInputEnd "'" "`nkey to be pressed")
        KeyWait(KSA.manInputEnd, "D") ;waits until the final hotkey is pressed before continuing
        ToolTip("")
        SendInput("{Enter}")
        MouseMove(xpos, ypos)
        SendInput("{MButton}")
        block.Off()
    }

    /**
     * This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
     * @param {Integer} amount is the value you want the gain to adjust (eg. -2, 6, etc)
     */
    static gain(amount)
    {
        if !IsNumber(amount) {
            ;// throw
            errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
        }
        keys.allWait()
        Critical
        tool.Cust("Adjusting Gain", 0.5)
        block.On()
        coord.s()
        check := winget.Title()
        if check = "Audio Gain" {
            SendInput(amount "{Enter}")
            block.Off()
            return -1
        }
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return false
        }

        premUIA := premUIA_Values()

        try {
            if ImageSearch(&x3, &y3, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), effCtrlNN.y + effCtrlNN.height, "*2 " ptf.Premiere "noclips.png"){ ;checks to see if there aren't any clips selected as if it isn't, you'll start inputting values in the timeline instead of adjusting the gain
                delaySI(50, KSA.timelineWindow, KSA.selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
                this().__fxPanel()
                if !obj.imgSrchMulti({x1: effCtrlNN.x, y1: effCtrlNN.y, x2: effCtrlNN.x + (effCtrlNN.width/KSA.ECDivide), y1: effCtrlNN.y + effCtrlNN.height},, &audx, &audy, ptf.Premiere "effctrlAudio.png", ptf.Premiere "effctrlAudio1.png") {
                    block.Off() ;just incase
                    return false
                }
            }
        } catch {
            block.Off()
            errorLog(UnsetError("ClassNN wasn't given a value", -1),, 1)
            return
        }
        sleep 100
        if IsSet(premUIAEl)
            effCtrlNN.uiaVar.AdobeEl.ElementFromPath(premUIA.timeline).SetFocus()
        else
            this.__checkTimelineFocus()
        sleep 100
        SendInput(KSA.gainAdjust)
        if !WinWait("Audio Gain",, 3) {
            tool.Cust("Waiting for gain window timed out")
            block.Off()
            return false
        }

        ;// the below sendinput use to begin with a simple +{Tab} but it appears that since either v24.0/v24.1 doing so will
        ;// instead focus the cancel button
        SendInput("{Tab 3}{Up 3}{Down}{Tab}" amount "{Enter}")
        WinWaitClose("Audio Gain")
        block.Off()
        return true
    }

    /** This function once bound to `~Numpad1-9::` allows the user to quickly adjust the gain of a selected track by simply pressing `NumpadSub/NumpadAdd` then their desired value. It will wait for 2 keys to be pressed so that a double digit number can be inputed. If only a single digit is required, press any other key (ie. enter). If no second input is pressed, the function will continue after `2s` */
    static numpadGain() {
        if this.timelineVals = false {
            this.__checkTimeline()
            return
        }
		title := WinGet.Title(, false)
		if (title = "Audio Gain" || title = "") || this.timelineFocusStatus() != 1 ||
            (A_PriorKey != "NumpadSub" && A_PriorKey != "NumpadAdd") {
			; SendInput("{" A_ThisHotkey "}") ;// because we preface the hotkey with `~` we no longer need this
			return
		}
        priorKey := (A_PriorKey = "NumpadSub") ? "-" : ""
		firstKey := SubStr(A_ThisHotkey, -1, 1), secondKey := ""
        ih := InputHook("L2 T2", "{NumpadEnter}", "{" A_ThisHotkey "}")
        ih.Start()
        ih.Wait()
        if IsDigit(ih.Input)
            secondKey := ih.Input
		prem.gain(priorKey firstKey secondKey)
    }

    /** This function checks the state of an internal variable to determine if the user wishes for the timeline to be specifically focused. If they do, it will then check to see if the timeline is already focused by calling `prem.timelineFocusStatus()` */
	static __checkTimelineFocus() {
		if this.focusTimelineStatus != true
            return
        check := this.timelineFocusStatus()
        if check != false
            return
        sleep 1
        SendEvent(KSA.timelineWindow)
        sleep 25
	}

    /**
	 * This function will toggle the state of an internal variable that tracks whether you user wishes for timeline focusing to be enabled or disabled.
	 * Toggling this can help scenarios where the user has multiple sequences open and the main function would otherwise start cycling between them
	 */
	static __toggleTimelineFocus() {
		which := (this.focusTimelineStatus = true) ? "disabled" : "enabled"
		tool.Cust(Format("Timeline focusing is now {}.", which), 2000)
		this.focusTimelineStatus := !this.focusTimelineStatus
	}

    /**
     * ### This function contains `KSA` values that need to be set correctly
     * Press a button *(ideally a mouse button)*, this function then changes to the "hand tool" and clicks so you can drag and easily move along the timeline, then it will swap back to the tool of your choice (selection tool for example).

     * This function will (on first use) check the coordinates of the timeline and store them, then on subsequent uses ensures the mouse position is within the bounds of the timeline before firing - this is useful to ensure you don't end up accidentally dragging around UI elements of Premiere.

     * This function will timeout after 10s by default as a preventative measure for stuck keys
     * @param {String} tool is the hotkey you want the script to input to swap TO (ie, hand tool, zoom tool, etc). (consider using KSA values)
     * @param {String} toolorig is the hotkey you want the script to input to bring you back to your tool of choice (consider using KSA values)
     * @param {Integer} timeout the number of `seconds` you want the function to wait before intentionally timing out. Defaults to `10`
    */
    static mousedrag(premtool, toolorig, timeout := 10) {
        if GetKeyState("RButton", "P") ;this check is to allow some code in `Premiere_RightClick.ahk` to work
            return
        SetTimer(rdisable, -1)
        rdisable() {
            if GetKeyState("RButton", "P") ;this check is to allow some code in `Premiere_RightClick.ahk` to work
                return
            SetTimer(rdisable, -50)
        }
        useUIA := false

        coordObj := obj.MousePos()
        ;// from here down to the begining of again() is checking for the width of your timeline and then ensuring this function doesn't fire if your mouse position is beyond that, this is to stop the function from firing while you're hoving over other elements of premiere causing you to drag them across your screen
        if !this.__checkTimeline() {
            return
        }

        ;// this below line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
        if !this.__checkCoords(coordObj) {
            SetTimer(rdisable, 0)
            return
        }

        premUIA := premUIA_Values()
        ;// create UIA element so we can focus the timeline more efficiently later
        try {
            premUIAEl := this.__createUIAelement(false)
            useUIA := true
        }
        premUIAEl := IsSet(premUIAEl) ? premUIAEl.AdobeEl  : false

        SetTimer(again.Bind(timeout, useUIA, premUIAEl), -400)
        again(timeout, useUIA, premUIAEl)
        again(timeout, useUIA, el) {
            ;// we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
            if !GetKeyState(KSA.DragKeywait, "P") {
                SetTimer(rdisable, 0)
                return
            }
            if A_ThisHotkey = KSA.DragKeywait {
                ;// this is here so it doesn't reactivate if you quickly let go before the timer comes back around
                if !GetKeyState(A_ThisHotkey, "P") {
                    SetTimer(rdisable, 0)
                    return
                }
            }
            if !this.timelineFocusStatus() {
                if useUIA = true && premUIAEl != false {
                    try premUIAEl.ElementFromPath(premUIA.timeline).SetFocus()
                    sleep 400 ;// if you don't sleep here premiere will not properly let go of lbutton until the timer fires up to 400ms later
                }
                else
                    this.__checkTimelineFocus()
            }
            SendInput(premtool "{LButton Down}")
            if A_ThisHotkey = KSA.DragKeywait && GetKeyState(KSA.DragKeywait, "P") ;we check for the defined value here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
                KeyWait(A_ThisHotkey, "T" timeout)
            else if A_ThisHotkey != KSA.DragKeywait && GetKeyState(KSA.DragKeywait, "P")
                KeyWait(KSA.DragKeywait, "T" timeout) ;A_ThisHotkey won't work here as the assumption is that LAlt & Xbutton2 will be pressed and ahk hates that
            SendInput("{LButton Up}")
            SendInput(toolorig)
            SetTimer(rdisable, 0)
        }
    }

    /**
     * This function will check for the blue outline around the timeline (using stored values within the class) that a focused window in premiere will ususally have.
     * @returns {Trilean} true/false/-1. `-1` indicates that the timeline coordinates could not be determined.
     */
    static timelineFocusStatus() {
        if !this.__checkTimeline()
            return -1
        origcoord := A_CoordModePixel, returnCoord() => A_CoordModePixel := origcoord
        coord.client(, false)
        if PixelGetColor(this.timelineRawX-1, this.timelineRawY+10) = this.focusColour {
            returnCoord()
            return true
        }
        returnCoord()
        return false
    }

    /**
     * ### Note: This function will evaluate the premiere timeline coordinates based off the `Client` coordmode. This cannot be changed.
     * A function to retrieve the coordinates of the Premiere timeline. These coordinates are then stored within the `Prem {` class.
     * @param {Boolean} tools whether you wish to have tooltips appear informing the user about timeline values. Defaults to true. Sends tooltips on `WhichToolTip` 11/12/13
     * @returns {Boolean} `true/false`
     */
    static getTimeline(tools := true) {
        try {
            if WinGetClass("A") = "DroverLord - Window Class" ;// if you're focused on a window that isn't the main premiere window, controlgetclassnn will retrieve different values
                switchTo.Premiere() ;// so we have to bring focus back to the main window first
        } catch {
            errorLog(UnsetError("Unable to determine the active window", -1),, 1)
            return false
        }
        ;// because we're using UIA we shouldn't need to focus the timeline to grab information about it
        ; SendInput(KSA.timelineWindow)
        ; SendInput(KSA.timelineWindow)
        sleep 75
        coord.client()
        premUIA := premUIA_Values()
        if !timelineNN := this.__uiaCtrlPos(premUIA.timeline,,, false)
            return false
        this.timelineRawX     := timelineNN.x, this.timelineRawY := timelineNN.y
        this.timelineXValue   := timelineNN.x + timelineNN.width - 22  ;accounting for the scroll bars on the right side of the timeline
        this.timelineYValue   := timelineNN.y + 46          ;accounting for the area at the top of the timeline that you can drag to move the playhead
        this.timelineXControl := timelineNN.x + 236         ;accounting for the column to the left of the timeline
        this.timelineYControl := timelineNN.y + timelineNN.height - 25 ;accounting for the scroll bars at the bottom of the timeline
        this.timelineVals     := true
        if tools = true
            SetTimer(tooltips, -100)
        return true
        tooltips() {
            ; tool.Wait()
            tool.Cust("prem.getTimeline() found the coordinates of the timeline.", 4.0,,, 10)
            tool.Cust("This function will not check coordinates again until a script refresh.`nIf this script grabbed the wrong coordinates, refresh and try again!", 4.0,, 30, 11)
            tool.Cust("If this script fails to function correctly, recheck your Prem_UIA coords`nbefore refreshing the script and trying again!", 4.0,, 73, 12)
        }
    }

    /**
     * ### This function has been broken for a while. Premiere now makes it so that if you're on the very last character of a text block, <kbd>Ctrl</kbd> + <kbd>Left</kbd> won't do anything. Move one character to the left and suddenly it works.
     * Premiere is really dumb and doesn't let you ctrl + backspace, this function is to return that functionality
     */
    static wordBackspace() {
        SendMode("Event")
        SetKeyDelay(15)
        sendLeft() {
            Send("{Ctrl Down}{Shift Down}")
            Send("{Left}")
            Send("{Shift Up}{Ctrl Up}")
        }
        keys.allWait("second")
        sendLeft()
        store := clip.clear()
        Send("^c")
        if !ClipWait(0.1) || check := (StrLen(A_Clipboard) = 1) ? 1 : 0
            {
                additional := true
                if IsSet(check) && check = 1
                    Send("{Right}")
                else if A_Clipboard = A_Space
                    {
                        Send("{Right}")
                        Send("{BackSpace}")
                        additional := false
                    }
                Send("{Space}")
                Send("{Left}")
                sendLeft()
                Send("{BackSpace}")
                if additional
                    Send("{Delete}")
            }
        Send("{BackSpace}")
        clip.returnClip(store.storedClip)
    }

    /**
     * Getting back to the selection tool while you're editing text or in other edge case scenarios can be quite painful.
     * This function will instead attempt to warp to the selection tool on your toolbar and presses it instead. If that fails it will focus the toolbar and send the hotkey instead.
     */
    static selectionTool() {
        MouseGetPos(&xpos, &ypos)
        sleep 50
        block.On()
        premUIA := premUIA_Values()
        if !toolsNN := this.__uiaCtrlPos(premUIA.tools,,, false) {
            block.Off()
            return
        }
        if ImageSearch(&xx, &yy, toolsNN.x, toolsNN.y, toolsNN.x + toolsNN.width, toolsNN.y + toolsNN.height, "*2 " ptf.Premiere "selection_2.png") {
            block.Off()
            return
        }
        if ImageSearch(&x, &y, toolsNN.x, toolsNN.y, toolsNN.x + toolsNN.width, toolsNN.y + toolsNN.height, "*2 " ptf.Premiere "selection.png") {
            coord.client("Mouse", false)
            MouseMove(x, y)
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            SendInput(KSA.programMonitor)
            block.Off()
            return
        }
        sleep 100
        if A_Index > 3 {
            SendInput(KSA.timelineWindow)
            SendInput(KSA.selectionPrem)
            SendInput(KSA.programMonitor)
            errorLog(Error("Couldn't find the selection tool", -1), "Used the selection hotkey instead", 1)
            block.Off()
            return
        }
    }

    /**
     * Trying to zoom in on the preview window can be really annoying when the hotkey only works while the window is focused
     * This function will ensure it happens regardless
     * @param {String} command the hotkey to send to premiere to zoom however you wish
    */
    static zoomPreviewWindow(command) {
        __sendOrig() {
            if A_ThisHotkey != "" {
                hot := SubStr(A_ThisHotkey, 1, 1) = "$" ? SubStr(A_ThisHotkey, 2) : A_ThisHotkey
                SendInput(hot)
            }
        }
        title := WinGet.PremName()
        if WinGetTitle("A") != title.winTitle {
            __sendOrig()
            return
        }
        premUIA := premUIA_Values()
        createEl := this.__createUIAelement(false)
        toolsNN  := this.__uiaCtrlPos(premUIA.tools, false, createEl, false)
        if !toolsNN || SubStr(createEl.activeElement, 1, StrLen(createEl.activeElement)-3) = premUIA.project ||
            ImageSearch(&xx, &yy, toolsNN.x, toolsNN.y, toolsNN.x + toolsNN.width, toolsNN.y + toolsNN.height, "*2 " ptf.Premiere "text.png") {
            __sendOrig()
            return
        }
        ;// we first need to focus a window that won't cycle through anything if you activate it multiple times
        ;// if you don't, activating the program monitor while it's already activated will cycle timeline sequences
        delaySI(50, KSA.effectControls, KSA.programMonitor, command)
    }

    /**
     * Quickly and easily move any number of frames in the desired direction.
     * @param {String} direction the direction you wish to move
     * @param {Integer} frames the amount of frames you wish to move in that direction
     * @param {String} windowHotkey the hotkey you wish to send to premiere to focus your window of choice. Defaults to the `Effect Controls` window
     */
    static moveKeyframes(direction, frames, windowHotkey := KSA.effectControls) {
        if direction != "left" && direction != "right" {
            ;// throw
            errorLog(ValueError("Value is not a valid direction", direction, -1),,, 1)
        }
        delaySI(50, windowHotkey, windowHotkey)
        SendInput(Format("`{{1} {2}`}", direction, frames))
    }

    /**
     * A function to simply open an asset folder
     * @param {String} dir the path to the directory you wish to open
     */
    static openEditingDir(dir) {
        dirObj := obj.SplitPath(dir)
        if WinExist(dirObj.name) {
            WinActivate(dirObj.name)
            return
        }
        Run(dir)
        if !WinWaitActive(dirObj.name,, 3) {
            if WinExist(dirObj.name)
                WinActivate(dirObj.name)
        }
    }

    /**
     * This function returns whether the classes internal timeline values have been set
     * @returns {Boolean}
     */
    static __checkTimelineValues() {
        if (this.timelineXValue = 0 || this.timelineYValue = 0 || this.timelineXControl = 0 || this.timelineYControl = 0) ||
            (this.timelineVals = false)
            return false
        return true
    }

    /**
     * This function waits for the timeline to be in focus
     * @param {Integer} timout how many `seconds` you want to wait before this function times out
     */
    static __waitForTimeline(timeout := 5) {
        loop timeout {
            if this.timelineFocusStatus() != true {
                this.__checkTimelineFocus()
                sleep 1000
                continue
            }
            return true
        }
        return false
    }

    /**
     * Checks to see if the timeline values within `prem {` have been set. If not, this function will attempt to retrieve them.
     * @param {Boolean} tools whether you wish to have tooltips appear informing the user about timeline values
     * @returns {Boolean} if the timeline cannot be determined, returns `false`. Else returns `true`
     */
	static __checkTimeline(tools := true) {
		if  !this.__checkTimelineValues() {
			if !this.getTimeline(tools)
				return false
		}
		return true
	}

    /**
     * This function checks if the mouse is outside the bounds of the timeline.
     * This code should work regardless of where you have the timeline (unless you make your timeline comically small, then you may encounter issues)
     * @returns {Boolean} if the cursor is **not** within the timeline, returns `false`. Else returns `true`
     */
	static __checkCoords(coordObj) {
		if ((coordObj.x > this.timelineXValue) || (coordObj.x < this.timelineXControl) || (coordObj.y < this.timelineYValue) || (coordObj.y > this.timelineYControl))
			return false
		return true
	}

    /**
     * This function handles accelorating scrolling within premiere. It specifically expects the first activation hotkey to be either `alt` or `shift`.
     * This function will attempt to only fire within the timeline.
     *
     * *Due to ahk quirkiness, this function can act incredibly laggy and cause windows to beep if it's not placed in the perfect spot in your script.*
     * @param {Integer} altAmount the amount of accelerated scrolling you want
     * @param {Integer} scrollAmount the amount of accelerated scrolling you want
     */
    static accelScroll(altAmount := 3, scrollAmount := 5) {
        if !this.__checkTimeline()
			return
        origMouse := obj.MousePos()
        if !this.__checkCoords(origMouse)
            scrollAmount := 1, altAmount := 1
        getDir := getHotkeys()
        switch getdir.first {
            case "Alt": delaySI(0, SendInput(Format("!{{1} {2}}", getDir.second, altAmount)))
            default:    delaySI(0, SendInput(Format("{{1} {2}}", getDir.second, scrollAmount)))
        }
    }


    /**
     * This is an internal function for `prem.Previews()` simply to make code a little cleaner. It handles sending a desired hotkey to delete previews then waiting for the delete dialogue box premiere presents the user.
     * @param {String} sendHotkey which hotkey you wish to send
     */
    __delprev(sendHotkey, wasActive := false) {
        SendInput(sendHotkey)
        if !WinWait("Confirm Delete " prem.exeTitle,, 3) {
            if wasActive = "active" {
                SendInput(sendHotkey)
                if !WinWait("Confirm Delete " prem.exeTitle,, 2)
                    return
            }
        }
        WinActivate("Confirm Delete " prem.exeTitle)
        if !WinWaitActive("Confirm Delete " prem.exeTitle,, 3)
            return
        sleep 1000
        SendInput("{Enter}")
        if !WinExist("Confirm Delete " prem.exeTitle)
            return
        loop 3 {
            WinActivate("Confirm Delete " prem.exeTitle)
            sleep 100
            SendInput("{Enter}")
            sleep 500
            if !WinExist("Confirm Delete " prem.exeTitle)
                return
        }
    }

    /**
     * This function handles different hotkeys related to `Previews` (both rendering & deleting them). This function will attempt to save the project before doing anything.
     *
     * > This function contains code that will check for `PremiereRemote` and use it if detected. This code will make the function more reliable.
     * @param {String} which whether you wish to delete or render a preview. If deleting, pass `"delete"` else pass an empty string
     * @param {String} sendHotkey which hotkey you wish to send
     */
    static Previews(which, sendHotkey) {
        if !WinActive(this.exeTitle)
            return
        title := WinGet.PremName()
        if title.saveCheck != false
            attempt := this.saveAndFocusTimeline()
        switch which {
            case "delete": this().__delprev(sendHotkey, attempt ?? false)
            default:
                SendInput(sendHotkey)
                if !WinWait("Rendering",, 2) {
                    if attempt ?? false = "active" {
                        SendInput(sendHotkey)
                        if !WinWait("Rendering",, 2) {
                            tool.Cust("Waiting for rendering window timed out.`nLag may have caused the hotkey to be sent before Premiere was ready.")
                            return
                        }
                    }
                }
        }
    }

    /**
     * Checks to see if the playhead is within the defined coordinates
     * @param {Integer} coordObj an object containing the cursor coordinates you want pixelsearch to check. This object should contain: `{x1: , y1: , x2: , y2: }`. The default to search the timeline (assuming values have been set) can be found in the example`
     * @param {Hexadecimal} playheadCol the colour you wish pixelsearch to look for
     * @returns {Obj/Boolean false} if successful and the playhead is found, returns object `{x: , y: }`. Else returns `false`
     * ```
     * origMouse := obj.MousePos()
     * searchPlayhead({x1: prem.timelineXValue, y1: origMouse.y, x2: prem.timelineXControl, y2: origMouse.y})
     * ```
     */
    static searchPlayhead(coordObj, playheadCol := this.playhead) {
        if PixelSearch(&pixX, &pixY, coordObj.x1, coordObj.y1, coordObj.x2, coordObj.y2, playheadCol)
			return {x: pixX, y: pixY}
        return false
    }

    /**
     * This function will search for the playhead and then slowly begin scrubbing forward. This function was designed to make scrubbing for thumbnail screenshots easier
     */
    static thumbScroll() {
        block.On()
        ;// set coord mode and grab the cursor position
		coord.s()
        storeHotkey := A_ThisHotkey
		origMouse := obj.MousePos()
        originalSpeed := this.scrollSpeed
        ;// checks to see whether the timeline position has been located
        if !this.__checkTimeline() {
            block.Off()
            keys.allWait()
			return
        }
		;// checks the coordinates of the mouse against the coordinates of the timeline to ensure the function
		;// only continues if the cursor is within the timeline
		if !this.__checkCoords(origMouse) {
            block.Off()
            keys.allWait()
			return
        }
        ;// check whether the timeline is already in focus & focuses it if it isn't
		this.__checkTimelineFocus()
        ;// determines the position of the playhead
        if !playhead := this.searchPlayhead({x1: prem.timelineXValue, y1: origMouse.y, x2: prem.timelineXControl, y2: origMouse.y}) {
            block.Off()
            errorLog(TargetError("Could not determine the position of the playhead", -1),, 1)
            keys.allWait()
            return
        }
        SendInput(KSA.shuttleStop)
        MouseMove(playhead.x, playhead.y)
        SendInput("{LButton Down}")
        block.Off()
        if !GetKeyState(storeHotkey, "P") {
            SendInput("{LButton Up}")
            return
        }
        PremHotkeys.__HotkeySetThumbScroll(["Shift", "Ctrl"])
        while GetKeyState(storeHotkey, "P") {
            getpos := obj.MousePos()
            if !this.__checkCoords(getpos)
                break
            MouseMove(this.scrollSpeed, 0,, "R")
            sleep 50
        }
        SendInput("{LButton Up}")
        PremHotkeys.__HotkeyReset(["Shift", "Ctrl"])
        this.scrollSpeed := originalSpeed
    }

    /**
     * #### This function requires you to properly set your ripple trim previous/next keys correctly within `KSA` as well as requires you to make those same keys call `prem.rippleTrim()` in your main ahk script.
     * If the user immediately attempts to resume playback after ripple trimming the playhead will sometimes not be placed at the new clip and will inadvertently begin playback where you might not expect it
     * This function attempts to delay playback immediately after a trim to mitigate this behaviour. This function might require some adjustment from the user depending on how fast/slow their pc is
     * @param {Integer} delayMS the delay in `ms` that you want the function to wait before attempting to resume playback. Defaults to a value set within the class
     */
    static delayPlayback(delayMS?) {
        this.defaultDelay := IsSet(delayMS) ? delayMS : this.defaultDelay
        delayMS := IsSet(delayMS) ? delayMS : this.defaultDelay
        __sendSpace() => (SendEvent(ksa.playStop), Exit())
        if !this.timelineFocusStatus() || (A_PriorKey != ksa.premRipplePrev && A_PriorKey != ksa.premRippleNext)
            __sendSpace()
        SetTimer((*) => __sendSpace(), -(delayMS-this.delayTime))
    }

    /** Tracks how long it has been since the user used a ripple trim. This function is to provide proper functionality to `prem.delayPlayback()` */
    static rippleTrim() {
        SendEvent(A_ThisHotkey)
        SetTimer(__track.Bind(A_TickCount), 16)
        __track(initialTime) {
            currentTime := A_TickCount - initialTime
            if currentTime >= this.defaultDelay {
                this.delayTime := 0
                return
            }
            this.delayTime := currentTime
        }
    }

    /**
     * #### This function is almost entirely designed for my own workflow and requires hardcoded variables at the top of the class that are then specifically acted apon in various other classes/scripts.
     * A function to facilitate quickly retriving large quantities of screenshots for yt thumbnails. This function is designed to be called from a streamdeck script and there may be unexpected behaviour if done in any other way
     * @param {String} who the name of the person I'm grabbing the screenshot of
     * @param {Boolean} change determine if the function is being called to change the new starting value
     */
    static screenshot(who, change := false) {
        if change = true {
            title := "Change stored value"
            storedVar := 0
            changeGUI := tomshiBasic(,, -0x30000, title) ; WS_MINIMIZEBOX := 0x20000, WS_MAXIMIZEBOX := 0x10000
            listArr := []
            loop files ptf.rootDir "\Streamdeck AHK\screenshots\*.ahk", "F" {
                SplitPath(A_LoopFileFullPath,,,, &name)
                if name = "Change"
                    continue
                listArr.Push(name)
            }
            if listarr.Length < 1 {
                listArr := ["Desktop", "Narrator", "Mully", "Eddie", "Juicy", "Josh", "guest1", "guest2"]
            }
            changeGUI.AddDropDownList("vDropdwn Choose1 Sort", listArr) ;//! make alphabetical
            changeGUI.AddEdit("Number Range1-100")
            changeGUI.AddUpDown("vUpDwn", 1)
            changeGUI.AddButton("x+10 y+-27", "Set").OnEvent("Click", (guiCtrl, *) => __setVal(guiCtrl))

            changeGUI.OnEvent("Close", (*) => ExitApp())
            changeGUI.OnEvent("Escape", (*) => ExitApp())
            changeGUI.show()
            WinWaitClose(title)

            __setVal(guiCtrl, *) {
                which := changeGUI["Dropdwn"].text
                val := changeGUI["UpDwn"].value
                this.sc%which% := val
                changeGUI.Destroy()
                storedVar := Format("{},{}", which, val)
                return
            }
            return storedVar
        }
        sleep 50
        scrshtTitle := "Export Frame"
        premUIA := premUIA_Values()
        if !progMonNN := this.__uiaCtrlPos(premUIA.programMon,,, false) {
            block.Off()
            return
        }

        premUIA := premUIA_Values()
        try premUIAEl := this.__createUIAelement(false)

        __clickProx(x, y) {
            block.On()
            MouseGetPos(&origX, &origY)
            MouseMove(x, y, 2)
            SendInput("{Click}")
            sleep 250
            MouseMove(origX, origY, 2)
            sleep 250
            block.Off()
        }

        if IsSet(premUIAEl)
            premUIAEl.AdobeEl.ElementFromPath(premUIA.timeline).SetFocus()
        else
            this.__checkTimelineFocus()
        sleep 50
        if proxSrch := ImageSearch(&proxX, &proxY, progMonNN.x, progMonNN.y/2, progMonNN.x+progMonNN.width, progMonNN.y+progMonNN.height+50, "*2 " ptf.Premiere "\proxy_on.png") {
            __clickProx(proxX, proxY)
        }
        SendEvent(ksa.premExportFrame)
        if !WinWait(scrshtTitle,, 3) {
            block.Off()
            return
        }
        SendEvent(who "_" this.sc%who%)
        if this.sc%who% = 1 {
            if !WinWaitClose(scrshtTitle,, 10) {
                block.Off()
                return
            }
            if !proxSrch {
                block.Off()
                return
            }
            __clickProx(proxX, proxY)
            block.Off()
            return
        }
        SendEvent("{Enter}")
        if !WinWaitClose(scrshtTitle,, 10) {
            block.Off()
            return
        }
        sleep 50
        if !proxSrch {
            block.Off()
            return
        }
        __clickProx(proxX, proxY)
    }

    /** A function to simply copy the current anchor point coordinates and transfer them to the position value. This function is designed for use in the `Transform` Effect and not the motion tab. */
    static anchorToPosition() {
        clipb := clip.clear()
        if !clip.copyWait(clipb.storedClip)
            return
        anch1 := A_Clipboard
        clip.clear()
        SendEvent("{Tab}")
        if !clip.copyWait(clipb.storedClip)
            return
        anch2 := A_Clipboard
        delaySI(50, "{Tab}", anch1, "{Tab}", anch2, "{Enter}")
        clip.delayReturn(clipb.storedClip)
    }

    ;//! *** ===============================================

    class Excalibur {

        lockNumpadKeys := Mip("Space", ",", "Numpad0", ",", "NumpadSub", "{BackSpace}")
        /**
         * Sets or resets some numpad functionality for `lockTracks()`
         */
        __lockNumpadKeys(set_reset := "set", which := "") {
            switch set_reset, "Off" {
                case "set":
                    __set(sendHotkey, *) => SendInput(sendHotkey)
                    for k, v in this.lockNumpadKeys {
                        Hotkey(k, __set.Bind(v), "On")
                    }
                case "reset":
                    for k2, v2 in this.lockNumpadKeys {
                        try {
                            Hotkey(k2, k2)
                        } catch {
                            Hotkey(k2, "Off")
                        }
                    }
                    try {
                        Hotkey("NumpadDiv", "NumpadDiv")
                    } catch {
                        Hotkey("NumpadDiv", "Off")
                    }
            }
        }

        /**
         * This function allows the user to select a range of tracks to toggle instead of needing to type them one by one. It will either wait for two numbers to be input or for <kbd>NumpadEnter</kbd> to be pressed.
         */
        __divHotkey(*) {
            __finish() {
                errorLog(Error("Input value is not a number."),, true)
                tool.Wait()
            }
            tool.Cust("Type first number then press NumpadEnter", 3.0)
            ih := InputHook("L2", "{NumpadEnter}")
            ih.Start()
            ih.Wait()
            firstNum := ih.Input
            if !IsInteger(firstNum) {
                __finish()
                ExitApp()
            }

            tool.Cust("Type second number then press NumpadEnter", 3.0)
            ih2 := InputHook("L2", "{NumpadEnter}")
            ih2.Start()
            ih2.Wait()
            secondNum := ih2.input
            if !IsInteger(secondNum) {
                __finish()
                ExitApp()
            }

            startingVal := Min(firstNum, secondNum)
            arr := [startingVal]
            loop (Max(firstNum, secondNum)-Min(firstNum, secondNum)) {
                arr.Push(++startingVal)
            }
            for v in arr
                SendInput(v ",")
            SendInput("{Enter}")
        }

        /**
         * #### This function requires the premiere plugin `Excalibur` to be installed and for `KSA.excalLockVid/KSA.excalLockAud` to be correctly set.
         * Quickly and easily lock/unlock multiple audio/video tracks
         * @param {String} which determines which track you wish to adjust. Must be either `"video"` or `"audio"`
         */
        static lockTracks(which := "Video") {
            switch which, "Off" {
                case "audio": SendInput(KSA.excalLockAud)
                case "video": SendInput(KSA.excalLockVid)
                default: return
            }
            if !WinWait("Lock " StrTitle(which) " Tracks",, 3)
                return
            sleep 200
            SendInput("{Down}")
            this().__lockNumpadKeys("set", which)
            Hotkey("NumpadDiv", this().__divHotkey, "On")
        }
    }
}

class PremHotkeys {
    /**
     * Resets an array of keys to their original `Hotkey` functions
     * @param {Array} keyArr an array of keynames
     */
    static __HotkeyReset(keyArr) {
        for k in keyArr {
            try {
                Hotkey(k, k)
            } catch {
                try {
                    Hotkey(k, "Off")
                }
            }
        }
    }

    /**
     * Sets an array of keys to the passed in function
     * @param {Array} arr an array of keynames
     * @param {FuncObj} func a passed in function that all keynames will be passed into
     * @param {String} options allows the user to pass addition `Hotkey` options. This parameter can be omitted
     */
    static __HotkeySet(arr, func, options := "") {
        try {
            for v in arr {
                Hotkey(v, func.Bind(v), "On " options)
            }
        }
    }

    /**
     * Function for `prem.thumbScroll()` sets hotkeys on <kbd>Shift</kbd> & <kbd>Ctrl</kbd> to speed up/slow down the cursor moving
     * @param {Array} arr all keys you wish to assign a function
     */
    static __HotkeySetThumbScroll(arr) {
        this.__HotkeySet(arr, __set)

        /**
         * A function to define what each hotkey passed will do
         * @param {String} which the keyname
         */
        __set(which, *) {
            switch which {
                case "Shift":  prem.scrollSpeed += 5
                case "Ctrl":
                if prem.scrollSpeed <= 5 {
                    prem.scrollSpeed := 1
                    return
                }
                prem.scrollSpeed -= 5
            }
        }
    }
}