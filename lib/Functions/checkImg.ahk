; { \\ #Includes
#Include <Classes\errorLog>
; }

/**
 * This function is syntatic sugar for checking if a file exists and doing an imagesearch at the same time.
 * This is helpful when you need to test for a variety of images due to slight aliasing breaking things but you don't want ahk to throw an error
 * if a file of a certain name doesn't exist.
 *
 * This function defaults to `"*2 "` but you can override this by placing a new choice at the beginning of `checkfilepath`.
 * This function supports as many options as you wish
 * @param {String} checkfilepath the path of the file you wish to check/imagesearch
 * @param {VarRef} returnX/returnY are the return x/y values you wish to pass back
 * @param {Object} coords are the coordinates you wish to search. Defaults to:
     * ```
     * coords := {x1: 0, y1:0, x2: A_ScreenWidth, y2: A_ScreenHeight}
     * ```
 * @param {Boolean/Object} tooltips whether you want `errorLog()` to produce tooltips if it runs into an error. This parameter can be a simple true/false or an object that errorLog is capable of understanding
 */
checkImg(checkfilepath, &returnX?, &returnY?, coords?, tooltips := false) {
    fileCheck := (check := InStr(checkfilepath, "*",, -1, -1))
                 ? SubStr(checkfilepath, (space := InStr(checkfilepath, " ",, check, 1)+1))
                 : checkfilepath
    if !FileExist(fileCheck)
        {
            errorLog(ValueError("Desired file could not be found", -1, fileCheck),, tooltips)
            return false
        }
    coord := {x1: 0, y1: 0, x2: A_ScreenWidth, y2: A_ScreenHeight}
    if IsSet(coords) {
        for key, value in coords.OwnProps() {
            coord.%key% := value
        }
    }
    imgCheck := (IsSet(check) && check != 0)
                ? SubStr(checkfilepath, 1, space-1)
                : "*2 "
    if !ImageSearch(&returnX, &returnY, coord.x1, coord.y1, coord.x2, coord.y2, imgCheck fileCheck)
        {
            errorLog(Error("Could not locate the requested image on the screen", -1),, tooltips)
            return false
        }
    return true
}