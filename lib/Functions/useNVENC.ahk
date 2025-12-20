; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Functions\Win32_VideoController.ahk
; }

/**
 * A function to (rather rudimentarily) determine whether or not to use nvenc.
 *
 * ### This function requires `ffmpeg` to be installed
 * @returns {Boolean}
 */
useNVENC() {
    getGPU := Win32_VideoController()
    checkCUDA := cmd.result("ffmpeg -hide_banner -hwaccels")
    if (!getGPU.Has("NVIDIA") || !InStr(checkCUDA, "cuda",,, 1))
        return false
    return true
}