;Adjust the location of your scripts by changing the value below. This folder should be the root folder and with NO trailing backslash

;[Premiere]

;==activate windows==

/**
 * This value will send the keyboard shortcut you have set to scale the frame to the composition size Window within Premiere.

 Can be set within KSA.ahk/ini
 */
scaleFrameSize := IniRead(ptf.files["KSAini"], "Premiere", "Scale frame size")

/**
 * This value will send the keyboard shortcut you have set to activate the Program Monitor Window within Premiere.

 Can be set within KSA.ahk/ini
 */
programMonitor := IniRead(ptf.files["KSAini"], "Premiere", "Program Monitor")

/**
 * This value will send the keyboard shortcut you have set to activate the Effect Controls Window within Premiere.

 Can be set within KSA.ahk/ini
 */
effectControls := IniRead(ptf.files["KSAini"], "Premiere", "Effect Controls")

/**
 * This value will send the keyboard shortcut you have set to activate the Media Browser Window within Premiere.

 Can be set within KSA.ahk/ini
 */
mediaBrowser := IniRead(ptf.files["KSAini"], "Premiere", "Media Browser")

/**
 * This value will send the keyboard shortcut you have set to activate the Projects Window within Premiere.

 Can be set within KSA.ahk/ini
 */
projectsWindow := IniRead(ptf.files["KSAini"], "Premiere", "Projects")

/**
 * This value will send the keyboard shortcut you have set to activate the Effects Window within Premiere.

 Can be set within KSA.ahk/ini
 */
effectsWindow := IniRead(ptf.files["KSAini"], "Premiere", "Effects")

/**
 * This value will send the keyboard shortcut you have set to activate the Tools Window within Premiere.

 Can be set within KSA.ahk/ini
 */
 toolsWindow := IniRead(ptf.files["KSAini"], "Premiere", "Tools")

/**
 * This value will send the keyboard shortcut you have set to activate the timeline Window within Premiere.

 Can be set within KSA.ahk/ini
 */
timelineWindow := IniRead(ptf.files["KSAini"], "Premiere", "Timeline")



;==tools==
/**
 * This value will send the keyboard shortcut you have set to swap to the hand tool within Premiere

 Can be set within KSA.ahk/ini
 */
handPrem := IniRead(ptf.files["KSAini"], "Premiere", "Hand")

/**
 * This value will send the keyboard shortcut you have set to swap to the selection tool within Premiere

 Can be set within KSA.ahk/ini
 */
selectionPrem := IniRead(ptf.files["KSAini"], "Premiere", "Selection")

/**
 * This value will send the keyboard shortcut you have set to swap to the cut tool within Premiere

 Can be set within KSA.ahk/ini
 */
 cutPrem := IniRead(ptf.files["KSAini"], "Premiere", "Cut")


;==other shortcuts==
/**
 * This value will send the keyboard shortcut you have set to select the find box within Premiere

 Can be set within KSA.ahk/ini
 */
findBox := IniRead(ptf.files["KSAini"], "Premiere", "Find Box")

/**
 * This value will send the keyboard shortcut you have set to open the gain menu within Premiere

 Can be set within KSA.ahk/ini
 */
gainAdjust := IniRead(ptf.files["KSAini"], "Premiere", "Gain")

/**
 * This value will send the keyboard shortcut you have set to zoom out of the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
zoomOut := IniRead(ptf.files["KSAini"], "Premiere", "Zoom Out")

/**
 * This value will send the keyboard shortcut you have set to create a new text layer within Premiere

 Can be set within KSA.ahk/ini
 */
newText := IniRead(ptf.files["KSAini"], "Premiere", "New Text Layer")

/**
 * This value will send the keyboard shortcut you have set to go to the next edit point within Premiere

 Can be set within KSA.ahk/ini
 */
nextEditPoint := IniRead(ptf.files["KSAini"], "Premiere", "Next Edit Point")

/**
 * This value will send the keyboard shortcut you have set to go to the previous edit point within Premiere

 Can be set within KSA.ahk/ini
 */
previousEditPoint := IniRead(ptf.files["KSAini"], "Premiere", "Previous Edit Point")

/**
 * This value will send the keyboard shortcut you have set to nudge down clips on the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
nudgeDown := IniRead(ptf.files["KSAini"], "Premiere", "Nudge Clip Down")

/**
 * This value will send the keyboard shortcut you have set to nudge up clips on the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
nudgeUp := IniRead(ptf.files["KSAini"], "Premiere", "Nudge Clip Up")

/**
 * This value will send the keyboard shortcut you have set to select the clip at playhead within Premiere

 Can be set within KSA.ahk/ini
 */
selectAtPlayhead := IniRead(ptf.files["KSAini"], "Premiere", "Select at Playhead")

/**
 * This value will send the keyboard shortcut you have set to deselect all within Premiere

 Can be set within KSA.ahk/ini
 */
deselectAll := IniRead(ptf.files["KSAini"], "Premiere", "Deselect All")

/**
 * This value will send the keyboard shortcut you have set to open the speed menu within Premiere

 Can be set within KSA.ahk/ini
 */
speedMenu := IniRead(ptf.files["KSAini"], "Premiere", "Speed")

/**
 * This value will send the keyboard shortcut you have set to move the playhead to the cursor within Premiere

 Can be set within KSA.ahk/ini
 */
playheadtoCursor := IniRead(ptf.files["KSAini"], "Premiere", "Playhead to Cursor")

/**
 * This value will send the keyboard shortcut you have set to reset the current workspace within Premiere

 Can be set within KSA.ahk/ini
 */
resetWorkspace := IniRead(ptf.files["KSAini"], "Premiere", "reset changes to workspace")

/**
 * This value will send the keyboard shortcut you have set to speedup playback within Premiere

 Can be set within KSA.ahk/ini
 */
speedUpPlayback := IniRead(ptf.files["KSAini"], "Premiere", "speed up playback")

/**
 * This value will send the keyboard shortcut you have set to slow down playback within Premiere

 Can be set within KSA.ahk/ini
 */
slowDownPlayback := IniRead(ptf.files["KSAini"], "Premiere", "slow down playback")

/**
 * This value will send the keyboard shortcut you have set to play/stop playback within Premiere

 Can be set within KSA.ahk/ini
 */
playStop := IniRead(ptf.files["KSAini"], "Premiere", "play/stop")

/**
 * This value will send the keyboard shortcut you have set to open the ingest settings menu within Premiere

 Can be set within KSA.ahk/ini
 */
premIngest := IniRead(ptf.files["KSAini"], "Premiere", "ingest")

/**
 * This value will send the keyboard shortcut you have set to open the ingest settings menu within Premiere

 Can be set within KSA.ahk/ini
 */
shuttleStop := IniRead(ptf.files["KSAini"], "Premiere", "shuttle stop")

;==Labels==
labelViolet := IniRead(ptf.files["KSAini"], "Premiere", "Violet")
labelIris := IniRead(ptf.files["KSAini"], "Premiere", "Iris")
labelCaribbean := IniRead(ptf.files["KSAini"], "Premiere", "Caribbean")
labelLavender := IniRead(ptf.files["KSAini"], "Premiere", "Lavender")
labelCerulean := IniRead(ptf.files["KSAini"], "Premiere", "Cerulean")
labelForest := IniRead(ptf.files["KSAini"], "Premiere", "Forest")
labelRose := IniRead(ptf.files["KSAini"], "Premiere", "Rose")
labelMango := IniRead(ptf.files["KSAini"], "Premiere", "Mango")
labelPurple := IniRead(ptf.files["KSAini"], "Premiere", "Purple")
labelBlue := IniRead(ptf.files["KSAini"], "Premiere", "Blue")
labelTeal := IniRead(ptf.files["KSAini"], "Premiere", "Teal")
labelMagenta := IniRead(ptf.files["KSAini"], "Premiere", "Magenta")
labelTan := IniRead(ptf.files["KSAini"], "Premiere", "Tan")
labelGreen := IniRead(ptf.files["KSAini"], "Premiere", "Green")
labelRed := IniRead(ptf.files["KSAini"], "Premiere", "Red")
labelYellow := IniRead(ptf.files["KSAini"], "Premiere", "Yellow")







;[Photoshop]

;==tools==

/**
 * This value will send the keyboard shortcut you have set to change to the hand tool within Photoshop

 Can be set within KSA.ahk/ini
 */
handTool := IniRead(ptf.files["KSAini"], "Photoshop", "Hand")

/**
 * This value will send the keyboard shortcut you have set to change to the pen tool within Photoshop

 Can be set within KSA.ahk/ini
 */
penTool := IniRead(ptf.files["KSAini"], "Photoshop", "Pen")

/**
 * This value will send the keyboard shortcut you have set to change to the selection tool within Photoshop

 Can be set within KSA.ahk/ini
 */
selectionTool := IniRead(ptf.files["KSAini"], "Photoshop", "Selection")

/**
 * This value will send the keyboard shortcut you have set to change to the zoom tool within Photoshop

 Can be set within KSA.ahk/ini
 */
zoomTool := IniRead(ptf.files["KSAini"], "Photoshop", "Zoom")



;==hotkeys==

/**
 * This value will send the keyboard shortcut you have set to go into free transform within Photoshop

 Can be set within KSA.ahk/ini
 */
freeTransform := IniRead(ptf.files["KSAini"], "Photoshop", "Free Transform")

/**
 * This value will send the keyboard shortcut you have set to open the image size menu within Photoshop

 Can be set within KSA.ahk/ini
 */
imageSize := IniRead(ptf.files["KSAini"], "Photoshop", "Image Size")

/**
 * This value will send the keyboard shortcut you have set to save as copy within Photoshop

 Can be set within KSA.ahk/ini
 */
saveasCopy := IniRead(ptf.files["KSAini"], "Photoshop", "Save As Copy")









;[After Effects]
;==activate windows==

/**
 * This value will send the keyboard shortcut you have set to show/hide the audio panel in Adobe After Effects

 Can be set within KSA.ahk/ini
 */
audioAE := IniRead(ptf.files["KSAini"], "After Effects", "show/hide audio")

/**
 * This value will send the keyboard shortcut you have set to show/hide the effects panel in Adobe After Effects

 Can be set within KSA.ahk/ini
 */
effectsAE := IniRead(ptf.files["KSAini"], "After Effects", "show/hide effects")

;==tools==

/**
 * This value will send the keyboard shortcut you have set to change to the hand tool within After Effects

 Can be set within KSA.ahk/ini
 */
handAE := IniRead(ptf.files["KSAini"], "After Effects", "Hand")

/**
 * This value will send the keyboard shortcut you have set to change to the selection tool within After Effects

 Can be set within KSA.ahk/ini
 */
selectionAE := IniRead(ptf.files["KSAini"], "After Effects", "Selection")



;==hotkeys==

/**
 * This value will send the keyboard shortcut you have set to go the the next keyframe within After Effects

 Can be set within KSA.ahk/ini
 */
nextKeyframe := IniRead(ptf.files["KSAini"], "After Effects", "Next Keyframe")

/**
 * This value will send the keyboard shortcut you have set to go the the previous keyframe within After Effects

 Can be set within KSA.ahk/ini
 */
previousKeyframe := IniRead(ptf.files["KSAini"], "After Effects", "Previous Keyframe")



;==properties==

/**
 * This value will send the keyboard shortcut you have set to open the scale property within After Effects

 Can be set within KSA.ahk/ini
 */
scaleProp := IniRead(ptf.files["KSAini"], "After Effects", "Scale")

/**
 * This value will send the keyboard shortcut you have set to open the position property within After Effects

 Can be set within KSA.ahk/ini
 */
positionProp := IniRead(ptf.files["KSAini"], "After Effects", "Position")

/**
 * This value will send the keyboard shortcut you have set to open the anchor point property within After Effects

 Can be set within KSA.ahk/ini
 */
anchorpointProp := IniRead(ptf.files["KSAini"], "After Effects", "Anchor Point")

/**
 * This value will send the keyboard shortcut you have set to open the opacity property within After Effects

 Can be set within KSA.ahk/ini
 */
opacityProp := IniRead(ptf.files["KSAini"], "After Effects", "Opacity")

/**
 * This value will send the keyboard shortcut you have set to open the rotation property within After Effects

 Can be set within KSA.ahk/ini
 */
rotationProp := IniRead(ptf.files["KSAini"], "After Effects", "Rotation")

;==other==
/**
 * This value will send the keyboard shortcut you have set to open the composition settings within After Effects

 Can be set within KSA.ahk/ini
 */
 compSettings := IniRead(ptf.files["KSAini"], "After Effects", "comp")




;[Resolve]

;==hotkeys==

/**
 * This value will send the keyboard shortcut you have set to select the clip at playhead within Resolve

 Can be set within KSA.ahk/ini
 */
resolveSelectPlayhead := IniRead(ptf.files["KSAini"], "Resolve", "Select at Playhead Resolve")

/**
 * This value will send the keyboard shortcut you have set to deselect the clip at playhead within Resolve

 Can be set within KSA.ahk/ini
 */
resolveDeselect := IniRead(ptf.files["KSAini"], "Resolve", "Deselect all")






;[OBS]

/**
 * This value will send the keyboard shortcut you have set to save a clip from the replay buffer within OBS Studio

 Can be set within KSA.ahk/ini
 */
replayBuffer := IniRead(ptf.files["KSAini"], "OBS", "Replay Buffer")

/**
 * This value will send the keyboard shortcut you have set to save a clip from the Source Record Plugin within OBS Studio

 Can be set within KSA.ahk/ini
 */
sourceRecord1 := IniRead(ptf.files["KSAini"], "OBS", "Source Record 1")

/**
 * This value will send the keyboard shortcut you have set to enable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
enableOBSPreview := IniRead(ptf.files["KSAini"], "OBS", "Enable Preview")

/**
 * This value will send the keyboard shortcut you have set to disable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
disableOBSPreview := IniRead(ptf.files["KSAini"], "OBS", "Disable Preview")

/**
 * This value will send the keyboard shortcut you have set to screenshot the preview window within OBS Studio

 Can be set within KSA.ahk/ini
*/
screenshotOBS := IniRead(ptf.files["KSAini"], "OBS", "Screenshot")





;[Hotkeys]

/**
 * This value is a key or key combination that is being called upon within a function. These values will need to be adjusted within KSA.ini to fit however you choose to activate these functions
 */
manInputEnd := IniRead(ptf.files["KSAini"], "Hotkeys", "manualInput End")

/**
  * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
  */
functionHotkey := IniRead(ptf.files["KSAini"], "Hotkeys", "VSCode Function")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
minimiseHotkey := IniRead(ptf.files["KSAini"], "Hotkeys", "Minimise Hotkey")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
maximiseHotkey := IniRead(ptf.files["KSAini"], "Hotkeys", "Maximise Hotkey")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
;altKeywait := IniRead(ptf.files["KSAini"], "Hotkeys", "Alt Keywait")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
DragKeywait := IniRead(ptf.files["KSAini"], "Hotkeys", "Mousedrag Keywait")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
speedHotkey := IniRead(ptf.files["KSAini"], "Hotkeys", "Speed")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
longSkip := IniRead(ptf.files["KSAini"], "Hotkeys", "10s skip")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
focusCode := IniRead(ptf.files["KSAini"], "Hotkeys", "focus code")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
focusWork := IniRead(ptf.files["KSAini"], "Hotkeys", "focus workspace")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
collapseFold := IniRead(ptf.files["KSAini"], "Hotkeys", "collapse folders")

/**
 * This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
focusExplorerWin := IniRead(ptf.files["KSAini"], "Hotkeys", "focus explorer window")


;[ImageSearchCoords]

;[Premiere]

/**
 * This value is how much you want the total pixel width of your Effect Controls panel to be divided by. Because in my workspace my EC panel is over 2k pixels, it slows down the performance of all scripts, so I divide it by 3.

 This value can be set within KSA.ahk/ini
 */
ECDivide := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "EC Divide")


/**
  * This value is the first x coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbX1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "MB x1")

/**
  * This value is the first y coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbY1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "MB y1")

/**
  * This value is the second x coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbX2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "MB x2")

/**
  * This value is the second y coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbY2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "MB y2")

/**
  * This value is the first x coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxX1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "sfx x1")

/**
  * This value is the first y coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxY1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "sfx y1")

/**
  * This value is the second x coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxX2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "sfx x2")

/**
 * This value is the second y coordinate for the imagesearch within the sfx bin project window within premiere pro.

 Can be set within KSA.ahk/ini
 */
sfxY2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "sfx y2")


;movepreview() coords
/**
  * This value is for the X coordinate for just off center of your preview window.

  Can be set within KSA.ahk/ini
  */
moveX := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "move x")

/**
  * This value is for the Y coordinate for just off center of your preview window.

  Can be set within KSA.ahk/ini
  */
moveY := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "move y")



;[discord]
/**
  * This value is the first x coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyx1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "reply x1")

/**
  * This value is the first y coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyy1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "reply y1")

/**
  * This value is the second x coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyx2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "reply x2")

/**
  * This value is the second y coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyy2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "reply y2")

;[Resolve]

/**
 * This value is the first x coordinate for the imagesearch to find the inspector button within Davinci Resolve.

 Can be set within KSA.ahk/ini
 */
inspectx1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "INSPECT x1")

/**
  * This value is the first y coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspecty1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "INSPECT y1")

/**
  * This value is the second x coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspectx2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "INSPECT x2")

/**
  * This value is the second y coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspecty2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "INSPECT y2")


/**
  * This value is the first x coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidx1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Video x1")

/**
  * This value is the first y coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidy1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Video y1")

/**
  * This value is the second x coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidx2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Video x2")

/**
  * This value is the second y coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidy2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Video y2")


/**
  * This value is the first x coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propx1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Property x1")

/**
  * This value is the first y coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propy1 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Property y1")

/**
  * This value is the second x coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propx2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Property x2")

/**
  * This value is the second y coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propy2 := IniRead(ptf.files["KSAini"], "ImageSearchCoords", "Property y2")