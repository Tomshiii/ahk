/************************************************************************
 * @description A class to maintain "wrapper" functions that take normal ahk functions and instead return their variables as objects
 * @file obj.ahk
 * @author tomshi
 * @date 2022/12/26
 * @version 1.0.0
 ***********************************************************************/

class obj {
    /**
     * This function turns the inbuilt function `SplitPath` into a function that returns an object.
     * ```
     * ;// Example Dir
     * script := obj.SplitPath("E:\Github\ahk\My Scripts.ahk")
     * script.Name       ; My Scripts.ahk
     * script.Dir        ; E:\Github\ahk
     * script.Ext        ; ahk
     * script.NameNoExt  ; My Scripts
     * script.Drive      ; E:
     * ```
     * @param {any} Path is the input path that will be split
     * @returns {object} `x.path` - `x.name` - `x.dir` - `x.ext` - `x.namenoext` - `x.drive`
     */
    static SplitPath(Path) {
        SplitPath(Path, &Name, &Dir, &Ext, &NameNoExt, &Drive)
        return {Name: Name, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }

    /**
     * This function acts as a wrapper for `MouseGetPos()` to return its VarRefs as an object instead
     * @param {Integer} flags pass in normal flag settings for MouseGetPos. This can be omitted
     * @returns {Object} contains an object of all standard MouseGetPos VarRefs
     * eg:
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
     * @param {String} excludeTitle the title of any window you wish to exclude
     * @param {String} excludeText the text of any window you wish to exclude
     * @returns {object} contains an object of all standard WinGetPos VarRefs
     * ```
     * window := obj.WinPos()
     * window.x
     * window.y
     * window.width
     * window.height
     * ```
     */
    static WinPos(winTitle := "A", winText?, excludeTitle?, excludeText?) {
        WinGetPos(&x, &y, &width, &height, winTitle, winText, excludeTitle, excludeText)
        return {x: x, y: y, width: width, height: height}
    }
}