; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\obj.ahk
; }

/**
 * This function uses the built in windows command `Robocopy "{}" "{}" /MIR /R:1` to mirrow two directories
 * @param {Map} [dirsMap?] a map containing all the required information. Must be in the following style; `Map("path", {label: "", serial: , dirPath: ""}, "dest", {label: "", serial: , dirPath: ""})` where;
 * @param `"path"` acts as the source directory, `"dest"` acts as the destination directory
 * @param {String} [label] The name of the drive
 * @param {Integer} [serial] The serial number of the drive
 * @param {String} [dirPath] The directory you wish to sync from/too
 *
 * @returns {Boolean}
 */
syncDirectories(dirsMap?) {
	myDirsMap := (!IsSet(dirsMap) || !IsObject(dirsMap) || !dirsMap.has("path") || !dirsMap.has("dest") || !dirsMap["dest"].HasOwnProp('label') || !dirsMap["dest"].HasOwnProp('serial') || !dirsMap["dest"].HasOwnProp('dirPath')) || !dirsMap["path"].HasOwnProp('label') || !dirsMap["path"].HasOwnProp('serial') || !dirsMap["path"].HasOwnProp('dirPath')
		? Map("path", {label: "Tom Work", serial: 3829588704, dirPath: "W:\_Assets"}, "dest", {label: "storage", serial: 489231902, dirPath: "N:\_Backups\Folder Backups\Tom Assets"})
		: dirsMap
	path := obj.SplitPath(myDirsMap["path"].dirPath)
	dest := obj.SplitPath(myDirsMap["dest"].dirPath)
	cmnd := 'Robocopy "{1}" "{2}" /MIR /R:1'
	if !DirExist(path.path) || !DirExist(dest.path)
		return false

	getList := DriveGetList("FIXED") . DriveGetList("NETWORK")
	if InStr(getList, SubStr(path.Drive, 1, 1)) && InStr(getList, SubStr(dest.Drive, 1, 1)) {
		labelW  := DriveGetLabel(path.Drive "\"),   labelS := DriveGetLabel(dest.Drive "\")
		serialW := DriveGetSerial(path.Drive "\"), serialS := DriveGetSerial(dest.Drive "\")
		; MsgBox(labelW "-" myDirsMap["path"].label "`n" labelS "-" myDirsMap["dest"].label "`n" serialW "-" myDirsMap["path"].serial "`n" serialS "-" myDirsMap["dest"].serial)
		if labelW = myDirsMap["path"].label && labelS = myDirsMap["dest"].label && serialW = myDirsMap["path"].serial && serialS = myDirsMap["dest"].serial {
			cmd.run(,,, Format(cmnd, path.path, dest.path),, "hide")
			return true
		}
	}
	return false
}

WM_DEVICECHANGE(wParam, lparam, msg, hwnd) {
    static DBT_DEVICEARRIVAL := 0x8000
    ;// if new drive was inserted
    if (wParam = DBT_DEVICEARRIVAL) {
		lastDrive := cmd.result('powershell -NoProfile -Command "Get-Volume | Where-Object DriveType -eq `'Fixed`' | Sort-Object @{Expression = {(Get-Item ($_.DriveLetter + `':\`')).CreationTime}} -Descending | Select-Object -First 1 -ExpandProperty DriveLetter"')
		getList := DriveGetList("FIXED")
		if lastDrive = "S" && InStr(getList, "S") && InStr(getList, "W") && DriveGetLabel("W:/") = "Tom Work" {
            syncDirectories()
			return
        }
    }
}