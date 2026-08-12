/************************************************************************
 * @description my version of the `HotkeylessAHK` file
 * @link https://github.com/sebinside/HotkeylessAHK
 * @author sebinside, tomshi
 * @date 2026/08/04
 * @version 1.1.13
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
#Include Functions\detect.ahk
#Include Functions\checkBool.ahk
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

    addMatchedAdjustmentLayer(adjustmentLayerPath := "_Assets/01_Other/Adjustment Layer", makeSelection := true) => (OtherFuncs.addAdjustLayer(adjustmentLayerPath, makeSelection))
    renderAndReplace(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, handles?, inceff?) => (OtherFuncs.rndrRplcOrg(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, handles?, inceff?))

    closeExplorer() => (ProcessClose("explorer.exe"))
}

;// === any functions/hotkeys that don't really make much sense anywhere else
class OtherFuncs {
    /** calls `prem.renderAndReplace()` then calls the `organiseProj` `PremiereRemote` function. Might not make sense for anyone else with a different prem bin structure */
    static rndrRplcOrg(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, handles?, inceff?) {
        if !prem.renderAndReplace(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path, handles?, inceff?)
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
}
