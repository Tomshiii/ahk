/************************************************************************
 * @description A library of useful Premiere functions to speed up common tasks. Most functions within this class use `KSA` values - if these values aren't set correctly you may run into confusing behaviour from Premiere
 * Originally designed for v22.3.1 of Premiere. As of 2023/06/30 code is maintained for the version of Premiere listed below
 * Any code after that date is no longer guaranteed to function on previous versions of Premiere. Please see the version number below to know which version of Premiere I am currently using for testing.
 * @premVer 25.0
 * @author tomshi
 * @date 2025/04/22
 * @version 2.1.62
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
#Include <GUIs\tomshiBasic>
#Include <Other\UIA\UIA>
#Include <Functions\getHotkeys>
#Include <Functions\delaySI>
#Include <Functions\detect>
#Include <Functions\checkStuck>
#Include <Other\Notify\Notify>
; }

class Prem {

    static __New() {
        UserSettings := UserPref()
        this.currentSetVer := SubStr(UserSettings.premVer, 2)
        UserSettings.__delAll()
        UserSettings := ""

        switch {
            ;// spectrum ui
            case VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0:
                ;// set timeline and playhead colours
                this.playhead := 0x4096F3, this.focusColour := 0x4096F3, this.secondChannel := 65
                ;// set layer button offsets (these get added onto `timelineRawX`)
                this.layerSource := 16, this.layerLock := 48, this.layerTarget := 71, this.layerSync := 96, this.layerMute := 119, this.layerSolo := 142, this.layerEmpty := 0x1D1D1D, this.layerDivider := 0x303030, this.valueBlue := 0x4096f3, this.effCtrlSegment := 21, this.iconHighlight := 0x6A6A6A
            ;// old ui
			case VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0:
                ;// set timeline and playhead colours
                this.playhead := 0x2D8CEB, this.focusColour := 0x2D8CEB, this.secondChannel := 55, this.valueBlue := 0x205cce, this.effCtrlSegment := 21
        }
    }

    static currentSetVer := ""
    static spectrumUI_Version := "25.0"

    static exeTitle := Editors.Premiere.winTitle
    static winTitle := this.exeTitle
    static class    := Editors.Premiere.class
    static path     := ptf["Premiere"]

    ;// colour of playhead
    static playhead  := 0x4096F3

    ;// colour of highlighted icons
    static iconHighlight := 0x6A6A6A

    ;// valuehold()
    static valueBlue      := 0x4096f3
    static effCtrlSegment := 21

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
    static focusColour      := 0x4096F3

    ;// rbuttonPrem
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

    ;// swapChannels()
    static secondChannel := 0

    ;// toggleLayerButtons()
    static layerSource := 16
    static layerLock   := 48
    static layerTarget := 71
    static layerSync   := 96
    static layerMute   := 119
    static layerSolo   := 142
    static layerEmpty   := 0x1D1D1D
    static layerDivider := 0x303030
    static toggleWaiting := false

    __fxPanel() => (delaySI(16, KSA.effectControls, ksa.programMonitor, KSA.effectControls))

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
        if !needResult {
            Run(sendcommand,, "Hide")
            return true
        }
        else {
            if InStr(getResp := cmd.result(sendcommand), "Failed to connect to localhost") {
                tool.cust("Unable to connect to localhost server. PremiereRemote Extension may not be running.")
                errorLog(Error("1. Unable to connect to localhost server. PremiereRemote Extension may not be running."))
                return false
            }
            try parse := JSON.parse(getResp)
            catch {
                tool.cust("Unable to connect to localhost server. PremiereRemote Extension may not be running.")
                errorLog(Error("2. Unable to connect to localhost server. PremiereRemote Extension may not be running."))
                return false
            }
            return parse["result"]
        }
    }

    /**
     * Calls a `PremiereRemote` function to directly save the current project. This function will also double check to ensure the active sequence does not change after the save attempt
     * @param {Boolean} [andWait=true] determines whether you wish for the function to wait for the `Save Project` window to open/close
     *
     * @returns {Boolean/String}
     * - `true`: successful
     * - `false`: `PremiereRemote`/`saveProj` func/`projPath` func not found/save attempt fails (server not running)
     * - `"timeout"`: waiting for the save project window to open/close timed out
     * - `"noseq"` : `focusSequence`/`getActiveSequence` func not found
     */
    static save(andWait := true, checkSeqTime := 1000, checkAmount := 1) {
        if !this.__checkPremRemoteDir("saveProj") || !this.__checkPremRemoteFunc("getActiveSequence")
            return false
        origSeq := this.__remoteFunc("getActiveSequence")
        if !this.__remoteFunc("saveProj")
            return false

        if !andWait
            return true

        ;// waiting for save dialogue to open & close
        if !WinWait("Save Project",, 3)
            return "timeout_nosave"
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
        saveAttempt := this.save()
        if (saveAttempt = false || saveAttempt = "timeout" || saveAttempt = "timeout_nosave") {
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
        if !IsSet(carx) || !IsSet(cary) || (!carx && !cary)
            return
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
     * checks for and disables the `Direct Manipulation` button that appears in the bottom left of the program monitor when you select a clip
     * this button being enabled can be annoying as it will then pause playback if you click anything else in the timeline
     * @param {String} [toggleKey=ksa.toggleCropDirectManip] the shortcut to send to toggle off Direct Manip. Defaults to a KSA value
     */
    static disableDirectManip(toggleKey := ksa.toggleCropDirectManip) {
        ;// button was only added in specrum UI
        if VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0
            return
        coord.client()
        block.On()
        premUIA := premUIA_Values()
        if !progNN := this.__uiaCtrlPos(premUIA.programMon,,, false) {
            block.Off()
            return
        }
        if PixelGetColor(progNN.x+15, progNN.y+(progNN.height-10)) != this.iconHighlight
            return

        delaySI(25, toggleKey, toggleKey)

        block.Off()
        return
    }

    /**
     * A function to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
     * @param {String} control is which control you wish to adjust. This parameter is CASE SENSETIVE!!. Valids options; `Position`, `Scale`, `Rotation`, `Opacity`
     * @param {Integer} optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
     */
    static valuehold(control, optional := 0)
    {
        ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
        ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
        ;You can plug your own x distance in by changing the value below
        coord.client()
        MouseGetPos(&xpos, &ypos)
        block.On()
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        if !this.checkNoClips(effCtrlNN, &x, &y) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            return
        }
        motionPos := {x: effCtrlNN.x+57, y: effCtrlNN.y+62}
        switch {
            ;// spectrum UI
            case VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0: effCtrlArr := ["Position", "Scale", "Scale Width", "Uniform Scale", "Rotation", "Anchor Point", "Anti-flicker Filter", "Crop Left", "Crop Top", "Crop Right", "Crop Bottom", "Opacity Title", "Opacity Mask", "Opacity", "Blend Mode"]
            ;// old ui
			case VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0: effCtrlArr := ["Position", "Scale", "Scale Width", "Uniform Scale", "Rotation", "Anchor Point", "Anti-flicker Filter", "Opacity Title", "Opacity Mask", "Opacity", "Blend Mode"]
        }
        startPos := {x: motionPos.x+15, y: motionPos.y+this.effCtrlSegment}
        for i, v in effCtrlArr {
            if v !== control && i != effCtrlArr.Length
                continue
            if v !== control && i = effCtrlArr.Length {
                block.Off()
                errorLog(IndexError("Failed to find the requested control", -1, control),, 1)
                keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                return
            }
            startPos.y += (this.effCtrlSegment*i)-(this.effCtrlSegment*0.75)
            break
        }

        ;// determining the edge of the pixel search (otherwise it might grab the playhead)
        if !ImageSearch(&collapseX, &collapseY, effCtrlNN.x, effCtrlNN.y, effCtrlNN.x + (effCtrlNN.width/ksa.ECDivide), effCtrlNN.y+50, "*2 " ptf.Premiere "effCtrlCollapse.png") {
            block.Off()
            errorLog(TargetError("Failed to find the edge of the Effect Controls window", -1),, 1)
            keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            MouseMove(xpos, ypos)
            return
        }

        if !PixelSearch(&xcol, &ycol, startPos.x, startPos.y, collapseX, startpos.y + (this.effCtrlSegment*.75), this.valueBlue, 6) {
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
            if !ImageSearch(&x2, &y2, startPos.x, startPos.y - (this.effCtrlSegment*.25), startPos.x + 1500, startPos.y + (this.effCtrlSegment*.75), "*2 " ptf.Premiere "reset.png") {
                MouseMove(xpos, ypos)
                block.Off()
                errorLog(Error("Couldn't find the reset button", -1),, 1)
                return
            }
            MouseMove(x2, y2)
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            this.disableDirectManip()
            block.Off()
            return
        }
        ;// waiting for the user to release the key
        SendInput("{Click Down}")
        block.Off()
        keys.allWait()
        SendInput("{Click Up}" "{Enter}")
        sleep 200 ;was experiencing times where ahk would just fail to excecute the below mousemove. no idea why. This sleep seems to stop that from happening and is practically unnoticable
        this.disableDirectManip()
        MouseMove(xpos, ypos)
    }

    /**
     * Move back and forth between edit points from anywhere in premiere. Be careful that your `shuttle stop` keyframe doesn't have any additional keyboard shortcuts assigned with modifiers.
     * ie. if `Shuttle Stop` is <kbd>k</kbd> don't have anything set to <kbd>Shift + k</kbd> or <kbd>Ctrl + k</kbd> etc. Otherwise if you activate this function consecutively, modifiers might "leak" when unintended causing that hotkey to be activated.
     * @param {String} window the hotkey required to focus the desired window within premiere
     * @param {String} direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
     * @param {String} [keyswait="all"] a string you wish to pass to `keys.allWait()`'s first parameter
     * @param {Boolean/Object} [checkMButton=false] determine whether the function will wait to see if <kbd>MButton</kbd> is pressed shortly after (or is being held). This can be useful with panning around Premiere's `Program` monitor (assuming this function is activated using tilted scroll wheels, otherwise leave this param as false). This parameter can either be set to `true/false` or an object containing key `T` along with the timeout duration. Eg. `{T:"0.3"}`
     */
    static wheelEditPoint(window, direction, keyswait := "all", checkMButton := false) {
        SetKeyDelay(0)
        if Type(window) != "string" || Type(direction) != "string" || Type(keyswait) != "string" || (Type(checkMButton) != "integer" && Type(checkMButton) != "object") {
            ;// throw
            errorLog(TypeError("Incorrect Parameter type passed to function", -1),,, true)
            return
        }
        if checkMButton != false {
            if GetKeyState("MButton", "P") || GetKeyState("MButton")
                return
            timeoutVal := (IsObject(checkMButton) && checkMButton.HasOwnProp("T")) ? "T" LTrim(String(checkMButton.T), "T") : "T0.1"
            if KeyWait("MButton", timeoutVal " D")
                return
        }
        SendInput(KSA.shuttleStop)
        sleep 25
        premUIA := premUIA_Values()
        try premEl := prem.__createUIAelement(false)

        switch window {
            ;// If you ever use the multi camera view, the current method of doing things is required as otherwise there is a potential for premiere to get stuck within a multicam nest for whatever reason. Doing it this way however, is unfortunately slower.
            ;// hopefully one day adobe fixes this bug @link https://community.adobe.com/t5/premiere-pro-bugs/next-previous-edit-point-on-any-track-gets-stuck-in-multi-camera-view/idi-p/15250392#M48002
            ;// if you do not use the multiview window simply replace the below line with `this.__checkTimelineFocus()` or `premEl.AdobeEl.ElementFromPath(premUIA.timeline).SetFocus()`
            case ksa.timelineWindow:
                try {
                    premEl.AdobeEl.ElementFromPath(premUIA.effectsControl).SetFocus()
                    premEl.AdobeEl.ElementFromPath(premUIA.timeline).SetFocus()
                } catch {
                    SendEvent(ksa.effectControls)
                    Sleep(50)
                    this.__checkTimelineFocus()
                }
            case ksa.effectControls:
                try {
                    premEl.AdobeEl.ElementFromPath(premUIA.effectsControl).SetFocus()
                    Sleep(25)
                    premEl.AdobeEl.ElementFromPath(premUIA.programMonitor).SetFocus()
                    Sleep(25)
                    premEl.AdobeEl.ElementFromPath(premUIA.effectsControl).SetFocus()
                    delaySI(20, "^a", ksa.deselectAll)
                }
                catch {
                    delaySI(20, window, ksa.programMonitor, window, "^a", ksa.deselectAll) ;// indicates the user is trying to use `Select previous/next Keyframe`
                }
            default: SendInput(window) ;focuses the timeline/desired window
        }
        SendInput(direction)
        switch keyswait {
            case "second": keys.allWait("second")
            case "first":  keys.allWait("first")
            default:       keys.allWait() ;prevents hotkey spam
        }
    }

    /** checks to see if there are any clips selected */
    static checkNoClips(UIA_obj, &x, &y) {
        if ImageSearch(&x, &y, UIA_obj.x, UIA_obj.y, UIA_obj.x + (UIA_obj.width/KSA.ECDivide), UIA_obj.y + UIA_obj.height, "*2 " ptf.Premiere "noclips.png") {
            SendInput(KSA.selectAtPlayhead)
            sleep 50
            ;// checks for no clips again incase it has attempted to select 2 separate audio/video tracks
            if ImageSearch(&x, &y, UIA_obj.x, UIA_obj.y, UIA_obj.x + (UIA_obj.width/KSA.ECDivide), UIA_obj.y + UIA_obj.height, "*2 " ptf.Premiere "noclips.png")
                return false
        }
        return true
    }

    /**
     * This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
     */
    static movepreview()
    {
        coord.client()
        block.On()
        MouseGetPos(&xpos, &ypos)
        premUIA := premUIA_Values()
        if !effCtrlNN := this.__uiaCtrlPos(premUIA.effectsControl,,, false) {
            block.Off()
            return
        }
        this.__checkTimelineFocus() ;focuses the timeline
        sleep 25
        if !this.checkNoClips(effCtrlNN, &x, &y) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            return
        }
        motionPos := {x: effCtrlNN.x+57, y: effCtrlNN.y+62}
        MouseMove(motionPos.x + 25, motionPos.y+5)
        SendInput("{Click}")
        sleep 50
        ToolTip("")
        ;// gets the state of the hotkey, enough time now has passed that if the user just presses the button, you can assume they want to reset the paramater instead of edit it
        if !GetKeyState(A_ThisHotkey, "P") {
            this.reset()
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
                if check != 0x232323 && check != 0x000000 {
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
                            this.disableDirectManip()
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
        getMouse := obj.MousePos()
        this.disableDirectManip()
        MouseMove(getMouse.x, getMouse.y, 2)
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
        if !this.checkNoClips(effCtrlNN, &x, &y) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            return
        }
        MouseGetPos(&xpos, &ypos)
        motionPos := {x: effCtrlNN.x+57, y: effCtrlNN.y+62}
        if !ImageSearch(&xcol, &ycol, motionPos.x, motionPos.y-20, motionPos.x+700, motionPos.y+20, "*2 " ptf.Premiere "reset.png") {
            block.Off()
            errorLog(Error("Could not find reset image", -1),, 1)
            return
        }
        MouseMove(xcol+2, ycol+2)
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
        if !this.checkNoClips(effCtrlNN, &x, &y) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            return
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

    /**
     * This function once bound to <kbd>NumpadMult::</kbd>/<kbd>NumpadAdd::</kbd> allows the user to quickly adjust the gain of a selected track by simply pressing <kbd>NumpadSub</kbd>/<kbd>NumpadAdd</kbd> then their desired value followed by <kbd>NumpadEnter</kbd>. Alternatively, if the user presses <kbd>NumpadMult</kbd> after pressing the activation hotkey, the audio `level` will be changed to the desired value instead (however the user needs `PremiereRemote` installed for this feature to work)
     * @param {String} [which=A_ThisHotkey] whether the user wishes to add or subtract the desired value. If the user is using either <kbd>NumpadSub</kbd>/<kbd>NumpadAdd</kbd> or <kbd>-</kbd>/<kbd>+</kbd> as the activation hotkey this value can be left blank, otherwise the user should set it as either <kbd>-</kbd>/<kbd>+</kbd>
     * @param {String} [sendOnFail="{" A_ThisHotkey "}"] what the function will send to `SendInput` in the event that the timeline isn't the active panel
     */
    static numpadGain(which := A_ThisHotkey, sendOnFail := "{" A_ThisHotkey "}") {
        which := LTrim(which, "~")
        which := (which = "NumpadSub") ? "-" : ""

        ;// check to see if the user is typing
        if CaretGetPos(&carx, &cary) {
            SendInput(sendOnFail)
            return
        }

        if this.timelineVals = false {
            this.__checkTimeline()
            return
        }
        needsTimelineFocus := false
		title := WinGet.Title(, false)
        descernTitle := (title = "Audio Gain" || title = "") ? true : false
        currTimelineStatus := this.timelineFocusStatus()

        ;// because getting the UIA element of the active window is slow, we need to start an initial inputhook here for the sole purpose
        ;// of check whether * is pressed, otherwise it may end up missed while waiting
        ;// this does however mean we nean to manually stop this input hook or the user may lose control
        star_ih := InputHook()
        star_ih.Start()

        ;// logic to determine whether to send the fail hotkey and alert the user, or continue as expected
		if descernTitle || currTimelineStatus != 1 {
            premUIA    := premUIA_Values()
            createEl   := this.__createUIAelement(true)
            toolsNN    := this.__uiaCtrlPos(premUIA.tools, false, createEl, false)
            textStatus := ImageSearch(&xx, &yy, toolsNN.x+200, toolsNN.y, toolsNN.x+200 + 200, toolsNN.y + toolsNN.height, "*2 " ptf.Premiere "text.png")

            switch {
                case (!descernTitle && currTimelineStatus != 1) && (textStatus = false):
                    if createEl.activeElement !== premUIA.effectsControl {
                        star_ih.Stop()
                        SendInput(sendOnFail star_ih.Input)
                        tool.Cust("If you are attempting to adjust audio;`nThe timeline is not currently in focus", 2000)
                        return
                    }
                    needsTimelineFocus := true
                default:
                    star_ih.Stop()
                    SendInput(sendOnFail star_ih.Input)
                    return
            }
		}

        ih := InputHook("L5 T4", "{NumpadEnter}")
        ih.Start()
        ih.Wait()
        star_ih.Stop()

        starCheck := star_ih.Input
        sendGain  := ih.Input
        sendAsLevel := false
        if star := ((InStr(sendGain, "*") || InStr(starCheck, "*")) ? true : false) || mult := InStr(sendGain, "NumpadMult") {
            sendGain := (star != false) ? StrReplace(sendGain, "*", "") : StrReplace(sendGain, "NumpadMult", "")
            sendAsLevel := true
        }

        ;// removes anything that isn't a digit or `+`/`-`
        sendGain := RegExReplace(sendGain, "[^\d.]")
        if !IsNumber(sendGain) {
            ;// if the user times out, or the regex fails, we want to halt here or you'll end up with a `nan` keyframe in prem
            tool.Cust("A number could not be interpreted from the input keys. Please try again", 2.0)
            return
        }
        block.On()
        ;// otherwise we proceed
        if needsTimelineFocus = true
            this.__checkTimelineFocus()
        if !sendAsLevel || !this.__checkPremRemoteDir("changeAudioLevels")
            this.gain(which sendGain)
        else {
            levels := this.__remoteFunc("changeAudioLevels", true, "level=" String(which sendGain))
            if levels != true && levels != "true" {
                errorLog(MethodError("Unexpected response", -1), "Response: " levels " - Type: " Type(levels))
                Notify.Show('prem.numpadGain()', 'Setting ``level`` keyframe may have encountered an issue.', 'C:\Windows\System32\imageres.dll|icon80', 'Speech Misrecognition', , 'dur=5 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red')
                block.Off()
                return
            }
        }
        block.Off()
    }

    /** This function checks the state of an internal variable to determine if the user wishes for the timeline to be specifically focused. If they do, it will then check to see if the timeline is already focused by calling `prem.timelineFocusStatus()` */
	static __checkTimelineFocus() {
        check := this.timelineFocusStatus()
        if check != false
            return
        sleep 1
        SendEvent(KSA.timelineWindow)
        sleep 25
	}

    /**
     * ### This function contains `KSA` values that need to be set correctly, Most notibly `DragKeywait` needs to be set to the same key you use to ACTIVATE the function.
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
            status := this.timelineFocusStatus()
            if status != true {
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

    static __checkAlwaysUIA() {
        UserSettings := UserPref()
        if UserSettings.Always_Check_UIA = true {
            if UserSettings.Set_UIA_Limit_Daily = true && UserSettings.UIA_Daily_Limit_Day = A_YDay
                return
            premUIA_Values(false).__setNewVal()
            UserSettings.UIA_Daily_Limit_Day := A_YDay
            UserSettings.__delAll()
            UserSettings := ""
        }
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
        UserSettings := UserPref()
        mainScriptName := UserSettings.mainScriptName
        UserSettings.__delAll()
        UserSettings := ""
        orig := detect()
        resetOrig(obj) => (A_DetectHiddenWindows := obj.Windows, A_TitleMatchMode := obj.Title)

        ;// this block is called if the function originates from a script that isn't `UserSettings.mainScriptName`
        if A_ScriptName != mainScriptName ".ahk" && WinExist(mainScriptName ".ahk") {
            try {
                activeObj := ComObjActive("{0A2B6915-DEEE-4BF4-ACF4-F1AF9CDC5468}")
                if activeObj.__checkTimelineValues() {
                    coord.client()
                    this.timelineRawX     := activeObj.timelineRawX,     this.timelineRawY     := activeObj.timelineRawY
                    this.timelineXValue   := activeObj.timelineXValue,   this.timelineYValue   := activeObj.timelineYValue
                    this.timelineXControl := activeObj.timelineXControl, this.timelineYControl := activeObj.timelineYControl
                    this.timelineVals     := true
                    return true
                }
            } catch {
                resetOrig(orig)
                Notify.Show(, "Failed to interact with ComObj, it may not be initialised yet.`nTry again soon.",,,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
                keys.allWait()
                Exit()
            }
        }
        resetOrig(orig)

        this.__checkAlwaysUIA()
        premUIA := premUIA_Values()
        if !timelineNN := this.__uiaCtrlPos(premUIA.timeline,,, false)
            return false

        ;// determine how much to account for the column left of the timeline based on premiere version
        xAddMap := Map("lessThan" this.spectrumUI_Version, 236, this.spectrumUI_Version, 204,
                        "default", 206)
        switch {
            case (VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0) && !(VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0): xAdd := xAddMap["lessThan" this.spectrumUI_Version]
            case xAddMap.Has(this.currentSetVer): xAdd := xAddMap[this.currentSetVer]
            default: xAdd := xAddMap["default"]
        }
        this.timelineRawX     := timelineNN.x, this.timelineRawY := timelineNN.y
        this.timelineXValue   := timelineNN.x + timelineNN.width - 22  ;accounting for the scroll bars on the right side of the timeline
        this.timelineYValue   := timelineNN.y + 46                     ;accounting for the area at the top of the timeline that you can drag to move the playhead
        this.timelineXControl := timelineNN.x + xAdd                   ;accounting for the column to the left of the timeline
        this.timelineYControl := timelineNN.y + timelineNN.height - 25 ;accounting for the scroll bars at the bottom of the timeline
        this.timelineVals     := true
        if tools = true {
            Notify.Show(,"
            (
                prem.getTimeline() found the coordinates of the timeline. This function will not check coordinates again until a script refresh.
                If this script grabbed the wrong coordinates, refresh and try again! If this script fails to function correctly, recheck your
                Prem_UIA coords before refreshing the script and trying again!
            )",,,, 'POS=BC DUR=6 MALI=CENTER BC=242424 show=Fade@250 hide=Fade@250')
        }
        return true
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
		if !this.__checkTimelineValues() {
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
        if !playhead := this.searchPlayhead({x1: this.timelineXValue, y1: origMouse.y, x2: this.timelineXControl, y2: origMouse.y}) {
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
            ListLines(0)
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
        usePremRemote := false
        if !this.__checkPremRemoteDir('getProxyToggle') || !this.__checkPremRemoteFunc('setProxies') {
            if proxSrch := obj.imgSrchMulti({x1: progMonNN.x, y1: progMonNN.y/2, x2: progMonNN.x+progMonNN.width, y2: progMonNN.y+progMonNN.height+50},, &proxX, &proxY, ptf.Premiere "\proxy_on.png", ptf.Premiere "\proxy_on2.png") {
                __clickProx(proxX, proxY)
            }
        } else {
            usePremRemote := true
            getState := this.__remoteFunc("getProxyToggle", true)
            if getState = true || getState = "1"
                this.__remoteFunc("setProxies",, "toggle=0")
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
            if !usePremRemote {
                if !proxSrch {
                    block.Off()
                    return
                }
                __clickProx(proxX, proxY)
            }
            else
                this.__remoteFunc("setProxies",, "toggle=1")
            block.Off()
            return
        }
        SendEvent("{Enter}")
        if !WinWaitClose(scrshtTitle,, 10) {
            block.Off()
            return
        }
        sleep 50
        if !usePremRemote {
            if !proxSrch {
                block.Off()
                return
            }
            __clickProx(proxX, proxY)
        }
        else
            this.__remoteFunc("setProxies",, "toggle=1")
        block.Off()
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

    /**
     * This function is mostly designed for my own workflow and isn't really built out with an incredible amount of logic.
     *
     * This function was originally designed to swap the L/R channel on a single track stereo file but may also function on a dual track stereo file where you're expecting both the L & R channels to use the same media source channel. attempting to use this script on anything else will either produce unintended results or will simply not function at all
     * @param {Integer} [mouseSpeed=2] what speed the mouse should move to interact with the Modify Clip window
     * @param {Number} [adjustGain=false] determine whether to adjust gain after modifying the channels. It should be noted once again that this function is specifically designed for my workflow - if it swaps to the R channel it will increase gain by this parameter, if it swaps to the left it wil take away this parameter
     * @param {String} [changeLabel?] leave unset if you do not wish to change the label colour of the selected clip(s), otherwise provide the hotkey required to change to the desired colour
     */
    static swapChannels(mouseSpeed := 2, adjustGain := false, changeLabel?) {
        block.On()
        clipWinTitle := "Modify Clip"
        coord.s()
        origCoords := obj.MousePos()
        SetDefaultMouseSpeed(mouseSpeed)

        if !WinActive(clipWinTitle) {
            if this.__checkTimelineValues() = true {
                sleep 100
                if !this.__waitForTimeline(3)
                    return
            }
            SendInput(ksa.audioChannels)
            if !WinWait(clipWinTitle,, 3) {
                block.Off()
                errorLog(Error("Timed out waiting for window", -1),, 1)
                return
            }
            sleep 150
        }

        clipWin := obj.WinPos(clipWinTitle)
        __searchChannel(&x, &y, &chan, &clip) => (chan := ImageSearch(&x, &y, clipWin.x, clipWin.y + 150, clipWin.x + 200, clipWin.y + 500, "*2 " ptf.Premiere "channel1.png"), clip := ImageSearch(&x, &y, clipWin.x, clipWin.y + 125, clipWin.x + 200, clipWin.y + 325, "*2 " ptf.Premiere "clip1.png"))
        if !__searchChannel(&x, &y, &chan, &clip) {
            sleep 150
            if !__searchChannel(&x, &y, &chan, &clip) {
                block.Off()
                errorLog(TargetError("Couldn't find channel 1.", -1),, 1)
                return
            }
        }
        left  := obj.imgSrchMulti({x1: x, y1: y - 50, x2: x + 200, y2: y + 50},, &checkX, &checkY, ptf.Premiere "L_unchecked.png", ptf.Premiere "L_unchecked2.png") ? coords := {x: checkX, y: checkY} : false
        right := obj.imgSrchMulti({x1: x+50, y1: y - 50, x2: x + 200, y2: y + 50},, &checkX, &checkY, ptf.Premiere "R_unchecked.png", ptf.Premiere "R_unchecked2.png") ? coords := {x: checkX, y: checkY} : false

        ;// if the file isn't dual channel it might not have two checkboxes and thus `coords` won't be set
        if (!IsSet(coords) || !coords) || (!left && !right) {
            MouseMove(x, y)
            block.Off()
            errorLog(TargetError("Couldn't find unchecked channel.", -1),, true)
            return
        }
        which := (left != 0) ? "L_unchecked.png" : "R_unchecked.png"
        Click(Format("{} {}", coords.x+10, coords.y+30))
        if chan != 0 {
            ;// this block is to correct when L is one channel and R is another
            ;// both should end up the same channel
            if ImageSearch(&rX, &rY, x, y, x+60, y+60, ptf.Premiere "channel_R.png") {
                secLeft := (IsSet(left)) ? obj.imgSrch(ptf.Premiere "channel_unchecked.png", {x1: rX, y1: ry, x2: rX + 200, y2: ry+15}) : false
                secRight := (IsSet(right)) ? obj.imgSrch(ptf.Premiere "channel_unchecked.png", {x1: rX+50, y1: ry, x2: rX + 200, y2: ry+15}) : false
                if !secLeft && !secRight {
                    block.Off()
                    errorLog(TargetError("Couldn't find unchecked channel.", -1),, 1)
                    return
                }
                if which = "R_unchecked.png" && secRight != false || which = "L_unchecked.png" && secLeft != false
                    Click(Format("{} {}", coords.x+10, coords.y+this.secondChannel))
            }
        }

        if !ImageSearch(&okX, &okY, clipWin.x, (clipWin.y + clipWin.height) - 150, clipWin.x + clipWin.width, clipWin.y + clipWin.height, "*2 " ptf.Premiere "channels_ok.png") {
            block.Off()
            errorLog(TargetError("Couldn't find OK button.", -1),, 1)
            return
        }
        MouseMove(okX, okY, 1)
        SendInput("{Click}")
        MouseMove(origCoords.x, origCoords.y, 2)

        if WinExist(clipWinTitle)
            WinWaitClose(clipWinTitle)
        sleep 50

        if adjustGain != false && IsNumber(adjustGain) {
            addOrSub := (left != 0) ? "-" : ""
            this.gain(addOrSub adjustGain)
        }
        if !IsSet(changeLabel) {
            block.Off()
            return
        }
        ; sleep 100
        SendInput(changeLabel)
        block.Off()
    }

    /**
     * A function designed to allow the user to quickly dismiss certain fx windows that otherwise require them to manually dismiss them
     * @param {String} [onFailure="{Escape}"] what the function will send in the event that the active window isn't defined
     */
    static escFxMenu(onFailure := "{Escape}") {
		windows := Map(
			"Clip Fx Editor", true, "Track Fx Editor", true
		)
		activeWin := WinGetTitle("A")
		inList := false
		for k, v in windows {
			if InStr(activeWin, k)
				inList := true
		}
		coord.s()
		mousePos := obj.MousePos()
		winObj   := obj.WinPos(activeWin)
        (inList = true && WinGetTitle("A") == activeWin) ? SendEvent("{Click " ((winObj.x+winObj.width)-19) A_Space winObj.y+16 "}") : (SendInput(onFailure), Exit())
		MouseMove(mousePos.x, mousePos.y)
		sleep 200
		this.__checkTimelineFocus()
	}

    /**
     * Premiere loves to spit stupid warning boxes at you, especially if it has even the smallest issue trying to playback audio. This function will detect that window and automatically click the x button to close the window. This is especially necessary when using other functions of mine like those in `Premiere_RightClick.ahk` as the error window messes with the active window and may confuse those scripts
     */
    static dismissWarning() {
        if (!WinExist("DroverLord - Overlay Window") ||
            GetKeyState("LButton", "P")) ;// can't drag panels unless we check
            return

        block.On()
        coord.s()
        origMouse := obj.MousePos()
        drover    := obj.WinPos("DroverLord - Overlay Window")
        MouseMove((drover.x + drover.width)-15, drover.y+15, 2)
        SendInput("{Click}")
        MouseMove(origMouse.x, origMouse.y, 2)
        block.Off()
    }

    /**
     * A function to quickly drag the audio or video track from the source monitor to the timeline. This is often easier than dealing with insert/override quirkiness.
     * @param {String} [audOrVid="audio"] determine whether you wish to drag the audio or video track. This parameter must be either `"audio"` or `"video"`
     * @param {String} [sendOnFailure=A_ThisHotkey] define what hotkey you want this function to send in the event that the main premiere window isn't the active window. This function will correctly handle any single key activation hotkey - if your activation is more (ie `Ctrl & F19`) you will need to instead define this parameter as `"^{F19}" etc
     * @param {String} [specificFile=false] if set the function will only activate if the desired file is open within the source monitor
     */
    static dragSourceMon(audOrVid := "audio", sendOnFailure := A_ThisHotkey, specificFile := false) {
        if audOrVid != "audio" && audOrVid != "video" {
            ;// throw
            errorLog(PropertyError("Incorrect value in Parameter #1", -1),,, true)
            return
        }
        key := keys.allWait("second")
        if key.HasProp("first") {
            if key.first = "Shift" {
                errorLog(ValueError("``Shift`` cannot be the first activation hotkey.", -1),,, true)
                return
            }
        }
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        try activeWin := WinGetTitle("A")
        if !IsSet(activeWin) || activeWin != getTitle.winTitle {
            if !InStr(A_ThisHotkey, "&")
                try SendInput("{" Format("sc{:X}", GetKeySC(A_ThisHotkey)) "}")
            /* else
                try SendInput(sendOnFailure) */
            return
        }

        if !this.__checkPremRemoteDir("sourceMonName") || !this.__checkPremRemoteFunc("sourceMonName") {
            ;// throw
            errorLog(MethodError("Some PremiereRemote functions are missing.", -1),,, true)
            return
        }
        block.On()
        coord.client()
        origMouse := obj.MousePos()
        if specificFile != false && specificFile != "" {
            getName := this.__remoteFunc("sourceMonName", true)
            if getName != specificFile {
                __exit() {
                    errorLog(TargetError("The requested file: " specificFile "`nisn't open in the Source Monitor", -1),, true)
                    block.Off()
                    Exit()
                }
                if specificFile = "Bars and Tone - Rec 709" {
                    this.__remoteFunc("setBarsAndTone", false)
                    sleep 50
                    recheck := this.__remoteFunc("sourceMonName", true)
                    if recheck != specificFile
                        __exit()
                }
                else
                    __exit()
            }
        }

        premUIA   := premUIA_Values()
        if !sourceMonNN := this.__uiaCtrlPos(premUIA.sourceMon,,, false) {
            block.Off()
            return
        }
        prefixTitle := "sourceMon_"
        found := false
        loop 10 {
            indexNum := (A_Index = 1) ? "" : A_Index
            if !FileExist(ptf.Premiere prefixTitle audOrVid indexNum ".png")
                break
            if !ImageSearch(&sourceX, &sourceY, sourceMonNN.x, sourceMonNN.y+(sourceMonNN.height*0.7), sourceMonNN.x+sourceMonNN.width, sourceMonNN.y+sourceMonNN.height, "*2 " ptf.Premiere prefixTitle audOrVid indexNum ".png")
                continue
            found := true
            break
        }
        if found = false {
            errorLog(TargetError("Image: ``" prefixTitle audOrVid ".png`` not found. Source monitor may not contain a file.", -1),, true)
            block.Off()
            return
        }
        MouseClickDrag("Left", sourceX+4, sourceY+3, origMouse.x, origMouse.y, 1)
        block.Off()
    }

    /**
     * A function to flatten a multicam clip, optionally disable/enable it, then recolour it to a specific label colour.
     * @param {String} colour the hotkey required to set the colour of your choosing. Can be a `KSA` value
     */
    static flattenAndColour(colour) {
        keys.allWait()
        block.On()
        this.__checkTimelineFocus()
        delaySI(100, ksa.flattenMulti, colour)
        block.Off()
    }

    /**
     * A function designed to allow you to quickly adjust the size of the layer the cursor is within. <kbd>LAlt</kbd> **MUST** be one of the activation hotkeys and is required to be held down for the duration of this function.
     */
    static layerSizeAdjust() {
        storeHotkey := A_ThisHotkey
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        if WinGetTitle("A") != getTitle.winTitle
            return
        if !this.timelineFocusStatus()
            return

        if !activationKey := getHotkeys()
            return

        block.On()
        coord.client()
        origMouseCords := obj.MousePos()
        MouseMove(this.timelineRawX+10, origMouseCords.y, 2)
        KeyWait("LAlt", "L")
        MouseMove(origMouseCords.x, origMouseCords.y)
        checkStuck(["LAlt", "CapsLock"])
        if InStr(storeHotkey, "CapsLock") || InStr(storeHotkey, "sc03a")
            SetCapsLockState('AlwaysOff')
        block.Off()
    }

    /**
     * A function to quickly toggle the state of various layer settings for the layer the cursor is within. This funtion uses offset values of the `timelineRawX` value and as such the use of `PremiereUIA` is required.
     * @param {String} [which="target"] defines the button you wish to toggle. Accepted options are; `source`, `target`, `sync`, `mute`, `solo`, `lock`
     */
    static toggleLayerButtons(which := "target") {
        allowedParams := Mip("source", true, "target", true, "sync", true,
            "mute", true, "solo", true, "lock", true)
        if !allowedParams.Has(which) {
            ;// throw
            errorLog(MethodError("Incorrect Value in Parameter #1", -1, which),,, true)
            return
        }
        if (which = "target" || which = "source") && this.toggleWaiting = true
            return
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        if WinGetTitle("A") != getTitle.winTitle
            return

        block.On()
        coord.client()
        origMouseCords := obj.MousePos()

        if !this.timelineFocusStatus() && !this.__checkCoords(origMouseCords) {
            block.Off()
            return
        }

        dividerCheck := PixelGetColor(this.timelineRawX+5, origMouseCords.y)
        if dividerCheck = this.layerDivider {
            Notify.Show(, 'The user is currently hovering between a layer.`nThis function will not continue.', 'C:\Windows\System32\imageres.dll|icon90',,, 'dur=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xC72424')
            block.Off()
            return
        }

        topDiv := PixelSearch(&topDivX, &topDivY, this.timelineRawX+5, origMouseCords.y, this.timelineRawX+5, this.timelineRawY, this.layerDivider)
        botDiv := PixelSearch(&botDivX, &botDivY, this.timelineRawX+5, origMouseCords.y, this.timelineRawX+5, this.timelineYControl, this.layerDivider)
        midDivider := ImageSearch(&midDivX, &midDivY, this.timelineRawX+5, this.timelineRawY, this.timelineRawX+15, this.timelineYControl,  "*2 " ptf.Premiere "divider.png")

        if !topDiv || !botDiv || !midDivider {
            Notify.Show(, 'Could not determine the layer boundaries. Please try again.', 'C:\Windows\System32\imageres.dll|icon90',,, 'dur=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xC72424')
            block.Off()
            return
        }

        doMinusSmall := (which != "lock") ? "15" : "0"
        doMinus := (which != "lock") ? "32" : "0"
        midDivY += 2
        diff := botDivY-topDivY
        switch {
            ;// versions less than 25.2
            case (VerCompare(ptf.premIMGver, "v25.2") < 0) && (which != "lock" || diff <= 54): MouseMove(this.timelineRawX+this.layer%which%, topDivY+7, 1)
            case (VerCompare(ptf.premIMGver, "v25.2") < 0) && (which = "lock" && diff > 54): MouseMove(this.timelineRawX+this.layer%which%, topDivY+((diff/2)-doMinus), 1)

            ;// versions greater than or equal to 25.2
            case (VerCompare(ptf.premIMGver, "v25.2") >= 0):
                switch {
                    case (diff <= 54): MouseMove(this.timelineRawX+this.layer%which%, topDivY+6, 1)
                    case (diff > 54 && diff < 77): MouseMove(this.timelineRawX+this.layer%which%, topDivY+((diff/2)-doMinusSmall), 1)
                    case (diff >= 77): MouseMove(this.timelineRawX+this.layer%which%, topDivY+((diff/2)-doMinus), 1)
                }
        }

        if which = "solo" {
            ;// check to see if the user is hovering over a video track
            ;// we have to do this otherwise if the user spams the solo button, the function will double click the layer and expand it
            newCoords := obj.MousePos()
            if origMouseCords.y < midDivY {
                MouseMove(origMouseCords.x, origMouseCords.y, 1)
                block.Off()
                return
            }
        }
        SendInput("{Click}")
        MouseMove(origMouseCords.x, origMouseCords.y, 1)
        if !(which = "target" || which = "source") {
            block.Off()
            return
        }
        ;// if the user is attempting to change the source/target track we need to delay them
        ;// because premiere will refuse to change the toggle unless the user has stopped trying to change it
        ;// for around 400ms
        ;// the user may still encounter this behaviour if they toggle a different layer button, then immediately attempt
        ;// to toggle the source/target.
        this.toggleWaiting := true
        SetTimer((*) => (block.Off(), this.toggleWaiting := false), -400)
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
                            try Hotkey(k2, "Off")
                        }
                    }
                    try {
                        Hotkey("NumpadDiv", "NumpadDiv")
                    } catch {
                        try Hotkey("NumpadDiv", "Off")
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