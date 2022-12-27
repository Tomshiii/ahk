/************************************************************************
 * @description A class to maintain "wrapper" functions that take normal ahk functions and instead return their variables as objects
 * @file obj.ahk
 * @author tomshi
 * @date 2022/12/27
 * @version 1.0.1
 ***********************************************************************/

#Include <Functions\checkImg>

class obj {

    static winTitle := "A"
    static winText := ""
    static exTitle := ""
    static exText := ""

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
     * @param {any} Path is the input path that will be split
     * @returns {object} `x.path` | `x.name` | `x.dir` | `x.ext` | `x.namenoext` | `x.drive`
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
     * @param {string} winTitle is the winTitle you wish to get the position of, this will default to the active window
     * @param {String} winText is the winText of the window
     * @param {String} exTitle the title of any window you wish to exclude
     * @param {String} exText the text of any window you wish to exclude
     * @returns {object} contains an object of all standard WinGetPos VarRefs
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
     * @param {Integer} x1/2&y1/2 are the coordinates you wish to check
     * @param {String} imgFile is the path to the file you wish to search for
     * @returns {Object} containing the x&y coordinates of the located image
     * ```
     * img := obj.imgSrch(,,,, "image.png")
     * img.x
     * img.y
     * ```
     */
    static imgSrch(x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight, imgFile := "") {
        if !checkImg(imgFile, &x, &y, x1, y1, x2, y2)
            return false
        return {x: x, y: y}
    }
}