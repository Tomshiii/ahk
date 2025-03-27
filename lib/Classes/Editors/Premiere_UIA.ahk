/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2025/03/27
 * @version 2.0.15
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Classes\errorLog>
#Include <Classes\settings>
#Include <Functions\checkStuck>
#Include <Other\UIA\UIA>
#Include <Other\JSON>
#Include <Other\Notify\Notify>
#Include <Other\WinEvent>
; }

;// [Table of Contents]
;//!
/**
timeline              - The timeline panel
effectsControl        - The effects control panel
tools                 - The tools panel
programMonitor        - The Program monitor panel
sourceMonitor         - The Source monitor panel
effectsPanel          - The Effects panel
*/

Class premUIA_Values {
    __New(doChecks := true) {
        try this.activeObj := ComObjActive("{dcee88ec-9327-44cf-9d2a-5bc47c624e0e}")
        UserSettings := UserPref()
        this.mainScriptName := UserSettings.mainScriptName
        currentPremVer  := StrReplace(UserSettings.premVer, ".", "_")
        UserSettings    := ""
        try this.allVals := JSON.parse(FileRead(this.valueINI),, false)
        catch {
            ;// throw
            errorLog(Error("Parsing JSON Data Failed"),,, true)
        }
        this.currentVer := currentPremVer
        this.baseVer    := SubStr(this.currentVer, 1, InStr(this.currentVer, "_",, 1, 1)-1)

        if !doChecks
            return

        if !this.allVals.HasOwnProp(this.currentVer) && !this.allVals.HasOwnProp(this.baseVer) {
            if WinExist(prem.winTitle) {
                block.On()
                this.__setNewVal()
                checkStuck()
                block.Off()
                return
            }
            errorLog(UnsetError("Current Version has no values set. Please run ``premUIA_Values(false).__setNewVal()``", -1),,, true)
            return
        }
        this.__setClassVal()
        checkStuck()
    }

    valueINI   := ptf.SupportFiles "\UIA\values.ini"
    currentVer := false
    allValls   := false
    baseVer    := false
    activeObj  := {}
    mainScriptName := ""
    currentPremVer := ""

    windowHotkeys := Map(
        "effectsControl",   ksa.effectControls,
        "effectsPanel",     ksa.effectsWindow,
        "programMon",       ksa.programMonitor,
        "sourceMon",        ksa.sourceMonitor,
        "timeline",         ksa.timelineWindow,
        "tools",            ksa.toolsWindow,
        "project",          ksa.projectsWindow
    )

    /**
     * This function turns the parsed json data into class variables so the user may call on them as an extension of the class object
     */
    __setClassVal() {
        if !this.allVals.HasOwnProp(this.currentVer) && this.allVals.HasOwnProp(this.baseVer)
            this.currentVer := this.baseVer
        if ObjOwnPropCount(this.allVals.%this.currentVer%) != this.windowHotkeys.Count {
            errorLog(Error("The user is currently missing UIA values. Please set new values to ensure proper function."),, true)
        }
        for k, v in this.allVals.%this.currentVer%.Ownprops() {
            this.%k% := v
        }
    }

    /**
     * This function handles creating new json entries in the `values.ini` files
     */
    __setNewVal() {
        if this.activeObj.HasOwnProp('isRunning') && this.activeObj.isRunning = true {
            Notify.Show(, "Attempting to set UIA values is already in process.`nPlease wait.",,,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
            Exit()
        }
        this.activeObj.isRunning := true

        premName := WinGet.PremName()
        ; WinEvent.Exist((*) => (prem.dismissWarning(), switchTo.Premiere(), sleep(250)), "DroverLord - Overlay Window ahk_class DroverLord - Window Class")

        AdobeEl  := UIA.ElementFromHandle(premName.winTitle A_Space prem.winTitle)
        try {
            currentVers  := JSON.parse(FileRead(ptf.SupportFiles "\UIA\values.ini"),, false)
            originalVers := JSON.stringify(currentVers)
        } catch {
            this.activeObj.isRunning := false
            ;// throw
            errorLog(Error("Parsing JSON Data Failed"),,, true)
        }

        if !WinActivate(prem.winTitle)
            switchTo.Premiere()

        block.On()
        ;// we need to ensure playback here is halted, otherwise UIA is SUPER unresponsive
        ;// and for whatever reason known only to the adobe devs some hotkeys no longer function globally
        ;// if they contain any modifiers, so we have to do a check here to see if the user has any in their set hotkey
        if !InStr(ksa.shuttleStop, "+") && !InStr(ksa.shuttleStop, "^") && !InStr(ksa.shuttleStop, "!") && !InStr(ksa.shuttleStop, "Ctrl") && !InStr(ksa.shuttleStop, "Shift") && !InStr(ksa.shuttleStop, "Alt")
            SendInput(ksa.shuttleStop)
        else {
            try {
                delaySI(80, this.windowHotkeys["effectsControl"], this.windowHotkeys["programMon"])
                sleep 150
                currentEl := AdobeEl.GetUIAPath(UIA.GetFocusedElement())
                progMon := prem.__uiaCtrlPos(currentEl,,, false)
                programMonX1 := progMon.x+100, programMonX2 := progMon.x + progMon.width-100, programMonY1 := (progMon.y+progMon.height)*0.7,  programMonY2 := progMon.y + progMon.height + 150

                if ImageSearch(&x, &y, programMonX1, programMonY1, programMonX2, programMonY2, "*2 " ptf.Premiere "stop.png") {
                    Click(, x, y)
                    sleep 150
                }
            } catch {
                this.activeObj.isRunning := false
                block.off()
                errorLog(Error("UIA Values could not be determined. Please try again later"))
                Notify.Show(, "UIA Values could not be determined. Please try again later", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=BR DUR=3 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400')
                return
            }
        }

        if !currentVers.HasOwnProp(this.currentVer) {
            currentVers.%this.currentVer% := {}
            for currentPanel in this.windowHotkeys {
                currentVers.%this.currentVer%.%currentPanel% := {}
            }
        }

        attemptNotify := Notify.Show(, 'Attempting to retrive Premiere UIA Coordinates`nInputs will be temporarily disabled', 'C:\Windows\System32\imageres.dll|icon169',,, 'dur=3 mali=Center show=Fade@250 hide=Fade@250 maxW=400 bdr=0xDCCC75')
        tool.Cust("Attempting to retrive Premiere UIA Coordinates`nInputs will be temporarily disabled", 3.0,,, 9)
        for currentPanel, currHotkey in this.windowHotkeys {
            SendInput(currHotkey)
            sleep 50
            try currentEl := AdobeEl.GetUIAPath(UIA.GetFocusedElement())
            catch {
                if WinExist("DroverLord - Overlay Window ahk_class DroverLord - Window Class") {
                    prem.dismissWarning()
                    switchTo.Premiere()
                    if currentPanel != "timeline"
                        SendInput(currHotkey)
                    else
                        delaySI(50, this.windowHotkeys["effectsControl"], currHotkey) ;// if timeline is already active, it'll swap sequences which is annoying
                    sleep 50
                    try currentEl := AdobeEl.GetUIAPath(UIA.GetFocusedElement())
                    catch {
                        this.activeObj.isRunning := false
                        block.Off()
                        errorLog(Error("UIA Values could not be determined. Please try again later"))
                        Notify.Destroy(attemptNotify['hwnd'])
                        Notify.Show(, "UIA Values could not be determined. Please try again later", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=BR DUR=6 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400')
                        return
                    }
                }
            }
            currentVers.%this.currentVer%.%currentPanel% := currentEl
        }
        block.Off()
        this.allVals := currentVers
        this.__setClassVal()
        ; tool.Cust("This process may have no effect until all scripts are reloaded!", 3.0)
        Notify.Show(, "This process may have no effect until all scripts are reloaded!", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=TC DUR=3 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400')
        if JSON.stringify(currentVers) == originalVers
            return

        if !DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        tempPath := A_Temp "\tomshi\json_values.ini"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(JSON.stringify(currentVers), tempPath)
        try FileMove(tempPath, this.valueINI, true)
        this.activeObj.isRunning := false
    }

    __Delete() {
        this.activeObj.isRunning := false
        block.Off()
    }
}