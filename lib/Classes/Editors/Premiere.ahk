/************************************************************************
 * @description A library of useful Premiere functions to speed up common tasks. Most functions within this class use `KSA` values - if these values aren't set correctly you may run into confusing behaviour from Premiere
 * Code is maintained for the version of Premiere listed below
 * Functions are not guaranteed to work correctly on previous versions of Premiere. I make an effort to backport as much as I can, but as I only use one version of premiere I am unlikely to catch little niche issues. Please see the version number below to know which version of Premiere I am currently using for testing.
 * @premVer 26.3
 * @author tomshi
 * @date 2026/07/07
 * @version 2.4.43
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Settings.ahk
#Include Classes\block.ahk
#Include Classes\coord.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\winget.ahk
#Include Classes\obj.ahk
#Include Classes\keys.ahk
#Include Classes\switchTo.ahk
#Include Classes\clip.ahk
#Include Classes\errorLog.ahk
#Include Classes\WM.ahk
#Include Classes\cmd.ahk
#Include Classes\Mip.ahk
#Include Classes\Move.ahk
#Include Classes\CLSID_Objs.ahk
#Include Classes\Editors\Premiere_UIA.ahk
#Include Classes\Editors\Premiere_TimelineColours.ahk
#Include Classes\winExt.ahk
#Include Classes\notifyExt.ahk
#Include GUIs\tomshiBasic.ahk
#Include Other\UIA\UIA.ahk
#Include Other\WinEvent.ahk
#Include Functions\getHotkeys.ahk
#Include Functions\delaySI.ahk
#Include Functions\delayFuncs.ahk
#Include Functions\detect.ahk
#Include Functions\loadXML.ahk
#Include Functions\change_msgButton.ahk
#Include Functions\checkStuck.ahk
#Include Functions\isBool.ahk
#Include Functions\checkbool.ahk
#Include Functions\isObjHasProp.ahk
#Include Functions\determineAdobeVer.ahk
#Include Functions\base64Encode.ahk
#Include Other\Notify\Notify.ahk
#Include Other\ShinsImageScanClass.ahk
#Include Other\Array.ahk
#Include Other\_socket.ahk
; }

class Prem {

    static __New() {
        try this.UserSettings := CLSID_Objs.load("UserSettings")
        catch {
            this.UserSettings := UserPref(true)
        }
        ignoreWins := ["- Tomshi Installer", "Install Tomshi AHK", "uninstall.ahk", "closeAll.ahk", "reloadAll.ahk", "installNode.ahk", "installPremRemote.ahk"]
        ignoreWinExist(ignoreWins) {
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
        nodeInstalled   := RegRead("HKLM\SOFTWARE\Node.js", "Version", 0)
        remoteInstalled := DirExist(A_AppData "\Adobe\CEP\extensions\PremiereRemote")
        if (!nodeInstalled || !remoteInstalled) && !ignoreWinExist(ignoreWins) {
            throwStr := (!nodeInstalled && !remoteInstalled) ? "Node.js & PremiereRemote are not Installed. Both are  required.`nPlease reinstall for proper functionality." : ((!nodeInstalled && remoteInstalled) ? "Node.js is not currently installed. It is required for proper functionality.`nPlease install Node.js and try again." : "PremiereRemote is not currently installed. It is required for proper functionality.`nPlease install PremiereRemote and try again.")
            if A_ScriptName != "Core Functionality.ahk" && !ignoreWinExist(ignoreWins)
                throw TargetError(throwStr, -1)
            else
                errorLog(TargetError(throwStr, -1))
        }

        this.currentSetVer := SubStr(this.UserSettings.premVer, 2)
        ;// ensure minimum version
        regInstalledVer := determineAdobeVer({baseName: "Adobe Premiere Pro.exe", beta:"Adobe Premiere Pro (Beta).exe"})
        switch regInstalledVer {
            case false: (A_ScriptName != "Core Functionality.ahk" && !ignoreWinExist(ignoreWins)) ?errorLog(TargetError("Premiere is not currently installed or the incorrect version is set."),,, true) : errorLog(TargetError("Premiere is not currently installed or the incorrect version is set."))

            default:
                if VerCompare(regInstalledVer.version, this.minVer) < 0 {
                    ;// throw
                    errorLog(TargetError("Installed version of Premiere is not supported.`nMin version: " this.minVer,, regInstalledVer.version),,, true)
                }
        }

        this.setUI()
        if A_ScriptName != "Core Functionality.ahk" && winExt.ExistRegex("Core Functionality.ahk",,,, true) && !ignoreWinExist(ignoreWins) {
            try {
                activeObj := CLSID_Objs.load("prem")
                this.theme := activeObj.theme, this.defaultTheme := activeObj.theme
                this.timelineCol := activeObj.timelineCol, this.timelineColArr := activeObj.timelineColArr
                this.sequenceArr := activeObj.sequenceArr
                this.__setTimelineCol(this.UI, this.theme)
            } catch {
                this.__determineTheme()
            }
        } else {
            this.__determineTheme()
        }

        if A_ScriptName = "Core Functionality.ahk" && regInstalledVer != false && nodeInstalled != false && remoteInstalled != false  {
            if (this.useSwapSequences = true || this.useSwapSequences = "true")
                SetTimer(this.__setCurrSeq.Bind(this), this.prevSeqDelay)

            ;// check for premremote and NPM before setting timer
            extensionsPath := A_AppData "\Adobe\CEP\extensions"
            remotePath     := extensionsPath "\PremiereRemote"
            getNPM := cmd.result('powershell -c "Get-Command -Name npm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1"')
            if DirExist(remotePath) && (getNPM != false && getNPM != "")
                SetTimer(this.checkRemote.Bind(this), 2000)

            ;// toggle multicam when audio effect windows become active
            if !WinEvent.IsRegistered("Active", "Clip Fx Editor " this.exeTitle)
                WinEvent.Active((*) => (this.__disableMulticamOnAudioEffect("disable", "Clip Fx Editor " this.exeTitle)), "Clip Fx Editor " this.exeTitle)
            if !WinEvent.IsRegistered("Close", "Clip Fx Editor " this.exeTitle)
                WinEvent.Close((*) => (this.__disableMulticamOnAudioEffect("enable", "Clip Fx Editor " this.exeTitle)), "Clip Fx Editor " this.exeTitle)
        }
    }

    static minVer := "26.2"
    static KSA {
        get => CLSID_Objs.load("KSA")
    }
    static UserSettings := ""
    static currentSetVer := ""
    static spectrumUI_Version := "25.0"
    static timelineCols := Mip()
    static timelineColArr := []
    static theme := "darkest"
    static defaultTheme {
        get {
            try return this.UserSettings.premDefaultTheme
            catch {
                return this.theme
            }
        }
    }
    static UI := "Spectrum"
    static defaultUI := "Spectrum"
    static sequenceArr := []
    static resetSeqTimer := false
    static prevSeqDelay {
        get => (this.UserSettings.premPrevSeqDelay * 1000)

    }
    static pauseSeqTimer := false
    static useSwapSequences {
        get => this.UserSettings.use_swapSequences
    }
    static remoteActive := "loading"

    static exeTitle := Editors.Premiere.winTitle
    static winTitle := this.exeTitle
    static class    := Editors.Premiere.class
    static path     := ptf["Premiere"]

    ;// colour of playhead
    static playhead  := 0x4096F3

    ;// colour of various icons
    static iconHighlight := 0x6A6A6A
    static eyeDisabled   := 0x4B4B4B
    static soloColour    := 0xE9C700
    static muteColour    := 0xE9C700

    ;// transition handles
    static transitionHandleInsideSquare := 0xB0B0B0
    static transitionHandleHalfSquare := 0x6A6A6A

    ;// track keyframes
    static keyframeGrey := 0xb0b0b0
    static keyframeBlue := 0x4096f3

    ;// valuehold()
    static valueBlue      := 0x4096f3
    static effCtrlSegment := 21

    ;// variable for prem.thumbScroll()
    static scrollSpeed := 5

    ;// variables for `getTimeline()`
    static timelineVals     := false
    static timelineRawX     := 0
    static timelineRawY     := 0
    static timelineXValue   := 0
    static timelineYValue   := 0
    static timelineXControl := 0
    static timelineYControl := 0
    static focusColour      := 0x4096F3
    static editTabX         := 154
    static editTabY         := 35
    static editTabCol       := 0xD0D0D0

    ;// rbuttonPrem
    static RClickIsActive      := false

    ;// variables for `delayPlayback()` && `rippleTrim()`
    static defaultDelay := 400
    static delayTime    := 0

    ;// screenshots
    static scEddie        := "1"
    static scNarrator     := "1"
    static scJuicy        := "1"
    static scMully        := "1"
    static scJosh         := "1"
    static scDesktop      := "1"
    static scEnvironment  := "1"
    static scGuest1  := "1"
    static scGuest2  := "1"

    ;// PremiereRemote variables
    static remoteDir := A_AppData "\Adobe\CEP\extensions\PremiereRemote"
    static indexFile := this.remoteDir "\host\src\index.tsx"

    ;// swapChannels()
    static secondChannel := 0

    ;// toggleLayerButtons()
    static layerSource := 16
    static layerLock   := 48
    static layerTarget := 71
    static layerSync   := 96
    static layerMute   := 119
    static layerSolo   := 142
    static layerDivider := 0x303030
    static toggleWaiting := false
    static toggleableButtons := Mip("source", true, "target", true, "sync", true, "mute", true, "solo", true, "lock", true)

    static prevMulticamState := true
    static audioWaitClose    := false

    ;// MButton
    static MButtonPanning := false

    static __OSwindow() => WinExist("OS_PopupWindow ahk_class DroverLord - Window Class " this.winTitle)

    static checkRemote() {
        if !WinExist(this.winTitle)
            return
        try {
            sock := winsock("probe", (s,e,c) => this.probeCB(s,e,c), "IPV4")
            sock.Connect("localhost", 8081)
        } catch {
            errorLog(TargetError("Couldn't probe localhost", -1))
            return
        }
    }

    static probeCB(sock, event, err) {
        if (event = "Connect") {
            this.remoteActive := (err = 0)
            sock.Close()
        } else if (event = "Close") {
            this.remoteActive := false
            sock.Close()
        }
    }

    static setUI() {
        switch  {
            case VerCompare(this.currentSetVer, this.spectrumUI_Version) >= 0: this.UI := "Spectrum"
            default: this.UI := this.defaultUI
        }
    }

    /** Sets required class values for the user's premiere theme. Versions greater than the Spectrum UI update will have their theme determined automatically based off their premiere settings file */
    static __determineTheme() {
        ;// timeline colours + themes
        switch this.UI {
            case "Spectrum":
                filecheck := (FileExist(ptf['PremProfile'] "Adobe Premiere Pro Prefs")) ? ptf['PremProfile'] "Adobe Premiere Pro Prefs" : ((FileExist(ptf['PremProfile'] "Adobe Premiere Prefs")) ? ptf['PremProfile'] "Adobe Premiere Prefs" : false)
                if !filecheck {
                    this.theme := this.defaultTheme
                    this.__setTimelineCol("Spectrum", this.theme) ;// defaults to this.defaultTheme
                    return
                }
                loadSettings := loadXML(FileRead(filecheck))
                if !loadSettings {
                    if !Notify.Exist('notDetermined') {
                        Notify.Show('Premiere theme could not be determined. Settings file was busy', 'Defaulting to "' this.defaultTheme '". Fallback default can be set in ``settingsGUI()``', 'C:\Windows\System32\imageres.dll|icon94',,, 'theme=Dark dur=6 bdr=Red show=Fade@250 hide=Fade@250 maxW=400 tag=notDetermined')
                        errorLog(Error("Premiere theme could not be determined. File was busy", -1))
                    }
                    this.__setTimelineCol("Spectrum", this.defaultTheme)
                    return
                }

                props := loadSettings.selectSingleNode("/PremiereData/Preferences/Properties/fe.color.brightnesscc8.1")
                switch props.text {
                    case "7.9999998211860657": this.theme := "darkest", this.__setTimelineCol("Spectrum", this.theme)
                    case "34.999999403953552": (MsgBox("The current theme is currently unsupported. Reverting to: " this.defaultTheme), this.theme := "darkest", this.__setTimelineCol("Spectrum", this.theme)) ;this.theme := "dark",    this.__setTimelineCol("Spectrum", this.theme)
                    case "80.000001192092896": (MsgBox("The current theme is currently unsupported. Reverting to: " this.defaultTheme), this.theme := "darkest", this.__setTimelineCol("Spectrum", this.theme)) ;this.theme := "light",   this.__setTimelineCol("Spectrum", this.theme)
                    case "0":
                        sleep 50
                        if !Notify.Exist('notDeterminedIntZero') {
                            Notify.Show('Premiere theme could not be determined.', 'Sometimes the Premiere settings file has the parameter set to ``0``.`nFlipping your setting back and forth generally fixes the issue.', 'C:\Windows\System32\imageres.dll|icon94',,, 'theme=Dark dur=6 bdr=Red show=Fade@250 hide=Fade@250 maxW=400 tag=notDeterminedIntZero')
                            errorLog(Error("Premiere theme could not be determined. Settings File int: " props.text, -1))
                            setWithRemote := (this.__checkPremRemoteDir('setProperty') && WinExist(this.winTitle) != 0)

                            title := "Fix settings file"
                            SetTimer(change_msgButton.Bind(title, "darkest", "dark", "light"), 16)
                            setTheme := MsgBox("Set your theme. Which theme are you using?", title, "0x2 0x1000")
                            WinWaitClose(title)
                            switch setTheme {
                                case "Abort": ;// darkest
                                    props.text := "7.9999998211860657"
                                    loadSettings.save(filecheck)
                                    (setWithRemote) ? this.__remoteFunc('setProperty',, "pref=fe.color.brightnesscc8.1", "value=7.9999998211860657", "persistent=true", "createIfNotExist=false") : ""
                                    this.theme := "darkest"
                                case "Retry": ;// dark
                                    MsgBox("This theme is currently unsupported. Reverting to: " this.defaultTheme)
                                    props.text := "7.9999998211860657"
                                    loadSettings.save(filecheck)
                                    (setWithRemote) ? this.__remoteFunc('setProperty',, "pref=fe.color.brightnesscc8.1", "value=7.9999998211860657", "persistent=true", "createIfNotExist=false") : ""
                                    this.theme := "darkest"
                                    /* props.text := "34.999999403953552"
                                    loadSettings.save(filecheck)
                                    (setWithRemote) ? this.__remoteFunc('setProperty',, "pref=fe.color.brightnesscc8.1", "value=34.999999403953552", "persistent=true", "createIfNotExist=false") : ""
                                    this.theme := "dark" */
                                case "Ignore": ;// light
                                    MsgBox("This theme is currently unsupported. Reverting to: " this.defaultTheme)
                                    props.text := "7.9999998211860657"
                                    loadSettings.save(filecheck)
                                    (setWithRemote) ? this.__remoteFunc('setProperty',, "pref=fe.color.brightnesscc8.1", "value=7.9999998211860657", "persistent=true", "createIfNotExist=false") : ""
                                    this.theme := "darkest"
                                    /* props.text := "80.000001192092896"
                                    loadSettings.save(filecheck)
                                    (setWithRemote) ? this.__remoteFunc('setProperty',, "pref=fe.color.brightnesscc8.1", "value=80.000001192092896", "persistent=true", "createIfNotExist=false") : ""
                                    this.theme := "light" */
                            }
                        }
                        this.__setTimelineCol("Spectrum", this.defaultTheme)
                    default:
                        sleep 50
                        if !Notify.Exist('notDetermined') {
                            Notify.Show('Premiere theme could not be determined.', 'Defaulting to "' this.defaultTheme '". Fallback default can be set in ``settingsGUI()``', 'C:\Windows\System32\imageres.dll|icon94',,, 'theme=Dark dur=6 bdr=Red show=Fade@250 hide=Fade@250 maxW=400 tag=notDetermined')
                            errorLog(Error("Premiere theme could not be determined.", -1))
                        }
                        this.__setTimelineCol("Spectrum", this.defaultTheme)
                }
        }

        ;// other values
        switch this.UI {
            case "Spectrum":
                ;// set timeline and playhead colours
                this.playhead := 0x4096F3, this.focusColour := 0x4096F3, this.secondChannel := 65
                ;// set layer button offsets (these get added onto `timelineRawX`)
                this.layerSource := 16, this.layerLock := 48, this.layerTarget := 71, this.layerSync := 96, this.layerMute := 119, this.layerSolo := 142, this.valueBlue := 0x4096f3, this.effCtrlSegment := 21
                ;// edit tab
                this.editTabX := 154, this.editTabY := 35
                ;// keyframes
                this.keyframeGrey := 0xb0b0b0, this.keyframeBlue := 0x4096f3
        }
    }

    __fxPanel() => (delaySI(16, KSA.effectControls, ksa.programMonitor, KSA.effectControls))

    /**
     * This function cuts repeat code. It activates the findbox and waits for the carot to appear.
     */
    __findBox() {
        SendInput(KSA.findBox)
        tool.Cust("if you hear windows, blame premiere")
        coord.c("screen")
        CaretGetPos(&findx)
        if findx = "" ;This checks to see if premiere has found the findbox yet, if it hasn't it will initiate the below loop
            {
                loop {
                        if A_Index > 5
                            {
                                SendInput(KSA.findBox) ;adjust this in the ini file
                                tool.Cust("if you hear windows, blame adobe", 2000)
                            }
                        sleep 30
                        CaretGetPos(&findx)
                        if A_Index > 20 ;if this loop fires 20 times and premiere still hasn't caught up, the function will cancel itself
                            {
                                block.Off()
                                errorLog(IndexError("Couldn't find the findbox", -1),, 1)
                                return false
                            }
                    } until findx != "" ; as soon as premiere has found the find box, this will populate and break the loop
            }
        return findx
    }

    /**
     * Check for a window containing a class used by windows to denote that a file select/dir select GUI is open (ie. a save window)
     * @returns {Boolean} true if the window **doesn't** exist or false if it does
     */
    static __checkDialogueClass() {
        if WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro.exe") || WinExist("ahk_class #32770 ahk_exe Adobe Premiere Pro (Beta).exe") {
            return false
        }
        return true
    }
    /**
     * This function checks for the existence of [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main). Can also check for the existence of a specific function within the `index.tsx` file
     * @param {String} [checkFunc=""] the name of the function you wish to check for
     * @returns {Boolean}
     */
    static __checkPremRemoteDir(checkFunc := "") {
        return (DirExist(this.remoteDir) && FileExist(this.indexFile) && this.__checkPremRemoteFunc(checkFunc) ? true : false)
    }

    /**
     * This function checks the [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main) `index` file for the desired function
     * @param {String} checkFunc the function name you wish to search for. ie `projPath`
     * @returns {Boolean}
     */
    static __checkPremRemoteFunc(checkFunc) {
        return ((InStr(readFile := FileRead(this.indexFile), Format("{}: function (", checkFunc)) ||
                    InStr(readFile, Format("{}: function(", checkFunc)))
                    ? true : false)
    }

    /**
     * uses the user's `KSA.shuttlestop` hotkey to stop playback
     *
     * ~stops playback within premiere using either `PremiereRemote` or the user's shuttle stop keybind. Must be set within `KSA`~ *(read comments in function for why this functionality has been disabled)*
     * @param {Boolean} [checkIsPlaying=false] whether the function will actively check if something is playing before issuing a command to stop playback. Requires `PremiereRemote`. Defaults to `false` (can cause slowdown in big comps). *Note: this parameter will only work if the multicam view is not enabled. adobe is dumb*
     * */
    static stopPlayback(checkIsPlaying := false) {
        ckDir := this.__checkPremRemoteDir('isPlaying')
        if !ckDir || !checkIsPlaying {
            SendInput(KSA.shuttleStop)
            return
        }
        if !this.__remoteFunc('isPlaying', true)
            return
        SendInput(KSA.shuttleStop)

        /*
        ;// unfortunately there's no way to track the state of the multicam monitor
        ;// which means there's no real way to ensure we "stop" playback when the multicam monitor is active
        ;// because calling qe.project.getActiveSequence().multicam.stop(); actually just acts as a `play/stop` toggle
        :(

        ckDir := this.__checkPremRemoteDir(), ckStop := this.__checkPremRemoteFunc('stopPlayback'), ckIsPlaying := this.__checkPremRemoteFunc('isPlaying')
        if !ckDir || !ckStop || !ckIsPlaying {
			SendInput(KSA.shuttleStop)
            return
        }
        if !checkIsPlaying {
            this.__remoteFunc('stopPlayback')
            return
        }
        if !this.__remoteFunc('isPlaying', true)
            return
        this.__remoteFunc('stopPlayback') */
    }

    /**
     * uses the user's `KSA.playStop` hotkey to start playback
     *
     *  ~starts playback within premiere using either `PremiereRemote` or the user's Play-Stop Toggle keybind. Must be set within `KSA`~ *(read comments in function for why this functionality has been disabled)*
     *
     * ~@param {Integer} [speed=1] Determine playback speed. `1` is normal, `2` is double, `0.5` is half, `-1` is backwards, etc. This parameter will only work if `PremiereRemote` is installed and used to resume playback. Otherwise normal playback will occur. *Note: this parameter will only work if the multicam view is not enabled. adobe is dumb*~
     * */
    static startPlayback() {
        delaySI(, KSA.shuttleStop, KSA.playStop)

        ;// unfortunately prem is kinda really dumb and the normal player & the multicam player are two completely separate things
        ;// which means you can start/stop one, but they aren't the same - so if you try to call the startPlayback commands for both
        ;// it'll inevitably stop playback for the other. And since there's no real way to programmatically determine if the multicam view
        ;// is active, we can't determine which to use so we're left using keyboard shortcuts
        ;// even `qe.startPlayback();` acts as a play/stop toggle...

        /* ckDir := this.__checkPremRemoteDir(), ckStart := this.__checkPremRemoteFunc('startPlayback'), ckIsPlaying := this.__checkPremRemoteFunc('isPlaying')
        if !ckDir || !ckStart || !ckIsPlaying {
			delaySI(, KSA.shuttleStop, KSA.playStop)
            return
        }
        if !IsFloat(speed) && !IsInteger(speed)
            speed := 1
        if !checkIsPlaying {
            this.__remoteFunc('startPlayback',, "speed=" String(speed))
            return
        }
        isPlaying := this.__remoteFunc('isPlaying', true)
        if speed == 1 && isPlaying
            return
        this.__remoteFunc('startPlayback',, "speed=" String(speed)) */
    }

    /**
     * a helper function for `PremiereRemote` `__remote()` functions to sanitise their parameter string
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
     * This function is syntatic sugar to activate a [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main) function
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
        if !this.__checkPremRemoteDir(whichFunc) {
            MsgBox("PremiereRemote is not installed or function does not exist.`nFunction: " whichFunc,, "262160")
            return false
        }
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true) {
            errorLog(Error("Core Functionality.ahk is not open but is required.", -1),, true)
            return false
        }

        checkPrem := WinGet.PremName()
        checkType := (Type(checkPrem) != "Object")
        if !checkPrem || checkType
            return false
        checkTitle := (checkPrem.winTitle = "" || !checkPrem.wintitle), checkCanSave := (checkPrem.titleCheck = -1)
        if  checkTitle || checkCanSave {
            return false
        }

        if A_ScriptName != "Core Functionality.ahk" {
            activeObj := CLSID_Objs.clone("prem")
            if activeObj.remoteActive = "loading" {
                notifyExt.showIfNotExist("premSocketLoading",, "Socket connection still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return -1
            }
            if !activeObj.remoteActive {
                errorLog(Error("A socket connection could not be established", -1),, true)
                return false
            }
        } else {
            if this.remoteActive = "loading" {
                notifyExt.showIfNotExist("premSocketLoading",, "Socket connection still being established. Please wait.", 'C:\Windows\System32\imageres.dll|icon233',,, "theme=Dark DUR=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red")
                return -1
            }
            if !this.remoteActive {
                errorLog(Error("A socket connection could not be established", -1),, true)
                return false
            }
        }

        paramsString := this.__sanitiseParams(params)
        sendcommand := Format('curl "http://localhost:8081/{1}?{2}"', whichFunc, String(paramsString))
        if !needResult {
            Run(sendcommand,, "Hide")
            return true
        }
        if InStr(getResp := cmd.result(sendcommand), "Failed to connect to localhost") {
            errorLog(Error("1. Unable to connect to localhost server. PremiereRemote Extension may not be running.", -1),, true)
            return false
        }
        try parse := JSON.parse(getResp)
        catch {
            errorLog(Error("2. Unable to connect to localhost server. PremiereRemote Extension may not be running."),, true)
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
     * This function is syntatic sugar to activate a [PremiereRemote](https://github.com/sebinside/PremiereRemote/tree/main) uxp function. This function is in testing as `PremiereRemote` uxp functionality is still in development
     * @param {String} whichFunc the function you wish to call. **must include the file name**, eg. `common/getActiveSequenceName`
     * @param {Boolean} [needResult=false] determines whether the user needs this function to return a result back from the cmd window.
     * @param {Varadic/String} params any additional paramaters you need to pass to your function. do **not** add the `&` that goes between paramaters, this function will add that itself
     *
     * ## Warning
     *
     * ##### *If you intend on sending a parameter that contains a SPACE you need to use `%20` instead. ie; instead of `Gaussian Blur`, use `Gaussian%20Blur`*. The function will attempt to rectify this for you automatically, but relying on such could result in issues.
     * ##### Similarly; sending a parameter with `&` may cause issues. It is recommended to send `%26` instead. This function will attempt to rectify the issue itself but again, relying on such could result in issues.
     * @returns {String} if the user sets `needResult` to `true` this function will return a string containing the response. The response will have its surrounding `"` quotes removed (eg. `fd75a385-7c84-48af-b6ee-a6c5a69c4c24` *not* `"fd75a385-7c84-48af-b6ee-a6c5a69c4c24"`)
     */
    static __remoteUXP(whichFunc, needResult := false, params*) {
        if !InStr(whichFunc, "/") {
            errorLog(PropertyError('Parameter #1 does not contain path to desired file', -1), whichFunc)
            MsgBox("prem.__remoteUXP() failed.`n`nParameter #1 does not contain path to desired file")
            return false
        }
        paramsString := prem.__sanitiseParams(params)
        sendcommand := Format('curl -X GET "http://localhost:8084/{1}?{2}"', whichFunc, String(paramsString))
        if !needResult {
            Run(sendcommand,, "Hide")
            return true
        }
        getResp := cmd.result(sendcommand)
        try parse := JSON.parse(getResp)
        if !IsSet(parse) && getResp != ""
            return ((SubStr(getResp, 1, 1) = '"' && SubStr(getResp, -1, 1) = '"') ? SubStr(getResp, 2, StrLen(getResp)-2) : getResp)
        if parse.Has("error") {
            errorLog(ValueError(parse["error"],-1), whichFunc "_" paramsString)
            MsgBox("prem.__remoteUXP() failed.`n`nError: " parse["error"] "`nFunction:" whichFunc "`nPassed Params:" paramsString)
            return false
        }
        return false
    }

    static _scan := ""
    static _scanTitle := ""

    /**
     * Checks the active Premiere window to see whether the `Edit` tab is currently active
     * @returns {Boolean}
     */
    static isEditTabActive() {
        if !WinExist(this.exeTitle) {
            ;// throw
            errorLog(TargetError("Premiere is currently not open."),,, true)
            return false
        }
        name := WinGet.PremName()
        if !name || !isObjHasProp(name, "winTitle", false) {
            errorLog(UnsetError("Could not determine Premiere window title", -1))
            return false
        }

        if !this.setShinsIMG(name.winTitle)
            return false
        return this._scan.PixelPosition(this.editTabCol, this.editTabX, this.editTabY, 3)
    }

    static setShinsIMG(title) {
        if !this._scan {
            this._scanTitle := title
            try this._scan := ShinsImageScanClass(this._scanTitle)
            catch {
                errorLog(UnsetError("ShinsImageScanClass failed to be set.", -1), "title: " title)
                return false
            }
            this._scan.autoUpdate := 0
            try this._scan.Update()
            catch {
                errorLog(MethodError("ShinsImageScanClass failed to update. Had not been set.", -1), Format("title: {} || hwnd: {}", title, this._scan.hwnd))
                return false
            }
            return true
        }
        hwnd := WinExist(title)
        if this._scanTitle != title || this._scan.hwnd != hwnd {
            this._scanTitle := title
            this._scan.hwnd := WinExist(this._scanTitle)
            if !this._scan.hwnd || !this._scanTitle
                return false
            try this._scan.Update()
            catch {
                errorLog(MethodError("ShinsImageScanClass failed to update. Was set but different values were present.", -1), Format("title: {} || hwnd: {}", title, this._scan.hwnd))
                return false
            }
            return true
        }
        try this._scan.Update()
        catch {
            errorLog(MethodError("ShinsImageScanClass failed to update. Was already set", -1), Format("title: {} || hwnd: {}", title, this._scan.hwnd))
            return false
        }
        return true
    }

    /**
     * Calls a `PremiereRemote` function to directly save the current project. This function will also double check to ensure the active sequence does not change after the save attempt
     * @param {Boolean} [andWait=true] determines whether you wish for the function to wait for the `Save Project` window to open/close
     * @param {Integer} [checkSeqTime=1000] the value you wish the function to sleep before checking if the active sequence was changed
     * @param {Integer} [checkAmount=1] the amount of times you wish for the function to check (with a sleep delay of `checkSeqTime` inbetween each). Be aware that using a value higher than `1` may result in the function changing the sequence in the event that the user manually changes it after a save
     * @param {Boolean} [continueOnBusy=false] determine whether to continue with a save attempt even if Premiere may be busy
     * @returns {Boolean/String}
     * - `true`      : successful
     * - `false`     : `PremiereRemote`/`saveProj` func/`projPath` func not found/save attempt fails (server not running)
     * - `"timeout"` : waiting for the save project window to open/close timed out
     * - `"noseq"`   : `focusSequence`/`getActiveSequence` func not found
     * - `"busy"`    : another window may be open in premiere that could cause saving to fail
     */
    static save(andWait := true, checkSeqTime := 1000, checkAmount := 1, continueOnBusy := false) {
        if !IsInteger(checkAmount) || !IsInteger(checkSeqTime) || !isBool(andWait) || !isBool(continueOnBusy) {
            errorLog(PropertyError("Incorrect Parameter Type"),,, true)
            return false
        }
        ;// the below windows will halt the save process if they exist
        haltSave := "Clip Fx Editor - RX 11"
        if winExt.ExistRegex(haltSave) {
            if !winExt.WaitCloseRegex(haltSave,, 10)
                return "busy"
        }
        premWindow := WinGet.PremName()
        if !premWindow || Type(premWindow) != "Object" ||
            ((premWindow.winTitle = "" || !premWindow.wintitle) &&
            premWindow.titleCheck = -1 && premWindow.saveCheck = -1) {
            errorLog(UnsetError("prem.save() was unable to determine the title of the Premiere Pro window"), "The user may not have the correct year set within the settings", 1)
            return false
        }
        try procName := WinGetProcessName(premWindow.winTitle), procClass := WinGetClass(premWindow.wintitle)
        catch {
            ;// prem may have crashed
            return false
        }
        editTab := this.isEditTabActive()
        if continueOnBusy = false && ((procName = "Adobe Premiere Pro.exe" || procName = "Adobe Premiere Pro (Beta).exe") && (procClass != "Premiere Pro" && procClass != "Premiere Pro (Beta)")) || editTab = false
            return "busy"
        if !this.__checkPremRemoteDir("saveProj")
            return false
        actSequence := this.__checkPremRemoteFunc("getActiveSequence"), focusSequence := this.__checkPremRemoteFunc("focusSequence")
        if !actSequence || !focusSequence
            return "noseq"
        if checkAmount != 0
            origSeq := this.__remoteFunc("getActiveSequence", true)
        state := {hasAppeared: false, hasClosed: false}
        try WinEvent.Exist((*) => state.hasAppeared := true, "Save Project " prem.exeTitle)
        try WinEvent.Close((*) => state.hasClosed := true, "Save Project " prem.exeTitle)
        __stopCallbacks() {
            try {
                WinEvent.Stop('Exist', "Save Project " prem.exeTitle)
                WinEvent.Stop('Close', "Save Project " prem.exeTitle)
            }
        }

        ;// func won't continue until this premiereremote func finishes (saving completes)
        blocker := block_ext()
        blocker.On(false)
        SetTimer((*) => blocker.Off(), -250)
        if !this.__remoteFunc("saveProj", true) {
            __stopCallbacks()
            blocker.Off()
            return false
        }
        __stopCallbacks()

        if !andWait {
            blocker.Off()
            return true
        }

        ;// waiting for save dialogue to open & close
        if !state.hasAppeared {
            blocker.Off()
            return "timeout_nosave"
        }
        if !state.hasClosed {
            blocker.Off()
            return "timeout"
        }

        if checkAmount = 0 {
            blocker.Off()
            return true
        }
        if origSeq = "" {
            blocker.Off()
            errorLog(Error("Premiere failed to retrieve the originally active sequence before saving. Aborting"))
            return true
        }
        blocker.Off()
        sleep checkSeqTime
        loop checkAmount {
            currentSeq := this.__remoteFunc("getActiveSequence", true)
            if currentSeq != origSeq {
                errorLog(Error("Current Sequence=" currentSeq " || Orig Sequence=" origSeq))
                this.__remoteFunc("focusSequence",, "ID=" String(origSeq))
                return true
            }
            sleep checkSeqTime
        }

        return true
    }

    /**
     * This function is to reduce repeat code and is designed to save the current project, then wait for premiere to catch up refocusing the timeline.
     * This function will never *always* work perfectly due to Premiere being Premiere and ranging quite wildly how it performs at any given time.
     * If you notice any issues you may need to slow this function down even further.
     *
     * This function is mostly designed to be used in scripts like `render and replace.ahk` and the `render previews` scripts where **speed** isn't *super* important.
     * @returns {Boolean|String} returns boolean or `"active"` if timeline was the active window
     */
    static saveAndFocusTimeline() {
        if !uiaVals := premUIA_Values.initialise()
            return
        saveAttempt := this.save()
        if (saveAttempt = false || saveAttempt = "timeout" || saveAttempt = "timeout_nosave") {
            SendEvent("^s")
            if !WinWait("Save Project",, 3) {
                tool.Cust("Function timed out waiting for save prompt")
                return false
            }
            if !WinWaitClose("Save Project",, 5) {
                tool.Cust("Function timed out waiting for save prompt to close")
                return false
            }
        }
        if !uiaVals.__isUiaElementActive("timelineWindow", uiaVals) {
            tool.Cust("Premiere should automatically refocus the timeline")
            sleep 1000
            return "active"
        }
        tool.Cust("Checking if timeline is in focus", 500, -180,, 16)
        sleep 500
        if this.__checkTimelineValues() {
            if !this.__waitForTimeline()
                return false
        }
        tool.Cust("Letting Premiere catch up...", 500, -180,, 16)
        sleep 500
        return true
    }

    /**
     * This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work.
     * @param {String} item in this function defines what it will type into the search box (the name of your preset within premiere)
     */
    static preset(item)
    {
        if Type(item) != "string" {
            ;// throw
            errorLog(TypeError("Incorrect value type in Parameter #1", -1, item),,, 1)
        }
        keys.allWait()
        ToolTip("Your Preset is being dragged")
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])

        if item = "loremipsum" ;YOUR PRESET MUST BE CALLED "loremipsum" FOR THIS TO WORK - IF YOU WANT TO RENAME YOUR PRESET, CHANGE THIS VALUE TOO - this if statement is code specific to text presets
            this().__loremipsum({x: effCtrlNN.location.x, y: effCtrlNN.location.y}, {width: effCtrlNN.location.w, height: effCtrlNN.location.h}, &eyeX, &eyeY)
        /** this is simply to cut needing to repeat this code below */
        effectbox() {
            effCtrlNN.SetFocus()
            if !this().__findBox()
                return
            SendInput("^a" "+{BackSpace}")
            SetTimer(delete, -250)
            /** this function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job */
            delete() {
                if WinExist("Delete Item") {
                    SendInput("{Esc}")
                    sleep 100
                    effCtrlNN.SetFocus()
                    if !this().__findBox()
                        return
                    SendInput("^a" "+{BackSpace}")
                    sleep 60
                    if WinExist("Delete Item") {
                        SendInput("{Esc}")
                        sleep 50
                    }
                }
            }
        }
        effectbox()
        coord.c("screen") ;change caret coord mode to window
        CaretGetPos(&carx, &cary) ;get the position of the caret (blinking line where you type stuff)
        if !IsSet(carx) || !IsSet(cary) || (!carx && !cary)
            return
        MouseMove(carx-5, cary+5) ;move to the caret (instead of defined pixel coords) to make it less prone to breaking
        SendInput(item) ;create a preset of any effect, must be in a folder as well
        sleep 50
        MouseMove(0, 65,, "R") ;move down to the saved preset (must be in an additional folder)
        SendInput("{Click Down}")
        if item = "loremipsum" ;set this hotkey within the Keyboard Shortcut Adjustments.ini file
            {
                MouseMove(eyeX, eyeY - "5")
                SendInput("{Click Up}")
                effectbox()
                this.__focusTimeline()
                MouseMove(xpos, ypos)
                block.Off()
                return
            }
        MouseMove(xpos, ypos) ;in some scenarios if the mouse moves too fast a video editing software won't realise you're dragging. if this happens to you, add ', "2" ' to the end of this mouse move
        SendInput("{Click Up}")
        effectbox() ;this will delete whatever preset it had typed into the find box
        this.__focusTimeline()
        block.Off()
        ToolTip("")
    }

    /**
     * this function is called within `preset()` and is pulled out simply to make that function more readable
     * @param {Object} classObj an object `{x: , y: }` to pass in the classNN variables
     * @param {Object} widHeiObj an object `{width: , height: }` to pass in the classNN variables
     * @param {VarRef} returnXY passing variables back to the function
     */
    __loremipsum(classObj, widHeiObj, &returnX, &returnY) {
        sleep 100
        delaySI(150, KSA.timelineWindow, KSA.timelineWindow, KSA.newText)
        sleep 150
        ;// premiere can slow down depending on the size of your project so it's best
        ;// to build in multiple checks for most things
        loop {
            if A_Index > 30 { ;// 3s
                block.Off()
                errorLog(Error("Couldn't find the graphics tab", -1),, 1)
                return
            }
            if ImageSearch(&x2, &y2, classObj.x, classObj.y, classObj.x + (widHeiObj.width/2), classObj.y + widHeiObj.height, "*2 " ptf.Premiere "graphics.png") ;checks for the graphics panel that opens when you select a text layer
                break
            sleep 100
        }
        loop {
            if A_Index > 30 { ;// 3s
                block.Off()
                errorLog(Error("Couldn't find the eye icon", -1),, 1)
                return
            }
            if A_Index > 1 && y2 < 900 ;// the y value it searches will increase as the loop index increases
                y2 += 100
            if ImageSearch(&xeye, &yeye, x2, y2, x2 + 200, y2 + 100, "*2 " ptf.Premiere "eye.png") ;searches for the eye icon for the original text
                break
            sleep 100
        }
        MouseMove(xeye, yeye)
        SendInput("{Click}")
        MouseGetPos(&returnX, &returnY)
        sleep 50
    }

    /**
     * This function is to move to the effects window and highlight the search box to allow manual typing
     */
    static fxSearch()
    {
        coord.s()
        block.On()
        this().__fxPanel()
        if !this().__findBox()
            return
        this().__fxPanel()
        SendInput("^a" "+{BackSpace}")
        SetTimer(delete, -250)
        /** This function simply checks for premiere's "delete preset" window that will appear if the function accidentally tries to delete your desired preset. This is simply a failsafe just incase the loop above fails to do its intended job */
        delete() {
            if WinExist("Delete Item") {
                SendInput("{Esc}")
                sleep 100
                this().__fxPanel()
                if !this().__findBox()
                    return
                this().__fxPanel()
                SendInput("^a" "+{BackSpace}")
                sleep 60
                if WinExist("Delete Item") {
                    SendInput("{Esc}")
                    sleep 50
                }
            }
        }
        block.Off()
    }

    /**
     * checks for and disables the `Direct Manipulation` button that appears in the bottom left of the program monitor when you select a clip
     * this button being enabled can be annoying as it will then pause playback if you click anything else in the timeline
     * @param {String} [toggleKey=ksa.toggleCropDirectManip] the shortcut to send to toggle off Direct Manip. Defaults to a KSA value
     */
    static disableDirectManip(toggleKey := ksa.toggleCropDirectManip) {
        ;// button was only added in specrum UI
        if VerCompare(this.currentSetVer, this.spectrumUI_Version) < 0
            return
        coord.s()
        block.On()
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        progNN := premUIA.UIA_Objs["programMonitor"]
        if PixelGetColor(progNN.location.x+15, progNN.location.y+(progNN.location.h-10)) != this.iconHighlight {
            block.Off()
            return
        }
        delaySI(25, toggleKey, toggleKey)
        block.Off()
        return
    }

    /**
     * Checks the `Effect Controls` window to ensure a clip is selected
     * @param {UIA Object} [effCont] the effect controls UIA control. it is recommended to use `effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])` for an updated window
     * @param {VarRef} [sourceButt?] pass back the `Show/Hide Timeline View` button control if it is found
     * @param {VarRef} [motionPos?] pass back the `Toggle the effect on or off` button control if it is found
     * @returns {Boolean}
     */
    static isClipSelected(effCont, &sourceButt?, &motionPos?) {
        try sourceButt := effCont.FindElement({LocalizedType:"button", Name:"Show/Hide Timeline View"})
        try motionPos  := effCont.FindElement({LocalizedType:"button", Name:"Toggle the effect on or off"})
        if !this.__remoteFunc('isSelected', true) || !IsSet(sourceButt) || !IsSet(motionPos)
            return false
        return true
    }

    /**
     * ## Warning
     * - ##### The activation key for this function needs to be a *single* key without any modifiers.
     * - ##### The `Motion` property must be visible for this function to work; the user can have unassigned masks above it, but that property must still be on the screen for logic to continue
     *
     * A function to warp to one of a videos values (scale , x/y, rotation, etc) click and hold it so the user can drag to increase/decrease. Also allows for tap to reset.
     * @param {String} control is which control you wish to adjust. This parameter is CASE SENSETIVE!!. Valids options; `Position`, `Scale`, `Rotation`, `Opacity`
     * @param {Integer} optional is used to add extra x axis movement after the pixel search. This is used to press the y axis text field in premiere as it's directly next to the x axis text field
     */
    static valuehold(control, optional := 0)
    {
        ;This function will only operate correctly if the space between the x value and y value is about 210 pixels away from the left most edge of the "timer" (the icon left of the value name)
        ;I use to have it try to function irrespective of the size of your panel but it proved to be inconsistent and too unreliable.
        ;You can plug your own x distance in by changing the value below
        coord.s()
        MouseGetPos(&xpos, &ypos)
        block.On()
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])
        if !this.isClipSelected(effCtrlNN, &sourceButt, &motionPos) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            keys.allWait()
            return
        }
        if !this.__setEffContScrollbar(effCtrlNN) {
            block.Off()
            keys.allWait()
            return
        }
        this.__focusTimeline() ;focuses the timeline
        motionPos := {x: effCtrlNN.location.x+57, y: motionPos.location.y}
        switch this.UI {
            case "Spectrum": effCtrlArr := ["Position", "Scale", "Scale Width", "Uniform Scale", "Rotation", "Anchor Point", "Anti-flicker Filter", "Crop Left", "Crop Top", "Crop Right", "Crop Bottom", "Opacity Title", "Opacity Mask", "Opacity", "Blend Mode"]
        }
        startPos := {x: motionPos.x+15, y: motionPos.y+this.effCtrlSegment}
        for i, v in effCtrlArr {
            if v !== control && i != effCtrlArr.Length
                continue
            if v !== control && i = effCtrlArr.Length {
                block.Off()
                errorLog(IndexError("Failed to find the requested control", -1, control),, 1)
                keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
                MouseMove(xpos, ypos)
                return
            }
            startPos.y += (this.effCtrlSegment*i)-(this.effCtrlSegment*0.75)
            break
        }
        if !PixelSearch(&xcol, &ycol, startPos.x, startPos.y, sourceButt.location.x+3, startpos.y + (this.effCtrlSegment*.75), this.valueBlue, 6) {
            block.Off()
            errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
            keys.allWait() ;as the function can't find the property you want, it will wait for you to let go of the key so it doesn't continuously spam the function and lag out
            MouseMove(xpos, ypos)
            return
        }
        MouseMove(xcol + optional, ycol)
        sleep 50 ;required, otherwise it can't know if you're trying to tap to reset
        ToolTip("")
        if !GetKeyState(A_ThisHotkey, "P") {
            switch this.UI {
                ;// check version - pre Spectrum UI will need to start imagesearch higher
                ;// spectrum ui
                case "Spectrum": startSegment := this.effCtrlSegment*.25, endSegment := this.effCtrlSegment*.75
            }
            ;// searches for the reset button to the right of the value you want to adjust. if it can't find it, the below block will happen
            if !ImageSearch(&x2, &y2, startPos.x, startPos.y - startSegment, startPos.x + 1500, startPos.y + endSegment, "*2 " ptf.Premiere "reset.png") {
                MouseMove(xpos, ypos)
                block.Off()
                errorLog(Error("Couldn't find the reset button", -1),, 1)
                return
            }
            MouseMove(x2, y2)
            SendInput("{Click}")
            MouseMove(xpos, ypos)
            this.disableDirectManip()
            block.Off()
            return
        }
        ;// waiting for the user to release the key
        SendInput("{Click Down}")
        block.Off()
        keys.allWait()
        SendInput("{Click Up}" "{Enter}")
        sleep 200 ;was experiencing times where ahk would just fail to excecute the below mousemove. no idea why. This sleep seems to stop that from happening and is practically unnoticable
        this.disableDirectManip()
        MouseMove(xpos, ypos)
    }

    /**
     * Move back and forth between edit points from anywhere in premiere. Be careful that your `shuttle stop` keyframe doesn't have any additional keyboard shortcuts assigned with modifiers.
     * ie. if `Shuttle Stop` is <kbd>k</kbd> don't have anything set to <kbd>Shift + k</kbd> or <kbd>Ctrl + k</kbd> etc. Otherwise if you activate this function consecutively, modifiers might "leak" when unintended causing that hotkey to be activated. By default `Play around` was set for me which was causing issues
     * @param {String} window the hotkey required to focus the desired window within premiere
     * @param {String} direction is the hotkey within premiere for the direction you want it to go in relation to "edit points"
     * @param {String} [keyswait=1] an integer you wish to pass to `keys.allWait()`'s first parameter
     * @param {Boolean/Object} [checkMButton=false] determine whether the function will wait to see if <kbd>MButton</kbd> is pressed shortly after (or is being held). This can be useful with panning around Premiere's `Program` monitor (assuming this function is activated using tilted scroll wheels, otherwise leave this param as false). This parameter can either be set to `true/false` or an object containing key `T` along with the timeout duration. Eg. `{T:"0.3"}`
     * @param {String} [activationKeys="{Shift}{F21}{F23}"] the keys you use to activate this function so they can be passed to `block_ext()` (otherwise you may have issues activating this hotkey consecutively)
     */
    static wheelEditPoint(window, direction, keyswait := 1, checkMButton := false, activationKeys := "{Shift}{F21}{F23}") {
        SetKeyDelay(0)
        if Type(window) != "string" || Type(direction) != "string" || Type(keyswait) != "integer" || (Type(checkMButton) != "integer" && Type(checkMButton) != "object") {
            ;// throw
            errorLog(TypeError("Incorrect Parameter type passed to function", -1),,, true)
            return
        }
        if checkMButton != false {
            if GetKeyState("MButton", "P") || GetKeyState("MButton")
                return
            timeoutVal := (IsObject(checkMButton) && checkMButton.HasOwnProp("T")) ? "T" LTrim(String(checkMButton.T), "T") : "T0.1"
            if KeyWait("MButton", timeoutVal " D")
                return
        }
        if !premUIA := premUIA_Values.initialise()
            return
        blocker := block_ext()
        blocker.On(,, "{Tab}{F4}{Enter}{sc01C}{NumpadEnter}{sc11C}{vk0D}{Escape}" activationKeys)
        this.stopPlayback()
        sleep 50

        switch window {
            case ksa.timelineWindow:
                ;// If you ever use the multi camera view you unfortunately cannot simply send the required hotkey, for whatever reason there is a potential for premiere to get stuck within a multicam nest.
                ;// hopefully one day adobe fixes this bug - https://community.adobe.com/t5/premiere-pro-bugs/next-previous-edit-point-on-any-track-gets-stuck-in-multi-camera-view/idi-p/15250392#M48002

                ;// I think simply moving the playhead back and forth avoids the issue
                delaySI(30, ksa.stepBackOneFrame, ksa.stepforwardOneFrame)
                /*
                 but moving the playhead using cep doesn't seem to work the same way... for.. whatever reason.
                 right := ObjBindMethod(this, '__remoteFunc', 'movePlayheadFrames', false, "subtract=false", "frames=1")
                left  := ObjBindMethod(this, '__remoteFunc', 'movePlayheadFrames', false, "subtract=true", "frames=1")
                delayFuncs(16, right, left)
                */
                this.__focusTimeline()

            case ksa.effectControls:
                try {
                    premUIA.AdobeEl.UIA_obj["effectControls"].SetFocus()
                    Sleep(25)
                    premUIA.AdobeEl.UIA_obj["programMonitor"].SetFocus()
                    Sleep(25)
                    premUIA.AdobeEl.UIA_obj["effectControls"].SetFocus()
                    Sleep(50)
                    delaySI(20, "^a", ksa.deselectAll)
                }
                catch {
                    delaySI(20, window, ksa.programMonitor, window, "^a", ksa.deselectAll) ;// indicates the user is trying to use `Select previous/next Keyframe`
                }
            default: SendInput(window) ;focuses the timeline/desired window
        }
        SendInput(direction)
        keys.allWait(keyswait) ;prevents hotkey spam
        blocker.Off()
    }

    /**
     * This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values
     */
    static movepreview()
    {
        coord.s()
        block.On()
        MouseGetPos(&xpos, &ypos)
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])
        this.__focusTimeline() ;focuses the timeline
        sleep 25
        if !this.isClipSelected(effCtrlNN) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            keys.allWait()
            return
        }
        if !this.__setEffContScrollbar(effCtrlNN) {
            block.Off()
            keys.allWait()
            return
        }
        motionPos := {x: effCtrlNN.location.x+57, y: effCtrlNN.location.y+62}
        MouseMove(motionPos.x + 25, motionPos.y+5)
        SendInput("{Click}")
        sleep 50
        ToolTip("")
        ;// gets the state of the hotkey, enough time now has passed that if the user just presses the button, you can assume they want to reset the paramater instead of edit it
        if !GetKeyState(A_ThisHotkey, "P") {
            this.reset()
            block.Off()
            return
        }
        ;//* you can simply double click the preview window to achieve the same result in premiere, but doing so then requires you to wait over .5s before you can reinteract with it which imo is just dumb, so unfortunately clicking "motion" is both faster and more reliable to move the preview window
        /**
         * This codeblock is potentially used below if the first loop fails
         */
        fallback() {
            tool.Cust("fallback")
            origX := previewWin.x + 10, origY := previewWin.height
            previewWin.y += 30
            previewWin.x += 15
            loop {
                previewWin.x += 5, previewWin.y += 10
                if previewWin.x > previewWin.x + previewWin.width
                    previewWin.x := origX
                if previewWin.y > origY
                    {
                        MouseMove(xpos, ypos)
                        block.Off()
                        keys.allWait()
                        return false
                    }
                check := PixelGetColor(previewWin.x, previewWin.y)
                if check != 0x232323 && check != 0x000000 {
                    MouseMove(previewWin.x, previewWin.y)
                    break
                }
            }
            return true
        }

        progClassNN := ControlGetClassNN(premUIA.UIA_Objs["programMonitor"].GetControlId()) ;gets the ClassNN value of the effects control window
        previewWin := obj.CtrlPos(progClassNN)
        if !IsObject(previewWin)
            return
        startX := (previewWin.x + (previewWin.width/2)) - 20
        startY := (previewWin.y + (previewWin.height/2)) - 10
        MouseMove(startX, startY) ;move to the preview window
        loop {
            MouseGetPos(&colX, &colY)
            if PixelGetColor(colX, colY) != 0x000000
                break
            if A_Index > 4
                {
                    if !fallback()
                        {
                            errorLog(IndexError("Couldn't find the video in the Program Monitor.", -1)
                                        , "Or the function kept finding pure black at each checking coordinate", 1)
                            this.disableDirectManip()
                            return
                        }
                    break
                }
            switch A_Index {
                case 1: MouseMove(startX + 150, startY + 100)
                case 2: MouseMove(startX - 150, startY + 100)
                case 3: MouseMove(startX - 150, startY - 100)
                case 4: MouseMove(startX + 150, startY - 100)
            }
        }
        SendInput("{Click Down}")
        sleep 50
        block.Off()
        keys.allWait()
        SendInput("{Click Up}")
        if !getMouse := obj.MousePos()
            return
        this.disableDirectManip()
        MouseMove(getMouse.x, getMouse.y, 2)
        ;!MouseMove(xpos, ypos) ; // moving the mouse position back to origin after doing this is incredibly disorienting
    }

    /**
     * This function moves the cursor to the reset button to reset the "motion" effects
     */
    static reset()
    {
        keys.allWait()
        coord.s()
        block.On()
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])
        timelineAct := premUIA_Values.__isUiaElementActive('timelineWindow', premUIA)
        this.__focusTimeline() ;focuses the timeline
        if !this.isClipSelected(effCtrlNN) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            keys.allWait()
            return
        }
        if !this.__setEffContScrollbar(effCtrlNN) {
            block.Off()
            keys.allWait()
            return
        }
        try {
            reset := effCtrlNN.FindElement({LocalizedType:"button", Name:"Reset Effect"}).Invoke()
        }
        if timelineAct {
            sleep 50
            this.__focusTimeline() ;focuses the timeline
        }
        block.Off()
    }

    /**
     * Sets the Effect Controls scrollbar to its topmost value if it has been moved
     * @param {UIA Object} [effCont] the effect controls UIA control. it is recommended to use `effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])` for an updated window
     * @param {Integer} [mouseSpeed=0] the value to be passed to `SetDefaultMouseSpeed()`. Defaults to `0`
     * @param {Integer} [timeout=1000] the time in `ms` you want to check to ensure the scrollbar has moved. Will check every `50ms`
     * @returns {Boolean}
     */
    static __setEffContScrollbar(effCont, mouseSpeed := 0, timeout := 1000) {
        SetDefaultMouseSpeed(mouseSpeed)
        coord.s()
        try scrollBar := effCont.FindElement({LocalizedType:"scroll bar", Name:"UI_ScrollBar"})
        catch {
            errorLog(Error("Failed to find the Effect Controls scrollbar", -1))
            notifyExt.showIfNotExist("premEffContScrollbarFind",, 'Failed to find the Effect Controls scrollbar',,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
            return false
        }
        if scrollBar.value = 0
            return true
        getCoords := obj.MousePos()
        Click(scrollBar.location.x + (scrollBar.location.w/2) A_Space scrollBar.location.y+1)
        sleep 50
        MouseMove(getCoords.x, getCoords.y, 1)

        hasMoved := false
        loop (50/timeout) {
            if scrollBar.Value = 0 {
                hasMoved := true
                break
            }
            continue
        }
        if !hasMoved {
            errorLog(Error("Failed to move the Effect Controls scrollbar", -1))
            notifyExt.showIfNotExist("premEffContScrollbarMove",, 'Failed to move the Effect Controls scrollbar',,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
            return false
        }
        return true
    }

    /**
     * This function will warp to and press any value in premiere to manually input a number
     * @param {String} property is the value you want to adjust. ie "scale"
     * @param {Integer} optional is the optional pixels to move the mouse to grab the Y axis value instead of the X axis
     */
    static manInput(property, optional := 0)
    {
        getHotkeys(&first, &waitHotkey)
        MouseGetPos(&xpos, &ypos)
        coord.s()
        block.On()
        if !premUIA := premUIA_Values.initialise() {
            block.Off()
            return
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])
        this.__focusTimeline()
        if !this.isClipSelected(effCtrlNN) {
            block.Off()
            errorLog(Error("No clips are selected", -1),, 1)
            keys.allWait()
            return
        }
        if !this.__setEffContScrollbar(effCtrlNN) {
            block.Off()
            keys.allWait()
            return
        }
        ;// finds the scale value you want to adjust, then finds the value adjustment to the right of it
        if !obj.imgSrchMulti({x1: effCtrlNN.location.x, y1: effCtrlNN.location.y, x2: effCtrlNN.location.x + (effCtrlNN.width/2), y2: effCtrlNN.location.y + effCtrlNN.location.h},, &x, &y
            , ptf.Premiere property ".png"
            , ptf.Premiere property "2.png"
            , ptf.Premiere property "3.png"
            , ptf.Premiere property "4.png"
        )
            {
                block.Off()
                errorLog(Error("Couldn't find the property requested.", -1, property),, 1)
                return
            }
        if !PixelSearch(&xcol, &ycol, x, y, x + "740", y + "40", this.valueBlue, 2) ;searches for the blue text to the right of the scale value
            {
                block.Off()
                errorLog(Error("Couldn't find the blue 'value' text", -1),, 1)
                return
            }
        MouseMove(xcol + optional, ycol)
        keywait(waitHotkey)
        SendInput("{Click}")
        ToolTip("manInput() is waiting for the NumpadEnter key to be pressed")
        KeyWait("{NumpadEnter}", "D") ;waits until the final hotkey is pressed before continuing
        ToolTip("")
        SendInput("{Enter}")
        MouseMove(xpos, ypos)
        SendInput("{MButton}")
        block.Off()
    }

    /**
     * This function is to increase/decrease gain within premiere pro. This function will check to ensure the timeline is in focus and a clip is selected
     * @param {Integer} amount is the value you want the gain to adjust (eg. -2, 6, etc)
     */
    static gain(amount)
    {
        if !IsNumber(amount) {
            ;// throw
            errorLog(TypeError("Invalid parameter type in Parameter #1", -1, amount),,, 1)
        }
        keys.allWait()
        Critical
        if !check := winget.Title()
            return
        blocker := block_ext()
        blocker.On(false)
        coord.s()

        if check = "Audio Gain" {
            ;// if the gain window is already open, then all we want to do is ensure the caret is visible, then highlight the gain textbox and input our value
            if !CaretGetPos(&xcar, &ycar) {
                loop {
                    SendInput("{Tab}")
                    sleep 25
                    if !CaretGetPos(&xcar, &ycar) {
                        continue
                    }
                    sleep 25
                    break
                }
            }
            SendInput("{Tab 3}{Up 3}{Down}{Tab}" amount "{Enter}")
            WinWaitClose("Audio Gain",, 1.5)
            blocker.Off()
            return -1
        }
        if !premUIA := premUIA_Values.initialise() {
            blocker.Off()
            return false
        }
        effCtrlNN := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])

        try {
            funcExist := this.isClipSelected(effCtrlNN)
            switch funcExist {
                case false:
                    delaySI(50, KSA.timelineWindow, KSA.selectAtPlayhead) ;~ check the keyboard shortcut ini file to adjust hotkeys
                    this().__fxPanel()
                    if !obj.imgSrchMulti({x1: effCtrlNN.location.x, y1: effCtrlNN.location.y, x2: effCtrlNN.location.x + (effCtrlNN.location.w/2), y1: effCtrlNN.location.y + effCtrlNN.location.h},, &audx, &audy, ptf.Premiere "effctrlAudio.png", ptf.Premiere "effctrlAudio1.png") {
                        blocker.Off()
                        notifyExt.showIfNotExist("premNoClipSelectedGain",, 'No clip was selected, gain cannot be adjusted',,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                        return false
                    }
                case true:
                    if !this.__remoteFunc('isSelected', true) {
                        blocker.Off()
                        notifyExt.showIfNotExist("premNoClipSelectedGain",, 'No clip was selected, gain cannot be adjusted',,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                        return false
                    }

            }
        } catch {
            blocker.Off()
            errorLog(UnsetError("ClassNN wasn't given a value", -1))
            notifyExt.showIfNotExist("premNoClassNN",,"ClassNN wasn't given a value",,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
            return
        }
        sleep 100
        this.__focusTimeline()
        sleep 100
        SendInput(KSA.gainAdjust)
        if !WinWait("Audio Gain",, 3) {
            errorLog(TimeoutError("Waiting for gain window timed out"),, true)
            blocker.Off()
            return false
        }

        ;// the below sendinput use to begin with a simple +{Tab} but it appears that since either v24.0/v24.1 doing so will
        ;// instead focus the cancel button
        SendInput("{Tab 3}{Up 3}{Down}{Tab}" amount "{Enter}")
        WinWaitClose("Audio Gain",, 1.5)
        blocker.Off()
        return true
    }

    /**
     * #### This function requires `PremiereRemote`
     * This function once bound to <kbd>NumpadMult::</kbd>/<kbd>NumpadAdd::</kbd> allows the user to quickly adjust the gain of a selected track by simply pressing <kbd>NumpadSub</kbd>/<kbd>NumpadAdd</kbd> then their desired value followed by <kbd>NumpadEnter</kbd>. Alternatively, if the user presses <kbd>NumpadMult</kbd> after pressing the activation hotkey, the audio `level` will be changed to the desired value instead. This function can be canceled by pressing <kbd>Escape</kbd>.
     * @param {String} [which=A_ThisHotkey] whether the user wishes to add or subtract the desired value. If the user is using either <kbd>NumpadSub</kbd>/<kbd>NumpadAdd</kbd> or <kbd>-</kbd>/<kbd>+</kbd> as the activation hotkey this value can be left blank, otherwise the user should set it as either <kbd>-</kbd>/<kbd>+</kbd>
     * @param {String} [sendOnFail="{" A_ThisHotkey "}"] what the function will send to `SendInput` in the event that the timeline isn't the active panel
     */
    static numpadGain(which := A_ThisHotkey, sendOnFail := "{" A_ThisHotkey "}") {
        which := LTrim(which, "~")
        which := (which = "NumpadSub") ? "-" : ""

        ;// check to see if the user is typing
        if CaretGetPos(&carx, &cary) {
            SendInput(sendOnFail)
            return
        }

        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }

        needsTimelineFocus := false
		title := WinGet.Title()
        descernTitle := (title = "") ? true : false
        currTimelineStatus := this.timelineFocusStatus()

        ;// because getting the UIA element of the active window is slow, we need to start an initial inputhook here for the sole purpose
        ;// of check whether * is pressed, otherwise it may end up missed while waiting
        ;// this does however mean we nean to manually stop this input hook or the user may lose control
        star_ih := InputHook()
        star_ih.Start()
        ih := InputHook("L5 T4", "{NumpadEnter}{Esc}")
        ih.Start()

        if !this.__checkPremRemoteDir('isSelected') {
            ;// throw
            ih.Stop(), star_ih.Stop()
            errorLog(MethodError('This function requires PremiereRemote'),,, true)
            return
        }
        checkSelected := this.__remoteFunc('isSelected', true)

        ;// logic to determine whether to send the fail hotkey and alert the user, or continue as expected
		if (descernTitle || currTimelineStatus != 1) && title != "Audio Gain" {
            if !premUIA := premUIA_Values.initialise() {
                ih.Stop(), star_ih.Stop()
                errorLog(TargetError('Creating UIA element failed'))
                return
            }
            textStatus := premUIA.isToolSelected("textTool", premUIA)

            switch {
                case (!descernTitle && currTimelineStatus != 1) && (textStatus = false):
                    if !premUIA.__isUiaElementActive('effectControls', premUIA) {
                        ih.Stop(), star_ih.Stop()
                        SendInput(sendOnFail star_ih.Input)
                        tool.Cust("If you are attempting to adjust audio;`nThe timeline is not currently in focus", 2000)
                        return
                    }
                    needsTimelineFocus := true
                case (!descernTitle && currTimelineStatus != 1) && (textStatus = true) && premUIA.__isUiaElementActive('programMonitor', premUIA):
                    ih.Stop(), star_ih.Stop()
                    SendInput(sendOnFail star_ih.Input)
                    return
                case (currTimelineStatus != true): needsTimelineFocus := true
                default:
                    ih.Stop(), star_ih.Stop()
                    SendInput(sendOnFail star_ih.Input)
                    return
            }
		} else if !checkSelected && title != "Audio Gain" {
            ih.Stop(), star_ih.Stop()
            errorLog(TargetError("No clip selected. Cancelling"),, {time: 2000})
            return
        }

        ih.Wait()
        star_ih.Stop()

        switch {
            case ih.EndReason = "Timeout":
                tool.Cust(A_ThisFunc "() timed out. Further number inputs may result in`nmoving clips instead of adjusting audio", 5.0)
                errorLog(Error('Function timed out'))
                return
            case ih.EndKey = "Escape": return
        }
        starCheck := star_ih.Input
        sendGain  := ih.Input
        sendAsLevel := false
        if star := ((InStr(sendGain, "*") || InStr(starCheck, "*")) ? true : false) || mult := InStr(sendGain, "NumpadMult") {
            sendGain := (star != false) ? StrReplace(sendGain, "*", "") : StrReplace(sendGain, "NumpadMult", "")
            sendAsLevel := true
        }

        orig := sendGain
        ;// removes anything that isn't a digit or `+`/`-`
        sendGain := RegExReplace(sendGain, "[^\d.]")
        if !IsNumber(sendGain) {
            ;// if the user times out, or the regex fails, we want to halt here or you'll end up with a `nan` keyframe in prem
            tool.Cust("A number could not be interpreted from the input keys. Please try again", 2.0)
            errorLog(ValueError('A number could not be interpreted from the input keys', -1, sendGain), "Original: " orig " || Regex: " sendGain " || starCheck: " starCheck)
            return
        }
        block.On()
        ;// otherwise we proceed
        if needsTimelineFocus = true
            this.__focusTimeline()
        if !sendAsLevel || !this.__checkPremRemoteDir("changeAudioLevels")
            this.gain(which sendGain)
        else {
            if title = "Audio Gain" {
                errorLog(MethodError("Levels cannot be adjusted while the gain window is open", -1))
                notifyExt.showIfNotExist("premLevelsGain", 'Levels cannot be adjusted while the gain window is open.', 'C:\Windows\System32\imageres.dll|icon80', 'Speech Misrecognition', , 'dur=5 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red')
                block.Off()
                return
            }
            levels := this.__remoteFunc("changeAudioLevels", true, "level=" String(which sendGain))
            if levels != true && levels != "true" {
                errorLog(MethodError("Unexpected response", -1), "sent value: " String(which sendGain) " Response: " levels " - Type: " Type(levels))
                notifyExt.showIfNotExist("premLevelKeyframe", 'prem.numpadGain()', 'Setting ``level`` keyframe may have encountered an issue.', 'C:\Windows\System32\imageres.dll|icon80', 'Speech Misrecognition', , 'dur=5 show=Fade@250 hide=Fade@250 maxW=400 bdr=Red')
                block.Off()
                return
            }
        }
        block.Off()
    }

    /** This function will determine if the timeline is already focused or not. If it isn't, it will focus it. */
	static __focusTimeline() {
        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }
        if this.timelineFocusStatus() = true
            return
        sleep 1
        SendEvent(KSA.timelineWindow)
        sleep 25
	}

    /**
     * Press a button *(ideally a mouse button)*, this function then changes to the "hand tool" and clicks so you can drag and easily move along the timeline, then it will swap back to the tool of your choice (selection tool for example).

     * This function will (on first use) check the coordinates of the timeline and store them, then on subsequent uses ensures the mouse position is within the bounds of the timeline before firing - this is useful to ensure you don't end up accidentally dragging around UI elements of Premiere.

     * This function will timeout after 10s by default as a preventative measure for stuck keys
     * @param {String} tool is the hotkey you want the script to input to swap TO (ie, hand tool, zoom tool, etc). (consider using KSA values)
     * @param {String} toolorig is the hotkey you want the script to input to bring you back to your tool of choice (consider using KSA values)
     * @param {Integer} [timeout=10] the number of `seconds` you want the function to wait before intentionally timing out. Defaults to `10`
     * @param {String} [dragWait=KSA.DragKeywait] The hotkey this function will wait for release before finalising logic. Defaults to the `KSA` value `DragKeyWait`. It is not recommended to simply use `A_ThisHotkey` as quick actions can trip up ahk causing that value to get poisoned
    */
    static mousedrag(premtool, toolorig, timeout := 10, dragWait := ksa.DragKeywait) {
        if GetKeyState("RButton", "P") ;this check is to allow some code in `Premiere_RightClick.ahk` to work
            return
        SetTimer(rdisable, -1)
        rdisable() {
            if GetKeyState("RButton", "P") ;this check is to allow some code in `Premiere_RightClick.ahk` to work
                return
            SetTimer(rdisable, -50)
        }

        if this.__OSwindow() && WinActive(this.winTitle) {
            SendInput("{Escape}")
            this.__focusTimeline()
        }
        coord.s()
        if !coordObj := obj.MousePos()
            return
        ;// from here down to the begining of again() is checking for the width of your timeline and then ensuring this function doesn't fire if your mouse position is beyond that, this is to stop the function from firing while you're hoving over other elements of premiere causing you to drag them across your screen
        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }

        ;// this below line of code ensures that the function does not fire if the mouse is outside the bounds of the timeline. This code should work regardless of where you have the timeline (if you make you're timeline comically small you may encounter issues)
        if !this.__checkCoords(coordObj) {
            SetTimer(rdisable, 0)
            return
        }

        this.__focusTimeline()
        if !premUIA := premUIA_Values.initialise() {
            SetTimer(rdisable, 0)
            return
        }

        SetTimer(again.Bind(timeout), -400)
        again(timeout)
        again(timeout) {
            ;// we check for the defined value `dragWait` (`ksa.DragKeywait` by default) here because LAlt in premiere is used to zoom in/out and sometimes if you're pressing buttons too fast you can end up pressing both at the same time
            isKey := false
            i := 0
            hot := getHotkeysArr()
            for _, v in hot {
                if GetKeyname(hot[(hot.Length+1)-A_Index]) = dragWait {
                    isKey := true
                    i := _
                    break
                }
            }
            if !isKey || (i != 0 && !GetKeyState(activationKey := GetKeyName(hot[i]), "P")) {
                SetTimer(rdisable, 0)
                this.__focusTimeline()
                __finish()
                return
            }

            if !this.timelineFocusStatus()
                return

            __finish()

            __finish() {
                ;// bc we're in a timer here, it's possible for another hotkey to start before this timer begins
                ;// this check here avoids that scenario causing issues
                activationKey := IsSet(activationKey) ? activationKey : ((i != 0) ? GetKeyName(hot[i]) : dragWait)
                if GetKeyState(activationKey, "P") {
                    SendInput(premtool "{LButton Down}")
                    KeyWait(activationKey, "T" timeout)
                }
                SendInput("{LButton Up}")
                SendInput(toolorig)
                SetTimer(rdisable, 0)
            }
        }
    }

    /**
     * This function will check for the blue outline around the timeline (using stored values within the class) that a focused window in premiere will ususally have.
     * @returns {Trilean} true/false/-1. `-1` indicates that the timeline coordinates could not be determined.
     */
    static timelineFocusStatus() {
        if !this.timelineVals {
            this.__setTimelineValues()
            return -1
        }
        if !this.__setTimelineValues()
            return -1
        origcoord := A_CoordModePixel, returnCoord() => A_CoordModePixel := origcoord
        coord.s()
        if PixelGetColor(this.timelineRawX-1, this.timelineRawY+10) = this.focusColour {
            returnCoord()
            return true
        }
        returnCoord()
        return false
    }

    /**
     * ### Note: This function will evaluate the premiere timeline coordinates based off the `screen` coordmode. This cannot be changed.
     * A function to retrieve the coordinates of the Premiere timeline. These coordinates are then stored within the `Prem {` class.
     * @param {Boolean} tools whether you wish to have tooltips appear informing the user about timeline values. Defaults to true. Sends tooltips on `WhichToolTip` 11/12/13
     * @returns {Boolean} `true/false`
     */
    static getTimeline(tools := true) {
        coord.s()

        ;// this block is called if the function originates from a script that isn't `Core Functionality.ahk`
        if A_ScriptName != "Core Functionality.ahk" {
            try {
                activeObj := CLSID_Objs.load("prem")
                if activeObj.__checkTimelineValues() {
                    coord.s()
                    this.timelineRawX     := activeObj.timelineRawX,     this.timelineRawY     := activeObj.timelineRawY
                    this.timelineXValue   := activeObj.timelineXValue,   this.timelineYValue   := activeObj.timelineYValue
                    this.timelineXControl := activeObj.timelineXControl, this.timelineYControl := activeObj.timelineYControl
                    this.timelineVals     := true
                    return true
                }
            } catch {
                Critical("Off")
                notifyExt.showIfNotExist("failedCSLIDobj",, "Failed to interact with ComObj, it may not be initialised yet.`nTry again soon.",,,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
                keys.allWait()
                return false
            }
        }

        if !premUIA := premUIA_Values.initialise() {
            keys.allWait()
            return false
        }
        timelineNN := premUIA.UIA_Objs['timelineWindow']

        ;// determine how much to account for the column left of the timeline based on premiere version
        xAddMap := Map("26.2", 204)
        for k, v in xAddMap {
            if VerCompare(this.currentSetVer, k) >= 0 {
                xAdd := v
                continue
            }
            break
        }

        Critical()
        if A_ScriptName != "Core Functionality.ahk" {
            try {
                ;// we're setting the Core Functionality object (and this object) with the timeline coords - this will allow other scripts to retrieve them without needing to set them again
                activeObj := CLSID_Objs.load("prem")
                coord.s()
                activeObj.timelineRawX     := this.timelineRawX     := timelineNN.location.x
                activeObj.timelineRawY     := this.timelineRawY     := timelineNN.location.y
                activeObj.timelineXValue   := this.timelineXValue   := timelineNN.location.x + timelineNN.location.w - 22  ;accounting for the scroll bars on the right side of the timeline
                activeObj.timelineYValue   := this.timelineYValue   := timelineNN.location.y + 46                          ;accounting for the area at the top of the timeline that you can drag to move the playhead
                activeObj.timelineXControl := this.timelineXControl := timelineNN.location.x + xAdd                        ;accounting for the column to the left of the timeline
                activeObj.timelineYControl := this.timelineYControl := timelineNN.location.y + timelineNN.location.h - 25  ;accounting for the scroll bars at the bottom of the timeline
                activeObj.timelineVals     := this.timelineVals     := true
                activeObj := ""
                Critical("Off")
            } catch {
                activeObj := ""
                Critical("Off")
                notifyExt.showIfNotExist("failedCSLIDobj",, "Failed to interact with ComObj, it may not be initialised yet.`nTry again soon.",,,, 'POS=BR BC=C72424 show=Fade@250 hide=Fade@250')
                keys.allWait()
                return false
            }
        }
        if tools = true {
            notifyExt.showIfNotExist("premTimelineCoords",, "Timeline Coordinates successfully determined.", 'C:\Windows\System32\imageres.dll|icon61',,, 'POS=BR DUR=3 MALI=CENTER BC=0x1F1F1F bdr=0x5959FF show=Fade@250 hide=Fade@250')
        }
        return true
    }

    /** resets internal values for the timeline */
    static __resetTimelineVals() {
        this.timelineVals := false, this.timelineRawX := 0, this.timelineRawY := 0, this.timelineXValue := 0, this.timelineYValue := 0, this.timelineXControl := 0, this.timelineYControl := 0
    }

    /**
     * This function will attempt to select the desired tool using UIA.
     * @param {String} [tool=selectionTool] the name of the tool. Must correspond to a tool set within `Premiere_UIA.ahk` or the function will throw.
     */
    static selectTool(tool := "selectionTool") {
        if !premUIA := premUIA_Values.initialise()
            return false
        if premUIA.isToolSelected(tool, premUIA) = false {
            try premUIA.UIA_Objs[tool].Click()
            catch {
                return false
            }
        }
        return true
    }

    /**
     * Trying to zoom in on the preview window can be really annoying when the hotkey only works while the window is focused
     * This function will ensure it happens regardless
     * @param {String} command the hotkey to send to premiere to zoom however you wish
     * @param {Boolean} [zoomToFit=true] determine whether the hotkey you're trying to send is the `zoom to fit` hotkey. This hotkey was made a global hotkey in premiere versions >=25.2 so this function has code to end logic early if the user's prem ver is higher than that
    */
    static zoomPreviewWindow(command, zoomToFit := false) {
        __sendOrig() {
            if A_ThisHotkey != "" {
                hot := SubStr(A_ThisHotkey, 1, 1) = "$" ? SubStr(A_ThisHotkey, 2) : A_ThisHotkey
                SendInput(hot)
            }
        }
        title := WinGet.PremName()
        CaretGetPos(&carx, &carY)
        if WinGet.Title() != title.winTitle || CaretGetPos(&carx, &carY) {
            __sendOrig()
            return
        }

        hot := (SubStr(command, 1, 1) = "$" && StrLen(command) > 1) ? SubStr(command, 2) : command

        ;// with prem 25.2 zoom to fit can be set as a global hotkey
        if zoomToFit = true && VerCompare(ptf.premSETver, "v25.2") >= 0 {
            SendInput(command)
            return
        }
        if !premUIA := premUIA_Values.initialise()
            return
        toolsNN := premUIA.UIA_Objs["toolsWindow"]
        projActive := premUIA.__isUiaElementActive("projectsWindow", premUIA)
        textStatus := premUIA.isToolSelected("textTool", premUIA)
        if !toolsNN || (projActive = true) || textStatus {
            __sendOrig()
            return
        }
        ;// we first need to focus a window that won't cycle through anything if you activate it multiple times
        ;// if you don't, activating the program monitor while it's already activated will cycle timeline sequences
        delaySI(50, KSA.effectControls, KSA.programMonitor, command)
    }

    /**
     * Quickly and easily move any number of frames in the desired direction.
     * @param {String} direction the direction you wish to move
     * @param {Integer} frames the amount of frames you wish to move in that direction
     * @param {String} windowHotkey the hotkey you wish to send to premiere to focus your window of choice. Defaults to the `Effect Controls` window
     */
    static moveKeyframes(direction, frames, windowHotkey := KSA.effectControls) {
        if direction != "left" && direction != "right" {
            ;// throw
            errorLog(ValueError("Value is not a valid direction", direction, -1),,, 1)
        }
        delaySI(50, windowHotkey, windowHotkey)
        SendInput(Format("`{{1} {2}`}", direction, frames))
    }

    /**
     * A function to simply open an asset folder
     * @param {String} dir the path to the directory you wish to open
     */
    static openEditingDir(dir) {
        dirObj := obj.SplitPath(dir)
        if WinExist(dirObj.name) {
            WinActivate(dirObj.name)
            return
        }
        Run(dir)
        if !WinWaitActive(dirObj.name,, 3) {
            if WinExist(dirObj.name)
                WinActivate(dirObj.name)
        }
    }

    /**
     * This function returns whether the classes internal timeline values have been set
     * @returns {Boolean}
     */
    static __checkTimelineValues() {
        try premObj := CLSID_Objs.load("prem")
        catch {
            premObj := ""
            return false
        }
        if (this.timelineXValue = 0 || this.timelineYValue = 0 || this.timelineXControl = 0 || this.timelineYControl = 0) ||
            (this.timelineVals = false || premObj.timelineVals = false) {
            premObj := ""
            return false
        }
        premObj := ""
        return true
    }

    /**
     * This function waits for the timeline to be in focus
     * @param {Integer} timout how many `seconds` you want to wait before this function times out
     */
    static __waitForTimeline(timeout := 5) {
        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }
        loop timeout {
            if !this.timelineFocusStatus() {
                this.__focusTimeline()
                sleep 1000
                continue
            }
            return true
        }
        return false
    }

    /**
     * Checks to see if the timeline values within `prem {` have been set. If not, this function will attempt to retrieve them.
     * @param {Boolean} tools whether you wish to have tooltips appear informing the user about timeline values
     * @returns {Boolean} if the timeline cannot be determined, returns `false`. Else returns `true`
     */
	static __setTimelineValues(tools := true) {
		if !this.__checkTimelineValues() {
			if !this.getTimeline(tools)
				return false
		}
		return true
	}

    /**
     * This function checks if the mouse is outside the bounds of the timeline.
     * This code should work regardless of where you have the timeline (unless you make your timeline comically small, then you may encounter issues)
     * @returns {Boolean} if the cursor is **not** within the timeline, returns `false`. Else returns `true`
     */
	static __checkCoords(coordObj) {
		if ((coordObj.x > this.timelineXValue) || (coordObj.x < this.timelineXControl) || (coordObj.y < this.timelineYValue) || (coordObj.y > this.timelineYControl))
			return false
		return true
	}

    /**
     * This function handles accelorating scrolling within premiere. It specifically expects the first activation hotkey to be either `alt` or `shift`.
     * This function will attempt to only fire within the timeline.
     *
     * *Due to ahk quirkiness, this function can act incredibly laggy and cause windows to beep if it's not placed in the perfect spot in your script.*
     * @param {Integer} altAmount the amount of accelerated scrolling you want
     * @param {Integer} scrollAmount the amount of accelerated scrolling you want
     */
    static accelScroll(altAmount := 2, scrollAmount := 5) {
        SetStoreCapsLockMode(true)
        if !this.__setTimelineValues()
			return
        if !origMouse := obj.MousePos()
            return
        withinTimeline := this.__checkCoords(origMouse)
        if GetKeyState("SC03A", "P") && withinTimeline = true
            return
        if !withinTimeline
            scrollAmount := 1, altAmount := 1
        getDir := getHotkeys()
        if !getDir
            return
        switch GetKeyName(getdir.first) {
            case "Alt", "LAlt": delaySI(0, SendInput(Format("!{{1} {2}}", getDir.second, altAmount)))
            default:    delaySI(0, SendInput(Format("{{1} {2}}", getDir.second, scrollAmount)))
        }
    }


    /**
     * This is an internal function for `prem.Previews()` simply to make code a little cleaner. It handles sending a desired hotkey to delete previews then waiting for the delete dialogue box premiere presents the user.
     * @param {String} sendHotkey which hotkey you wish to send
     */
    __delprev(sendHotkey, wasActive := false) {
        SendInput(sendHotkey)
        if !WinWait("Confirm Delete " prem.exeTitle,, 3) {
            if wasActive = "active" {
                SendInput(sendHotkey)
                if !WinWait("Confirm Delete " prem.exeTitle,, 2)
                    return
            }
        }
        WinActivate("Confirm Delete " prem.exeTitle)
        if !WinWaitActive("Confirm Delete " prem.exeTitle,, 3)
            return
        sleep 1000
        SendInput("{Enter}")
        if !WinExist("Confirm Delete " prem.exeTitle)
            return
        loop 3 {
            WinActivate("Confirm Delete " prem.exeTitle)
            sleep 100
            SendInput("{Enter}")
            sleep 500
            if !WinExist("Confirm Delete " prem.exeTitle)
                return
        }
    }

    /**
     * This function handles hotkeys related to deleting `Previews`. This function will attempt to save the project before doing anything.
     *
     * @param {String} sendHotkey which hotkey you wish to send
     */
    static deletePreviews(sendHotkey) {
        if !WinActive(this.exeTitle)
            return
        title := WinGet.PremName()
        if title.saveCheck != false
            attempt := this.saveAndFocusTimeline()
        this().__delprev(sendHotkey, attempt ?? false)
    }

    /** This function handles rendering `Previews` between the current `In`/`Out` point. This function *requires* `PremiereRemote` */
    static renderPreviewsInOut() {
        prem.save(, 0, 0)
        prem.__remoteFunc('renderPreviews')
    }

    /**
     * Checks to see if the playhead is within the defined coordinates
     * @param {Integer} coordObj an object containing the cursor coordinates you want pixelsearch to check. This object should contain: `{x1: , y1: , x2: , y2: }`. The default to search the timeline (assuming values have been set) can be found in the example`
     * @param {Hexadecimal} playheadCol the colour you wish pixelsearch to look for
     * @returns {Obj/Boolean false} if successful and the playhead is found, returns object `{x: , y: }`. Else returns `false`
     * ```
     * if !origMouse := obj.MousePos()
     *    return
     * searchPlayhead({x1: prem.timelineXValue, y1: origMouse.y, x2: prem.timelineXControl, y2: origMouse.y})
     * ```
     */
    static searchPlayhead(coordObj, playheadCol := this.playhead) {
        if PixelSearch(&pixX, &pixY, coordObj.x1, coordObj.y1, coordObj.x2, coordObj.y2, playheadCol)
			return {x: pixX, y: pixY}
        return false
    }

    /**
     * This function will search for the playhead and then slowly begin scrubbing forward. This function was designed to make scrubbing for thumbnail screenshots easier
     */
    static thumbScroll() {
        storeHotkey := A_ThisHotkey
		if !origMouse := obj.MousePos()
            return
        block.On()
        ;// set coord mode and grab the cursor position
		coord.s()
        originalSpeed := this.scrollSpeed
        ;// checks to see whether the timeline position has been located
        if !this.__setTimelineValues() {
            block.Off()
            keys.allWait()
			return
        }
		;// checks the coordinates of the mouse against the coordinates of the timeline to ensure the function
		;// only continues if the cursor is within the timeline
		if !this.__checkCoords(origMouse) {
            block.Off()
            keys.allWait()
			return
        }
        ;// check whether the timeline is already in focus & focuses it if it isn't
		this.__focusTimeline()
        ;// determines the position of the playhead
        if !playhead := this.searchPlayhead({x1: this.timelineXValue, y1: origMouse.y, x2: this.timelineXControl, y2: origMouse.y}) {
            block.Off()
            errorLog(TargetError("Could not determine the position of the playhead", -1),, 1)
            keys.allWait()
            return
        }
        this.stopPlayback()
        MouseMove(playhead.x, playhead.y)
        SendInput("{LButton Down}")
        block.Off()
        if !GetKeyState(storeHotkey, "P") {
            SendInput("{LButton Up}")
            return
        }
        PremHotkeys.__HotkeySetThumbScroll(["Shift", "Ctrl"])
        while GetKeyState(storeHotkey, "P") {
            if !getpos := obj.MousePos() || !this.__checkCoords(getpos)
                break
            MouseMove(this.scrollSpeed, 0,, "R")
            sleep 50
        }
        SendInput("{LButton Up}")
        PremHotkeys.__HotkeyReset(["Shift", "Ctrl"])
        this.scrollSpeed := originalSpeed
    }

    /**
     * #### This function requires you to properly set your ripple trim previous/next keys correctly within `KSA` as well as requires you to make those same keys call `prem.rippleTrim()` in your main ahk script. This function must also then be called from the key you generally use to toggle playback (default is `Space`)
     * If the user immediately attempts to resume playback after ripple trimming the playhead will sometimes either; not be placed at the beginning of the clip and will inadvertently begin playback where you might not expect it to, or will simply not resume playback if the user tries to resume playback immediately after ripple trimming
     * This function attempts to delay playback immediately after a trim to mitigate this behaviour. This function might require some adjustment from the user depending on how fast/slow their pc is
     * @param {Integer} delayMS the delay in `ms` that you want the function to wait before attempting to resume playback. Defaults to a value set within the class
     */
    static delayPlayback(delayMS?) {
        this.defaultDelay := IsSet(delayMS) ? delayMS : this.defaultDelay
        delayMS := IsSet(delayMS) ? delayMS : this.defaultDelay
        if !this.__checkTimelineValues() {
            this.getTimeline(false)
            return
        }
        if !this.timelineFocusStatus()
            return
        __sendSpace() => (SendEvent(ksa.playStop))
        if (A_PriorKey != ksa.premRipplePrev && A_PriorKey != ksa.premRippleNext) ||
            ((A_PriorKey = ksa.premRipplePrev || A_PriorKey = ksa.premRippleNext) && (this.delayTime >= delayMS) || this.delayTime = 0) {
                __sendSpace()
                return
            }
        SetTimer(__sendSpace, -(delayMS-this.delayTime))
    }

    /**
     * Tracks how long it has been since the user used a ripple trim. This function is to provide proper functionality to `prem.delayPlayback()`
     * @param {Boolean} [pauseFirst=true] determnines whether to stop playback before attempting to ripple trim (requires `ksa.shuttleStop` to be set correctly)
     * @param {Integer} [delay=50] how long you wish for the function to stall after halting playback before attempting to ripple trim. This is necessary as premiere can be a little slow to receive inputs so spamming them back to back may result in some inputs being missed. If `pauseFirst` is set to false, this parameter is irrelevant
     */
    static rippleTrim(pauseFirst := true, delay := 50) {
        Critical()
        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }
        ;// ensure the user isn't typing
        if CaretGetPos(&x, &y) || !this.timelineFocusStatus() {
            SendInput(A_ThisHotkey)
            return
        }
        this.delayTime += 1
        if pauseFirst = true {
            this.stopPlayback()
            sleep(delay)
        }
        SendEvent(A_ThisHotkey)
        SetTimer(__track.Bind(A_TickCount), 16)
        __track(initialTime) {
            ListLines(0)
            currentTime := A_TickCount - initialTime
            if currentTime >= this.defaultDelay {
                this.delayTime := 0
                return
            }
            this.delayTime := currentTime
        }
    }

    /**
     * Copies the selected content to the clipboard, then performs a ripple delete
     * @link https://github.com/kristenmaxwell/KMAP/blob/master/premiere/inc_premiere_subroutines.ahk#L70
     */
    static rippleCut() {
        checkForFunc := this.__checkPremRemoteDir("isSelected")
        if !checkForFunc && !this.__remoteFunc('isSelected', true) {
            if !checkForFunc {
                    errorLog(MethodError('This function requires ``PremiereRemote``', -1),, true)
                }
            return
        }
        name := WinGet.PremName()
        MenuSelect(name.winTitle, "", "Edit", "Copy")
        MenuSelect(name.winTitle, "", "Edit", "Ripple Delete")
    }

    /**
     * A function to simply copy the current anchor point coordinates and transfer them to the position value. This function is designed for use in the `Transform` Effect and not the motion tab.
     * @param {Boolean} [ae=false] determine whether you're calling this function for after effects or premiere as some of the logic may be different per version.  Defaults to `false`
     */
    static anchorToPosition(ae := false) {
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
        if ae = true {
            delaySI(50, "{Tab}", anch1, "{Tab}", anch2, "{Enter}")
            clip.delayReturn(clipb.storedClip)
            blocker.Off()
            return
        }
        switch {
            ;// versions 25.4 and greater. They now focus the reset button when you tab
            case VerCompare(this.currentSetVer, "25.5") >= 0: delaySI(50, "{Tab 2}", anch1, "{Tab}", anch2, "{Enter}")
            ;// versions below 25.4
            ; case VerCompare(this.currentSetVer, "25.4") < 0: delaySI(50, "{Tab}", anch1, "{Tab}", anch2, "{Enter}")
        }

        clip.delayReturn(clipb.storedClip)
        blocker.Off()
    }

    /**
     * This function is mostly designed for my own workflow and isn't really built out with an incredible amount of logic.
     *
     * This function was originally designed to swap the L/R channel on a single track stereo file but may also function on a dual track stereo file where you're expecting both the L & R channels to use the same media source channel. attempting to use this script on anything else will either produce unintended results or will simply not function at all
     * @param {Integer} [mouseSpeed=2] what speed the mouse should move to interact with the Modify Clip window
     * @param {Number} [adjustGain=false] determine whether to adjust gain after modifying the channels. It should be noted once again that this function is specifically designed for my workflow - if it swaps to the R channel it will increase gain by this parameter, if it swaps to the left it wil take away this parameter
     * @param {String} [changeLabel?] leave unset if you do not wish to change the label colour of the selected clip(s), otherwise provide the hotkey required to change to the desired colour
     */
    static swapChannels(mouseSpeed := 2, adjustGain := false, changeLabel?) {
        block.On()
        clipWinTitle := "Modify Clip"
        coord.s()
        if !origCoords := obj.MousePos()
            return
        SetDefaultMouseSpeed(mouseSpeed)

        if !WinActive(clipWinTitle) {
            if this.__checkTimelineValues() = true {
                sleep 100
                if !this.__waitForTimeline(3)
                    return
            }
            SendInput(ksa.audioChannels)
            if !WinWait(clipWinTitle,, 3) {
                block.Off()
                errorLog(Error("Timed out waiting for window", -1),, 1)
                return
            }
            sleep 150
        }

        if !clipWin := obj.WinPos(clipWinTitle)
            return
        __searchChannel(&x, &y, &chan, &clip) => (chan := ImageSearch(&x, &y, clipWin.x, clipWin.y + 150, clipWin.x + 200, clipWin.y + 500, "*2 " ptf.Premiere "channel1.png"), clip := ImageSearch(&x, &y, clipWin.x, clipWin.y + 125, clipWin.x + 200, clipWin.y + 325, "*2 " ptf.Premiere "clip1.png"))
        if !__searchChannel(&x, &y, &chan, &clip) {
            sleep 150
            if !__searchChannel(&x, &y, &chan, &clip) {
                block.Off()
                errorLog(TargetError("Couldn't find channel 1.", -1),, 1)
                return
            }
        }
        left  := obj.imgSrchMulti({x1: x, y1: y - 50, x2: x + 200, y2: y + 50},, &checkX, &checkY, ptf.Premiere "L_unchecked.png", ptf.Premiere "L_unchecked2.png") ? coords := {x: checkX, y: checkY} : false
        right := obj.imgSrchMulti({x1: x+50, y1: y - 50, x2: x + 200, y2: y + 50},, &checkX, &checkY, ptf.Premiere "R_unchecked.png", ptf.Premiere "R_unchecked2.png") ? coords := {x: checkX, y: checkY} : false

        ;// if the file isn't dual channel it might not have two checkboxes and thus `coords` won't be set
        if (!IsSet(coords) || !coords) || (!left && !right) {
            MouseMove(x, y)
            block.Off()
            errorLog(TargetError("Couldn't find unchecked channel.", -1),, true)
            return
        }
        which := (left != 0) ? "L_unchecked.png" : "R_unchecked.png"
        Click(Format("{} {}", coords.x+10, coords.y+30))
        if chan != 0 {
            ;// this block is to correct when L is one channel and R is another
            ;// both should end up the same channel
            if ImageSearch(&rX, &rY, x, y, x+60, y+60, ptf.Premiere "channel_R.png") {
                secLeft := (IsSet(left)) ? obj.imgSrch(ptf.Premiere "channel_unchecked.png", {x1: rX, y1: ry, x2: rX + 200, y2: ry+15}) : false
                secRight := (IsSet(right)) ? obj.imgSrch(ptf.Premiere "channel_unchecked.png", {x1: rX+50, y1: ry, x2: rX + 200, y2: ry+15}) : false
                if !secLeft && !secRight {
                    block.Off()
                    errorLog(TargetError("Couldn't find unchecked channel.", -1),, 1)
                    return
                }
                if which = "R_unchecked.png" && secRight != false || which = "L_unchecked.png" && secLeft != false
                    Click(Format("{} {}", coords.x+10, coords.y+this.secondChannel))
            }
        }

        if !ImageSearch(&okX, &okY, clipWin.x, (clipWin.y + clipWin.height) - 150, clipWin.x + clipWin.width, clipWin.y + clipWin.height, "*2 " ptf.Premiere "channels_ok.png") {
            block.Off()
            errorLog(TargetError("Couldn't find OK button.", -1),, 1)
            return
        }
        MouseMove(okX, okY, 1)
        SendInput("{Click}")
        MouseMove(origCoords.x, origCoords.y, 2)

        if WinExist(clipWinTitle)
            WinWaitClose(clipWinTitle)
        sleep 50

        if adjustGain != false && IsNumber(adjustGain) {
            addOrSub := (left != 0) ? "-" : ""
            this.gain(addOrSub adjustGain)
        }
        if !IsSet(changeLabel) {
            block.Off()
            return
        }
        ; sleep 100
        SendInput(changeLabel)
        block.Off()
    }

    /**
     * A function designed to allow the user to quickly dismiss certain fx windows that otherwise require them to manually dismiss them
     * @param {String} [onFailure="{Escape}"] what the function will send in the event that the active window isn't defined
     */
    static escFxMenu(onFailure := "{Escape}") {
        ;// excalibur window
        if WinExist("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME") {
            WinClose("ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME")
            sleep 200
            this.__focusTimeline()
            return
        }
		windows := Map(
			"Clip Fx Editor", true, "Track Fx Editor", true
		)
		activeWin := WinGet.Title()
		inList := false
		for k, v in windows {
			if InStr(activeWin, k)
				inList := true
		}
		coord.s()
        mousePos := obj.MousePos(), winObj := obj.WinPos(activeWin)
		if !mousePos || !winObj
            return
        (inList = true && WinGet.Title() == activeWin) ? SendEvent("{Click " ((winObj.x+winObj.width)-19) A_Space winObj.y+16 "}") : (SendInput(onFailure), Exit())
		MouseMove(mousePos.x, mousePos.y)
		sleep 200
		this.__focusTimeline()
	}

    /**
     * Premiere loves to spit stupid warning boxes at you, especially if it has even the smallest issue trying to playback audio. This function will detect that window and automatically click the x button to close the window. This is especially necessary when using other functions of mine like those in `Premiere_RightClick.ahk` as the error window messes with the active window and may confuse those scripts
     * @param {boolean} [waitWinClose=true] determines whether to wait for the window to close or not
     * @param {String} [window="DroverLord - Overlay Window ahk_class DroverLord - Window Class"] the window you wish to wait to close. This parameter is meaningless unless `waitWinClose` is set to `true`
     */
    static dismissWarning(waitWinClose := true, window := "DroverLord - Overlay Window ahk_class DroverLord - Window Class") {
        if !WinActive(this.winTitle)
            return
        ;// we have to do a few checks
        ;// can't drag panels unless we check `LButton` state & in premiere v25.3 the function sometimes causes the mouse to shoot near
        ;// the program monitor unless we check the state of ctrl/alt
        if (!hwnd := WinExist(window) || GetKeyState("LButton", "P")) || (GetKeyState("LCtrl", "P") || GetKeyState("LAlt", "P"))
            return

        block.On()
        coord.s()
        if !origMouse := obj.MousePos() {
            block.Off()
            return
        }

        try WinClose(hwnd)
        catch {
            __manualMethod()
            return
        }
        if !WinExist(hwnd) {
            if !waitWinClose
                return
            WinWaitClose(window,, 5)
            return
        }
        __manualMethod()

        __manualMethod() {
            if !drover := obj.WinPos(window) {
                block.Off()
                return
            }
            MouseMove((drover.x + drover.width)-15, drover.y+15, 2)
            SendInput("{Click}")
            MouseMove(origMouse.x, origMouse.y, 2)
            block.Off()
            if !waitWinClose
                return
            WinWaitClose(window,, 5)
        }
    }

    /**
     * A function to quickly drag the audio or video track from the source monitor to the timeline. This is often easier than dealing with insert/override quirkiness.
     * @param {String} [audOrVid="audio"] determine whether you wish to drag the audio or video track. This parameter must be either `"audio"` or `"video"`
     * @param {String} [sendOnFailure=A_ThisHotkey] define what hotkey you want this function to send in the event that the main premiere window isn't the active window. This function will correctly handle any single key activation hotkey - if your activation is more (ie `Ctrl & F19`) you will need to instead define this parameter as `"^{F19}" etc
     * @param {String} [specificFile=false] if set the function will only activate if the desired file is open within the source monitor. Defaults to `false`. If not set to `false` a path must be provided to the file; ie. `"_Assets/01_Other/Bars and Tone - Rec 709"` you may encounter issues if you try to use `\` instead of `/`
     * @param {Boolean} [searchForFile=false] if set to `true` the function will attempt to search for the desired file provided in `specificFile`, then attempt to load it into the source monitor. Defaults to `false`
     */
    static dragSourceMon(audOrVid := "audio", sendOnFailure := A_ThisHotkey, specificFile := false, searchForFile := false) {
        if audOrVid != "audio" && audOrVid != "video" {
            ;// throw
            errorLog(PropertyError("Incorrect value in Parameter #1", -1),,, true)
            return
        }
        key := keys.allWait()
        if !key
            return
        for v in key {
            try name := GetKeyName(v)
            catch {
                continue
            }
            if name = "Shift" || name = "+" {
                errorLog(ValueError("``Shift`` cannot be the first activation hotkey.", -1),,, true)
                return
            }
        }
        blocker := block_ext()
        blocker.On()
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        try activeWin := WinGet.Title()
        if !IsSet(activeWin) || activeWin != getTitle.winTitle {
            if !InStr(A_ThisHotkey, "&")
                try SendInput("{" Format("sc{:X}", GetKeySC(A_ThisHotkey)) "}")
            /* else
                try SendInput(sendOnFailure) */
            blocker.Off()
            return
        }

        ckDir := this.__checkPremRemoteDir("sourceMonName"), ckFunc := this.__checkPremRemoteFunc("sourceMonName"), ckLoad := this.__checkPremRemoteFunc("loadInSourceMonitor")
        if !ckDir || !ckFunc || !ckLoad {
            ;// throw
            blocker.Off()
            errorLog(MethodError("Some PremiereRemote functions are missing. Aborting", -1),,, true)
            return
        }
        coord.s()
        if !origMouse := obj.MousePos() {
            blocker.Off()
            return
        }
        if specificFile != false && specificFile != "" {
            getName := this.__remoteFunc("sourceMonName", true)
            sourceMonFile := SubStr(specificFile, (pos := instr(specificFile, "/",, -1) || pos := instr(specificFile, "\",, -1)) ? pos+1 : 1)
            if getName != specificFile {
                __exit() {
                    errorLog(TargetError("The requested file: " sourceMonFile "`ncould not be found or could not be loaded into the source monitor.", -1),, true)
                    blocker.Off()
                    return
                }
                if searchForFile = true {
                    this.__remoteFunc("loadInSourceMonitor",, "itemPath=" specificFile)
                    sleep 150
                    recheck := this.__remoteFunc("sourceMonName", true)
                    if recheck != sourceMonFile {
                        __exit()
                        return
                    }
                } else {
                    __exit()
                    return
                }
            }
        }

        if !premUIA := premUIA_Values.initialise() {
            blocker.Off()
            return
        }
        sourceMonNN := premUIA.UIA_Objs["sourceMonitor"]
        prefixTitle := "sourceMon_"
        found := false
        loop 10 {
            indexNum := (A_Index = 1) ? "" : A_Index
            if !FileExist(ptf.Premiere prefixTitle audOrVid indexNum ".png")
                break
            heightNum := (A_Index = 1) ? 0.7 : Max(Round(0.7-Number(Format("0.{1}", indexNum-1)), 1), 0.1)
            if !ImageSearch(&sourceX, &sourceY, sourceMonNN.location.x, sourceMonNN.location.y+(sourceMonNN.location.h*heightNum), sourceMonNN.location.x+sourceMonNN.location.w, sourceMonNN.location.y+sourceMonNN.location.h, "*2 " ptf.Premiere prefixTitle audOrVid indexNum ".png")
                continue
            found := true
            break
        }
        if found = false {
            errorLog(TargetError("Image: ``" prefixTitle audOrVid ".png`` not found. Source monitor may not contain a file.", -1),, true)
            blocker.Off()
            return
        }
        MouseClickDrag("Left", sourceX+4, sourceY+3, origMouse.x, origMouse.y, 1)
        blocker.Off()
    }

    /**
     * A function to flatten a multicam clip, optionally disable/enable it, then recolour it to a specific label colour.
     * @param {String} colour the hotkey required to set the colour of your choosing. Can be a `KSA` value
     */
    static flattenAndColour(colour) {
        keys.allWait()
        block.On()
        this.__focusTimeline()
        delaySI(100, ksa.flattenMulti, colour)
        block.Off()
    }

    /**
     * determine if the current cursor position is hovering over a layer divider
     * @param {Object} [coords] an object containing the `x`/`y` value of the current cursor coords
     * @returns {Boolean}
     */
    static __layerDividerCheck(coords) {
        dividerCheck := PixelGetColor(this.timelineRawX+5, coords.y)
        if dividerCheck = this.layerDivider {
            notifyExt.showIfNotExist("premLayerDivider",, 'The user is currently hovering between a layer.`nThis function will not continue.', 'C:\Windows\System32\imageres.dll|icon90',,, 'dur=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xC72424')
            return false
        }
        return true
    }

    /**
     * Determines the x/y pos of the middle divider using UIA
     * @param {VarRef} [] x/y values of middle divider
     * @returns {boolean/VarRef} returns `true`/`false` for success of the imagesearch - if true will also return the x/y/bottom y value of the middle divider as varrefs
     */
    static __getlayerMid(&midDivX?, &midDivY?, &midDivYBottom?) {
        try {
            if !premUIA := premUIA_Values.initialise()
                return false

            ;// the timeline pane itself loses its hwnd if you swap sequences, so we have to use the container instead
            timelineWindow := UIA.ElementFromHandle(premUIA.UIA_Hwnd["timelineWindow"])
            timelineUIA    := timelineWindow.FindElement({Name:"Timeline", LocalizedType:"pane"})
            children       := timelineUIA.Children

            icvIndices := []
            for i, child in children {
                if child.Name == "UI_InteractiveControlView" {
                    ;// Check if any direct child is a text element - if so, skip it
                    hasText := false
                    for grandchild in child.Children {
                        if grandchild.LocalizedType == "text" {
                            hasText := true
                            break
                        }
                    }
                    if !hasText
                        icvIndices.Push(i)
                }
                if icvIndices.Length == 2
                    break
            }
            if icvIndices.Length < 2
                return false

            adjustVal     := 3 ;// the pixel difference between the top/bottom of the scroll bar control & the middle divider bar. May change in future versions
            midDivX       := timelineUIA.Location.x
            midDivY       := children[icvIndices[1]].Location.y + children[icvIndices[1]].Location.h + adjustVal
            midDivYBottom := children[icvIndices[2]].Location.y - adjustVal
        } catch {
            return false
        }
        return true
    }

    /**
     * Determines the top/bottom position of the layer the cursor is currently within. Will also optionally determine the position of the middle divider
     * @param {Object} [coords] an object containing the `x`/`y` value of the current cursor coords
     * @param {Boolean} [searchMid=true] determine whether to search for the middle divider
     * @param {VarRef} [] x/y values of `top`/`bot`/`mid` in that order
     * @param {Boolean} [showError=true] determine whether to show the `Notify {` error on failure. May be useful to disable this if systematically trying to determine all layer positions as it will show the error once it runs out of tracks
     * @returns {Boolean/Object} returns boolean `false` on failure or an object containing all coords on success
     */
    static __getlayerTopBottom(coords, searchMid := true, &topDivX?, &topDivY?, &botDivX?, &botDivY?, &midDivX?, &midDivY?, &midDivBot?, showError?) {
        doNotify := IsSet(showError) && (showError=true || showError=false) ? showError : true
        topDiv := PixelSearch(&topDivX, &topDivY, this.timelineRawX+5, coords.y, this.timelineRawX+5, this.timelineRawY, this.layerDivider)
        botDiv := PixelSearch(&botDivX, &botDivY, this.timelineRawX+5, coords.y, this.timelineRawX+5, this.timelineYControl, this.layerDivider)
        mid := (searchMid = true) ? this.__getlayerMid(&midDivX, &midDivY, &midDivBot) : true
        if (!topDiv || !botDiv || !mid) {
            if doNotify = true && !Notify.Exist("premLayerBounds")
                Notify.Show(, 'Could not determine the layer boundaries. Please try again.', 'C:\Windows\System32\imageres.dll|icon90',,, 'dur=3 show=Fade@250 hide=Fade@250 maxW=400 bdr=0xC72424 tag=premLayerBounds')
            return false
        }
        return {topX: topDivX, topY: topDivY, botX: botDivX, botY: botDivY, midX: midDivX ?? false, midY: midDivY ?? false, midBot: midDivBot ?? false}
    }

    /**
     * A function designed to allow you to quickly adjust the size of the layer the cursor is within. <kbd>LAlt</kbd> **MUST** be one of the activation hotkeys and is required to be held down for the duration of this function.
     * @param {Boolean} [capsLockDisable=true] (if the user does *NOT* use <kbd>CapsLock</kbd> to activate this function, they should set this value to `false`) because I use capslock as the activation key (and also have it set to "AlwaysOff"), ahk is a bit quirky and will sometimes just not reset that even if I use `SetStoreCapsLockMode(true)` - so setting this parameter to `true` will cause the function to manually call `SetCapsLockState('AlwaysOff')` at the end of its logic
     * @param {Boolean} [middle=false] determine whether you wish to adjust the middle divider instead of the current track. Be aware that due to windows/ahk issues when it comes to tracking whether keys are still held down; this function will not move the divider to the desired location until the user has let go of <kbd>LAlt</kbd>
     */
    static layerSizeAdjust(capsLockDisable := true, middle := false) {
        if !WinActive(this.winTitle)
            return
        __resetCaps(storekey, capslockState) {
            if (InStr(storeHotkey, "CapsLock") || InStr(storeHotkey, "sc03a")) && !capslockState && capsLockDisable = true
                SetCapsLockState('AlwaysOff')
        }
        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }
        SetDefaultMouseSpeed(0)
        SetStoreCapsLockMode(true)
        InstallKeybdHook(true, true)
        capslockState := GetKeyState("CapsLock", "T")
        storeHotkey := A_ThisHotkey
        if !this.__setTimelineValues() {
            __resetCaps(storeHotkey, capslockState)
			return
        }
        if !this.timelineFocusStatus() {
            this.__focusTimeline()
            tool.Cust("The timeline has been focused, you will need to reactive`nthe hotkey to continue", 3.0)
            __resetCaps(storeHotkey, capslockState)
            return
        }
        coord.s()
        blocker := block_ext()
        blocker.On()

        getTitle := WinGet.PremName(), origMouseCords := obj.MousePos(), activationKey := getHotkeys(), LAltAct1 := GetKeyState("LAlt", "P"), LAltAct2 := GetKeyState("LAlt"), actWindow := WinGet.Title()
        ;// avoid attempting to fire unless main window is active
        if !getTitle || !origMouseCords || !activationKey || (!LAltAct1 && !LAltAct2) || actWindow != getTitle.winTitle {
            blocker.Off()
            return
        }
        withinTimeline := this.__checkCoords(origMouseCords)
        if withinTimeline != true {
            blocker.Off()
            return
        }
        blocker.Off()

        switch middle {
            ;// adjust layers
            case false:
                if !this.__layerDividerCheck(origMouseCords) || !this.__getlayerTopBottom(origMouseCords, middle,, &topDivY,,,, &midDivY) {
                    return
                }
                block.On()
                MouseMove(this.timelineRawX+10, topDivY+4)
                KeyWait("LAlt", "L")
                if !checkAgain := this.__getlayerTopBottom({x:0, y: topDivY+4}, false)
                    MouseMove(origMouseCords.x, topDivY+4)
                else
                    MouseMove(origMouseCords.x, (checkAgain.topY+checkAgain.botY)/2)
                checkStuck(["LAlt", "CapsLock"])
            case true:
                ;// adjust middle divider
                if !this.__getlayerMid(, &midDivY) {
                    return
                }
                MouseMove(origMouseCords.x, midDivY+2)
                move.clipMouse("y", false)
                tool.Cust("Move the mouse to the desired height,`nThen let go of LAlt.", 3000,,, 9)
                KeyWait("LAlt", "L")
                tool.Cust("",,,, 9)
                move.setMouseClip()
                coord.s() ;// clipMouse changes the coordmode to "mouse"
                if !newCoords := obj.MousePos() {
                    return
                }
                MouseClickDrag("Left", this.timelineRawX+10, midDivY+2, this.timelineRawX+10, newCoords.y)
                MouseMove(origMouseCords.x, newCoords.y)
                keyss := getHotkeysArr()
                checkStuck(["LAlt", GetKeyName(keyss[-1])])
        }
        __resetCaps(storeHotkey, capslockState)
        block.Off()
    }

    /**
     * Determines the coordinates for where a specified button will be
     * @param {String} [button] the button you wish to search for. Accepted buttons are found within the `toggleableButtons` map at the top of the class
     * @param {Integer} [topDivY] the top divider line for the layer you're operating on
     * @param {Integer} [botDivY] the bottom divider line for the layer you're operating on
     * @returns {Object} {x, y} returns the coordinates for the designated button
     */
    static __determineButtonPos(button, topDivY, botDivY) {
            if !this.toggleableButtons.Has(button) {
            ;// throw
            errorLog(MethodError("Incorrect Value in Parameter #1", -1, button),,, true)
            return
        }
            doMinusSmall := (button != "lock") ? "15" : "0"
            doMinus := (button != "lock") ? "32" : "0"
            diff := botDivY-topDivY
            xpos := this.timelineRawX+this.layer%button%
            ypos := 0
            switch {
                ;// versions less than 25.2
                case (VerCompare(ptf.premSETver, "v25.2") < 0) && (button != "lock" || diff <= 54): ypos := topDivY+7
                case (VerCompare(ptf.premSETver, "v25.2") < 0) && (button = "lock" && diff > 54):   ypos := topDivY+((diff/2)-doMinus)

                ;// versions greater than or equal to 25.2
                case (VerCompare(ptf.premSETver, "v25.2") >= 0):
                    switch {
                        case (diff <= 35):              ypos := topDivY+6
                        case (diff > 35 && diff <= 54): ypos := topDivY+15
                        case (diff > 54 && diff < 77):  ypos := topDivY+((diff/2)-doMinusSmall)
                        case (diff >= 77):              ypos := topDivY+((diff/2)-doMinus)
                    }
            }
            return {x: xpos, y: ypos}
        }

    /**
     * A function to quickly toggle the state of various layer settings for the layer the cursor is within. This funtion uses offset values of the `timelineRawX` value and as such the use of `PremiereUIA` is required.
     * @param {String} [which="target"] defines the button you wish to toggle. Accepted options are; `source`, `target`, `sync`, `mute`, `solo`, `lock`
     */
    static toggleLayerButtons(which := "target") {
        if !this.toggleableButtons.Has(which) {
            ;// throw
            errorLog(MethodError("Incorrect Value in Parameter #1", -1, which),,, true)
            return
        }
        if (which = "target" || which = "source") && this.toggleWaiting = true
            return
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        if WinGet.Title() != getTitle.winTitle
            return

        if !this.timelineVals {
            this.__setTimelineValues()
            return
        }

        keys.allWait(2)
        block.On()
        coord.s()

        origMouseCords := obj.MousePos()
        if !origMouseCords || (!this.timelineFocusStatus() && !this.__checkCoords(origMouseCords)) {
            block.Off()
            return
        }

        if !this.__layerDividerCheck(origMouseCords) || !this.__getlayerTopBottom(origMouseCords, true, &topDivX, &topDivY, &botDivX, &botDivY, &midDivX, &midDivY) {
            block.Off()
            return
        }
        midDivY += 2
        getMovePos := this.__determineButtonPos(which, topDivY, botDivY)
        MouseMove(getMovePos.x, getMovePos.y, 1)

        if which = "solo" {
            ;// check to see if the user is hovering over a video track
            ;// we have to do this otherwise if the user spams the solo button, the function will double click the layer and expand it
            if !newCoords := obj.MousePos() {
                block.Off()
                return
            }
            if origMouseCords.y < midDivY {
                MouseMove(origMouseCords.x, origMouseCords.y, 1)
                block.Off()
                return
            }
        }
        SendInput("{Click}")
        MouseMove(origMouseCords.x, origMouseCords.y, 1)
        if !(which = "target" || which = "source") {
            block.Off()
            return
        }
        ;// if the user is attempting to change the source/target track we need to delay them
        ;// because premiere will refuse to change the toggle unless the user has stopped trying to change it
        ;// for around 400ms
        ;// the user may still encounter this behaviour if they toggle a different layer button, then immediately attempt
        ;// to toggle the source/target.
        this.toggleWaiting := true
        SetTimer((*) => (block.Off(), this.toggleWaiting := false), -400)
    }

    /**
     * A wrapper function to set the scale of the currently selected clip. This function **requires** the use of `PremiereRemote`
     * @param {Float} [scaleVal] the value you wish to set the scale property to
     */
    static setScale(scaleVal) {
        if !this.__checkPremRemoteDir('setScale') {
            ;// throw
            errorLog(MethodError('Required PremiereRemote functions missing', -1),,, true)
            return
        }
        if !this.__remoteFunc('isSelected', true)
            return
        this.__remoteFunc('setScale',, "scale=" String(scaleVal))
    }

    /**
     * determines the coordinates of all buttons for all audio/video layers
     * @param {String} [audOrVid="aud"] whether you wish to return the locations for audio layers or video layers
     * @param {Object} [mouseCoords?] pass in an `obj.MousePos()` mouse coordinates. If not provided, they will be retrieved within this function
     * @returns {Map/false/-1} if the window title cannot be determined, or `audOrVid` != "aud" or "vid" - returns `false` ||
     * if the middle divider line cannot be determined - returns `-1` ||
     * else returns a map of all coordinates for all buttons
     * ```
     * layers := prem.__getAllLayerButtonPos("aud")
     * ;// layers[1]["solo"].x
{ 1:{
    "lock":{
      "x":456,
      "y":919
    },
    "mouseLayer":"false",
    "mute":{
      "x":527,
      "y":919
    },
    "solo":{
      "x":550,
      "y":919
    },
    "source":{
      "x":424,
      "y":919
    },
    "sync":{
      "x":504,
      "y":919
    },
    "target":{
      "x":479,
      "y":919
    }
  }
}
     * ```
     */
    static __getAllLayerButtonPos(audOrVid := "aud", mouseCoords?) {
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        if WinGet.Title() != getTitle.winTitle || (audOrVid != "aud" && audOrVid != "vid")
            return false
        coord.s()
        if !this.__checkTimelineValues()
            return false
        if !mid := this.__getlayerMid(, &midDivY)
            return -1
        if !IsSet(mouseCoords) {
            if !mouseCoords := obj.MousePos()
                return false
        }
        A := Map()
        allPos := this.__getAllLayerPos(midDivY, audOrVid)
        for i, v in allPos {
            current := Map()
            for k in this.toggleableButtons {
                current[k] := this.__determineButtonPos(k, allPos[i]['top'], allPos[i]['bot'])
            }
            current["mouseLayer"] := (mouseCoords.y > allPos[i]['top'] && mouseCoords.y < allPos[i]['bot']) ? "true" : "false"
            A[A_index] := current
        }
        return A
    }

    /**
     * determines the coordinates of all layers currently visible in the timeline
     * @param {Number} [midDivY=""] a parameter to pass in the middle divider `y` coordinate if it has already been located
     * @param {String} [vidOrAud="aud"] whether to operate down on the audio layers or up on the video layers
     * @param {Integer} [stopAt=false] a track number to stop at to cancel operation early. Leave as `false` to return all visible values
     * @returns {Map} returns a map containing `["top"]`, `["bot"]`, `["mid"]`
     */
    static __getAllLayerPos(midDivY := "", vidOrAud := "aud", stopAt := false) {
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName()
        if WinGet.Title() != getTitle.winTitle
            return false

        coord.s()
        if !this.__checkTimelineValues()
            return false
        if !midDivY {
            if !this.__getlayerMid(, &midDivY)
                return false
        }
        A := Map()
        startPos := (vidOrAud = "aud") ? midDivY += 6 : midDivY -= 3
        loop {
            if IsInteger(stopAt) && stopAt != false && A_Index > stopAt
                break
            if !getLayerPos := this.__getlayerTopBottom({x: this.timelineXValue+15, y: startPos}, false,,,,,,,, false)
                break
            current := Map()
            current["top"] := getLayerPos.topY, current["bot"] := getLayerPos.botY, current["mid"] := getLayerPos.topY+((getLayerPos.botY-getLayerPos.topY)/2)
            A[A_index] := current
            startPos := (vidOrAud = "aud") ? getLayerPos.botY + 1 : getLayerPos.topY - 1
        }
        return A
    }

    static ignoreToggleEnabledKey := false

    /**
     * ### This function requires `PremiereRemote`
     * A function to toggle the `enabled`/`disabled` state of a clip on the desired layer. This function will operate on either the audio/video tracks depending on whether the cursor is above or below the middle dividing line.
     *
     * If you want this function to work at full speed you **CANNOT** place it under a `#HotIf`. If you do, any subsequent activations of the function will act as
     * individual activations and the `inputhook` simply will not do its job. I don't know why, it hurts my brain. You also **CANNOT** activate this function with a <kbd><!</kbd> you **MUST** simply use <kbd>!</kbd>. ahk is weird. Misplacing these activation keys may result in slow performance with this function due to autohotkey
     *
     * I recommend activating this function like so;
     * ```
!1::
!2::
!3::
!4::
!5::
!6::
!7::
!8::
!9::prem.toggleEnabled(, "aud", 1)
     * ```
     * @param {Integer} [track=A_ThisHotkey] The track you wish to operate on. If this parameter is not just an integer it will attempt to do a rudimentary check on the activation hotkey, expecting a number to be the final activation key in the chain
     * @param {String} [audOrVid=false] determine whether to operate on the audio or video tracks. By default this value is set to `false` and it is determined purely by the user's cursor position. otherwise set to either `"vid"` or `"aud"`
     * @param {Integer} [offset=0] Allows the user to offset the track number, ie. if their `track` number is `1` and offset is `1` the function will operate on track `2`. Useful to skip multicam tracks
     * @param {Boolean | String} [allExcept=false] This value may be `true`, `false` OR `"all"`. Setting this value to `true` will toggle the status of every track *except* the desired track. Leaving this value as `false` will only toggle the desired track(s). Setting this value to `"all"` will toggle all tracks beyond the user's `offset`. Defaults to `false`.
     * @param {Integer | String} [ignore=false] This parameter will determine if `allExcept - "all"` or `allExcept - true` will ignore any tracks. If provided with an `integer` (1->9), any tracks greater than that value (plus your offset) will be ignored. eg. if `offset` is set to `1` and `ignore` is set to `8` tracks `9` and beyond will be ignored. Alternatively, this parameter can be set to `settings` and then the value store in `settings.ini - toggleEnabled_ignore` will be used instead. This value can be adjusted within `settingsGUI()`
     */
    static toggleEnabled(track := A_ThisHotkey, audOrVid := false, offset := 0, allExcept := false, ignore := false) {
        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName(), actTitle := WinGet.Title()
        if !WinActive(editors.Premiere.winTitle) || !getTitle || actTitle != getTitle.winTitle {
            ;// why does the sendinput no longer do anything in this block
            ;// but if you pull it out it works (but kills itself)
            ;// ahk is weird (or I'm dumb idk)
            if !this.ignoreToggleEnabledKey {
                this.ignoreToggleEnabledKey := true
                SetTimer(__resetIgnore.Bind(this), -100)
                SendInput(A_ThisHotkey) ;// you can't do this for this func, it'll constantly loop itself to death if you do
            }
            __resetIgnore(*) {
                this.ignoreToggleEnabledKey := false
            }

            return
        }
        premUIA := premUIA_Values.initialise()
        if allExcept != true && allExcept != false && allExcept != "all" {
            ;// throw
            errorLog(PropertyError("Parameter allExcept unaccepted value", allExcept),,, true)
            return
        }
        if !allExcept {
            which := []
            currHotkey := getHotkeysArr()
            if IsInteger(GetKeyName(currHotkey[currHotkey.Length])) && (track = A_ThisHotkey && !IsDigit(track))
                which.Push(GetKeyName(currHotkey[currHotkey.Length])+offset)
            else if (track != A_ThisHotkey && IsDigit(String(track)))
                which.Push(track+offset)
            ih := InputHook("L0", "{Escape}{LAlt Up}")
            ; ih.OnChar := __onInp
            ih.OnKeyDown := __onDown.Bind(which)
            ih.OnKeyUp := __onUp
            ih.KeyOpt("{All}", "SNI")
            ih.KeyOpt("{Escape}{LAlt Up}", "E")
            ih.Start()
            ih.Wait()

            __onInp(ih, char) {
                for i, v in which {
                    if char+offset = v {
                        which.RemoveAt(i)
                        return
                    }
                }
                which.Push(char+offset)
            }
            __onDown(which, ih, vk, sc) {
                hotkeyName := GetKeyName(Format("vk{:X}", vk))
                if IsNumber(hotkeyName) && hotkeyName >= 1 && hotkeyName <= 9
                    __onInp(ih, hotkeyName)
            }
            __onUp(ih, vk, sc) {
                hotkeyName := GetKeyName(Format("vk{:X}", vk))
                if hotkeyName = GetKeyName(currHotkey[1]) || hotkeyName = "L" GetKeyName(currHotkey[1]) || hotkeyName = "R" GetKeyName(currHotkey[1])
                    ih.stop()
            }

            track := "queue"
        }
        blocker := block_ext()
        blocker.On(, "{LCtrl}{RCtrl}{LAlt}{RAlt}{LWin}{RWin}", "{Tab}{F4}{Enter}{sc01C}{NumpadEnter}{sc11C}{vk0D}{Escape}")
        SetDefaultMouseSpeed(0)
        coord.s()
        if !this.__setTimelineValues() {
            blocker.Off()
            return
        }
        if !this.__checkPremRemoteDir() {
            blocker.Off()
            errorLog(MethodError('This function requires PremiereRemote functionality', -1))
            return
        }
        checkTrack := false
        funcs := ['isSelected', 'movePlayheadFrames', 'isClipEnabled', 'toggleEnabled', 'getAudioTracks', 'getVideoTracks']
        for v in funcs {
            if !this.__checkPremRemoteFunc(v) {
                checkTrack := true
                break
            }
        }
        if checkTrack = true {
            blocker.Off()
            errorLog(MethodError('This function requires additional PremiereRemote functions for proper functionality', -1))
            return
        }

        ;// prem is dumb and sometimes ignores inputs if you're too fast
        if this.__remoteFunc('isSelected', true) {
            SendInput(ksa.deselectAll)
            if this.__remoteFunc('isSelected', true) {
                sleep 50
                SendInput(ksa.deselectAll)
                sleep 25
                if this.__remoteFunc('isSelected', true) {
                    errorLog(MethodError("Deselecting failed. Please try again"))
                    blocker.Off()
                    return
                }
            }
        }
        ; SendInput(ksa.selectionPrem)
        this.selectTool()
        sleep 16
        if !origMouseCords := obj.MousePos() {
            blocker.Off()
            return
        }
        movedPlayhead  := false
        if PixelGetColor(origMouseCords.x, origMouseCords.y) = this.playhead {
            this.__remoteFunc('movePlayheadFrames',, "subtract=true", "frames=3")
            movedPlayhead := true
        }
        withinTimeline := this.__checkCoords(origMouseCords)
        if withinTimeline != true {
            blocker.Off()
            return
        }

        if !audOrVid {
            middleDivider := this.__getlayerMid(&midDivX, &midDivY)
            aboveOrBelow := (origMouseCords.y < midDivY) ? true : false
        } else {
            middleDivider := false
            midDivY := false
            aboveOrBelow := (audOrVid = "vid") ? true : false
        }
        maxTracks := (aboveOrBelow = true) ? this.__remoteFunc('getVideoTracks', true) : this.__remoteFunc('getAudioTracks', true)
        if !IsSet(splitHotkey) && track != "queue" && track = A_ThisHotkey && (StrLen(A_ThisHotkey) > 1) && !IsInteger(A_ThisHotkey) {
            splitHotkey := getHotkeysArr()
            if !IsInteger(GetKeyName(splitHotkey[splitHotkey.Length])) {
                ;// throw
                blocker.Off()
                errorLog(PropertyError("No track provided and final hotkey isn't a number"),,, true)
                return
            }
            track := GetKeyName(splitHotkey[splitHotkey.Length])
        }
        if track != "queue" {
            if !IsInteger(track) {
                blocker.Off()
                return
            }
            if track+offset < 1 {
                blocker.Off()
                notifyExt.showIfNotExist("premIncorrectTrackIndex", 'toggleEnabled()', 'Desired track must be greater than 1',, 'Speech Misrecognition',, 'dur=6 ts=12 bdr=Red maxW=400 pad=,,,,,,,0')
                errorLog(ValueError("Desired track must be greater than 1", -1))
                return
            }
        }

        ;// we need to avoid any modifiers potentially messing with the function if the user
        ;// happens to let go at the perfect time
        if allExcept != false {
            __timerTooltip(*) => (tool.Cust("Please release modifier keys...", 10.0,,, 17))
            if !IsSet(splitHotkey)
                splitHotkey := getHotkeysArr()
            SetTimer(__timerTooltip, -500)
            loop splitHotkey.length {
                if keys.modifiers.has(currentKey := GetKeyName(splitHotkey[splitHotkey.length+1-A_Index])) {
                    if GetKeyState(currentKey, "P") {
                        KeyWait(GetKeyName(splitHotkey[splitHotkey.length+1-A_Index]))
                    }
                }
            }
            try SetTimer(__timerTooltip, 0)
            tool.Cust("", 0,,, 17)
        }

        vidOrAud := (aboveOrBelow=true) ? "vid" : "aud"
        if !allLayers := this.__getAllLayerPos(midDivY, vidOrAud, maxTracks) {
            blocker.Off()
            errorLog(UnsetError("Couldn't determine layers"))
            return
        }

        __doToggle(isAll := false) {
            checkStuck()
            SendInput("{LAlt Down}{LShift Down}")
            handles := false
            for v in whichTracks {
                MouseMove(origMouseCords.x, allLayers[Integer(v)]["mid"], 0)
                sleep 0
                getPixelCol := PixelGetColor(origMouseCords.x, allLayers[Integer(v)]["mid"])
                if getPixelCol = this.transitionHandleInsideSquare || getPixelCol = this.transitionHandleHalfSquare {
                    handles := true
                }
                SendInput("{LButton}")
                sleep 0
            }
            SendInput("{LAlt Up}{LShift Up}")
            sleep 30
            this.__remoteFunc('toggleEnabled')
            sleep 30

            if handles = true && !Notify.Exist("premTransitionHandles") {
                Notify.Show(, 'Some layers may have had the transition handle visible causing selection to fail.', 'C:\Windows\System32\imageres.dll|icon80', 'Windows Startup',, 'theme=Dark dur=5 bdr=Gray maxW=400 tag=premTransitionHandles')
            }
        }

        whichTracks := []
        hasMap := Map()
        origIgnore := ignore
        if ignore = "settings" {
            try ignore := this.UserSettings.toggleEnabled_ignore
            catch {
                errorLog(TargetError("Failed to determine settings value: toggleEnabled_ignore"))
                notifyExt.showIfNotExist("premignoreSetting", 'prem.toggleEnabled()', '"Failed to determine settings value: toggleEnabled_ignore"',, 'Windows Feed Discovered',, 'theme=Dark dur=5 bdr=Red maxW=400')
                return
            }
        }

        MouseMove(origMouseCords.x-10, origMouseCords.y, 0)
        switch allExcept {
            case "all":
                if origIgnore = "settings"
                    ignore += track-offset
                for k, v in allLayers {
                    if (offset != 0 && A_Index <= offset)
                        continue
                    if ignore != false && offset+1 >= ignore {
                        checkStuck()
                        blocker.Off()
                        this.ignoreKey := false
                        notifyExt.showIfNotExist("premIgnoreOffset", 'prem.toggleEnabled()', 'Ignore value cannot be >= your offset.',, 'Windows Feed Discovered',, 'theme=Dark dur=5 bdr=Red maxW=400')
                        return
                    }
                    if ignore != false && A_Index-offset >= ignore
                        break
                    layerColour := PixelGetColor(origMouseCords.x, allLayers[Integer(A_Index)]["mid"])
                    if this.timelineCols.Has(layerColour)
                        continue
                    whichTracks.Push(A_Index)
                }
                __doToggle()
            case false:
                for i, v in which {
                    hasMap.Set(v, true)
                }
                for k, v in allLayers {
                    if (track != "queue" && A_Index = track+offset) || (offset != 0 && A_Index <= offset)
                        continue
                    layerColour := PixelGetColor(origMouseCords.x, allLayers[Integer(A_Index)]["mid"])
                    if !hasMap.Has(A_Index) || this.timelineCols.Has(layerColour)
                        continue
                    whichTracks.Push(A_Index)
                }
                __doToggle()
            case true:
                for k, v in allLayers {
                    if A_Index = track+offset || (offset != 0 && A_Index <= offset)
                        continue
                    if ignore != false && (offset+1 >= ignore) {
                        checkStuck()
                        blocker.Off()
                        this.ignoreKey := false
                        notifyExt.showIfNotExist("premIgnoreOffset", 'prem.toggleEnabled()', 'Ignore value cannot be >= your offset.',, 'Windows Feed Discovered',, 'theme=Dark dur=5 bdr=Red maxW=400')
                        return
                    }
                    if ignore != false && A_Index-offset >= ignore {
                        if (track+offset >= ignore+offset)
                            notifyExt.showIfNotExist("premIgnoreOffset", 'prem.toggleEnabled()', 'Selected Track is greater than set ``Ignore value``',, 'Windows Feed Discovered',, 'theme=Dark dur=5 bdr=Red maxW=400')
                        break
                    }
                    layerColour := PixelGetColor(origMouseCords.x, allLayers[Integer(A_Index)]["mid"])
                    if this.timelineCols.Has(layerColour)
                        continue
                    whichTracks.Push(A_Index)
                }
                __doToggle()
        }
        if movedPlayhead = true {
            this.__remoteFunc('movePlayheadFrames',, "subtract=false", "frames=3")
        }
        MouseMove(origMouseCords.x, origMouseCords.y, 0)
        sleep 25
        SendInput(ksa.deselectAll)
        sleep 25
        checkStuck()
        blocker.Off()
        this.ignoreKey := false
    }

    /**
	 * Set internal colour variables based on the version of Premiere Pro the user currently has set within `settingsGUI()`
	 * @param {String} UI which UI version should be used. Currently accepts `Spectrum`
     * @param {String} theme which theme the user wishes to use. Currently accepts `darkest`
	 */
	static __setTimelineCol(UI, theme) {
        timelineCol := Mip()
        timelineColArr := []
        if !timelineColours.%UI%.HasProp(theme) {
            sleep 50
            notifyExt.showIfNotExist("timelineThemeNotSet",, '``timelineColours {`` does not have values set for the requested theme: ' theme '. Reverting to "' this.defaultTheme '" theme which can be set in ``settingsGUI()``.', 'C:\Windows\System32\imageres.dll|icon94',,, 'theme=Dark dur=6 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
            theme := (timelineColours.%UI%.has(this.defaultTheme)) ? this.defaultTheme : "darkest"
            this.theme := theme
        }
		for k, v in timelineColours.%UI%.%theme% {
			if Mod(A_Index, 2) != 0
				continue
			varName := timelineColours.%UI%.%theme%[k-1]
            timelineColArr.Push(Format("0x{:x}", v))
            timelineCol.Set(Format("0x{:x}", v), true)
		}
        this.timelineCols   := timelineCol
        this.timelineColArr := timelineColArr

        switch this.UI {
            case "Spectrum":
                switch this.theme {
                    ;// these colours may change in future versions
                    ;// but should work between 25.0->25.5 at a minimum
                    case "darkest":
                        this.eyeDisabled := 0x4B4B4B, this.iconHighlight := 0x6A6A6A, this.layerDivider := 0x303030, this.editTabCol := 0xD0D0D0, this.soloColour := 0xE9C700, this.muteColour := 0x67DEA8
                        this.transitionHandleInsideSquare := 0xB0B0B0
                        this.transitionHandleHalfSquare := 0x6A6A6A
                    case "dark":
                        this.eyeDisabled := 0x545454, this.iconHighlight := 0x3F3F3F, this.layerDivider := 0x3F3F3F, this.editTabCol := 0xD1D1D1, this.soloColour := 0xF4D500, this.muteColour := 0x81E9B8
                        this.transitionHandleInsideSquare := 0xB2B2B2
                        this.transitionHandleHalfSquare := 0x707070
                    case "light":
                        this.eyeDisabled := 0xD5D5D5, this.iconHighlight := 0xE6E6E6, this.layerDivider := 0xE6E6E6, this.editTabCol := 0x464646, this.soloColour := 0xF8D904, this.muteColour := 0x67DEA8
                        this.transitionHandleInsideSquare := 0x6D6D6D
                        this.transitionHandleHalfSquare := 0x000000
                }
        }
	}

    /**
     * A function to disable all muted or solo'd tracks
     * @param {String} [muteOrSolo="solo"] which you wish to operate on
     */
    static disableAllMuteSolo(muteOrSolo := "solo") {
        if muteOrSolo != "solo" && muteOrSolo != "mute"
            return

        if muteOrSolo = "mute" && this.__checkPremRemoteDir('unmuteAllMutedTracks') {
            this.__remoteFunc('unmuteAllMutedTracks')
            return
        }

        SetDefaultMouseSpeed(0)
        coord.s()
        if !this.__setTimelineValues()
			return

        getKeys := getHotkeysArr()
        if IsInteger(GetKeyName(getKeys[-1]))
            KeyWait(getKeys[-1])
        blocker := block_ext()
        blocker.On()

        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName(), actWin := WinGet.Title()
        if !getTitle || actWin != getTitle.winTitle {
            blocker.Off()
            return
        }

        colour := 0
        switch muteOrSolo {
            case "solo": colour := this.soloColour
            case "mute": colour := this.muteColour
        }

        if !origMouseCords := obj.MousePos() {
            blocker.Off()
            return
        }
        withinTimeline := this.__checkCoords(origMouseCords)
        if withinTimeline != true {
            blocker.Off()
            return
        }
        allButtons := this.__getAllLayerButtonPos(, origMouseCords)
        if !allButtons || allButtons = -1 {
            blocker.Off()
            switch allButtons {
                case false: notifyExt.showIfNotExist("premInvalidLayerVals", 'prem.disableAllMuteSolo()', 'Could not determine layer values',,,, 'theme=Dark dur=4 bdr=Red maxW=400')
                case -1: notifyExt.showIfNotExist("premMiddleDivider", 'prem.disableAllMuteSolo()', 'Failed to find the middle divider',,,, 'theme=Dark dur=4 bdr=Red maxW=400')
            }
            return
        }
        arr := []
        for k in allButtons {
            getColour := PixelGetColor(allButtons[k][muteOrSolo].x-3, allButtons[k][muteOrSolo].y-3)
            getColourOffset := PixelGetColor(allButtons[k][muteOrSolo].x-5, allButtons[k][muteOrSolo].y) ;// required to stop `Mute` false positives
            ; MouseMove(allButtons[k][muteOrSolo].x-3, allButtons[k][muteOrSolo].y-3)
            ; MsgBox("col: " getColour "`noffset: " getColourOffset "`ncompare: " colour "`nsolo: " Format("0x{:x}", this.soloColour) "`nmute: " Format("0x{:x}", this.muteColour) "`ntheme: " this.theme)
            ; MsgBox(getColour) ;// uncomment to determine the pixelcolour
            if getColour = colour && getColourOffset = colour
                arr.Push({x: allButtons[k][muteOrSolo].x-3, y: allButtons[k][muteOrSolo].y-3})
        }
        for i, v in arr {
            MouseMove(v.x, v.y, 1)
            SendInput("{Click}")
        }
        MouseMove(origMouseCords.x, origMouseCords.y, 1)
        blocker.Off()
    }

    /**
     * This function allows quick manipulation of a sequences video track visability
     * @param {String} [soloInverseDisable="solo"] determines whether to hide all visable tracks other than the track the cursor is hovering within (`solo`), whether to unhide all other visible tracks other than the track the cursor is within (`Inverse`), or whether to unhide all visible tracks (`disable`).
     */
    static soloVideo(soloInverseDisable := "solo") {
        SetDefaultMouseSpeed(0)
        coord.s()

        if soloInverseDisable = "disable" && this.__checkPremRemoteDir('enableAllVideoTracks') {
            this.__remoteFunc('enableAllVideoTracks')
            return
        }

        if !this.__setTimelineValues()
			return
        if soloInverseDisable != "solo" && soloInverseDisable != "inverse" && soloInverseDisable != "disable" {
            ;// throw
            errorLog(Error("Incorrect value in Parameter #1", -1),,, true)
            return
        }
        blocker := block_ext()
        blocker.On()

        ;// avoid attempting to fire unless main window is active
        getTitle := WinGet.PremName(), actWin := WinGet.Title(), activationKey := getHotkeys()
        if !getTitle || actWin != getTitle.winTitle || !activationKey {
            blocker.Off()
            return
        }

        if !origMouseCords := obj.MousePos() {
            blocker.Off()
            return
        }
        withinTimeline := this.__checkCoords(origMouseCords)
        if withinTimeline != true {
            blocker.Off()
            return
        }

        allButtons := this.__getAllLayerButtonPos("vid", origMouseCords)
        if !allButtons || allButtons = -1 {
            blocker.Off()
            switch allButtons {
                case false: notifyExt.showIfNotExist("premInvalidLayerVals", 'prem.soloVideo()', 'Could not determine layer values',,,, 'theme=Dark dur=4 bdr=Red maxW=400')
                case -1: notifyExt.showIfNotExist("premMiddleDivider", 'prem.soloVideo()', 'Failed to find the middle divider',,,, 'theme=Dark dur=4 bdr=Red maxW=400')
            }
            return
        }
        arr := []
        for k in allButtons {
            getColour := PixelGetColor(allButtons[k]["mute"].x+7, allButtons[k]["mute"].y)
            switch soloInverseDisable {
                case "solo":
                    if (allButtons[k]["mouseLayer"] = "true" && getColour = this.eyeDisabled) || (allButtons[k]["mouseLayer"] != "true" && getColour != this.eyeDisabled) {
                        arr.Push({x: allButtons[k]["mute"].x, y: allButtons[k]["mute"].y+3})
                    }
                case "inverse":
                    if (allButtons[k]["mouseLayer"] = "true" && getColour != this.eyeDisabled) || (allButtons[k]["mouseLayer"] != "true" && getColour = this.eyeDisabled) {
                        arr.Push({x: allButtons[k]["mute"].x, y: allButtons[k]["mute"].y+3})
                    }
                case "disable":
                        if getColour = this.eyeDisabled
                            arr.Push({x: allButtons[k]["mute"].x, y: allButtons[k]["mute"].y+3})
            }
        }
        for i, v in arr {
            MouseMove(v.x, v.y, 1)
            SendInput("{Click}")
        }
        MouseMove(origMouseCords.x, origMouseCords.y, 1)
        blocker.Off()
    }

    /**
     * This function is a wrapper function to toggle `Show Duplicate Frame Markers` and is intended to be used with `HotkeylessAHK` (although isn't necessary)
     * @link https://github.com/sebinside/HotkeylessAHK
     */
    static changeDupeFrameMarkers() {
        if !WinActive(this.winTitle) ;// this is here in the event the user calls this func from `HotkeylessAHK` - otherwise it'll throw an error if prem isn't active
            return
        if !this.__setTimelineValues()
			return
        this.__focusTimeline()
        SendInput(ksa.togDupeFrameMarkers)
    }

    /**
     * This function is a wrapper function for changing the label colour of a clip; ensuring that the timeline is in focus and that a clip is selected. This function is designed to be called from a streamdeck using the `HotkeylessAHK` tool
     *
     * #### This function requires `PremiereRemote` to adjust label colours on the timeline
     * @link https://github.com/sebinside/HotkeylessAHK
     * @param {String} [labelHotkey] the hotkey string that will be sent to `SendInput` to change the label colour to your desired choice
     */
    static changeLabel(labelHotkey) {
        if !WinActive(this.winTitle) ;// this is here in the event the user calls this func from `HotkeylessAHK` - otherwise it'll throw an error if prem isn't active
            return
        if !this.__setTimelineValues()
			return
        if !premUIA := premUIA_Values.initialise()
            return
        if premUIA.__isUiaElementActive("projectsWindow", premUIA) {
            SendInput(labelHotkey)
            return
        }
        if !this.__checkPremRemoteDir("isSelected") {
            ;// throw
            errorLog(MethodError('This function requires ``PremiereRemote`` to adjust labels on the timeline', -1),, true)
            return
        }
        this.__focusTimeline()
        if !this.__remoteFunc('isSelected', true)
            return
        SendInput(labelHotkey)
    }

    /** sends the hotkey set within KSA to delete all empty tracks */
    static deleteEmptyTracks() {
        if !WinActive(this.winTitle) ;// this is here in the event the user calls this func from `HotkeylessAHK` - otherwise it'll throw an error if prem isn't active
            return
        SendInput(ksa.deleteEmptyTracksAll)
    }

    /**
     * toggles the `Composite in Linear Color` option within the active sequence's settings, and optionally the `Maximum Render Quality` setting.
     * @param {Boolean} [enableMaxRenderQual=true] whether `Maximum Render Quality` will be enabled when `Linear Color` is set to `true`. Note: this function is not tracking the previous setting and will not return it if you toggle `Linear Color` again
     *
     * #### This function requires `PremiereRemote`
     */
    static toggleLinearColour(enableMaxRenderQual := true) {
        if !this.__checkPremRemoteDir('toggleLinearColour')
            return
        if Notify.Exist("premFailLinColour")
            Notify.Destroy("premFailLinColour")
        if Notify.Exist("premLinColour")
            Notify.Destroy("premLinColour")
        chkQual := checkBool(enableMaxRenderQual)
        if chkQual != true && chkQual != false
            chkQual := true
        toggle := this.__remoteFunc('toggleLinearColour', true, "enableMaxRenderQual=" chkQual)
        switch toggle {
            case "failure": notifyExt.showIfNotExist("premFailLinColour",, 'Toggling Linear Colour failed.', 'C:\Windows\System32\imageres.dll|icon237', 'Speech Misrecognition',, 'dur=5 bc=Black bdr=Red')
            default:
                state := (toggle = true) ? "Enabled" : "Disabled"
                notifyExt.showIfNotExist("premLinColour",, 'Toggling Linear Colour successful.`nNew setting: ' state,,,, 'dur=4 bc=Black bdr=Aqua')
        }
    }

    /** handles setting a timer to check the user's current open sequence. This timer provides functionality to `swapPreviousSequence()` */
    static __setCurrSeq(*) {
        ListLines(0)
        if this.pauseSeqTimer = true
            return
        if this.resetSeqTimer = true {
            this.resetSeqTimer := false
            newDelay := (this.useSwapSequences = "true" || this.useSwapSequences = true) ? this.prevSeqDelay : 0
            if !newDelay {
                this.sequenceArr := []
            }
            SetTimer(, newDelay)
            return
        }
        if !this.remoteActive
            return
        if !this.__checkPremRemoteDir("getActiveSequence")
            SetTimer(, 0)
        if !WinExist(this.winTitle) || !WinActive(this.winTitle)
            return
        premWindow := WinGet.PremName(,,, false)
        checkType := (Type(premWindow) != "Object")
        checkTitle := isObjHasProp(premWindow, "winTitle", false) && isObjHasProp(premWindow, "titleCheck", -1) && isObjHasProp(premWindow, "saveCheck", -1)
        checkCanSave := isObjHasProp(premWindow, "titleCheck", true)
		if !premWindow || checkType || !checkTitle || checkCanSave {
            return
        }
        seq := this.__remoteFunc("getActiveSequence", true)
        if !seq {
            return
        }

        toggleLimit  := this.UserSettings.premSwapSequencesLimit
        if this.sequenceArr.Length = 0 {
            this.sequenceArr.Push(seq)
            this.sequenceArr.Capacity := toggleLimit
            return
        }

        switch {
            case (seq = this.sequenceArr[1]): return
            case (this.sequenceArr.Length > 1 && seq = this.sequenceArr[this.sequenceArr.Length]):
                this.sequenceArr.InsertAt(1, this.sequenceArr.Pop())
                return
            case (!ind := this.sequenceArr.IndexOf(seq, 1)):
                this.sequenceArr.InsertAt(1, seq)
                this.sequenceArr.Capacity := toggleLimit
                return
            default:
                this.sequenceArr.RemoveAt(this.sequenceArr.IndexOf(seq, 1))
                this.sequenceArr.InsertAt(1, seq)
                this.sequenceArr.Capacity := toggleLimit
                return
        }
    }

    /**
     * swaps to the previous sequence the user had open.
     *
     * requires the use of `__setCurrSeq` which requires `PremiereRemote`
     */
    static swapPreviousSequence() {
        if !this.__checkPremRemoteDir("focusSequence") {
            ;// throw
            errorLog(MethodError("swapPreviousSequence() requires PremiereRemote to be installed"),,, true)
            return false
        }
        if (this.useSwapSequences != true && this.useSwapSequences != "true")
            return
        Critical()
        __pushToEnd() {
            Critical()
            this.sequenceArr.Push(this.sequenceArr[1])
            this.sequenceArr.RemoveAt(1)
            this.__remoteFunc("focusSequence",, "ID=" String(this.sequenceArr[1]))
        }
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true)
            return false
        try {
            activeObj := CLSID_Objs.load("prem")
            activeObj.pauseSeqTimer := true
            this.sequenceArr := activeObj.sequenceArr
            if this.sequenceArr.Length != 0
                __pushToEnd()
            activeObj.sequenceArr := this.sequenceArr
            activeObj.pauseSeqTimer := false
            activeObj := ""
            Critical("Off")
            return true
        } catch {
            activeObj := ""
            errorLog(MethodError("Failed to interact with Premiere Object", -1))
            Critical("Off")
            return false
        }
    }

    /** A function to close the currently active sequence within premiere. This function **requires** `PremiereRemote` */
    static closeActiveSequence(allExcept := false) {
        if !this.__checkPremRemoteDir("closeActiveSequence") {
            ;// throw
            errorLog(MethodError("closeActiveSequence() requires PremiereRemote to be installed"),,, true)
            return false
        }
        this.__remoteFunc('closeActiveSequence',, "allExcept=" allExcept)
    }

    /** determines if the `Multi-Camera View` button is selected. The button must be visible
     * @returns {-1|Boolean} if `premUIA_Values` have not been set, will return `-1`, else `true/false`
     */
    static __determineMultiCam() {
        if !premUIA := premUIA_Values.initialise()
            return -1
        progMon := UIA.ElementFromHandle(premUIA.UIA_Hwnd["programMonitor"])
        try multCam := progMon.FindElement({LocalizedType:"button", Name:"Toggle Multi-Camera View", matchmode:"Substring"})
        catch {
            timersActive := (WinEvent.IsRegistered("Active", "Clip Fx Editor " this.exeTitle) || WinEvent.IsRegistered("Close", "Clip Fx Editor " this.exeTitle))
            timerStr := (timersActive) ? "`n`nTimers will be stopped." : ""
            errorLog(MethodError("Could not determine Multi-Camera View button. Might not be visible in Program Monitor", -1))
            notifyExt.showIfNotExist("progMon_MultiCamButton",, "Could not determine Multi-Camera View button. May not be visible in Program Monitor." timerStr, 'C:\Windows\System32\imageres.dll|icon80', 'Windows Startup',, 'bdr=Red maxW=400 dur=4')
            if timerStr {
                try {
                    WinEvent.Stop("Active", "Clip Fx Editor " this.exeTitle)
                    WinEvent.Stop("Close", "Clip Fx Editor " this.exeTitle)
                }
            }
            return
        }
        return ((multCam.State = 0) ? false : true)
    }

    /**
     * Handles disabling multicam view if an audio effect window becomes active, then reenabling it if it was previously active once the window is closed.
     * This function is helpful as adjusting audio effects while the multicam view is active causes the program monitor to flicker like crazy
     * This function is expecting to be called from two separate `WinEvent` events
     */
    static __disableMulticamOnAudioEffect(which, title, *) {
        getTitle := WinGet.PremName()
        if !getTitle || !isObjHasProp(getTitle, "winTitle", false) {
            errorLog(UnsetError("Could not determine Premiere window title", -1))
            sleep 1500
            return false
        }
        if !WinActive(this.exeTitle)
            return
        if which = "disable" && this.audioWaitClose = true
            return
        if which = "enable" && !this.prevMulticamState {
            this.audioWaitClose := false
            return
        }
        multicamEnabled := this.__determineMultiCam()
        if multicamEnabled = -1
            return
        switch which {
            case "disable":
                this.audioWaitClose := true
                if !multicamEnabled {
                    this.prevMulticamState := false
                    WinWaitClose(title)
                    return
                }
                this.prevMulticamState := true
            case "enable":
                if multicamEnabled {
                    this.audioWaitClose := false
                    return
                }
        }
        sleep 50
        this.__focusTimeline()
        sleep 50
        SendInput(ksa.toggleMultiCam)
        WinWaitClose(title)
        if which = "enable"
            this.audioWaitClose := false
    }

    /**
     * Handles rendering the selected sequence (in the `Project` window) within Premiere (not AME).
     * This function is mostly expecting my project folder structure, or more accurately, expects that the current project file is within a subfolder, and that the root folder of your project is one folder back in the tree.
     *
     * ### Note
     * > Due to technical limitations, this function will currently only properly index filenames (& import after rendering) for certain `h264`/`h264`/`mov` files.
     *
     * ### Note
     * > Due to issues with Premiere, this function may just inadvertently fail to import files and cause the UI to no longer be able to import anything or save. Thanks prem
     * @param {String} [outputPath] the output folder. (this is AFTER the root folder, ie. if my project file is in `W:\work\airbnb\_project files` and I pass `timeline renders`, the file will be rendered to `W:\work\airbnb\timeline renders\`)
     * @param {String} [presetName] the name of a preset file contained within `..\Backups\Adobe Backups\Media Encoder\Presets`. A custom path cannot be given, it must be within that folder
     * @param {Boolean} [addToProj=true] whether you wish for the resulting file to be imported into the current project after rendering
     */
    static renderProjectSelection(outputPath, presetName, addToProj := true) {
        if !WinActive(this.exeTitle)
            return
        checkDir := this.__checkPremRemoteDir('renderInPrem')
        checkImport := this.__checkPremRemoteFunc('importFile')
        checkIsSequence := this.__checkPremRemoteFunc('selectionIsSequence')
        if !checkDir || !checkImport || !checkIsSequence {
            notifyExt.showIfNotExist('premRenderRemoteFuncs',, 'Required PremiereRemote functions are not installed', 'C:\Windows\System32\shell32.dll|icon148', 'Windows Message Nudge',, 'bdr=Red maxW=400 dur=4')
            return
        }
        presetPath := ptf.Backups "\Adobe Backups\Media Encoder\Presets"

        if !this.__remoteFunc('selectionIsSequence', true) {
            notifyExt.showIfNotExist('premSelectionNotSeq',, 'Current selection isn`'t a sequence or clip', 'C:\Windows\System32\imageres.dll|icon80', 'Windows Startup',, 'bdr=Red maxW=400 dur=4')
            return
        }

        title := WinGet.PremName()
        if title.saveCheck != false
            attempt := prem.saveAndFocusTimeline()
        sleep 100

        projPath   := WinGet.ProjPath()
        if !projPath {
            notifyExt.showIfNotExist('premRenderProjPath',, 'Could not determine the current project path', 'C:\Windows\System32\shell32.dll|icon148', 'Windows Message Nudge',, 'bdr=Red maxW=400 dur=4')
            return
        }
        renderPath := WinGet.pathU(projPath.Dir "\..\" outputPath)
        if !DirExist(renderPath)
            DirCreate(renderPath)

        if !FileExist(presetPath "\" presetName) && !FileExist(presetPath "\" presetName ".epr") {
            notifyExt.showIfNotExist('premRenderPresetPath',, 'Could not determine the desired render preset:`n' presetPath "\" presetName, 'C:\Windows\System32\shell32.dll|icon148', 'Windows Message Nudge',, 'bdr=Red maxW=400 dur=4')
            this.save()
            return
        }
        preset := FileExist(presetPath "\" presetName) ? presetPath "\" presetName : presetPath "\" presetName ".epr"
        file := this.__remoteFunc('renderInPrem', true, "outputPath=" StrReplace(renderPath, "\", "/"), "presetPath=" StrReplace(preset, "\", "/"))
        this.save()
        if checkbool(addToProj) && (file != false) && FileExist(file) {
            notifyExt.showIfNotExist('importRenderedFilePrem',, 'Importing file into Premiere', 'C:\Windows\System32\imageres.dll|icon179',,, 'dur=4 bdr=Purple show=Fade@250 hide=Fade@250 maxW=400')
            /* logger := log()
            logger.Append("Attempted to import: " StrReplace(file, "\", "/")) */
            ;// poll until Premiere's main thread is free
            __waitFree() {
                loop 20 {
                    sleep 1000
                    if (this.__remoteFunc('isMainThreadFree', true) = true)
                        return true
                }
                return false
            }
            if !__waitFree() {
                this.save()
                return
            }
            if !this.__remoteFunc('importFile', true, "filePath=" StrReplace(file, "\", "/"), "importAsStills=0")
                return
        }
        this.save()
    }

    /**
     * Sets the `Source`, `Format` & `Preset` combo boxes in the `Render and Replace` window
     * @param {String} [dropPreset] the preset you wish to select from the `Preset` dropdown list. To use a custom preset, the parameter must begin with `Custom:` (and is case sensitive), else, parameter must be one of the following (and is case sensitive);
     * ```
;// QuickTime
"GoPro CineForm RGB 12-bit with alpha at Maximum Bit Depth"
"GoPro CineForm RGB 12-bit with alpha"
"GoPro CineForm YUV 10-bit"
"Match Source - Apple ProRes 422 HQ"
"Match Source - Apple ProRes 422 LT"
"Match Source - Apple ProRes 422"
"Match Source - Apple ProRes 4444"
;// DNxHR/DNxHD
"Match Source - DNxHD"
;// MXF OP1a
"Match Source - AVC-Intra"
"Match Source - IMX"
"Match Source - XAVC"
"Match Source - XDCAM EX"
"Match Source - XDCAM HD"
     * ```
     * @param {String} [dropSource="Sequence"] the selection you wish to use in the `Source` dropdown list. Defaults to `Sequence`. Parameter must be one of the following (and is case sensitive);
     * ```
"Sequence"
"Individual Clips"
"Preset"
     * ```
     * @param {String} [dropFormat="QuickTime"] the selection you wish to use in the `Format` dropdown list. Defaults to `QuickTime`. To use a custom preset, the parameter must begin with `Custom:` (and is case sensitive), else, parameter must be one of the following (and is case sensitive);
     * ```
"DNxHR/DNxHD MXF OP1a"
"MXF OP1a"
"QuickTime"
     * ```
     * @param {UIA.IUIAutomationElement} [UIAObj] pass in a UIA element for reuse
     * @param {UIA.IUIAutomationElement} [AdobeEl] pass back the UIA element for reuse
     */
    static setRnderRplcPreset(dropPreset, dropSource := "Sequence", dropFormat := "QuickTime", UIAObj?, &AdobeEl?) {
        sources := Map("Sequence", true, "Individual Clips", true, "Preset", true)
        formats := Map("DNxHR/DNxHD MXF OP1a", true, "MXF OP1a", true, "QuickTime", true)
        presets := Map(
            ;// QuickTime
            "GoPro CineForm RGB 12-bit with alpha at Maximum Bit Depth", true,
            "GoPro CineForm RGB 12-bit with alpha", true,
            "GoPro CineForm YUV 10-bit", true,
            "Match Source - Apple ProRes 422 HQ", true,
            "Match Source - Apple ProRes 422 LT", true,
            "Match Source - Apple ProRes 422", true,
            "Match Source - Apple ProRes 4444", true,
            ;// DNxHR/DNxHD
            "Match Source - DNxHD", true,
            ;// MXF OP1a
            "Match Source - AVC-Intra", true,
            "Match Source - IMX", true,
            "Match Source - XAVC", true,
            "Match Source - XDCAM EX", true,
            "Match Source - XDCAM HD", true
        )
        customString := "Custom:"
        if (SubStr(dropFormat, 1, StrLen(customString)) !== customString) && !presets.Has(dropPreset)
            throw PropertyError("Incorrect Parameter Value", -1, dropPreset)
        if (SubStr(dropFormat, 1, StrLen(customString)) !== customString) && !formats.Has(dropFormat)
            throw PropertyError("Incorrect Parameter Value", -1, dropFormat)
        if !sources.Has(dropSource)
            throw PropertyError("Incorrect Parameter Value", -1, dropSource)

        if !IsSet(UIAObj) || (IsSet(UIAObj) && Type(UIAObj) != "UIA.IUIAutomationElement") {
            try AdobeEl := UIA.ElementFromHandle("Render and Replace " this.exeTitle,, false)
            catch {
                return false
            }
        } else {
            AdobeEl := UIAObj
        }
        _setComboBox(index, item) {
            box := AdobeEl.FindElement({LocalizedType:"combo box"},, index)
            if box.Value != item {
                try item := box.FindElement({LocalizedType:"list item", Name: item})
                catch {
                    ;// throw
                    errorLog(TargetError("Could not find: " item, -1),,, true)
                }
                item.select()
            }
            sleep 25
        }

        _setComboBox(1, dropSource) ;// source
        _setComboBox(2, dropFormat) ;// format
        _setComboBox(3, dropPreset) ;// preset
    }

    /**
     * Sets the `Location` combo box to the desired path in the `Render and Replace` window
     * @param {String} path the desired path you wish to use as the output location. (can also be set to `Next to Original Media`)
     * @param {UIA.IUIAutomationElement} [UIAObj] pass in a UIA element for reuse
     * @param {UIA.IUIAutomationElement} [AdobeEl] pass back the UIA element for reuse
     * @returns {Boolean}
     */
    static setRnderRplcPath(path, UIAObj?, &AdobeEl?) {
        if path = "timeline renders" {
            projPath := WinGet.ProjPath()
            path := WinGet.pathU(projPath.Dir "\..\timeline renders")
        }
        coord.s()
        SetDefaultMouseSpeed(0)
        origPos := obj.MousePos()
        if !IsSet(UIAObj) || (IsSet(UIAObj) && Type(UIAObj) != "UIA.IUIAutomationElement") {
            AdobeEl := UIA.ElementFromHandle("Render and Replace " this.exeTitle,, false)
        } else {
            AdobeEl := UIAObj
        }
        comb := AdobeEl.FindElement({LocalizedType:"combo box"},, 4)
        if comb.name = path
            return true
        comb.Click()
        if !WinWait("OS_PopupWindow " this.exeTitle,, 3)
            return false
        flyout := UIA.ElementFromHandle("OS_PopupWindow " this.exeTitle,, false)
        if path = "Next to Original Media" {
            item := flyout.FindElement({LocalizedType:"text", Name:"Choose Location..."})
            Send( "{Click " item.Location.x A_Space item.location.y "}")
            return true
        }
        item := flyout.FindElement({LocalizedType:"text", Name:"Choose Location..."})
        Send( "{Click " item.Location.x A_Space item.location.y "}")
        MouseMove(origPos.x, origPos.y, 0)
        if !WinWait("Select Folder " this.exeTitle,, 2)
            return false
        hwnd := WinExist("Select Folder " this.exeTitle)
        explorer.navigateUsingAddressbar(path, hwnd)
        selectFolderWin := UIA.ElementFromHandle(hwnd,, false)
        selectFolderWin.FindElement({LocalizedType:"button", Name:"Select Folder", AutomationId:"1"}).Click()
        return true
    }

    /**
     * This function is (for the most part) designed to be activated from a streamdeck but should still work separately. It handles going through the `render and replace` process for the selected clip(s). If the selected clip is a video it will also automate the `Render and Replace` window, including setting the desired output path.
     * @param {String/Boolean} [changeLabel] whether you wish for the selected clip to have its label colour changed. Will only change clips with a `mediatype` of `Video`
     * @param {String} [labelHotkey] the hotkey of the label colour you wish to change the selected clip to
     * @param {String} [dropPreset] the parameter that will be passed to `prem.setRnderRplcPreset()`. See that function for more detailed information.
     * @param {String} [dropSource] the parameter that will be passed to `prem.setRnderRplcPreset()`. See that function for more detailed information.
     * @param {String} [dropFormat] the parameter that will be passed to `prem.setRnderRplcPreset()`. See that function for more detailed information.
     * @param {String} [path] the parameter that will be passed to `prem.setRnderRplcPath()` and is the desired path you wish to use as the output location. (can also be set to `Next to Original Media`)
     * @returns {Boolean} returns boolean `false` if; premiere isn't the active window, waiting for the `Render and Replace` window timed out, the user has an audio file selected, setting the render path failed
     */
    static renderAndReplace(changeLabel, labelHotkey, dropPreset, dropSource, dropFormat, path) {
        if !WinActive(this.winTitle)
            return false
        clipType := this.__remoteFunc('clipType', true)
        title := WinGet.PremName()
        if title.saveCheck != false
            attempt := this.saveAndFocusTimeline()
        sleep 100
        if checkBool(changeLabel) && labelHotkey != "" && clipType = "Video"
            SendEvent(labelHotkey)
        sleep 50
        SendEvent(KSA.premRndrReplce)
        sleep 100
        if !WinWait("Render and Replace " this.exeTitle,, 2) {
            if (attempt ?? false) = "active" {
                SendInput(KSA.premRndrReplce)
                if !WinWait("Render and Replace " this.exeTitle,, 2) {
                    tool.Cust("Waiting for rendering window timed out.`nLag may have caused the hotkey to be sent before Premiere was ready.")
                    return false
                }
            }
        }
        if clipType != "Video"
            return false
        if !this.setRnderRplcPreset(dropPreset, dropSource, dropFormat,, &AdobeEl)
            return false
        if !this.setRnderRplcPath(path, AdobeEl)
            return false
        sleep 50
        if !WinWaitActive("Render and Replace " this.exeTitle,, 2) {
            try WinActivate("Render and Replace " this.exeTitle)
            if !WinWaitActive("Render and Replace " this.exeTitle,, 2)
                return false
        }
        AdobeEl.FindElement({LocalizedType:"button", Name:"OK"}).Invoke()
    }

    /**
     * A function to activate the Project panel and select the last item in the list. Useful after you've moved an item into another bin and premiere defaults to no selection afterwards
     */
    static goToLastProjPanelItem() {
        if !WinActive(prem.winTitle)
            return
        premUIA := premUIA_Values.initialise()
        if !premUIA.__isUiaElementActive("projectsWindow", premUIA) {
            SendInput(ksa.projectsWindow)
            sleep 50
        }
        delaySI(16, ksa.findBox, "{Delete}", "{Enter}") ;// clear any text in the findbox
        sleep 50
        SendInput(ksa.projItemEnd)
    }

    /**
     * Set the blend mode of the currently selected clip.
     * @param {String} [blendModeString] The name of the desired blend mode. Values include;
     *
     * `Normal`, `Dissolve`,
     * `Darken`, `Multiply`, `Color Burn`, `Linear Burn`, `Darker Color`,
     *
     * `Lighten`, `Screen`, `Color Dodge`, `Linear Dodge (Add)`, `Lighter Color`,
     *
     * `Overlay`, `Soft Light`, `Hard Light`, `Vivid Light`, `Linear Light`, `Pin Light`, `Hard Mix`,
     *
     * `Difference`, `Exclusion`, `Subtract`, `Divide`, `Hue`, `Saturation`, `Color`, `Luminosity`
     */
    static setBlendMode(blendModeString) {
        if !premUIA := premUIA_Values.initialise()
            return
        effCont := UIA.ElementFromHandle(premUIA.UIA_Hwnd["effectControls"])
        if !this.isClipSelected(effCont)
            return
        try {
            blendMode := effCont.FindElement({LocalizedType:"combo box"},, 2)
            blendMode.FindElement({LocalizedType:"list item", Name:blendModeString}).Select()
        }
    }

    /**
     * returns a list of all video/audio effects available in UXP
     * @returns {String}
     */
    static listAllUXPEffects() {
        t := prem.__remoteUXP('custom/listAllAvailableEffects', true)
        t := StrReplace(t, "||", "`n")
        t := StrReplace(t, "|", "`n")
        return t
    }

    /**
     * Save effects so they can be easily pasted later. Will also save custom keyframes/values. Simply select a clip and call the function.
     * @param {Boolean} [save=true] whether you wish to save the current clip, or paste the saved effect
     * @param {Integer} [slot=1] which slot you wish to call/save to
     * @param {Boolean} [saveToFile=false] determine whether you wish to use `Core Functionality` or write to disk to maintain saves between reloads
     */
    static effectSlot(save := true, slot := 1, saveToFile := false) {
        ; validateTypes(["Integer", "Integer"], save, slot) ;breaks hotkeylessahk
        slotsDir := ptf.rootDir "\Backups\Adobe Backups\Premiere\PremiereRemote\slots"
        if !DirExist(slotsDir)
            DirCreate(slotsDir)
        slotFile := slotsDir "\" slot
        switch checkBool(saveToFile) {
            case false:
                try slots := CLSID_Objs.load("premSlots")
                catch {
                    errorLog(MemoryError('Failed to retrieve slots object from Core Functionality.ahk', -1, slot))
                    notifyExt.showIfNotExist('premEffectSlotFailed',, "Failed to retrieve slots object from Core Functionality.ahk",,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                    return
                }
                if !slots.HasProp(slot) && checkBool(save) == false {
                    errorLog(TargetError('No data saved in slot', -1, slot))
                    notifyExt.showIfNotExist('premEffectSlotNoneSaved',, "No data saved in slot",,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                    return
                }
            case true:
                if checkBool(save) == false && !FileExist(slotFile) {
                    errorLog(TargetError('No data saved in slot file specified', -1, slot))
                    notifyExt.showIfNotExist('premEffectSlotNoneSaved',, "No data saved in slot file specified",,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                    return
                }
        }
        switch checkBool(save) {
            case true:
                t := prem.__remoteFunc('saveEffectSlotJSON', true)
                if InStr(t, "error") {
                    __checkErrors(t)
                    return
                }
                try json.parse(t)
                catch {
                    __checkErrors(t)
                    return
                }
                switch checkBool(saveToFile) {
                    case false:
                        try slots.%slot% := t
                        catch {
                            errorLog(MethodError('Failed to save effects to Core Func slot', -1, slot))
                            notifyExt.showIfNotExist('premEffectSlotFailedSave',, "Failed to save effects to Core Functionality slot: " slot,,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                        }
                    case true:
                        try {
                            if FileExist(slotFile)
                                FileDelete(slotFile)
                            FileAppend(t, slotFile)
                        } catch {
                            errorLog(MethodError('Failed to save effects to slot file', -1, slot))
                            notifyExt.showIfNotExist('premEffectSlotFailedSave',, "Failed to save effects to slot file: " slot "`n" slotFile,,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                            return
                        }
                }
                notifyExt.showIfNotExist('premEffectSlotSaved',, "Effects Saved to slot: " slot)
                return
            case false:
                switch checkBool(saveToFile) {
                    case false:
                        stringg := Base64Encode(slots.%slot%)
                        t := prem.__remoteFunc('applyEffectSlotJSON', true, "data=" stringg)
                    case true:
                        try {
                            stringg := Base64Encode(FileRead(slotFile))
                            t := prem.__remoteFunc('applyEffectSlotJSON', true, "data=" stringg)
                        } catch {
                            errorLog(MethodError('Failed to read effects slot file', -1, slot))
                            notifyExt.showIfNotExist('premEffectSlotFailedRead',, "Failed to read effects slot file: " slot "`n" slotFile,,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                            return
                        }
                }
                __checkErrors(t)
                return
        }

        __checkErrors(response) {
            switch {
                case (InStr(response, "ERROR: ") || InStr(response, "EvalScript error.") || InStr(response, "FAILED")):
                    notifyExt.showIfNotExist('premEffectERROR',, response,,,, 'theme=Dark dur=4 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                    errorLog(Error(response, -1))
                    return
            }
        }
    }

    __Delete() {
		try {
            WinEvent.Stop("Active", this.exeTitle " Clip Fx Editor")
            WinEvent.Stop("Close",  this.exeTitle " Clip Fx Editor")
            WinEvent.Stop("Close",  this.exeTitle)
        }
	}

    ;//! *** ===============================================

    class Excalibur {

        static __isInstalled() {
            return DirExist(A_AppData "\Adobe\CEP\extensions\knights_of_the_editing_table.excalibur")
        }

        lockNumpadKeys := Mip("Space", ",", "Numpad0", ",", "NumpadSub", "{BackSpace}")
        /**
         * Sets or resets some numpad functionality for `lockTracks()`
         */
        __lockNumpadKeys(set_reset := "set", which := "") {
            switch set_reset, "Off" {
                case "set":
                    __set(sendHotkey, *) => SendInput(sendHotkey)
                    for k, v in this.lockNumpadKeys {
                        Hotkey(k, __set.Bind(v), "On")
                    }
                case "reset":
                    for k2, v2 in this.lockNumpadKeys {
                        try {
                            Hotkey(k2, k2)
                        } catch {
                            try Hotkey(k2, "Off")
                        }
                    }
                    try {
                        Hotkey("NumpadDiv", "NumpadDiv")
                    } catch {
                        try Hotkey("NumpadDiv", "Off")
                    }
            }
        }

        /**
         * This function allows the user to select a range of tracks to toggle instead of needing to type them one by one. It will either wait for two numbers to be input or for <kbd>NumpadEnter</kbd> to be pressed.
         */
        __divHotkey(*) {
            __finish() {
                errorLog(Error("Input value is not a number."),, true)
                tool.Wait()
            }
            tool.Cust("Type first number then press NumpadEnter", 3.0)
            ih := InputHook("L2", "{NumpadEnter}")
            ih.Start()
            ih.Wait()
            firstNum := ih.Input
            if !IsInteger(firstNum) {
                __finish()
                ExitApp()
            }

            tool.Cust("Type second number then press NumpadEnter", 3.0)
            ih2 := InputHook("L2", "{NumpadEnter}")
            ih2.Start()
            ih2.Wait()
            secondNum := ih2.input
            if !IsInteger(secondNum) {
                __finish()
                ExitApp()
            }

            startingVal := Min(firstNum, secondNum)
            arr := [startingVal]
            loop (Max(firstNum, secondNum)-Min(firstNum, secondNum)) {
                arr.Push(++startingVal)
            }
            for v in arr
                SendInput(v ",")
            SendInput("{Enter}")
        }

        /**
         * #### This function requires the premiere plugin `Excalibur` to be installed and for `KSA.excalLockVid/KSA.excalLockAud` to be correctly set.
         * Quickly and easily lock/unlock multiple audio/video tracks
         * @param {String} which determines which track you wish to adjust. Must be either `"video"` or `"audio"`
         */
        static lockTracks(which := "Video") {
            switch which, "Off" {
                case "audio": SendInput(KSA.excalLockAud)
                case "video": SendInput(KSA.excalLockVid)
                default: return
            }
            if !WinWait("Lock " StrTitle(which) " Tracks",, 3)
                return
            sleep 200
            SendInput("{Down}")
            this().__lockNumpadKeys("set", which)
            Hotkey("NumpadDiv", this().__divHotkey, "On")
        }
    }
}

class PremHotkeys {
    /**
     * Resets an array of keys to their original `Hotkey` functions
     * @param {Array} keyArr an array of keynames
     */
    static __HotkeyReset(keyArr) {
        for k in keyArr {
            try {
                Hotkey(k, k)
            } catch {
                try {
                    Hotkey(k, "Off")
                }
            }
        }
    }

    /**
     * Sets an array of keys to the passed in function
     * @param {Array} arr an array of keynames
     * @param {FuncObj} func a passed in function that all keynames will be passed into
     * @param {String} options allows the user to pass addition `Hotkey` options. This parameter can be omitted
     */
    static __HotkeySet(arr, func, options := "") {
        try {
            for v in arr {
                Hotkey(v, func.Bind(v), "On " options)
            }
        }
    }

    /**
     * Function for `prem.thumbScroll()` sets hotkeys on <kbd>Shift</kbd> & <kbd>Ctrl</kbd> to speed up/slow down the cursor moving
     * @param {Array} arr all keys you wish to assign a function
     */
    static __HotkeySetThumbScroll(arr) {
        this.__HotkeySet(arr, __set)

        /**
         * A function to define what each hotkey passed will do
         * @param {String} which the keyname
         */
        __set(which, *) {
            switch which {
                case "Shift":  prem.scrollSpeed += 5
                case "Ctrl":
                if prem.scrollSpeed <= 5 {
                    prem.scrollSpeed := 1
                    return
                }
                prem.scrollSpeed -= 5
            }
        }
    }
}