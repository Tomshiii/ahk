/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2026/02/02
 * @version 2.2.2
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\ptf.ahk
#Include Classes\winget.ahk
#Include Classes\switchTo.ahk
#Include Classes\errorLog.ahk
#Include Classes\settings.ahk
#Include Classes\Editors\Premiere.ahk
#Include Classes\tool.ahk
#Include Classes\CLSID_Objs.ahk
#Include Functions\checkStuck.ahk
#Include functions\detect.ahk
#Include Other\UIA\UIA.ahk
#Include Other\JSON.ahk
#Include Other\Notify\Notify.ahk
#Include Other\WinEvent.ahk
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
    static __New() {
        try UserSettings := CLSID_Objs.clone("UserSettings")
        catch {
            UserSettings := UserPref(true)
        }
        this.setVer := UserSettings.premVer
        currentPremVer  := StrReplace(UserSettings.premVer, ".", "_")
        try this.allVals := JSON.parse(FileRead(this.valueINI),, false)
        catch {
            block.Off()
            ;// throw
            errorLog(Error("Parsing JSON Data Failed"),,, true)
        }
        this.currentVer := currentPremVer
        this.baseVer    := SubStr(this.currentVer, 1, InStr(this.currentVer, "_",, 1, 1)-1)

        if A_ScriptName = "Core Functionality.ahk" {
            return
        }
    }

    static valueINI   := ptf.SupportFiles "\UIA\values.ini"
    static currentVer := false
    static setVer     := false
    static allValls   := false
    static baseVer    := false
    static currentPremVer := ""
    static beenSet    := false

    static windowHotkeys := Map(
        "effectsControl",   ksa.effectControls,
        "effectsPanel",     ksa.effectsWindow,
        "programMon",       ksa.programMonitor,
        "sourceMon",        ksa.sourceMonitor,
        "timeline",         ksa.timelineWindow,
        "tools",            ksa.toolsWindow,
        "project",          ksa.projectsWindow
    )
    static successCount := 0
    static initialise(doChecks := true, override := false) {
        if ((!doChecks && override = false) || !this.beenSet || (override = true)) {
            this.__setNewVal()
            block.Off()
            return
        }

        if !this.allVals.HasOwnProp(this.currentVer) && !this.allVals.HasOwnProp(this.baseVer) {
            if WinExist(prem.winTitle) {
                block.On()
                this.__setNewVal()
                checkStuck()
                block.Off()
                return
            }
            block.Off()
            errorLog(UnsetError("Current Version has no values set.", -1),,, true)
            return
        }
    }

    /**
     * This function turns the parsed json data into class variables so the user may call on them as an extension of the class object
     */
    static __setClassVal() {
        if !prem.__checkDialogueClass()
            return
        if !this.allVals.HasOwnProp(this.currentVer) && this.allVals.HasOwnProp(this.baseVer)
            this.currentVer := this.baseVer
        if ObjOwnPropCount(this.allVals.%this.currentVer%) != this.windowHotkeys.Count {
            errorLog(Error("The user is currently missing UIA values. Please set new values to ensure proper function."))
            if !Notify.Exist("UIAmissingVals")
                Notify.Show(, 'The user is currently missing UIA values.`nPlease set new values to ensure proper function.', 'C:\Windows\System32\imageres.dll|icon80', 'Windows Battery Critical',, 'theme=Dark dur=6 bdr=Red maxW=400 tag=UIAmissingVals')
        }
        for k, v in this.allVals.%this.currentVer%.Ownprops() {
            this.%k% := v
        }
    }

    /**
     * This function handles creating new json entries in the `values.ini` files
     */
    static __setNewVal() {
        Critical()
        activeObj := CLSID_Objs.load("uiaCheckRunning")
        if activeObj.HasOwnProp('isRunning') && activeObj.isRunning = true {
            block.Off()
            Critical("Off")
            if !Notify.Exist("UIAisRunning")
                Notify.Show(, "Attempting to set UIA values is already in process.`nPlease wait.",,,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250 tag=UIAisRunning')
            Exit()
        }
        detect(false, 2) ;// incase the user is midreload while attempting to set values
        activeObj.isRunning := true

        if !prem.__checkDialogueClass() {
            block.Off()
            activeObj.isRunning := false
            return
        }

        premName := WinGet.PremName()
        if !premName.winTitle {
            block.Off()
            activeObj.isRunning := false
            errorLog(UnsetError("Couldn't determine Premiere winTitle", -1))
            return
        }
        if prem.__checkPremRemoteDir('premVer') {
            try {
                premVerVal := prem.__remoteFunc('premVer', true)
                if !premVerVal
                    throw
                appVer := "v" premVerVal

                if (this.setVer != appVer) && (this.setVer ".0" != appVer) {
                    if !Notify.Exist("UIAwrongVer")
                        Notify.Show(, 'The currently set version of Premiere does not match the application version.`nConsider adjusting the set version in settingsGUI() and then reloading`n`nSet Version: ' this.setVer ".0 || Premiere Version: " appVer, 'C:\Windows\System32\imageres.dll|icon227', 'Windows Notify Messaging',, 'theme=Dark dur=10 bdr=Red maxW=400 tag=UIAwrongVer')
                    block.Off()
                    activeObj.isRunning := false
                    return
                }
            } catch {
                errorLog(MethodError("PremiereRemote server is currently not running correctly, or the incorrect year version is set."), "Try setting the correct version within ``settingsGUI()`` or restarting the server using ``resetNPM.ahk``")
                if !Notify.Exist("RemoteServer") {
                    Notify.Show(, 'PremiereRemote server is currently not running correctly,`nor the incorrect year version is set.`nTry setting the correct version within ``settingsGUI()`` or restarting the server using ``resetNPM.ahk``', 'C:\Windows\System32\imageres.dll|icon94',,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250 MALI=Center tag=RemoteServer maxw=500')
                }
                block.Off()
                activeObj.isRunning := false
                return
            }
        }
        ; WinEvent.Exist((*) => (prem.dismissWarning(), switchTo.Premiere(), sleep(250)), "DroverLord - Overlay Window ahk_class DroverLord - Window Class")

        AdobeEl  := UIA.ElementFromHandle(premName.winTitle A_Space prem.winTitle,, false)
        try {
            currentVers  := JSON.parse(FileRead(ptf.SupportFiles "\UIA\values.ini"),, false)
            originalVers := JSON.stringify(currentVers)
        } catch {
            block.Off()
            activeObj.isRunning := false
            ;// throw
            errorLog(Error("Parsing JSON Data Failed"),,, true)
        }

        if !WinActive(prem.winTitle)
            switchTo.Premiere()

        block.On()
        ;// we need to ensure playback here is halted, otherwise UIA is SUPER unresponsive
        ;// and for whatever reason known only to the adobe devs some hotkeys no longer function globally
        ;// if they contain any modifiers, so we have to do a check here to see if the user has any in their set hotkey
        if !InStr(ksa.shuttleStop, "+") && !InStr(ksa.shuttleStop, "^") && !InStr(ksa.shuttleStop, "!") && !InStr(ksa.shuttleStop, "Ctrl") && !InStr(ksa.shuttleStop, "Shift") && !InStr(ksa.shuttleStop, "Alt") {
            SendInput(ksa.shuttleStop)
        } else {
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
                block.off()
                activeObj.isRunning := false
                errorLog(Error("UIA Values could not be determined. Please try again later"))
                if !Notify.Exist("UIAnotDetermined")
                    Notify.Show(, "UIA Values could not be determined. Please try again later", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=BR DUR=6 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400 tag=UIAnotDetermined')
                return
            }
        }

        if !currentVers.HasOwnProp(this.currentVer) {
            currentVers.%this.currentVer% := {}
            for currentPanel in this.windowHotkeys {
                currentVers.%this.currentVer%.%currentPanel% := {}
            }
        }

        if !Notify.Exist("UIAattemptControls")
            attemptNotify := Notify.Show(, 'Attempting to retrive Premiere UIA Coordinates`nInputs will be temporarily disabled', 'C:\Windows\System32\imageres.dll|icon169',,, 'dur=3 mali=Center show=Fade@250 hide=Fade@250 maxW=400 bdr=0xDCCC75 tag=UIAattemptControls')

        checkDupes := Map()
        hasDupes   := false
        for currentPanel, currHotkey in this.windowHotkeys {
            if WinExist("Save Project " prem.winTitle) {
                block.Off()
                activeObj.isRunning := false
                if !Notify.Exist("UIAfailedControls")
                    Notify.Show('Error Setting Control', 'Some controls may have failed to be set!`nPlease reload and try again or you may encounter errors', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Message Nudge',, 'theme=Chestnut show=Fade@250 hide=Fade@250 maxW=400 tag=UIAfailedControls')
                errorLog(TargetError("Premiere save window is currently open. Aborting", -1))
                return
            }
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
                        block.Off()
                        activeObj.isRunning := false
                        errorLog(Error("UIA Values could not be determined. Please try again later"))
                        try Notify.Destroy(attemptNotify['hwnd'])
                        if !Notify.Exist("UIAnotDetermined")
                            Notify.Show(, "UIA Values could not be determined. Please try again later", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=BR DUR=6 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400 tag=UIAnotDetermined')
                        return
                    }
                }
            }
            if !IsSet(currentEl) {
                block.Off()
                activeObj.isRunning := false
                errorLog(Error("UIA Values could not be determined. Please try again later"))
                try Notify.Destroy(attemptNotify['hwnd'])
                if !Notify.Exist("UIAnotDetermined")
                    Notify.Show(, "UIA Values could not be determined. Please try again later", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=BR DUR=6 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400 tag=UIAnotDetermined')
                return
            }
            if checkDupes.Has(currentEl) {
                hasDupes := true
            }
            checkDupes.Set(currentEl, true)
            currentVers.%this.currentVer%.%currentPanel% := currentEl
            this.successCount += 1
        }
        if hasDupes = true {
            errorLog(Error("The function may have set duplicate UIA values. Please set new values to ensure proper function."))
            if !Notify.Exist("UIAhasDupes")
                Notify.Show(, 'The function may have set duplicate UIA values.`nPlease set new values to ensure proper function.', 'C:\Windows\System32\imageres.dll|icon80', 'Windows Battery Critical',, 'theme=Dark dur=6 bdr=Red maxW=400 tag=UIAhasDupes')
        }
        checkStuck(["XButton1", "XButton2", "Ctrl", "Shift", "Alt", "RButton", "LButton"])
        block.Off()
        this.allVals := currentVers
        this.__setClassVal()
        if !Notify.Exist("UIAnoEffect")
            Notify.Show(, "This process may have no effect until all scripts are reloaded!", A_WinDir '\system32\shell32.dll|Icon28',,, 'POS=TC DUR=3 MALI=CENTER IW=25 BC=7A3030 show=Fade@250 hide=Fade@250 maxW=400 tag=UIAnoEffect')
        if this.successCount != this.windowHotkeys.Count {
            if !Notify.Exist("UIADupes")
                Notify.Show('Error Setting Control', 'Some controls may have failed to be set!`nPlease reload and try again or you may encounter errors', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Message Nudge',, 'theme=Chestnut show=Fade@250 hide=Fade@250 maxW=400 tag=UIADupes')
        }
        this.successCount := 0
        this.beenSet := true
        if JSON.stringify(currentVers) == originalVers {
            activeObj.isRunning := false
            return
        }

        if !DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        tempPath := A_Temp "\tomshi\json_values.ini"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(JSON.stringify(currentVers), tempPath)
        try FileMove(tempPath, this.valueINI, true)
        activeObj.isRunning := false
    }

    __Delete() {
        block.Off()
        activeObj := CLSID_Objs.load("uiaCheckRunning")
        activeObj.isRunning := false

        premVals := CLSID_Objs.load("premUIA_Values")
        premVals.beenSet := false
    }
}