/************************************************************************
 * @description a class to contain often used functions to quickly and easily access common ffmpeg commands
 * @author tomshi
 * @date 2023/04/27
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Classes\winGet>
#Include <Functions\errorLog>
; }

class ffmpeg {

    /** generates a tooltip to alert the user the process has completed */
    __finished() => tool.tray({text: "ffmpeg process has finished", title: "ffmpeg process has completed!", options: 1}, 2000)

    /**
     * Retrieves the path of an active windows explorer process
     */
    __getPath() {
        hwnd := WinExist("A")
        return {path: WinGet.ExplorerPath(hwnd), hwnd: hwnd}
    }

    /**
     * Checks to ensure that windows explorer is active if the user has set the path to the active window
     * @param {String} path the path the user provides
     */
    __checkPath(path) {
        if path = "A" && !WinActive("ahk_class CabinetWClass") {
            ;// throw
            errorLog(TargetError("A path is required or Windows Explorer must be active", -1),,, 1)
        }
    }

    /**
     * sets the path variable to an object
     * @param {String} path the path the user provides
     * @returns {Object} an object containing the path to work on & a windows explorer hwnd if it was previously the active window
     */
    __setPath(path) {
        this.__checkPath(path)
        return path := (path = "A") ? this.__getPath() : {path: path, hwnd: ""}
    }

    /**
     * Sends the desired command to the command line
     * @param {String} command the command that will be sent to the command line
     * @param {String} path the path to use as the working directory for the command
     */
    __runCommand(command, path) => cmd.run(false, true, command, path)

    /**
     * attempts to activate the previously active explorer window
     * @param {Integer} hwnd the hwnd of the previously active explorer window
     */
    __activateWindow(hwnd) {
        try {
            WinActivate(hwnd)
        }
    }

    /**
     * Attempts to merge an audio file with a video file
     * uses;
     * `ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac output.mp4`
     * @param {String} videoFilePath the path to the desired video file
     * @param {String} audioFilePath the path to the desired audio file
     */
    merge_audio_video(videoFilePath, audioFilePath) {
        finalPath := obj.SplitPath(videoFilePath)
        ;// ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac output.mp4
        cmd.run(false, true, Format("ffmpeg -i `"{1}`" -i `"{2}`" -c:v copy -c:a aac `"{3}.mp4`"", videoFilePath, audioFilePath, finalPath.dir "\" finalPath.NameNoExt))
    }

    /**
     * Attempts to reencode the desired file into a h264 codec
     * @param {String} videoFilePath the path to the desired video file
     * @param {String} outputFileName the desired output name of your file. leaving this variable blank will leave the name the same (which may fail as ffmpeg may not be able to output a file if that name is already taken)
     * @param {String} preset the desired h264 preset to use. defaults to `medium`
     * @param {String} crf the desired crf value to use. defaults to `17`
     */
    convert2_h264(videoFilePath, outputFileName?, preset := "medium", crf := "17") {
        finalPath := obj.SplitPath(videoFilePath)
        finalFileName := IsSet(outputFileName) ? outputFileName : finalPath.NameNoExt
        ;// ffmpeg -i input.mp4 -c:v libx264 -preset ultrafast -crf 17 output.mkv
        cmd.run(false, true, Format("ffmpeg -i `"{1}`" -c:v libx264 -preset {3} -crf {4} `"{2}.mp4`"", videoFilePath, finalPath.dir "\" finalFileName, preset, crf))
    }

    /**
     * Attempts to convert all files of the input type, to the desired type
     * @param {String} path the path of the desired files. If no path is provided this parameter defaults to the active windows explorer window
     * @param {String} from the filetype you wish to convert from
     * @param {String} to the filetype you wish to conver to
     */
    all_XtoY(path := "A", from := "mkv", to := "mp4") {
        path := this.__setPath(path)
        ;// audio - video; ffmpeg commands
        ;// for %i in (*.mkv) do ffmpeg -i "%i" "%~ni.mp3"
        ;// for %f in (*.mkv) do ffmpeg -i "%f" -map 0 -c copy "%~nf.mp4"
        switch to {
            case "mp3", "wav": command := Format('for %i in (*.{1}) do ffmpeg -i `"%i`" `"%~ni.{2}`"', from, to)
            default:           command := Format('for %f in (*.{1}) do ffmpeg -i `"%f`" -map 0 -c copy `"%~nf.{2}`"', from, to)
        }
        this.__runCommand(command, path.path)
        this.__activateWindow(path.hwnd)
    }

    __Delete() {
        this.__finished()
    }
}
