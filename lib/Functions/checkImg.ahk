/**
 * This function is syntatic sugar for checking if a file exists and doing an imagesearch at the same time
 * This is helpful when you need to test for a variety of images due to slight aliasing breaking things
 */
checkImg(checkfilepath, &returnX?, &returnY?, x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight) {
    if !FileExist(checkfilepath)
        return false
    if !ImageSearch(&returnX, &returnY, x1, y1, x2, y2, "*2 " checkfilepath)
        return false
    return true
}