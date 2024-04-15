/************************************************************************
 * @description A class to facilitate using UIA variables with Premiere Pro
 * @author tomshi
 * @date 2024/04/15
 * @version 2.0.3
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\winget>
#Include <Classes\switchTo>
#Include <Classes\errorLog>
#Include <Classes\settings>
#Include <Other\UIA\UIA>
#Include <Other\JSON>
; }

;// [Table of Contents]
;//!
/**
timeline              - The timeline panel
effectsControl        - The effects control panel
tools                 - The tools panel
programMonitor        - The Program monitor panel
effectsPanel          - The Effects panel
*/

Class premUIA_Values {
    __New(doChecks := true) {
        UserSettings    := UserPref()
        currentPremVer  := StrReplace(UserSettings.premVer, ".", "_")
        UserSettings    := ""
        this.allVals    := JSON.parse(FileRead(this.valueINI),, false)
        this.currentVer := currentPremVer
        this.baseVer    := SubStr(this.currentVer, 1, InStr(this.currentVer, "_",, 1, 1)-1)

        if !doChecks
            return

        if !this.allVals.HasOwnProp(this.currentVer) && !this.allVals.HasOwnProp(this.baseVer) {
            if WinExist(prem.winTitle) {
                block.On()
                this.__setNewVal()
                block.Off()
                return
            }
            errorLog(UnsetError("Current Version has no values set. Please run ``premUIA_Values(false).__setNewVal()``", -1),,, true)
            return
        }
        this.__setClassVal()
    }

    valueINI   := ptf.SupportFiles "\UIA\values.ini"
    currentVer := false
    allValls   := false
    baseVer    := false

    windowHotkeys := Map(
        "effectsControl",   ksa.effectControls,
        "effectsPanel",     ksa.effectsWindow,
        "programMon",       ksa.programMonitor,
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
        UserSettings    := UserPref()
        currentPremVer  := StrReplace(UserSettings.premVer, ".", "_")
        UserSettings    := ""
        premName := WinGet.PremName()
        AdobeEl  := UIA.ElementFromHandle(premName.winTitle A_Space prem.winTitle)
        currentVers := JSON.parse(FileRead(ptf.SupportFiles "\UIA\values.ini"),, false)
        originalVers := JSON.stringify(currentVers)

        if !WinActivate(prem.winTitle)
            switchTo.Premiere()

        if !currentVers.HasOwnProp(currentPremVer) {
            currentVers.%currentPremVer% := {}
            for currentPanel in this.windowHotkeys {
                currentVers.%currentPremVer%.%currentPanel% := {}
            }
        }

        for currentPanel, currHotkey in this.windowHotkeys {
            SendInput(currHotkey)
            sleep 50
            currentEl := AdobeEl.GetUIAPath(UIA.GetFocusedElement())
            currentVers.%currentPremVer%.%currentPanel% := currentEl
        }

        this.allVals := currentVers
        this.__setClassVal()
        tool.Cust("This process may have no effect until all scripts are reloaded!", 3.0)
        if JSON.stringify(currentVers) == originalVers
            return

        if !DirExist(A_Temp "\tomshi")
            DirCreate(A_Temp "\tomshi")
        tempPath := A_Temp "\tomshi\json_values.ini"
        FileAppend(JSON.stringify(currentVers), tempPath)
        try FileMove(tempPath, this.valueINI, true)
    }
}