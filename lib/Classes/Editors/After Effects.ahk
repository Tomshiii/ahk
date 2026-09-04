/************************************************************************
 * @description A library of useful After Effects functions to speed up common tasks
 * Functions are not guaranteed to work correctly on previous versions of AE. Please see the version number below to know which version of AE I am currently using for testing.
 * @aeVer 26.3
 * @author tomshi
 * @date 2026/09/04
 * @version 1.5.5
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Settings.ahk
#Include Classes\block.ahk
#Include Classes\coord.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\keys.ahk
#Include Classes\obj.ahk
#Include Classes\cmd.ahk
#Include Classes\winGet.ahk
#Include Classes\errorLog.ahk
#Include Classes\switchTo.ahk
#Include Classes\clip.ahk
#Include Other\UIA\UIA.ahk
#Include Other\_socket.ahk
#Include Functions\delaySI.ahk
#Include Functions\detect.ahk
#Include Functions\determineAdobeVer.ahk
#Include Functions\isObjHasProp.ahk
; }

;Although I have some scripts for AE, they aren't as kept up to date as their Premiere cousins - most of my work is in premiere and the work that I do within AE is usually the same from project to project so there isn't as much room for expansion/experimentation. After Effects is also a lot harder to script for as it is significantly more sluggish and is more difficult to tell when you're within certain parts of the program making it harder for ahk to know when it's supposed to move on outside of just coding in multiple seconds worth of sleeps until AE chooses to react. As a result of all of this, some of these scripts may, at anytime, stop functioning the way I originally coded them to as AE decides to be ever so slightly more sluggish than previously and breaks everything - this has generally caused me to not only shy away from creating scripts for AE, but has also caused me to stop using some of the ones I create as they tend to break far too often which at the end of the day just wastes more of my time than is worth it

class AE {

    static __New() {
        try this.UserSettings := CLSID_Objs.load("UserSettings")
        catch {
            this.UserSettings := UserPref(true)
        }

        for name in AE.OwnProps() {
            ;// skip anything private (convention: starts with `__`), and __New itself
            if (SubStr(name, 1, 2) = "__")
                continue
            desc := AE.GetOwnPropDesc(name)
            if !desc.HasOwnProp("Call")
                continue
            orig := desc.Call
            AE.DefineProp(name, {Call: __guarded.Bind(orig)})
        }

        __guarded(orig, self, args*) {
            AE.__ensureChecked()
            return orig(self, args*)
        }

        if A_ScriptName != "Core Functionality.ahk" && winExt.ExistRegex("Core Functionality.ahk",,,, true) && !this.__ignoreWinExist() {
            try {
                activeObj := CLSID_Objs.load("ae")
                ignoreProps := Map('__checkedInstall', true, "ignoreWins", true, "KSA", true, "defaultTheme", true, "prevSeqDelay", true, "useSwapSequences", true, "toggleableButtons", true)
                for propName, propVal in activeObj.OwnProps() {
                    if this.HasProp(propName) && !ignoreProps.Has(propName) {
                        try this.%propName% := propVal
                    }
                }
            }
        }

        regInst := this.__isRegInstalledVer()
        if A_ScriptName = "Core Functionality.ahk" && regInst != false && this.__isNodeInstalled() != false && this.__isRemoteInstalled() != false {
            ;// check for aeremote and NPM before setting timer
            extensionsPath := A_AppData "\Adobe\CEP\extensions"
            remotePath     := extensionsPath "\AERemote"
            getNPM := cmd.result('powershell -c "Get-Command -Name npm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
            if DirExist(remotePath) && (getNPM != false && getNPM != "") {
                SetTimer(this.__checkRemote.Bind(this, this.portCEP, "cep"), 2000)
                ; SetTimer(this.__checkRemote.Bind(this, this.portUXP, "uxp"), 2000)
            }
        }
    }

    static __checkedInstall := false
    static ignoreWins := ["- Tomshi Installer", "Install Tomshi AHK", "uninstall.ahk", "closeAll.ahk", "reloadAll.ahk"]

    static __ignoreWinExist(ignoreWins := this.ignoreWins) {
        Critical()
        dct := detect()
        for v in ignoreWins {
            if WinExist(v) {
                resetOrigDetect(dct)
                Critical("Off")
                return true
            }
        }
        resetOrigDetect(dct)
        Critical("Off")
        return false
    }

    ;// everything that used to run unconditionally in __New() now lives here,
    ;// and only runs once, lazily, the first time any real method gets called
    static __ensureChecked() {
        if this.__checkedInstall
            return
        this.__checkedInstall := true

        if (!this.__isNodeInstalled() || !this.__isRemoteInstalled()) && !this.__ignoreWinExist() {
            throwStr := (!this.__isNodeInstalled() && !this.__isRemoteInstalled()) ? "Node.js & AERemote are not Installed. Both are  required.`nPlease reinstall for proper functionality." : ((!this.__isNodeInstalled() && this.__isRemoteInstalled()) ? "Node.js is not currently installed. It is required for proper functionality.`nPlease install Node.js and try again." : "AERemote is not currently installed. It is required for proper functionality.`nPlease install AERemote and try again.")
            if A_ScriptName != "Core Functionality.ahk" && !this.__ignoreWinExist()
                throw TargetError(throwStr, -1)
            else
                errorLog(TargetError(throwStr, -1))
        }

        ;// ensure minimum version
        regInstalledVer := this.__isRegInstalledVer()
        switch regInstalledVer {
            case false:
                (A_ScriptName != "Core Functionality.ahk" && !this.__ignoreWinExist()) ? errorLog(TargetError("After Effects is not currently installed or the incorrect version is set.", -1),,, true) : errorLog(TargetError("After Effects is not currently installed or the incorrect version is set.", -1))
            default:
                if VerCompare(regInstalledVer.version, this.minVer) < 0 {
                    (A_ScriptName != "Core Functionality.ahk" && !this.__ignoreWinExist()) ? errorLog(TargetError("Installed version of After Effects is not supported.`nMin version: " this.minVer, -1, regInstalledVer.version),,, true) : errorLog(TargetError("Installed version of After Effects is not supported.`nMin version: " this.minVer, -1, regInstalledVer.version))
                }
        }
    }

    static __checkRemote(port := 42500, cepOrUXP := "cep") {
        if !WinExist(this.winTitle)
            return
        try {
            sock := winsock("probe", (s,e,c) => this.__probeCB(s,e,c, cepOrUXP), "IPV4")
            sock.Connect("localhost", port)
        } catch {
            errorLog(TargetError("Couldn't probe localhost", -1))
            return
        }
    }

    static __probeCB(sock, event, err, cepOrUXP) {
        if (event = "Connect") {
            (cepOrUXP = "cep") ? this.remoteActiveCEP := (err = 0) : this.remoteActiveUXP := (err = 0)
            sock.Close()
        } else if (event = "Close") {
            (cepOrUXP = "cep") ? this.remoteActiveCEP := false : this.remoteActiveUXP := false
            sock.Close()
        }
    }
    static __isNodeInstalled() => RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
    static __isRemoteInstalled() => DirExist(A_AppData "\Adobe\CEP\extensions\AERemote")
    static __isRegInstalledVer() => determineAdobeVer({baseName: "AfterFX.exe", beta: "AfterFX (Beta).exe"})

    static UserSettings := ""
    static minVer := "22.6"
    static spectrumUI_Version := "25.0"

    static exeTitle := Editors.AE.winTitle
    static winTitle := this.exeTitle
    static class := Editors.AE.class
    static path := ptf["AE"]

    static portCEP := 42500
    static remoteDirCEP := A_AppData "\Adobe\CEP\extensions\AERemote"
    static indexFileCEP := this.remoteDirCEP "\host\src\index.tsx"

    static focusColour {
        get {
            switch {
                case VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0: return 0x066CE7
                case VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0:  return 0x2D8CEB
            }
        }
    }
    static currentSetVer {
        get => SubStr(this.UserSettings.aeVer, 2)
    }
    static currentYearVer {
        get =>  SubStr(this.UserSettings.aeVer, 2, 2)
    }

    /**
     * This function is syntatic sugar to activate a [AERemote](https://github.com/Tomshiii/PremiereRemote/tree/AE) function
     * @param {String} whichFunc the function you wish to call
     * @param {Boolean} [needResult=false] determines whether the user needs this function to return a result back from the cmd window.
     * @param {Varadic/String} params any additional paramaters you need to pass to your function. do **not** add the `&` that goes between paramaters, this function will add that itself
     *
     * ## Warning
     *
     * ##### *If you intend on sending a parameter that contains a SPACE you need to use `%20` instead. ie; instead of `Gaussian Blur`, use `Gaussian%20Blur`*. The function will attempt to rectify this for you automatically, but relying on such could result in issues.
     * ##### Similarly; sending a parameter with `&` may cause issues. It is recommended to send `%26` instead. This function will attempt to rectify the issue itself but again, relying on such could result in issues.
     * @returns {String} if the user sets `needResult` to `true` this function will return a string containing the response.
     */
    static __remoteFunc(whichFunc, needResult := false, params*) {
        if !this.__checkAERemoteDir(whichFunc) {
            errorLog(TargetError("AERemote is not installed or function does not exist.", -1, whichFunc),,, true)
            return false
        }
        if !this.__checkRemoteParams(whichFunc, params, "cep")
            return false
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true) {
            errorLog(Error("Core Functionality.ahk is not open but is required.", -1),, true)
            return false
        }

        checkAE := WinGet.AEName()
        checkType := (Type(checkAE) != "Object")
        if !checkAE || checkType
            return false
        checkTitle := (checkAE.winTitle = "" || !checkAE.wintitle), checkCanSave := (checkAE.titleCheck = -1)
        if checkTitle || checkCanSave {
            return false
        }

        if A_ScriptName != "Core Functionality.ahk" {
            activeObj := CLSID_Objs.clone("ae")
            if activeObj.remoteActiveCEP = "loading" {
                notifyExt.showIfNotExist("aeSocketConnectionErrorCEP",, "Socket connection to CEP plugin still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return -1
            }
            if !activeObj.remoteActiveCEP {
                errorLog(Error("A socket connection could not be established to CEP plugin", -1),, false)
                notifyExt.showIfNotExist('aeSocketConnectionErrorCEP',, "A socket connection could not be established to CEP plugin", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return false
            }
        } else {
            if this.remoteActiveCEP = "loading" {
                notifyExt.showIfNotExist("aeSocketLoadingCEP",, "Socket connection to CEP plugin still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return -1
            }
            if !this.remoteActiveCEP {
                errorLog(Error("A socket connection could not be established to CEP plugin", -1),, false)
                notifyExt.showIfNotExist('aeSocketConnectionErrorCEP',, "A socket connection could not be established to CEP plugin", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return false
            }
        }

        paramsString := this.__sanitiseParams(params)
        sendcommand := Format('curl "http://localhost:{3}/{1}?{2}"', whichFunc, String(paramsString), this.portCEP)
        if !needResult {
            Run(sendcommand,, "Hide")
            return true
        }
        if InStr(getResp := cmd.result(sendcommand), "Failed to connect to localhost") {
            if WinExist(this.winTitle) ;// will sometimes still fire after ae is closed
                errorLog(Error("1. Unable to connect to localhost server. AERemote Extension may not be running.", -1),, true)
            else
                errorLog(Error("1. remoteFunc was called but AE no longer appears to be open.", -1))
            return false
        }
        try parse := JSON.parse(getResp)
        catch {
            if WinExist(this.winTitle) ;// will sometimes still fire after ae is closed
                errorLog(Error("2. Unable to connect to localhost server. AERemote Extension may not be running."),, true)
            else
                errorLog(Error("2. remoteFunc was called but AE no longer appears to be open.", -1))
            return false
        }
        switch {
            case (!parse.has("result") && parse.has("message")):
                errorLog(ValueError(parse["message"],-1), whichFunc "_" paramsString)
                MsgBox("prem.__remoteFunc() failed.`n`nMessage: " parse["message"] "`nPassed Params:" paramsString)
                return false
            case parse.has("result") && parse["result"] != "true" && parse["result"] != "false":
                return parse["result"]
            case parse.has("result") && isBool(parse["result"]):
                return(parse["result"] = "true" ? true : false)
            default:
                return((parse.has("result")) ? parse["result"] : false)
        }
    }

    /**
     * This function checks for the existence of [AERemote](https://github.com/Tomshiii/PremiereRemote/tree/AE). Can also check for the existence of a specific function within the `index.tsx` file~, or desired UXP `ts` file~
     * @param {String} [checkFunc=""] if `cepOrUXP` is set to `cep`; the name of the function you wish to check for~, else; the `filename/functionname` ie, `custom/addMatchedAdjustmentLayers`~
     * @param {String} [cepOrUXP=cep] determine whether to check CEP functions ~or UXP functions. Must be either `cep` or `uxp`~
     * @returns {Boolean}
     */
    static __checkAERemoteDir(checkFunc := "", cepOrUXP := "cep") {
        switch cepOrUXP, 0 {
            case "cep": return (DirExist(this.remoteDirCEP) && FileExist(this.indexFileCEP) && this.__checkAERemoteFunc(checkFunc, cepOrUXP) ? true : false)
            /* case "uxp":
                ff := this.__splitUXPfileFunc(checkFunc)
                return (DirExist(this.remoteDirUXP) && FileExist(this.funcDirUXP "\" ff.fileName) && this.__checkAERemoteFunc(checkFunc, cepOrUXP) ? true : false) */
        }
    }

    /**
     * This function checks the [AERemote](https://github.com/Tomshiii/PremiereRemote/tree/AE) `index` or ~UXP `.ts`~ file for the desired function
     * @param {String} checkFunc if `cepOrUXP` is set to `cep`; the function name you wish to search for. ie `projPath`~, else; the `filename/functionname` ie, `custom/addMatchedAdjustmentLayers`~
     * @param {String} [cepOrUXP=cep] determine whether to check CEP functions ~or UXP functions. Must be either `cep` or `uxp`~
     * @returns {Boolean}
     */
    static __checkAERemoteFunc(checkFunc, cepOrUXP := "cep") {
        switch cepOrUXP, 0 {
            case "cep":
                return ((InStr(readFile := FileRead(this.indexFileCEP), Format("{}: function (", checkFunc)) ||
                    InStr(readFile, Format("{}: function(", checkFunc)))
                    ? true : false)
            /* case "uxp":
                if !ff := this.__splitUXPfileFunc(checkFunc)
                    return
                return ((InStr(readFile := FileRead(this.funcDirUXP "\" ff.fileName), Format("export async function {}(", ff.funcName)) ||
                    InStr(readFile, Format("export async function {} (", ff.funcName)))
                    ? true : false) */
        }
    }

    /**
     * check the parameters passed to a `__remoteFunc` method to ensure the user has passed them correctly
     * @param {String} [whichFunc] the `whichFunc` parameter passed to either cep ~or uxp~ `__remoteFunc()`
     * @param {Array} [params] an array of params passed to either cep ~or uxp~ `__remoteFunc()`
     * @param {String} [cepOrUXP=cep] determine whether to check CEP functions ~or UXP functions. Must be either `cep` or `uxp`~
     * @returns {Boolean}
     */
    static __checkRemoteParams(whichFunc, params, cepOrUXP := "cep") {
        for v in params {
            if !InStr(v, '=') {
                MsgBox("Parameter not specified`nFunction: " whichFunc,, "262160")
                return false
            }
            splt := StrSplit(v, '=',, 2)
            funcParams := this.__getAERemoteFuncParams(whichFunc, cepOrUXP)
            if funcParams != "" && funcParams != -1 {
                for v in splt {
                    if Mod(A_Index, 2) = 0
                        continue
                    if !funcParams.map.has(v) {
                        MsgBox("Parameter not found for given function`n`nParam: " v "`nFunction: " whichFunc "`ncepOrUXP: " cepOrUXP)
                        return false
                    }
                    /* if cepOrUXP = "uxp" && funcParams.map.get(v) = "boolean" && (splt[A_Index+1] = "1" || splt[A_Index+1] = "0") {
                        MsgBox("Incorrect paramater type`n`n" v "=" splt[A_Index+1] "`nneeds to be boolean" )
                        return false
                    } */
                }
            }
        }
        return true
    }

    /**
     * determines the parameters for the passed AERemote CEP function
     * @param {String} checkFunc the `whichFunc` passed to either `__remoteFunc()` function
     * @param {String} [cepOrUXP=cep] determine whether to check CEP functions ~or UXP functions.~ Must be either `cep` ~or `uxp`~
     * @returns {-1 | "" | Object} returns either; `-1` if function cannot be determined, `""` if the passed function does not contain any parameters, else an object containing `{arr: [all, params], map: Map(all, all, params, types)}`
     */
    static __getAERemoteFuncParams(checkFunc, cepOrUXP := "cep") {
        if !this.__checkAERemoteDir(checkFunc, cepOrUXP)
            return -1
        switch cepOrUXP, 0 {
            case "cep":
                readFile := FileRead(this.indexFileCEP)
                funcPos := (InStr(readFile, Format("{}: function (", checkFunc))) ? InStr(readFile, Format("{}: function (", checkFunc)) : InStr(readFile, Format("{}: function(", checkFunc))
            /* case "uxp":
                if !ff := this.__splitUXPfileFunc(checkFunc)
                    return -1
                readFile := FileRead(this.funcDirUXP "\" ff.fileName)
                funcPos := (InStr(readFile, Format("export async function {}(", ff.funcName))) ? InStr(readFile, Format("export async function {}(", ff.funcName)) : InStr(readFile, Format("export async function {} (", ff.funcName)) */
        }
        funcParamsString := SubStr(readFile, (openParenth := InStr(readFile, "(",, funcPos, 1)+1), (InStr(readFile, ")",, openParenth, 1))-openParenth)
        if funcParamsString = ""
            return ""
        if !InStr(funcParamsString, ",") {
            p := SubStr(funcParamsString, 1, InStr(funcParamsString, ':')-1)
            return {arr: [p], map: Mip(p, true)}
        }
        paramsSplit := StrSplit(funcParamsString, ",", A_Space "`n`r")
        paramsArr := []
        paramsMap := Mip()
        for v in paramsSplit {
            p := SubStr(v, 1, (splitPoint := InStr(v, ':'))-1)
            t := LTrim(SubStr(v, splitPoint+1))
            paramsArr.Push(p)
            paramsMap.Set(p, t)
        }
        return {arr: paramsArr, map: paramsMap}
    }

    /**
     * a helper function for `AERemote` `__remote()` functions to sanitise their parameter string
     * @param {Array} [params] an array of parameters to sanitise
     * @returns {String} the completed parameter string
     */
    static __sanitiseParams(params) {
        paramsString := ""
        if params.Length >= 1 {
            for k, v in params {
                if k = 1 {
                    paramsString := StrReplace(v, "&", "%26")
                    if params.Length == 1
                        break
                    continue
                }
                replaceStr := StrReplace(v, "&", "%26")
                paramsString := paramsString "&" replaceStr
            }
        }
        return StrReplace(paramsString, A_Space, "%20")
    }

    /**
     * Calls a `AERemote` function to directly save the current project.
     * @param {Boolean} [andWait=true] determines whether you wish for the function to wait for the `Save Project` window to open/close. (This is simply to get information returned to you, it should be noted that the thread will still halt until the `AERemote` save function has completed)
     * @param {Boolean} [continueOnBusy=false] determine whether to continue with a save attempt even if AE may be busy
     * @returns {Boolean/String}
     * - `true`      : successful
     * - `false`     : `AERemote`/`save` func/`projPath` not found/save attempt fails (server not running)
     * - `"timeout"` : waiting for the save project window to open/close timed out
     * - `"busy"`    : another window may be open in AE that could cause saving to fail
     */
    static save(andWait := true, continueOnBusy := false) {
        if !isBool(andWait) || !isBool(continueOnBusy) {
            errorLog(PropertyError("Incorrect Parameter Type"),,, true)
            return false
        }
        ;// the below windows will halt or delay the save process if they exist
        ; waitSave := "(?:) " this.winTitle
        haltSave := "(?:Save Project) " this.winTitle
        if winExt.ExistRegex(haltSave)
            return "busy"
        /* if winExt.ExistRegex(waitSave) {
            if !winExt.WaitCloseRegex(waitSave,, 10)
                return "busy"
        } */
        aeWindow := WinGet.AEName()
        if !aeWindow || Type(aeWindow) != "Object" ||
            ((aeWindow.winTitle = "" || !aeWindow.wintitle) &&
            aeWindow.titleCheck = -1 && aeWindow.saveCheck = -1) {
            errorLog(UnsetError("ae.save() was unable to determine the title of the After Effects window"), "The user may not have the correct year set within the settings", 1)
            return false
        }
        try procName := WinGetProcessName(aeWindow.winTitle), procClass := WinGetClass(aeWindow.wintitle)
        catch {
            ;// ae may have crashed
            return false
        }
        if continueOnBusy = false && ((procName = "ahk_exe AfterFX.exe.exe" || procName = "ahk_exe AfterFX.exe (Beta).exe") && (procClass ~= "^AE_CApplication_\d{2}(\.\d+)*$"))
            return "busy"
        state := {hasAppeared: false, hasClosed: false}
        try WinEvent.Exist((*) => state.hasAppeared := true, "Save Project " this.exeTitle)
        try WinEvent.Close((*) => state.hasClosed := true, "Save Project " this.exeTitle)
        __stopCallbacks() {
            try WinEvent.Stop('Exist', "Save Project " this.exeTitle)
            try WinEvent.Stop('Close', "Save Project " this.exeTitle)
        }
        ;// func won't continue until this aeremote func finishes (saving completes)
        blocker := block_ext()
        blocker.On(false)
        SetTimer((*) => blocker.Off(), -250)
        if !this.__remoteFunc("save", true) {
            __stopCallbacks()
            blocker.Off()
            return false
        }
        __stopCallbacks()

        blocker.Off()
        if !andWait
            return true

        ;// waiting for save dialogue to open & close
        if !state.hasAppeared
            return "timeout_nosave"
        if !state.hasClosed
            return "timeout"

        return true
    }

    /**
     * A weaker version of the Premiere_RightClick.ahk script. Set this to a button (mouse button ideally, or something obscure like ctrl + capslock). This function uses a few imagesearches to determine the position of the timeline - NOTE: The imagesearches are still somewhat reliant on the way I have AE setup (I divide some coord ranges to save time on first use), you may need to adjust these if your aetimeline is in a non standard place
     */
    static timeline()
    {
        coord.w()
        MouseGetPos(&xpos, &ypos)
        static graphX := unset
        static graphY := unset
        static end := unset
        static bottom := unset
        static set := unset

        /*
        A small function to get the coords of the graph icon, marker icon & mountain icon to determine the position of your timeline
        */
        getCoords(&graphX, &graphY, &end, &bottom)
        {
            activeWin := WinGet.Title()
            if !InStr(activeWin, "Adobe After Effects 20" ptf.AEYearVer " -") && !InStr(activeWin, "Adobe After Effects (Beta)")
                return
            tool.Cust(A_ThisFunc "() is grabbing the timeline coords")
            if ImageSearch(&x, &y, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " ptf.AE "graph.png") || ImageSearch(&x, &y, 0, 0, A_ScreenWidth / 2, A_ScreenHeight, "*2 " ptf.AE "graph2.png")
                {
                    graphX := x + 30
                    graphY := y + 8
                }
            if ImageSearch(&endX, &endY, A_ScreenWidth / 2, 200, A_ScreenWidth + 20, A_ScreenHeight, "*2 " ptf.AE "marker.png")
                end := endX - 12
            if ImageSearch(&mountX, &mountY, 0, A_ScreenHeight / 4, A_ScreenWidth / 1.5, A_ScreenWidth, "*2 " ptf.AE "mountain.png")
                bottom := mountY - 8
            set := true
        }
        if !IsSet(set)
            getCoords(&graphX, &graphY, &end, &bottom)
        if (!IsSet(graphX) || !IsSet(graphY) || !IsSet(end) || !IsSet(bottom)) || (!InStr(WinGet.Title(), "Adobe After Effects 20" ptf.AEYearVer " -") && !InStr(WinGet.Title(), "Adobe After Effects (Beta) -" ))
            {
                SendInput("{" A_ThisHotkey "}")
                tool.Wait()
                switch set ?? false {
                    case true: tool.Cust("The main window is not active")
                    default:
                        errorLog(UnsetError("A variable was not assigned a value", -1)
                                    , "Or the main window is not active", 1)
                }
                return
            }
        MouseGetPos(&newX, &newY)
        if(xpos > graphX and xpos < end) and (ypos > graphY and ypos < bottom)
            {
                block.On()
                if newX > graphX and newX < end
                    xpos := newX
                MouseMove(xpos, graphY) ;this will warp the mouse to the top part of your timeline defined by &timeline
                SendInput("{Click Down}")
                MouseMove(xpos, ypos)
                block.Off()
                keys.allWait()
                SendInput("{Click Up}")
            }
    }

    /**
     * This function is to quickly input a command into one of the properties of After Effects
     * @param {String} command The command you wish to input
     * @param {Boolean} delete Whether you need the function to delete an extra '(' or ']' that may get automatically generated by AE as the command is input
     */
    static wiggle(command, delete := true)
    {
        CaretGetPos(&findx)
        if findx = ""
            {
                tool.Cust("Couldn't find the caret which indicates you aren't ready to type something`nTo prevent any unintended inputs being sent to AE none will be sent", 3.0)
                errorLog(UnsetError("Couldn't determine the caret position.", -1, findx)
                            , "This indicates the user isn't ready to type anything.")
                return
            }
        SendInput("^a" "{BackSpace}")
        SendInput(command)
        sleep 500
        if delete
            SendInput("{Del}")
        SendInput("{NumpadEnter}")
    }

    /**
     * Sets the zoom state of the current viewer
     * @param {String | Number} [zoom="Fit up to 100%"] The zoom value you wish to set. May be `Fit up to 100%`/`Fit`, or must otherwise be an number between `1` => `1600`
     * @returns {Boolean}
     */
    static setViewerZoom(zoom := "Fit up to 100%") {
        if !WinActive(this.winTitle)
            switchTo.AE()
        aeName := WinGet.AEName()
        checkType := (Type(aeName) != "Object")
        if !aeName || checkType
            return false
        checkTitle := (aeName.winTitle = "" || !aeName.wintitle), checkCanSave := (aeName.titleCheck = -1)
        if checkTitle || checkCanSave {
            return false
        }
        aeWin := UIA.ElementFromHandle(aeName.winTitle,, false)
        coord.s()
        origMouse := obj.MousePos()
        SetMouseDelay(0)
        if zoom != "Fit" && zoom != "Fit up to 100%" && !IsNumber(zoom) && zoom <= 1600 && zoom >= 1 {
            ;// throw
            errorLog(TypeError("Incorrect Paramater type in Parameter #1", -1, zoom),,, true)
            return false
        }
        if zoom = "Fit" || zoom = "Fit up to 100%" {
            try listItem := aeWin.FindElement({Type:50007, Name:zoom})
            catch {
                return false
            }
            listItem.select()
            return true
        }
        try editTextBox := aeWin.FindElement({Type: 50004, Name: "Magnification percentage", matchmode:"Substring"})
        try percent := aeWin.FindElement({Type:50020, Name:"%"})
        catch {
            return false
        }
        MouseMove(percent.Location.x-10, editTextBox.Location.y+5)
        SendInput("{Click}")
        try editText := aeWin.FindElements({Type:50004, Name:"OS_EditText"})
        catch {
            return false
        }
        found := false
        el := false
        for v in editText {
            for child in v.children {
                if InStr(child.Name, "Magnification percentage") {
                    found := true
                    el := child
                    break
                }
            }
            if !found
                continue
        }
        if !found {
            return false
        }
        el.value := zoom
        SendInput("{Enter}")
        MouseMove(origMouse.x, origMouse.y)
        return true
    }

    /**
     * Checks the api to determine if a clip is selected
     * @returns {Boolean}
     */
    static isClipSelected() {
        if (!this.__remoteFunc('isSelected', true) && !this.__remoteFunc('isSelectedMultiple', true))
            return false
        return true
    }

    /** A function to simply copy the current anchor point coordinates and transfer them to the position value. This function is designed for use in the `Transform` Effect and not the motion tab. */
    static anchorToPosition() {
        cepSync := this.__remoteFunc('anchorToPosition', true)
        if cepSync = true
            return
        if !this.isClipSelected() {
            errorLog(TargetError("No clip selected.", -1))
            return
        }
        ;// check to see if the user is in a text field
        if !CaretGetPos(&carx, &cary) {
            tool.Cust("The user is not currently within a text field")
            return
        }
        clipb := clip.clear()
        if !clip.copyWait(clipb.storedClip)
            return
        blocker := block_ext()
        blocker.On()
        anch1 := A_Clipboard
        clip.clear()
        SendEvent("{Tab}")
        if !clip.copyWait(clipb.storedClip) {
            blocker.Off()
            return
        }
        anch2 := A_Clipboard
        delaySI(50, "{Tab}", anch1, "{Tab}", anch2, "{Enter}")
        clip.delayReturn(clipb.storedClip)
        blocker.Off()
    }

    /**
     * Uses UIA to determine if the desired tool is selected. This function may fail if the desired tool is not visible on the screen.
     * @param {String} [toolName] the name of the tool as seen in UIA. ie; `Selection Tool`, `Hand Tool`, `Zoom Tool`, `Orbit Around Cursor Tool`, `Pan Under Cursor Tool`, `Dolly Towards Cursor Tool`, `Rotation Tool`, `Pan Behind (Anchor Point) Tool`, `Rectangle Tool`, `Cube Tool`, `Pen Tool`, `Horizontal Type Tool`, `Brush Tool`, `Clone Stamp Tool`, `Eraser Tool`, Object Matte Tool`, `Puppet Position Pin Tool`
     * @returns {-1 | Boolean | Object}
     * if `returnObj` is `false`;
     *   - returns `-1` when; AE window cannot be determined, AE window is not active, UIA cannot find the `ToolsTab` or the desired tool's button.
     *   - Else returns `true`/`false`
     * if `returnObj` is `true`;
     *   - returns `{error: true, selected: unset, toolEl: unset}` when; AE window cannot be determined, AE window is not active, UIA cannot find the `ToolsTab` or the desired tool's button.
     *   - Else returns `{error: false, selected: Boolean, toolEl: UIA.IUIAutomationElement}`
     */
    static isToolSelected(toolName, returnObj := false) {
        try n := WinGet.AEName()
        if !WinActive(this.winTitle) && !WinActive(this.class) && (IsSet(n) && isObjHasProp(n, 'wintitle', false) && n.wintitle != "") {
            return (returnObj=false) ? -1 : {error: true, selected: unset, toolEl: unset}
        }
        aeUIA := UIA.ElementFromHandle(this.winTitle,, false)
        try toolsTab := aeUIA.FindElement({Type:50033, Name: "ToolsTab"})
        catch {
            errorLog(TargetError("Failed to find the Tools Tab", -1))
            return (returnObj=false) ? -1 : {error: true, selected: unset, toolEl: unset}
        }
        try tool := toolsTab.FindElement({Type:50000, Name:toolName, matchmode:"Substring"})
        catch {
            errorLog(TargetError("Failed to find the desired tool", -1, toolName))
            return (returnObj=false) ? -1 : {error: true, selected: unset, toolEl: unset}
        }
        toolBool := (tool.Value = "Selected") ? true : false
        return (returnObj = false ? toolBool : {error: false, selected: toolBool, toolEl: toolsTab})
    }

    /**
     * This function will attempt to select the desired tool using UIA.
     * @param {String} [toolName=Selection Tool] the name of the tool as seen in UIA. ie; `Selection Tool`, `Hand Tool`, `Zoom Tool`, `Orbit Around Cursor Tool`, `Pan Under Cursor Tool`, `Dolly Towards Cursor Tool`, `Rotation Tool`, `Pan Behind (Anchor Point) Tool`, `Rectangle Tool`, `Cube Tool`, `Pen Tool`, `Horizontal Type Tool`, `Brush Tool`, `Clone Stamp Tool`, `Eraser Tool`, Object Matte Tool`, `Puppet Position Pin Tool`
     * @returns {-1 | Boolean}
     */
    static selectTool(toolName := "Selection Tool") {
        selectedObj := this.isToolSelected(toolName, true)
        if selectedObj.error = true
            return -1
        if selectedObj.selected = false {
            try selectedObj.toolEl.FindElement({Type:50000, Name: toolName, matchmode:"Substring"}).Click()
            catch {
                errorLog(TargetError("Failed to click the desired tool.", -1, toolName))
                return false
            }
        }
        return true
    }

    __Delete() {
        try WinEvent.Stop('Exist', "Save Project " this.exeTitle)
        try WinEvent.Stop('Close', "Save Project " this.exeTitle)
	}
}
