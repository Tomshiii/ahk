;Adjust the location of your scripts by changing the value below. This folder should be the root folder and with NO trailing backslash

location := "E:\Github\ahk"
commLocation := "E:\comms" ;you will need to change this manually, locationReplace() will not touch it

;[Premiere]

;==activate windows==

/*
 This value will send the keyboard shortcut you have set to scale the frame to the composition size Window within Premiere.

 Can be set within KSA.ahk/ini
 */
scaleFrameSize := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Scale frame size")

/*
 This value will send the keyboard shortcut you have set to activate the Program Monitor Window within Premiere.

 Can be set within KSA.ahk/ini
 */
programMonitor := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Program Monitor")

/*
 This value will send the keyboard shortcut you have set to activate the Effect Controls Window within Premiere.

 Can be set within KSA.ahk/ini
 */
effectControls := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Effect Controls")

/*
 This value will send the keyboard shortcut you have set to activate the Media Browser Window within Premiere.

 Can be set within KSA.ahk/ini
 */
mediaBrowser := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Media Browser")

/*
 This value will send the keyboard shortcut you have set to activate the Projects Window within Premiere.

 Can be set within KSA.ahk/ini
 */
projectsWindow := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Projects")

/*
 This value will send the keyboard shortcut you have set to activate the Effects Window within Premiere.

 Can be set within KSA.ahk/ini
 */
effectsWindow := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Effects")

/*
 This value will send the keyboard shortcut you have set to activate the Tools Window within Premiere.

 Can be set within KSA.ahk/ini
 */
 toolsWindow := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Tools")

/*
 This value will send the keyboard shortcut you have set to activate the timeline Window within Premiere.

 Can be set within KSA.ahk/ini
 */
timelineWindow := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Timeline")



;==tools==
/*
 This value will send the keyboard shortcut you have set to swap to the hand tool within Premiere

 Can be set within KSA.ahk/ini
 */
handPrem := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Hand")

/*
 This value will send the keyboard shortcut you have set to swap to the selection tool within Premiere

 Can be set within KSA.ahk/ini
 */
selectionPrem := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Selection")

/*
 This value will send the keyboard shortcut you have set to swap to the cut tool within Premiere

 Can be set within KSA.ahk/ini
 */
 cutPrem := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Cut")


;==other shortcuts==
/*
 This value will send the keyboard shortcut you have set to select the find box within Premiere

 Can be set within KSA.ahk/ini
 */
findBox := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Find Box")

/*
 This value will send the keyboard shortcut you have set to open the gain menu within Premiere

 Can be set within KSA.ahk/ini
 */
gainAdjust := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Gain")

/*
 This value will send the keyboard shortcut you have set to zoom out of the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
zoomOut := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Zoom Out")

/*
 This value will send the keyboard shortcut you have set to create a new text layer within Premiere

 Can be set within KSA.ahk/ini
 */
newText := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "New Text Layer")

/*
 This value will send the keyboard shortcut you have set to go to the next edit point within Premiere

 Can be set within KSA.ahk/ini
 */
nextEditPoint := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Next Edit Point")

/*
 This value will send the keyboard shortcut you have set to go to the previous edit point within Premiere

 Can be set within KSA.ahk/ini
 */
previousEditPoint := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Previous Edit Point")

/*
 This value will send the keyboard shortcut you have set to nudge down clips on the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
nudgeDown := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Nudge Clip Down")

/*
 This value will send the keyboard shortcut you have set to nudge up clips on the timeline within Premiere

 Can be set within KSA.ahk/ini
 */
nudgeUp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Nudge Clip Up")

/*
 This value will send the keyboard shortcut you have set to select the clip at playhead within Premiere

 Can be set within KSA.ahk/ini
 */
selectAtPlayhead := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Select at Playhead")

/*
 This value will send the keyboard shortcut you have set to deselect all within Premiere

 Can be set within KSA.ahk/ini
 */
deselectAll := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Deselect All")

/*
 This value will send the keyboard shortcut you have set to open the speed menu within Premiere

 Can be set within KSA.ahk/ini
 */
speedMenu := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Speed")

/*
 This value will send the keyboard shortcut you have set to move the playhead to the cursor within Premiere

 Can be set within KSA.ahk/ini
 */
playheadtoCursor := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Playhead to Cursor")

/*
 This value will send the keyboard shortcut you have set to reset the current workspace within Premiere

 Can be set within KSA.ahk/ini
 */
resetWorkspace := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "reset changes to workspace")

/*
 This value will send the keyboard shortcut you have set to speedup playback within Premiere

 Can be set within KSA.ahk/ini
 */
speedUpPlayback := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "speed up playback")

/*
 This value will send the keyboard shortcut you have set to slow down playback within Premiere

 Can be set within KSA.ahk/ini
 */
slowDownPlayback := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "slow down playback")

/*
 This value will send the keyboard shortcut you have set to play/stop playback within Premiere

 Can be set within KSA.ahk/ini
 */
playStop := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "play/stop")

/*
 This value will send the keyboard shortcut you have set to open the ingest settings menu within Premiere

 Can be set within KSA.ahk/ini
 */
premIngest := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "ingest")

/*
 This value will send the keyboard shortcut you have set to open the ingest settings menu within Premiere

 Can be set within KSA.ahk/ini
 */
shuttleStop := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "shuttle stop")

;==Labels==
labelViolet := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Violet")
labelIris := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Iris")
labelCaribbean := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Caribbean")
labelLavender := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Lavender")
labelCerulean := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Cerulean")
labelForest := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Forest")
labelRose := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Rose")
labelMango := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Mango")
labelPurple := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Purple")
labelBlue := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Blue")
labelTeal := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Teal")
labelMagenta := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Magenta")
labelTan := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Tan")
labelGreen := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Green")
labelRed := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Red")
labelYellow := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Premiere", "Yellow")







;[Photoshop]

;==tools==

/*
 This value will send the keyboard shortcut you have set to change to the hand tool within Photoshop

 Can be set within KSA.ahk/ini
 */
handTool := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Hand")

/*
 This value will send the keyboard shortcut you have set to change to the pen tool within Photoshop

 Can be set within KSA.ahk/ini
 */
penTool := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Pen")

/*
 This value will send the keyboard shortcut you have set to change to the selection tool within Photoshop

 Can be set within KSA.ahk/ini
 */
selectionTool := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Selection")

/*
 This value will send the keyboard shortcut you have set to change to the zoom tool within Photoshop

 Can be set within KSA.ahk/ini
 */
zoomTool := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Zoom")



;==hotkeys==

/*
 This value will send the keyboard shortcut you have set to go into free transform within Photoshop

 Can be set within KSA.ahk/ini
 */
freeTransform := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Free Transform")

/*
 This value will send the keyboard shortcut you have set to open the image size menu within Photoshop

 Can be set within KSA.ahk/ini
 */
imageSize := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Image Size")

/*
 This value will send the keyboard shortcut you have set to save as copy within Photoshop

 Can be set within KSA.ahk/ini
 */
saveasCopy := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Photoshop", "Save As Copy")









;[After Effects]
;==activate windows==

/*
 This value will send the keyboard shortcut you have set to show/hide the audio panel in Adobe After Effects

 Can be set within KSA.ahk/ini
 */
audioAE := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "show/hide audio")

/*
 This value will send the keyboard shortcut you have set to show/hide the effects panel in Adobe After Effects

 Can be set within KSA.ahk/ini
 */
effectsAE := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "show/hide effects")

;==tools==

/*
 This value will send the keyboard shortcut you have set to change to the hand tool within After Effects

 Can be set within KSA.ahk/ini
 */
handAE := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Hand")

/*
 This value will send the keyboard shortcut you have set to change to the selection tool within After Effects

 Can be set within KSA.ahk/ini
 */
selectionAE := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Selection")



;==hotkeys==

/*
 This value will send the keyboard shortcut you have set to go the the next keyframe within After Effects

 Can be set within KSA.ahk/ini
 */
nextKeyframe := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Next Keyframe")

/*
 This value will send the keyboard shortcut you have set to go the the previous keyframe within After Effects

 Can be set within KSA.ahk/ini
 */
previousKeyframe := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Previous Keyframe")



;==properties==

/*
 This value will send the keyboard shortcut you have set to open the scale property within After Effects

 Can be set within KSA.ahk/ini
 */
scaleProp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Scale")

/*
 This value will send the keyboard shortcut you have set to open the position property within After Effects

 Can be set within KSA.ahk/ini
 */
positionProp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Position")

/*
 This value will send the keyboard shortcut you have set to open the anchor point property within After Effects

 Can be set within KSA.ahk/ini
 */
anchorpointProp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Anchor Point")

/*
 This value will send the keyboard shortcut you have set to open the opacity property within After Effects

 Can be set within KSA.ahk/ini
 */
opacityProp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Opacity")

/*
 This value will send the keyboard shortcut you have set to open the rotation property within After Effects

 Can be set within KSA.ahk/ini
 */
rotationProp := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "Rotation")

;==other==
/*
 This value will send the keyboard shortcut you have set to open the composition settings within After Effects

 Can be set within KSA.ahk/ini
 */
 compSettings := IniRead(location "\KSA\Keyboard Shortcuts.ini", "After Effects", "comp")




;[Resolve]

;==hotkeys==

/*
 This value will send the keyboard shortcut you have set to select the clip at playhead within Resolve

 Can be set within KSA.ahk/ini
 */
resolveSelectPlayhead := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Resolve", "Select at Playhead")

/*
 This value will send the keyboard shortcut you have set to deselect the clip at playhead within Resolve

 Can be set within KSA.ahk/ini
 */
resolveDeselect := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Resolve", "Deselect all")






;[OBS]

/*
 This value will send the keyboard shortcut you have set to save a clip from the replay buffer within OBS Studio

 Can be set within KSA.ahk/ini
 */
replayBuffer := IniRead(location "\KSA\Keyboard Shortcuts.ini", "OBS", "Replay Buffer")

/*
 This value will send the keyboard shortcut you have set to save a clip from the Source Record Plugin within OBS Studio

 Can be set within KSA.ahk/ini
 */
sourceRecord1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "OBS", "Source Record 1")

/*
 This value will send the keyboard shortcut you have set to enable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
enableOBSPreview := IniRead(location "\KSA\Keyboard Shortcuts.ini", "OBS", "Enable Preview")

/*
 This value will send the keyboard shortcut you have set to disable the preview window within OBS Studio

 Can be set within KSA.ahk/ini
 */
disableOBSPreview := IniRead(location "\KSA\Keyboard Shortcuts.ini", "OBS", "Disable Preview")

/*
 This value will send the keyboard shortcut you have set to screenshot the preview window within OBS Studio

 Can be set within KSA.ahk/ini
*/
screenshotOBS := IniRead(location "\KSA\Keyboard Shortcuts.ini", "OBS", "Screenshot")





;[Hotkeys]

/*
 This value is a key or key combination that is being called upon within a function. These values will need to be adjusted within KSA.ini to fit however you choose to activate these functions
 */
manInputEnd := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "manualInput End")

/*
  This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
  */
functionHotkey := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "VSCode Function")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
minimiseHotkey := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "Minimise Hotkey")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
maximiseHotkey := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "Maximise Hotkey")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
;altKeywait := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "Alt Keywait")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
DragKeywait := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "Mousedrag Keywait")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
speedHotkey := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "Speed")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
 */
longSkip := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "10s skip")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
focusCode := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "focus code")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
focusWork := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "focus workspace")

/*
 This value is a key or key combination that is being called upon within a function, these values will need to be adjusted within KSA.ahk/ini to fit however you choose to activate these functions
*/
collapseFold := IniRead(location "\KSA\Keyboard Shortcuts.ini", "Hotkeys", "collapse folders")



;[ImageSearchCoords]

;[Premiere]

/*
 This value is how much you want the total pixel width of your Effect Controls panel to be divided by. Because in my workspace my EC panel is over 2k pixels, it slows down the performance of all scripts, so I divide it by 3.

 This value can be set within KSA.ahk/ini
 */
ECDivide := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "EC Divide")


/*
  This value is the first x coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbX1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "MB x1")

/*
  This value is the first y coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbY1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "MB y1")

/*
  This value is the second x coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbX2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "MB x2")

/*
  This value is the second y coordinate for the imagesearch within the media browser window within premiere pro.

  Can be set within KSA.ahk/ini
  */
mbY2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "MB y2")

/*
  This value is the first x coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxX1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "sfx x1")

/*
  This value is the first y coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxY1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "sfx y1")

/*
  This value is the second x coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxX2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "sfx x2")

  /*
  This value is the second y coordinate for the imagesearch within the sfx bin project window within premiere pro.

  Can be set within KSA.ahk/ini
  */
sfxY2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "sfx y2")


;movepreview() coords
/*
  This value is for the X coordinate for just off center of your preview window.

  Can be set within KSA.ahk/ini
  */
moveX := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "move x")

/*
  This value is for the Y coordinate for just off center of your preview window.

  Can be set within KSA.ahk/ini
  */
moveY := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "move y")



;[discord]
/*
  This value is the first x coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyx1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "reply x1")

/*
  This value is the first y coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyy1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "reply y1")

/*
  This value is the second x coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyx2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "reply x2")

/*
  This value is the second y coordinate for the imagesearch to find the '@ON' reply button on discord incase the first attempt fails

  Can be set within KSA.ahk/ini
  */
;replyy2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "reply y2")

;[Resolve]

/*
 This value is the first x coordinate for the imagesearch to find the inspector button within Davinci Resolve.

 Can be set within KSA.ahk/ini
 */
inspectx1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "INSPECT x1")

/*
  This value is the first y coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspecty1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "INSPECT y1")

/*
  This value is the second x coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspectx2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "INSPECT x2")

/*
  This value is the second y coordinate for the imagesearch to find the inspector button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
inspecty2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "INSPECT y2")


/*
  This value is the first x coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidx1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Video x1")

/*
  This value is the first y coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidy1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Video y1")

/*
  This value is the second x coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidx2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Video x2")

/*
  This value is the second y coordinate for the imagesearch to find the video button within Davinci Resolve.

  Can be set within KSA.ahk/ini
  */
vidy2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Video y2")


/*
  This value is the first x coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propx1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Property x1")

/*
  This value is the first y coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propy1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Property y1")

/*
  This value is the second x coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propx2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Property x2")

/*
  This value is the second y coordinate for the imagesearch to find your property of choice within the inspector window within Davinci Resolve

  Can be set within KSA.ahk/ini
  */
propy2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "Property y2")


/*
  This value is the first x coordinate for the imagesearch to find everything required for the REffect() function.

  Can be set within KSA.ahk/ini
  */
effectx1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "effect x1")

/*
  This value is the first y coordinate for the imagesearch to find everything required for the REffect() function.

  Can be set within KSA.ahk/ini
  */
effecty1 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "effect y1")

/*
  This value is the second x coordinate for the imagesearch to find everything required for the REffect() function.

  Can be set within KSA.ahk/ini
  */
effectx2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "effect x2")

/*
  This value is the second y coordinate for the imagesearch to find everything required for the REffect() function.

  Can be set within KSA.ahk/ini
  */
effecty2 := IniRead(location "\KSA\Keyboard Shortcuts.ini", "ImageSearchCoords", "effect y2")
