/************************************************************************
 * @description my version of the `HotkeylessAHK` file
 * @link https://github.com/sebinside/HotkeylessAHK
 * @author sebinside, tomshi
 * @date 2026/08/25
 * @version 1.1.16
 ***********************************************************************/

#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
A_IconTip := "HotkeylessAHK"
; { \\ #Includes
#Include files\lib.ahk
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Editors\Premiere.ahk
#Include Classes\ptf.ahk
#Include Classes\switchTo.ahk
#Include Functions\detect.ahk
#Include Functions\checkBool.ahk
#Include Other\UIA\UIA.ahk
#Include GUIs\tomshiBasic.ahk
; }
TraySetIcon(ptf.Icons "\hotkeyless.ico")
; #NoTrayIcon

; HotkeylessAHK by sebinside
; ALL INFORMATION: https://github.com/sebinside/HotkeylessAHK
; Make sure that you have downloaded everything, especially the "/files" folder.
; Make sure that you have Node.js installed and available in the PATH variable.

serverPort := 42800 ; The port that the server will listen on. Make sure that this port is not blocked by your firewall or used by another application.

functionClassNames := ["CustomFunctions", "OtherFuncs"] ; this can be expanded to allow for other function classes, i.e., PersonalFunctions, WorkFunctions and so on. Note that duplicate function names may hide each other as there is no handling for scopes!
; These classes can (of course) be defined in other AHK files and imported using #Include "<path to AHK file>".

debug := false ; set to true to see the console output of the Node.js server. This will also show the console window, which is hidden by default.

SetupServer(serverPort, debug)
RunClient(serverPort, functionClassNames)

; Your custom functions go into the 'CustomFunctions' class.
; You can then call them by using the URL "localhost:<serverPort>/send/<functionName>"
; The function name "kill" is reserved.

Class CustomFunctions {
    changeLabel(label)                                       => (prem.changeLabel(label))
    changeDupe()                                             => (prem.changeDupeFrameMarkers())
    organiseProj()                                           => (prem.__remoteFunc('organiseProj'))
    setMarker(colour)                                        => (prem.__remoteFunc('setMarker',, "colour=" colour))
    removeMarker()                                           => (prem.__remoteFunc('removeMarkerAtPlayhead'))
    moveToAssetBin(folder)                                   => (prem.__remoteFunc('moveToAssetsBin',, 'folderPath=' folder))
    toggleLinearColour(enableMaxRenderQual)                  => (prem.toggleLinearColour(enableMaxRenderQual))
    renderPreviews()                                         => (prem.renderPreviewsInOut())
    deleteAllEmptyTracks()                                   => (prem.deleteEmptyTracks())
    renderSelection(outputPath, presetName, import := true)  => (prem.renderProjectSelection(outputPath, presetName, import))
    setSettings(params := "")                                => (prem.__remoteFunc('setSeqSettings',, "params=" params))
    goToLastProjPanelItem()                                  => (prem.goToLastProjPanelItem())
    setBlendMode(blendModeString)                            => (prem.setBlendMode(blendModeString))
    setAllEnableDisabled(enabled := "true")                  => (prem.__remoteFunc('setAllEnableDisabled',, "enabled=" enabled))
    effectSlot(save := true, slot := 1, saveToFile := false) => (prem.effectSlot(save, slot, saveToFile))
    matchLayers()                                            => (prem.__remoteUXP("custom/matchSelectedClipsToLowestTrack"))

    addMatchedAdjustmentLayer(adjustmentLayerPath := "_Assets/01_Other/Adjustment Layer", makeSelection := true)     => (OtherFuncs.addAdjustLayer(adjustmentLayerPath, makeSelection))
    renderAndReplace(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, timeout, handles?, inceff?) => (OtherFuncs.rndrRplcOrg(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, timeout, handles?, inceff?))
    setupProject()                                           => OtherFuncs.setupProject()
    setupMusicTracks(audioType := "Standard")                => OtherFuncs.setupMusicTracks(audioType)

    closeExplorer() => (ProcessClose("explorer.exe"))
}

;// === any functions/hotkeys that don't really make much sense anywhere else
class OtherFuncs {
    /** calls `prem.renderAndReplace()` then calls the `organiseProj` `PremiereRemote` function. Might not make sense for anyone else with a different prem bin structure */
    static rndrRplcOrg(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, timeout, handles?, inceff?) {
        if !prem.renderAndReplace(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, timeout, handles?, inceff?)
            return
        sleep 1000
        prem.__remoteFunc('organiseProj')
    }

    /** calls premremote func `addMatchedAdjustmentLayer()`. If it's my transform adjust layer, it also adds the transform effect */
    static addAdjustLayer(adjustmentLayerPath, makeSelection) {
        adjustName := SubStr(adjustmentLayerPath, InStr(adjustmentLayerPath, "/",, -1)+1)
        prem.__remoteFunc('addMatchedAdjustmentLayer',, 'adjustmentLayerPath=' adjustmentLayerPath, "makeSelection=" makeSelection)
        if checkBool(makeSelection) != true
            return
        switch adjustName {
            case "_transform_adjust layer": prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Geometry2")
            case "_colour_adjust layer":    prem.__remoteFunc('applyEffectOnAllSelectedClips',, "effectName=Lumetri%20Color")
        }
    }

    /** sets up a project using my template project file and desired bin structure */
    static setupProject() {
        backupsPath := ptf.Backups
        templateFile := backupsPath "\Adobe Backups\Premiere\Template\v" SubStr(prem.currentSetVer, 1, 2) "_2160p29.97.prproj"
        prem.__remoteUXP('custom/setupProjBin',, "templateProjectPath=" templateFile, "includeOptionalAssets=true")
    }

    /**
     * add 5 tracks after the desired track, optionally add 2 submixes
     * @param {String} [audioType="Standard"] which type of audio channel to add. Can be `Standard`/`5.1`/`mono`/`adaptive`
     */
    static setupMusicTracks(audioType := "Standard") {
        audTrackNum := prem.__remoteFunc('getAudioTracks', true)
        selectedTrack := ""
        afterGUI := tomshiBasic(,,, "After Track")
        afterGUI.AddText(, "After which track:")
        dropDownArr := ["None", "Before First Track"]
        loop audTrackNum {
            dropDownArr.Push("After Audio " A_Index)
        }
        afterGUI.AddDropDownList("Choose1 vdropDwn w200", dropDownArr)
        afterGUI.AddButton("x+5 y+-26", "Ok").OnEvent('Click', __okButt)
        closed := false
        afterGUI.OnEvent("Escape", (*) => (closed := true, afterGUI.Destroy()))
        afterGUI.OnEvent("Close", (*) => (closed := true, afterGUI.Destroy()))
        __okButt(*) {
            selectedTrack := afterGUI["dropDwn"].Text
            afterGUI.Destroy()
        }
        afterGUI.show()
        WinWaitClose("After Track")
        if closed = true
            return
        subMixes := MsgBox("Add submixes?",, 0x4)
        if !WinWaitActive(prem.winTitle,, 1) {
            switchTo.Premiere()
            if !WinWaitActive(prem.winTitle,, 5)
                return
        }
        if selectedTrack = "None" && subMixes = "no"
            return
        SendInput(ksa.premAddTracks)
        WinWait("Add Tracks")
        tracksUIA := UIA.ElementFromHandle("Add Tracks " prem.exeTitle,, false)
        __openEditText(uiaObj, name, value) {
            try {
                edit := uiaObj.FindElement({Type:50004, Name: name})
                edit.select()
                text := uiaObj.FindElement({Type:50004, Name: "OS_EditText" })
                actualText := text.FindElement({Type:50004, Name: name})
                actualText.value := value
            }
        }
        __openEditText(tracksUIA, "videoTracksCountHotTextNumber", 0)
        __openEditText(tracksUIA, "audioTracksCountHotTextNumber", 5)
        if subMixes = "yes"
            __openEditText(tracksUIA, "audioSubmixTracksCountHotTextNumber", 2)

        try {
            groups := tracksUIA.FindElements({Type:50026}, 4)
            ;// order; vid, aud, submix
            for i, group in groups {
                if i = 1
                    continue
                if i = 2 && selectedTrack != "None" {
                    audBoxes := group.FindElements({Type:50003})
                    listItem := audBoxes[1].FindElement({Type:50007, Name: selectedTrack})
                    listItem.select()
                    trackType := audBoxes[2].FindElement({Type:50007, Name: audioType})
                    trackType.select()
                }
                if i = 3 && subMixes = "yes" {
                    subBoxes := group.FindElements({Type:50003})
                    placement := subBoxes[1].FindElement({Type:50007, Name: "Before First Track"})
                    placement.select()
                    trackType := subBoxes[2].FindElement({Type:50007, Name: "Stereo"})
                    trackType.select()
                }
            }

            okButt := tracksUIA.FindElement({Type:50000, Name: "OK"})
            okButt.Invoke()
        }
    }
}
