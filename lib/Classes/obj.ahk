/************************************************************************
 * @description A class to maintain "wrapper" functions that take normal ahk functions and instead return their variables as objects
 * @file obj.ahk
 * @author tomshi
 * @date 2023/03/09
 * @version 1.1.2
 ***********************************************************************/

; { \\ #Includes
#Include <Functions\checkImg>
; }

class obj {

    static winTitle := "A"
    static winText := ""
    static exTitle := ""
    static exText := ""

    static x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight

    /**
     * This function turns the inbuilt function `SplitPath` into a function that returns an object.
     * ```
     * script := obj.SplitPath("E:\Github\ahk\My Scripts.ahk")
     * script.Name       ; My Scripts.ahk
     * script.Dir        ; E:\Github\ahk
     * script.Ext        ; ahk
     * script.NameNoExt  ; My Scripts
     * script.Drive      ; E:
     * ```
     * @param {String} Path is the input path that will be split
     * @returns {Object} `x.path` | `x.name` | `x.dir` | `x.ext` | `x.namenoext` | `x.drive`
     */
    static SplitPath(Path) {
        SplitPath(Path, &Name, &Dir, &Ext, &NameNoExt, &Drive)
        return {Name: Name, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }

    /**
     * This function acts as a wrapper for `MouseGetPos()` to return its VarRefs as an object instead
     * @param {Integer} flags pass in normal flag settings for MouseGetPos. This can be omitted
     * @returns {Object} contains an object of all standard MouseGetPos VarRefs
     * ```
     * `original := getMousePos()`
     * `original.x`       ;passes back the mouse x coordinate
     * `original.y`       ;passes back the mouse y coordinate
     * `original.win`     ;passes back the window the mouse is hovering
     * `original.control` ;passes back the control the mouse is hovering
     * ```
     */
    static MousePos(flags?) {
        MouseGetPos(&x, &y, &win, &control, flags?)
        return {x: x, y: y, win: win, control: control}
    }

    /**
     * This function acts as a wrapper for `WinGetPos()` to return its VarRefs as an object instead
     * @param {String} winTitle is the winTitle you wish to get the position of, this will default to the active window
     * @param {String} winText is the winText of the window
     * @param {String} exTitle the title of any window you wish to exclude
     * @param {String} exText the text of any window you wish to exclude
     * @returns {Object} contains an object of all standard WinGetPos VarRefs
     * ```
     * window := obj.WinPos()
     * window.x
     * window.y
     * window.width
     * window.height
     * ```
     */
    static WinPos(winTitle := this.winTitle, winText := this.winText, exTitle := this.exTitle, exText := this.exText) {
        WinGetPos(&x, &y, &width, &height, winTitle, winText, exTitle, exText)
        return {x: x, y: y, width: width, height: height}
    }

    /**
     * This function acts as a wrapper for `ImageSearch`. It will verify if the requested file exists and return the x and y coordinates as an object if it does.
     *
     * By default this function will have an option "*2 " but can be overridden by placing a new option at the beginning of `imgFile`
     * This function supports all imagesearch options
     * @param {String} imgFile is the path to the file you wish to search for
     * @param {Object} x1/2&y1/2 are the coordinates you wish to check. Defaults to:
     * ```
     * coords := {x1: 0, y1:0, x2: A_ScreenWidth, y2: A_ScreenHeight}
     * ```
     * @param {Boolean/Object} tooltips whether you want `errorLog()` to produce tooltips if it runs into an error. This parameter can be a simple true/false or an object that errorLog is capable of understanding
     * @returns {Object} containing the x&y coordinates of the located image
     *
     * ***
     * Example #1
     * ```
     * img := obj.imgSrch("image.png")
     * img.x
     * img.y
     * ```
     * ***
     * Example #2
     * ```
     * img := obj.imgSrch("image.png", {x1: 0, y1: 0, x2: 20, y2: 100})
     * img.x
     * img.y
     * ```
     */
    static imgSrch(imgFile := "", coords?, tooltips := false) {
        coord := {x1: this.x1, y1: this.y1, x2: this.x2, y2: this.y2}
        if IsSet(coords) {
            for v in coords.OwnProps() {
                for key, value in coords.OwnProps() {
                    coord.%key% := value
                }
            }
        }
        if !checkImg(imgFile, &x, &y, {x1: coord.x1, y1: coord.y1, x2: coord.x2, y2: coord.y2}, tooltips)
            return false
        return {x: x, y: y}
    }

    /**
     * This function is a wrapper function for `ControlGetPos()`.
     * @param {String} ctrl the desired control. If this value is left unset, it will attempt to grab the ClassNN of the currently active control and use that for `ControlGetPos()`
     * @returns {Object} returns an object containing all varrefs and the control name
     *
     * *If the function fails to get the position of the control, it will simply return `false`*
     * ```
     * button := obj.ctrlPos()
     * button.x         ;// returns the x coordinate of the control
     * button.y         ;// returns the y coordinate of the control
     * button.width     ;// returns the width of the control
     * button.height    ;// returns the height of the control
     * button.ctrl      ;// returns a string containing the control
     * ```
     */
    static ctrlPos(ctrl?, winTitle := this.winTitle, winText := this.winText, exTitle := this.exTitle, exText := this.exText) {
        if !IsSet(ctrl) {
            try {
                ctrl := ControlGetClassNN(ControlGetFocus(winTitle, winText, exTitle, exText)
                                        , winTitle , winText, exTitle, exText)
            }
        }
        try {
            ControlGetPos(&x, &y, &width, &height, ctrl, winTitle, winText, exTitle, exText)
            return {x: x, y: y, width: width, height: height, ctrl: ctrl}
        } catch {
            errorLog(UnsetError("Couldn't find the ClassNN value", -1, ctrl),, 1)
            return false
        }
    }

    /**
     * This function allows you to search for an image over a custom length of time.
     * ### How many times this function searches and how fast it can do so is completely depend on the size of the area you wish to search.
     * ### The bigger the area, the slower/less times the function will search for your image.
     * ##### for example: searching the entire screen is incredibly slow and may take multiple seconds just to check once
     * @param {Object} options an object containing potential options. See Examples below for all options. Defaults to:
     * ```
     * options := {wait: 1000, tooltips: false, imgFile: "null"}
     * ```
     * @param {Object} coords an object containing all coord points you wish to monitor. Defaults to:
     * ```
     * coords := {x1: 0, y1:0, x2: A_ScreenWidth, y2: A_ScreenHeight}
     * ```
     * @returns {Object} the x/y position the image is found
     *
     * Example #1
     * ```
     * img := obj.imgWait({wait: 2000, imgFile: "F:/untitled.png", tooltips: true})
     * ;// wait: time in ms you wish the function to search for the image
     *      ;// default: 1000
     * ;// imgFile: the filepath of the image you wish to search for
     * ;// tooltips: the parameter you with to pass to `obj.imgSrch()`
     *      ;// default: false
     * ```
     * ***
     * Example #2
     * ```
     * img := obj.imgWait({imgFile: "F:/untitled.png"}, {x1: 0, x2: A_ScreenWidth, y1: 0, y2: A_ScreenHeight})
     * ```
     */
    static imgWait(options, coords?) {
        start := A_TickCount
        var := false
        if (IsSet(options) && !IsObject(options)) || (IsSet(coords) && !IsObject(coords)) {
            ;// throw
            errorLog(ValueError("Expected an Object", -1),,, 1)
        }
        ;// default values
        opt := {wait: 1000, tooltips: false, imgFile: "null"}
        coord := {x1: this.x1, y1: this.y1, x2: this.x2, y2: this.y2}

        ;// if any values aren't passed to the function, they will be set to default
        for v in options.OwnProps() {
            for key, value in options.OwnProps() {
                opt.%key% := value
            }
        }
        if IsSet(coords) {
            for v in coords.OwnProps() {
                for key, value in coords.OwnProps() {
                    coord.%key% := value
                }
            }
        }

        SetTimer(() => var := "timed out", -options.wait)
        while !var || var = "" {
            var := this.imgSrch(opt.imgFile, {x1: coord.x1, y1: coord.y1, x2: coord.x2, y2: coord.y2}, opt.tooltips)
        }
        if var = "timed out"
            return false
        return {x: var.x, y: var.y}
    }
}