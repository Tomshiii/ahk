/************************************************************************
 * @description
 * @author tomshi
 * @date 2026/02/03
 * @version 1.1.1
 ***********************************************************************/
; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include Classes\obj.ahk
#Include Classes\WinGet.ahk
#Include Classes\cmd.ahk
#Include Functions\notifyIfNotExist.ahk
#Include Other\Notify\Notify.ahk
#Include Other\UIA\UIA.ahk
; }

class explorer {

    /**
     * A function to create a UIA element for an explorer window
     * @param {String} [currWin=WinGet.Title()] the explorer window you wish to operate on. Defaults to `WinGet.Title()`
     * @param {Boolean} [getActive=true] determines whether this function will check the currently active panel. Note; leaving this as true can add anywhere from `60-1000ms` of delay depending on how busy Premiere currently is and is best left as `false` if performance is the goal or the active element isn't needed
     * @returns {Object}
     * ```
     * createEl := this.__createUIAelement()
     * createEl.AdobeEl       ;// the UIA element created from the Premiere Pro window
     * createEl.activeElement ;// the UIA string of the currently active element
     * ```
     */
    static __createUIAelement(currWin := WinGet.Title(), getActive := true) {
        try explorerEl := UIA.ElementFromHandle(currWin " ahk_exe explorer.exe",, false)
        catch {
            try explorerEl := UIA.ElementFromHandle(currWin " ahk_class #32770",, false)
            catch {
                return false
            }
        }
        try currentEl  := (getActive = true) ? explorerEl.GetConditionPath(UIA.GetFocusedElement()) : ""
        return {uiaElement: explorerEl, activeElement: currentEl ?? ""}
    }

    /**
     * A safe way to call `explorer.getTab()` when the user only wants the path value (ie. `explorer.getTab().path`).
     * @param {Integer} [hwnd=WinExist("A")] the hwnd of the tab you wish to operate on. Defaults to the active window
     * @returns {String/Boolean}
     */
    static getPath(hwnd := WinExist("A")) => ((IsObject(path := this.getTab(hwnd)) && ObjHasOwnProp(path, 'Path') )? path.path : false)

    /**
    * This function returns an object containing some information about the desired windows explorer tab
    * @link Original code found here by lexikos: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907
    * @param {Integer} [hwnd=WinExist("A")] the hwnd of the tab you wish to operate on. Defaults to the active window
    * @returns {Object/Boolean false}
    * ```
    * getTab := explorer.getTab() ;// W:\work
    * getTab.path   ;// returns W:\work
    * getTab.hwnd   ;// returns the hwnd of the tab
    * getTab.comObj ;// returns the ComObject object for the tab so that it can be interacted with further
    * ```
    */
    static getTab(hwnd := WinExist("A")) {
        activeTab := 0
        try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
        catch
            return false
        for w in ComObject("Shell.Application").Windows {
            if w.hwnd != hwnd
                continue
            if activeTab { ; The window has tabs, so make sure this is the right one.
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
                ComCall(3, shellBrowser, "uint*", &thisTab:=0)
                if thisTab != activeTab
                    continue
            }
            return {path: w.Document.Folder.Self.Path, hwnd: w.hwnd, comObj: w}
        }
        return false
    }

    /**
     * retrieves the `AutomationID` for the active UIA element
     * @param {Object} [el] the UIA element you wish to operate on
     * @returns {String}
     */
    static __getUIAautoID(el) {
            if el.activeElement != "" {
                for v in el.activeElement {
                    for k, v2 in v.OwnProps() {
                        if k = "A" || k = "AutomationId" {
                            return v2
                        }
                    }
                }
            }
            return false
        }

    /**
     * A function to click the "Cancel search" button that appears in windows 1
     * @returns {Object} [uiaElement, activeAutoID] returns an object. Returns `false` on failure or `-1` if the window title cannot be determined or if creating a UIA element fails
     */
    static cancelSearch() {
        if !currWin := WinGet.Title()
            return -1
        if !InStr(currWin, "Search Results in") {
            return false
        }
        try explorerEl := this.__createUIAelement(currWin, true)
        catch {
            SendInput("{Browser_Back}")
            return -1
        }
        autoID := this.__getUIAautoID(explorerEl)
        try cancelButt := explorerEl.uiaElement.FindElement({LocalizedType:"app bar button", Name:"Close search", ClassName:"AppBarButton"}).Click()
        catch {
            SendInput("{Browser_Back}")
            return -1
        }
        return {uiaElement: explorerEl.uiaElement, activeAutoID: autoID}
    }

    /**
     * checks the explorer UI element for `PopupHost` which in windows 11 tends to appear if the path bar is interacted with
     * @param {Object} [el]
     */
    static isPopupHost(el) {
        try {
            popup := el.FindElement({Name:"PopupHost", LocalizedType:"pane", ClassName:"Microsoft.UI.Content.PopupWindowSiteBridge"})
            return popup
        }
        return false
    }

    /**
     * returns the number of files & subdirectories in the given directory
     * @param {String} [dir] the directory you wish to check
     * @param {Boolean} [recurse=false] determines whether you wish to recurse in the chosen directory or not
     * @link https://www.autohotkey.com/boards/viewtopic.php?p=494290#p494290
     * @returns {Boolean/Object} returns boolean false if dir does not exist, else;
     *
     * `{files: {Integer}, subdirs: {Integer}}`
     */
    static nItemsInDir(dir, recurse := false) {
        if !DirExist(dir)
            return false
        objFolder := ComObject('Scripting.FileSystemObject').GetFolder(dir)
        files := objFolder.Files.Count, folders := objFolder.SubFolders.Count
        loop files recurse ? dir '\*' : '', 'DR'
            n := this.nItemsInDir(A_LoopFilePath), files += n.files, folders += n.subdirs
        return {files: files, subdirs: folders}
    }

    /**
     * A function to select a file in an open file explorer window
     * @param {String} [fullPath] the full path of the file you wish to select
     * @param {Boolean} [checkAgain=false] determine whether to check again after 1.5s to ensure the file is selected. If the file is still being operated on by something like `ffmpeg` it may become deselected. This parameter isn't necessary if the file isn't being operated on when this function is called. Defaults to `false`
     * @returns {Boolean} returns `false` on failure/file not existing, returns `true` on success
     */
    static selectFileInOpenWindow(fullPath, checkAgain := false) {
        if !WinActive("ahk_exe explorer.exe") {
            notifyIfNotExist("explorerNotActive",, 'Windows explorer is not the active window so a selection could not be made', 'C:\Windows\System32\imageres.dll|icon4', 'Speech Misrecognition',, 'theme=Dark dur=5 bdr=Red maxW=400')
            return false
        }
        hwnd := WinExist("A")
        objPath := obj.SplitPath(fullPath)
        targetPath := objPath.dir
        fileToSelect := objPath.name

        __doActivate(targetPath, fileToSelect, *) {
            if !WinActive("ahk_exe explorer.exe")
                return
            SVSI_SELECT := 0x1
            SVSI_DESELECTOTHERS := 0x4
            SVSI_ENSUREVISIBLE := 0x8
            flags := SVSI_SELECT | SVSI_DESELECTOTHERS | SVSI_ENSUREVISIBLE

            explorerWindows := ComObject("Shell.Application").Windows
            for window in explorerWindows {
                if window.hWnd != hWnd
                    continue
                try {
                    if (window.Document.Folder.Self.Path != targetPath)
                        continue
                    folderView := window.Document
                    itemPath := targetPath "\" fileToSelect
                    folderItem := folderView.Folder.ParseName(fileToSelect)
                    if folderItem {
                        didSelection := true
                        folderView.SelectItem(folderItem, flags)
                        break
                    }
                } catch {
                    continue
                }
            }
        }
        __doActivate(targetPath, fileToSelect)
        if checkAgain = true
            SetTimer((*) => __doActivate.Bind(targetPath, fileToSelect), -1500)
        return
    }

    /**
     * Activates/runs the desired directory & focuses the desired file
     * @param {String} [filepath] the full filepath of the desired file/directory you wish to open and select
     * @returns {boolean}
     */
    static highlightFile(filepath) {
        SplitPath(filepath, &fileName, &Dir)
        SplitPath(Dir, &dirName,,,, &drive)
        __determineFolder(path, dirName, fileName, drive) {
            ;// handle if the chosen directory is the root of a drive
            if (StrLen(path) = 4 && SubStr(path, -3, 3) = ":\\") || (StrLen(path) = 3 && SubStr(path, -2, 2) = ":\") {
                getDriveName := DriveGetLabel(drive)
                if WinExist(getDriveName " (" drive ")") {
                    WinActivate()
                    this.selectFileInOpenWindow(filepath, true)
                    return true
                }
                Run(filepath,,, &pid)
                WinWait("ahk_pid " pid)
                WinActivate("ahk_pid " pid)
                return
            }

            hasPath := WinExist(path " ahk_exe explorer.exe")
            noPath  := WinExist(dirName " ahk_exe explorer.exe")
            if !hasPath && !noPath
                return false

            hwnd := (hasPath != 0) ? hasPath : noPath
            pathStr := this.getPath(hwnd)
            if pathStr == path {
                WinActivate(hwnd)
                if !WinWait(hwnd,, 2)
                    return true
                this.selectFileInOpenWindow(filepath, true)
                return true
            }
            return false
        }
        if WinExist(dir " ahk_exe explorer.exe") || WinExist(dirName " ahk_exe explorer.exe") {
            if __determineFolder(dir, dirName, fileName, drive)
                return true
        }
        cmd.exploreAndHighlight(filepath, true, true)
    }

    /**
     * @param {String} path
     * @param {Integer} windowHwnd
     * @link https://github.com/ThioJoe/ThioJoe-AHK-Scripts/blob/58874c8396c714f511f91bd4f3e8bb67f4592c66/Scripts/ExplorerDialogPathSelector.ahk#L851
     * @author ThioJoe
     */
    static navigateUsingAddressbar(path, windowHwnd) {
        CheckAddressbarReadyAndNavigate(attemptNumber := 1) {
            addressbarHwnd := ControlGetFocus("ahk_id " windowHwnd)
            addressBarClassNN := ControlGetClassNN(addressbarHwnd)

            ; Regex match if the address bar is an Edit control but not Edit1, which seems to always the file name box. But the address bar box might not always be Edit2
            if (addressBarClassNN != "Edit1" and addressBarClassNN ~= "Edit\d+") {
                DoNavigation(addressBarClassNN, addressbarHwnd)
            } else if (attemptNumber <= 3) {
                ; Try waiting a bit longer for the address bar to be ready
                Sleep(50)
                CheckAddressbarReadyAndNavigate(attemptNumber + 1)
            }
        }

        DoNavigation(_addressbarClassNN, _addressbarHwnd) {
            ControlSetText(path, _addressbarClassNN, "ahk_id " windowHwnd)
            ControlSend("{Enter}", _addressbarClassNN, "ahk_id " windowHwnd)
            ControlFocus("Edit1", "ahk_id " windowHwnd) ; Return focus to the file name box
        }
        ; Activate the window
        WinActivate("ahk_id " windowHwnd)
        WinWaitActive("ahk_id " windowHwnd)
        ; Try getting the text from the Edit1 control
        originalFileName := ""
        try {
            originalFileName := ControlGetText("Edit1", "ahk_id " windowHwnd)
            ControlSetText("", "Edit1", windowHwnd) ; Clear the text box just in case something weird happens so it doesn't save the file prematurely
        }

        ; Move focus to Address Bar
        Send("!{d}") ; For some reason doesn't seem to work sending to the window
        Sleep(50)
        CheckAddressbarReadyAndNavigate()

        ; Restore the original file name if it was there
        if (originalFileName != "") {
            ControlSetText(originalFileName, "Edit1", "ahk_id " windowHwnd)
        }

    }
}