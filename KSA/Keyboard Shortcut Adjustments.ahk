;All filepaths are absolute since this script gets #Include(ed) in other scripts that have different WorkingDir(s) than this one
;[Premiere]

;activate windows
effectControls := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Effect Controls")
mediaBrowser := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Media Browser")
projectsWindow := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Projects")
effectsWindow := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Effects")
timelineWindow := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Timeline")

;tools
handPrem := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Hand")
selectionPrem := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Selection")

;other shortcuts
findBox := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Find Box")
gainAdjust := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Gain")
zoomOut := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Zoom Out")
newText := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "New Text Layer")
nextEditPoint := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Next Edit Point")
previousEditPoint := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Previous Edit Point")
nudgeDown := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Nudge Clip Down")
selectAtPlayhead := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Select at Playhead")
deselectAll := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Deselect All")
speedMenu := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Speed")
playheadtoCursor := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Playhead to Cursor")

;Labels
labelViolet := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Violet")
labelIris := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Iris")
labelCaribbean := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Caribbean")
labelLavender := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Lavender")
labelCerulean := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Cerulean")
labelForest := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Forest")
labelRose := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Rose")
labelMango := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Mango")
labelPurple := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Purple")
labelBlue := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Blue")
labelTeal := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Teal")
labelMagenta := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Magenta")
labelTan := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Tan")
labelGreen := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Green")
labelRed := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Red")
labelYellow := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Premiere", "Yellow")

;[Photoshop]

;tools
handTool := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Hand")
penTool := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Pen")
selectionTool := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Selection")
zoomTool := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Zoom")

;hotkeys
freeTransform := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Free Transform")
imageSize := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Image Size")
saveasCopy := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "Photoshop", "Save As Copy")

;[After Effects]

;tools
handAE := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Hand")
selectionAE := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Selection")

;hotkeys
nextKeyframe := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Next Keyframe")
previousKeyframe := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Previous Keyframe")

;properties
scaleProp := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Scale")
positionProp := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Position")
anchorpointProp := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Anchor Point")
opacityProp := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Opacity")
rotationProp := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "After Effects", "Rotation")

;[OBS]
replayBuffer := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "OBS", "Replay Buffer")
sourceRecord1 := IniRead("C:\Program Files\ahk\ahk\KSA\Keyboard Shortcuts.ini", "OBS", "Source Record 1")