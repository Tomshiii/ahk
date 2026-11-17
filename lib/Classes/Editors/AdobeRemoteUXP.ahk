/************************************************************************
 * @description Shared base class for the `AE` and `Prem` classes. Holds all of the logic required to talk to the PremiereRemote UXP server (registry, parameter validation, socket/docker/panel checks, request + response handling) so it only needs to be written/maintained once.
 *
 * Both Adobe apps use the **same server, port and docker container** - After Effects functions are simply routed under the `ae/` prefix. Everything that differs between the two apps is exposed as a static property/hook that the derived class overrides.
 *
 * Because AHK static methods are inherited and `this` is always the *derived* class when calling `AE.method()`/`Prem.method()`, any state assigned here (`this.__uxpFuncMap := ...`, `this.__uxpOpen := ...`, etc) is stored per app automatically.
 *
 * Derived classes are expected to declare their own `portUXP`, `remoteDirUXP`, `indexFileUXP`, `winTitle` & `remoteActiveUXP`
 * @author tomshi
 * @date 2026/11/17
 * @version 1.0.1
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\errorLog.ahk
#Include Classes\null.ahk
#Include Classes\cmd.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\notifyExt.ahk
#Include Classes\Apps\docker.ahk
#Include Functions\isBool.ahk
#Include Functions\checkBool.ahk
#Include Other\_socket.ahk
#Include Other\JSON.ahk
; }

class AdobeRemoteUXP {

    ;// ====== identity / per app configuration (override in the derived class) ======
    static __app         := ""
    static __appName     := ""
    static __remoteName  := ""
    static __uxpPrefix   := ""
    static __notConnStr  := ""
    static currentSetVer := ""

    ;// the docker project/service that hosts the server. Shared by both apps
    static dockerProject := "premiereremote-uxp"
    static dockerService := "premiere-remote"

    ;// ====== shared state (assigned per derived class on first write) ======
    static __uxpInstalled := null
    static __uxpFuncMap   := false
    static __uxpRegStamp  := ""
    static __uxpOpen      := false

    ;// ====== hooks (override in the derived class) ======
    /** @returns {Object | false} the object returned by `WinGet.AEName()`/`WinGet.PremName()` */
    static __getWinObj() => false

    /** return `false` to stop `__remoteUXPCore()` before anything is sent */
    static __preflight() => true

    /** check whether a given function exists using the app's own check function */
    static __checkUXPFunc(checkFunc) => false

    /** any additional app specific requirement for UXP to be considered installed */
    static __uxpExtraCheck() => true

    ;// ====== installation ======
    /**
     * Determines whether the UXP plugin (+ docker) is installed. Result is cached once determined.
     * @returns {Boolean}
     */
    static __isUXPInstalled() {
        if this.__uxpInstalled = false || this.__uxpInstalled = true
            return this.__uxpInstalled
        if this.__uxpExtraCheck() && docker.isInstalled() && DirExist(this.remoteDirUXP) && FileExist(this.indexFileUXP) {
            this.__uxpInstalled := true
            return true
        }
        this.__uxpInstalled := false
        return false
    }

    /**
     * Determines whether the UXP plugin is installed
     * @returns {Boolean}
     */
    static __checkUXPDir() {
        this.__isUXPInstalled()
        return this.__uxpInstalled = true
    }

    ;// ====== socket probing ======
    /** attempts to connect to the UXP server so `remoteActiveUXP` can be kept up to date. Designed to be called on a timer */
    static __checkRemoteUXP() {
        if !WinExist(this.winTitle)
            return
        try {
            sock := winsock("probe", (s,e,c) => this.__probeCB(s,e,c), "IPV4")
            sock.Connect("localhost", this.portUXP)
        } catch {
            errorLog(TargetError("Couldn't probe localhost", -1))
            return
        }
    }

    static __probeCB(sock, event, err) {
        if (event = "Connect") {
            this.remoteActiveUXP := (err = 0)
            sock.Close()
        } else if (event = "Close") {
            this.remoteActiveUXP := false
            sock.Close()
        }
    }

    ;// ====== registry ======
    /**
     * Turns a function name into its registry key, applying the app's route prefix. Lets you write `custom/save` instead of `ae/custom/save`.
     * This also guarantees a call is routed to the correct app.
     * @param {String} name `custom/save` or `ae/custom/save`
     * @returns {String}
     */
    static __uxpName(name) {
        name := StrReplace(name, "\", "/")
        p := this.__uxpPrefix
        return (p = "" || SubStr(name, 1, StrLen(p)) = p) ? name : p name
    }

    /**
     * Fetches the UXP function registry from the plugin once per script run and caches it in memory
     * @param {Boolean} [forceRefresh=false] ignore the cache and re-fetch
     * @returns {Map | false}
     */
    static __getUXPRegistry(forceRefresh := false) {
        try stamp := FileGetTime(this.indexFileUXP)
        catch
            stamp := this.__uxpRegStamp
        if stamp != this.__uxpRegStamp
            forceRefresh := true

        if !forceRefresh && IsObject(this.__uxpFuncMap)
            return this.__uxpFuncMap

        resp := cmd.httpGet(Format("http://localhost:{1}/{2}common/getRegistryJSON", this.portUXP, this.__uxpPrefix))
        if resp == null || resp = "" || InStr(resp, this.__notConnStr)
            return false
        if resp is String && SubStr(resp, 1, 1) = '"' && SubStr(resp, -1, 1) = '"'
            resp := SubStr(resp, 2, StrLen(resp)-2)

        if IsObject(resp)
            registry := resp
        else {
            try registry := JSON.parse(StrReplace(resp, "\"))
            catch
                return false
        }
        if !(registry is Map)
            return false
        this.__uxpRegStamp := stamp
        return this.__uxpFuncMap := registry
    }

    /**
     * @param {String} whichFunc `file/func` (or `ae/file/func`), eg `custom/save`
     * @param {Boolean} [forceRefresh=false] ignore the cache and re-fetch function registry
     * @returns {false | Object} `{path, fileName, funcName, params}`
     */
    static __getUXPFuncInfo(whichFunc, forceRefresh := false) {
        whichFunc := this.__uxpName(whichFunc)
        if !registry := this.__getUXPRegistry(forceRefresh)
            return false
        if !registry.Has(whichFunc) {
            whichFunc := this.__warnUXPFuncCase(whichFunc, registry)
            if whichFunc = ""
                return false
        }

        lastSlash := InStr(whichFunc, "/",, -1)
        return {
            path: whichFunc,
            fileName: SubStr(whichFunc, 1, lastSlash-1),
            funcName: SubStr(whichFunc, lastSlash+1),
            params: registry[whichFunc]["params"]
        }
    }

    /**
     * if `whichFunc` only fails to match because of casing, warn the user with the correct path
     * @returns {String} the correctly cased registry key, or `""` if there's no case-insensitive match either
     */
    static __warnUXPFuncCase(whichFunc, registry) {
        for key in registry {
            if key = whichFunc {    ;// `=` is case-insensitive on strings
                msg := "UXP function path has incorrect casing.`nPassed: " whichFunc "`nExpected: " key
                errorLog(ValueError(msg, -2, whichFunc))
                notifyExt.showIfNotExist(this.__app "UXPFuncCase", this.__app ".__remoteUXP()", msg, 'C:\Windows\System32\imageres.dll|icon80',,, "theme=Dark dur=6 bdr=Red show=Fade@250 hide=Fade@250 maxW=800 POS=BC")
                return key
            }
        }
        errorLog(TargetError("UXP function does not exist in the plugin registry.", -1, whichFunc),,, true)
        return ""
    }

    ;// ====== parameters ======
    /**
     * a helper function for `__remote()` functions to sanitise their parameter string
     * @param {Array} [params] an array of parameters to sanitise
     * @returns {String} the completed parameter string
     */
    static __sanitiseParams(params) {
        clean := []
        for v in params {
            if v != ""
                clean.Push(StrReplace(StrReplace(v, "&", "%26"), A_Space, "%20"))
        }
        paramsString := ""
        for i, v in clean
            paramsString .= (i = 1 ? "" : "&") v
        return paramsString
    }

    /**
     * Validates the parameters passed to a remote function against the parameter definitions from the plugin registry
     * @param {String} funcPath the function path (used for error messages)
     * @param {Array} defs the parameter definitions from the registry
     * @param {Array} params the parameters the user passed, as `name=value` strings
     * @param {String} [extra=""] extra text appended to each error message
     * @returns {Boolean}
     */
    static __validateRemoteParams(funcPath, defs, params, extra := "") {
        passed := []
        for v in params {
            if v = ""
                continue
            if !InStr(v, '=') {
                MsgBox("Parameter not specified`nFunction: " funcPath extra,, "262160")
                return false
            }
            splt := StrSplit(v, '=',, 2)
            name := splt[1], value := splt[2]

            def := false
            for p in defs {
                if p["name"] == name {
                    def := p
                    break
                }
            }
            if !def {
                MsgBox("Parameter not found for given function`n`nParam: " name "`nFunction: " funcPath extra)
                return false
            }

            switch def["type"], 0 {
                case "boolean":
                    if value != "true" && value != "false" {
                        MsgBox("Incorrect parameter type`n`n" name "=" value "`nneeds to be boolean (true/false)")
                        return false
                    }
                case "number":
                    if !IsNumber(value) {
                        MsgBox("Incorrect parameter type`n`n" name "=" value "`nneeds to be a number")
                        return false
                    }
            }
            passed.Push(name)
        }

        for p in defs {
            if !p["required"]
                continue
            found := false
            for n in passed {
                if n == p["name"] {
                    found := true
                    break
                }
            }
            if !found {
                MsgBox("Required parameter missing`n`nParam: " p["name"] "`nFunction: " funcPath extra)
                return false
            }
        }
        return true
    }

    /**
     * check the parameters passed to a `__remoteUXP()` call to ensure the user has passed them correctly
     * @param {String} whichFunc the function being called
     * @param {Array} params an array of params passed to `__remoteUXP()`
     * @returns {Boolean}
     */
    static __checkUXPParams(whichFunc, params) {
        if !info := this.__getUXPFuncInfo(whichFunc)
            return false
        return this.__validateRemoteParams(info.path, info.params, params)
    }

    ;// ====== the main event ======
    /**
     * The shared logic behind `AE.__remoteUXP()` and `Prem.__remoteUXP()`. This function is syntatic sugar to activate a UXP function through the PremiereRemote server. If the function returns a `json` object, this function will attempt to pass that back as such.
     *
     * ## Warning
     * ##### *If you intend on sending a parameter that contains a SPACE you need to use `%20` instead. ie; instead of `Gaussian Blur`, use `Gaussian%20Blur`*. The function will attempt to rectify this for you automatically, but relying on such could result in issues.
     * ##### Similarly; sending a parameter with `&` may cause issues. It is recommended to send `%26` instead. This function will attempt to rectify the issue itself but again, relying on such could result in issues.
     * @param {String} whichFunc the function you wish to call, **including the file name**; eg. `custom/save`. If the file is stored in a folder, the entire path must be passed. The app's route prefix (`ae/`) is optional and added for you.
     * @param {Boolean} [runAsync=false] determines whether to tell `cmd.httpGet()` to run synchronously or asynchronously
     * @param {Varadic/String} params any additional paramaters, as `name=value` strings. do **not** add the `&` between paramaters, this function will add that itself
     * @returns {String | Boolean | Object | null}
     */
    static __remoteUXPCore(whichFunc, runAsync := false, params*) {
        if !WinExist(this.winTitle)
            return null
        ;// UXP only available in AE beyond 27.1
        if this.__app = "ae" {
            if VerCompare(this.currentSetVer, "v27.1") < 0
                return null
        }
        whichFunc := StrReplace(whichFunc, "\", "/")
        if !InStr(whichFunc, "/") {
            errorLog(PropertyError('__remoteUXP() failed. Parameter #1 does not contain path to desired file', -2, whichFunc), whichFunc,, true)
            return null
        }
        whichFunc := this.__uxpName(whichFunc)

        ;// app specific checks (ie. premiere's busy windows)
        if !this.__preflight()
            return null

        if !this.__checkUXPDir() {
            errorLog(TargetError(this.__remoteName " UXP is not installed.", -2, whichFunc),,, true)
            return null
        }
        if !this.__checkUXPFunc(whichFunc) {
            errorLog(TargetError(this.__remoteName " UXP function does not exist or UXP panel is not open.", -2, whichFunc),,, true)
            return null
        }
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true) {
            errorLog(Error("Core Functionality.ahk is not open but is required.", -2),,, true)
            return null
        }

        checkWin := this.__getWinObj()
        checkType := (Type(checkWin) != "Object")
        if !checkWin || checkType {
            errorLog(Error("Failed to determine " this.__appName " name", -1),, false)
            return null
        }
        checkTitle := (checkWin.winTitle = "" || !checkWin.wintitle), checkCanSave := (checkWin.titleCheck = null)
        if checkTitle || checkCanSave {
            errorLog(Error("Failed to determine " this.__appName " name", -1),, false)
            return null
        }

        ;// determine the state of the socket connection
        if A_ScriptName != "Core Functionality.ahk" {
            props := CLSID_Objs.loadProp(this.__app, ["remoteActiveUXP", "__uxpOpen"])
            remoteUXPState := props["remoteActiveUXP"]
            this.__uxpOpen := props["__uxpOpen"]
        } else {
            remoteUXPState := this.remoteActiveUXP
        }
        if remoteUXPState = "loading" {
            errorLog(Error("A socket connection could not be established to the UXP plugin", -1),, false)
            notifyExt.showIfNotExist(this.__app "SocketLoadingUXP",, "Socket connection to UXP plugin still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            return null
        }
        if !remoteUXPState {
            errorLog(Error("A socket connection could not be established to UXP plugin", -1),, false)
            notifyExt.showIfNotExist(this.__app "SocketConnectionErrorUXP",, "A socket connection could not be established to UXP plugin", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            return null
        }

        dockerInstalled := docker.isInstalled(), dockerIsRunning := docker.isRunning(), serverRunning := docker.isContainerRunning(this.dockerProject, this.dockerService)
        if !dockerInstalled || !dockerIsRunning || !serverRunning {
            errorLog(MethodError("Docker server for the " this.__remoteName " UXP panel is not currently running.", -2))
            notifyExt.showIfNotExist(this.__app "PanelDockerError",, "Docker server for the " this.__remoteName " UXP panel is not currently running.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            return null
        }

        if !this.__uxpOpen {
            isPanelOpen := cmd.httpGet(Format("http://localhost:{2}/{1}", this.__uxpPrefix "custom/isPanelOpen", this.portUXP), true)
            if isPanelOpen == null || (isPanelOpen != '"uxp visible=true"') {
                errorLog(MethodError(this.__remoteName " UXP panel isn't open.", -2))
                notifyExt.showIfNotExist(this.__app "PanelNotOpenUXP",, this.__remoteName " UXP panel is not open.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return null
            }
            this.__uxpOpen := true
            CLSID_Objs.writeProp(this.__app, "__uxpOpen", true)
        }

        ;// param check needs to happen later as it needs to retrieve the registry from the plugin
        if !info := this.__getUXPFuncInfo(whichFunc) {
            errorLog(TargetError("UXP function does not exist in the plugin registry.", -1, whichFunc),,, true)
            return null
        }
        if !this.__checkUXPParams(whichFunc, params) {
            errorLog(TargetError("User passed incorrect Parameters to function.", -1, whichFunc),,, true)
            return null
        }

        paramsString := this.__sanitiseParams(params)
        sendcommand := paramsString != ""
            ? Format('http://localhost:{3}/{1}?{2}', info.path, String(paramsString), this.portUXP)
            : Format("http://localhost:{2}/{1}", info.path, this.portUXP)
        getResp := cmd.httpGet(sendcommand, runAsync,, 0)

        if getResp == null || InStr(getResp, this.__notConnStr) {
            ;// will sometimes still fire after the app is closed
            if WinExist(this.winTitle) {
                errorLog(Error("1. Unable to connect to localhost server. " this.__remoteName " UXP Extension may not be running.", -1))
                notifyExt.showIfNotExist(this.__app "FailedResponseUXP",, "Unable to connect to localhost server. " this.__remoteName " UXP Extension may not be running.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
            }
            else
                errorLog(Error("1. remoteUXP was called but " this.__appName " no longer appears to be open.", -1))
            return null
        }
        if getResp ~= "null_version_\d+(?:\.\d+)*" {
            split := StrSplit(getResp, "_")
            throw MethodError("Unsupported minimum " this.__appName " version for the desired function`n" whichFunc " - requires " this.__appName " " split[-1], -2)
        }
        try parse := JSON.parse(getResp)
        catch as e {
            if !InStr(e.Message, "Malformed JSON - unrecognized character") {
                if WinExist(this.winTitle)
                    errorLog(Error("Unable to connect to localhost server. " this.__remoteName " UXP Extension may not be running."))
                else
                    errorLog(Error("remoteUXP was called but " this.__appName " no longer appears to be open.", -1))
                return null
            }
        }
        switch {
            case IsSet(parse) && parse.Has("error"):
                if Type(parse["error"]) = "String" {
                    errorLog(MethodError(parse["error"], -1), whichFunc "_" paramsString)
                    MsgBox(this.__app ".__remoteUXP() failed.`n`nError: " parse["error"] "`nFunction:" whichFunc "`nPassed Params:" paramsString)
                    return null
                }
                if parse.Has("instancePath") && parse.Has("message") {
                    errorLog(MethodError("UXP function encountered an error", -1), "func: " parse["instancePath"] " || error message: " parse["message"])
                    MsgBox(this.__app ".__remoteUXP() failed.`n`nCheck logs for details")
                    return null
                }

                e := JSON.stringify(parse)
                errorLog(MethodError("UXP function encountered an error", -1), e)
                MsgBox(this.__app ".__remoteUXP() failed.`n`n" e)
                return null
            case !IsSet(parse) && getResp != "":
                try {
                    envelope := JSON.parse('{"response":' getResp '}')
                    decodedResp := envelope["response"]

                    try return JSON.parse(decodedResp)
                    catch
                        return (isBool(decodedResp) ? checkBool(decodedResp) : decodedResp)
                }
                catch {
                    sanitiseResp := ((SubStr(getResp, 1, 1) = '"' && SubStr(getResp, -1, 1) = '"')
                        ? SubStr(getResp, 2, StrLen(getResp)-2)
                        : getResp)

                    return (isBool(sanitiseResp) ? checkBool(sanitiseResp) : sanitiseResp)
                }
        }
    }
}
