/**
 * This function acts as a wrapper for `MouseGetPos()` to return it's VarRefs as an object instead
 * @param {Integer} flags pass in normal flag settings for MouseGetPos. This can be omitted
 * @returns {Object} contains an object of all standard MouseGetPos VarRefs
 * eg:
 *
 * `original := getMousePos()`
 *
 * `original.x`     ;passes back the mouse x coordinate
 *
 * `original.y`     ;passes back the mouse y coordinate
 *
 * `original.win`   ;passes back the window the mouse is hovering
 *
 * `original.control` ;passes back the control the mouse is hovering
 */
getMousePos(flags?) {
    MouseGetPos(&x, &y, &win, &control, flags?)
    return {x: x, y: y, win: win, control: control}
}