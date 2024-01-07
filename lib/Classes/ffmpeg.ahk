/************************************************************************
 * @description a class to contain often used functions to quickly and easily access common ffmpeg commands
 * @author tomshi
 * @date 2024/01/08
 * @version 1.0.16
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Classes\winGet>
#Include <Classes\errorLog>
#Include <Other\JSON>
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
     * ```
     * path := _setPath("A")
     * path.path ;// the passed in Path
     * path.hwnd ;// the hwnd of the explorer window
     * ```
     */
    __setPath(path) {
        this.__checkPath(path)
        return path := (path = "A") ? this.__getPath() : {path: path, hwnd: ""}
    }

    /**
     * Get the index to append to the file if the user doesn't wish to overwrite it
     * @param {String} path the location of the file being worked on
     */
    __getIndex(path, extOverride := "") {
        pathobj := obj.SplitPath(path)
        pathobj.ext := (extOverride = "") ? pathobj.ext : extOverride
        index := 1
        loop {
            if FileExist(pathobj.dir "\" pathobj.NameNoExt "_" index "." pathobj.ext) {
                index++
                continue
            }
            break
        }
        return (pathobj.dir "\" pathobj.NameNoExt "_" index "." pathobj.ext)
    }

    /**
     * Sends the desired command to the command line
     * @param {String} command the command that will be sent to the command line
     * @param {String} path the path to use as the working directory for the command
     */
    __runCommand(command, path) => cmd.run(false, true, false, command, path)

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
     * Run the dir
     * @param {Object} obj the splitpath object that contains the path of the file being worked on
     */
    __runDir(obj) {
        if WinExist(obj.dir)
            WinActivate(obj.dir)
        else
            Run(obj.dir)
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
        cmd.run(false, true, false, Format("ffmpeg -i `"{1}`" -i `"{2}`" -c:v copy -c:a aac `"{3}.mp4`"", videoFilePath, audioFilePath, finalPath.dir "\" finalPath.NameNoExt))
    }

    /**
     * Attempts to reencode the desired file into the desired file codec. (h264/h265)
     * @param {String} videoFilePath the path to the desired video file
     * @param {String} outputFileName the desired output name of your file. leaving this variable blank will leave the name the same (which may fail as ffmpeg may not be able to output a file if that name is already taken)
     * @param {String} codec the desired h26x encoder to use. defaults to `libx264`
     * @param {String} preset the desired h264 preset to use. defaults to `veryfast`
     * @param {String} crf the desired crf value to use. defaults to `17`. If this parameter is set, `bitrate` must be set to false
     * @param {String} bitrate the deired bitrate value to use. Defaults to false. If this parameter is set, `crf` must be set to false
     */
    reencode_h26x(videoFilePath, outputFileName?, codec := "libx264", preset := "veryfast", crf := "17", bitrate := false) {
        if crf != false && bitrate != false {
            ;// throw
            errorLog(Error("CRF and Bitrate cannot be set at the same time. One parameter must be set to false"),,, 1)
            return
        }
        qualParam := crf != false ? "-crf " crf : "-b:v " bitrate "k"
        finalPath := obj.SplitPath(videoFilePath)
        finalFileName := IsSet(outputFileName) ? outputFileName : finalPath.NameNoExt
        ;// build command
        ;// ffmpeg -i input.mp4 -c:v libx264 -preset medium [-crf 17]/[-b:v 30000k] output.mp4
        command := Format("ffmpeg -i `"{1}`" -c:v {5} -preset {3} {4} `"{2}.mp4`"", videoFilePath, finalPath.dir "\" finalFileName, preset, qualParam, codec)
        cmd.run(false, true, false, command)
    }

    /**
     * Uses ffmpeg to determine the framerate of a file
     * @param {String} filePath the directory path of the file you wish to check
     * @returns {Integer} either the framerate of the file or boolean false upon failure
     */
    __determineFrameRate(filePath, defaultFramerate := 60) {
        ;// determine framerate of file
        frameCMD := Format('ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 "{1}"', filePath)
        frameCMD := cmd.result(frameCMD)
        ;// manipulate the resulting string to remove the `/` and anything after it
        probeFramerate := SubStr(frameCMD, 1, InStr(frameCMD, "/",, 1, 1)-1)
        ;// determining if result is successful
        frameRT  := IsInteger(probeFramerate) ? probeFramerate : false
        return frameRT
    }

    /**
     * Attempts to convert all files of the input type, to the desired type. You may notice this function flash a cmd window, that's ffmpeg determining the fps of the file it is operating on
     * @param {String} path the path of the desired files. If no path is provided this parameter defaults to the active windows explorer window
     * @param {String} from the filetype you wish to convert from
     * @param {String} to the filetype you wish to convert to
     * @param {Integer} frameRate the framerate you wish for the remux to obide by if ffmpeg cannot determine it (or it isn't an integer). This is important as otherwise a `60fps` file might end up remuxing as `60.0002fps` or something like that which has performance issues within NLE's like Premiere
     */
    all_XtoY(path := "A", from := "mkv", to := "mp4", frameRate := 60) {
        path := this.__setPath(path)
        ;// audio - video; ffmpeg loop commands
        ;// for %i in (*.mkv) do ffmpeg -i "%i" "%~ni.mp3"
        ;// for %f in (*.mkv) do ffmpeg -i "%f" -map 0 -c copy "%~nf.mp4"
        switch to {
            case "mp3", "wav":
                command := Format('for %i in (*.{1}) do ffmpeg -i `"%i`" `"%~ni.{2}`"', from, to)
                this.__runCommand(command, path.path)
                this.__activateWindow(path.hwnd)
            default: ;// assumes video file
                ;// attempt to determine framerate of all files in directory
                fileArr := Map()
                loop files path.path "\*." from, "F" {
                    frameRT := (!fps := this.__determineFrameRate(A_LoopFileFullPath, frameRate)) ? frameRate : fps
                    fileArr.Set(A_LoopFileFullPath, frameRT)
                }
                ;// operate on all files in the map
                for k, v in fileArr {
                    outputPath := obj.SplitPath(k)
                    command := Format('ffmpeg -i "{1}" -map 0 -c copy -video_track_timescale {3} "{2}"', k, outputPath.dir "\" outputPath.NameNoExt "." to, v)
                    this.__runCommand(command, path.path)
                }
                this.__activateWindow(path.hwnd)
        }
    }

    /**
     * Attempts to split all videos in half on the horizontal or vertical axis and reencode all `.mkv/.mp4` files in the chosen directory to two separate `.mp4` files. Files will be named `[original filename]_c1.mp4` and `[original filename]_c2.mp4` and placed in a folder called `crop_loop_output_loop_output`.
     * #### NOTE: `crf` & `bitrate` can NOT be set at the same time, one of them MUST be set to `false`
     * @param {String} path the desired path to excecute the loop. the active directory is used by default if no path is specified
     * @param {Object} options an object to contain all necessary encoding options. The defaults are listed below.
     * ```
     * options := {codec: "libx264", preset: "veryfast", crf: false, bitrate: 30000, horizontalVertical: "horizontal"}
     * ;// bitrate is set in kilobits
     * ```
     */
    all_Crop(path := "A", options?) {
        optionsDef := {codec: "libx264", preset: "veryfast", crf: false, bitrate: 30000, horizontalVertical: "horizontal"}
        if IsSet(options) {
            for k, v in options {
                if optionsDef.HasProp(k)
                    optionsDef.%k% := v
            }
        }
        ;// alert user if too many options set
        if optionsDef.crf != false && optionsDef.bitrate != false {
            ;// throw
            errorLog(ValueError("CRF and Bitrate cannot be used at the same time. Please set one value to false.", -1),,, 1)
            return
        }
        ;// determine crf or bitrate
        crfORbitrate := (optionsDef.crf = true) ? "-crf " optionsDef.crf : "-b:v " optionsDef.bitrate "k"
        path := this.__setPath(path)
        if !DirExist(path.path "\crop_loop_output")
            DirCreate(path.path "\crop_loop_output")
        ;// define horizontal or vertical
        filter := (optionsDef.horizontalVertical = "horizontal") ? "[0]crop=iw/2:ih:0:0[left];[0]crop=iw/2:ih:ow:0[right]" : "[0]crop=iw:ih/2:0:0[left];[0]crop=iw:ih/2:0:oh[right]"
        ;// build loop command
        ;// for %f in (*.mkv) do ffmpeg -i "%f" -c:v libx264 -preset veryfast -b:v 30000k -c:a copy -filter_complex "[0]crop=iw/2:ih:0:0[left];[0]crop=iw/2:ih:ow:0[right]" -map "[left]" "%~nf_c1.mp4" -map "[right]" -c:v libx264 -preset veryfast -b:v 30000k -c:a copy "%~nf_c2.mp4"
        command := Format('for %f in (*.mkv, *.mp4) do ffmpeg -i "%f" -c:v {1} -preset {2} {3} -c:a copy -filter_complex "{4}" -map "[left]" "{5}\%~nf_c1.mp4" -map "[right]" -c:v {1} -preset {2} {3} -c:a copy "{5}\%~nf_c2.mp4"', optionsDef.codec, optionsDef.preset, crfORbitrate, filter, path.path "\crop_loop_output")

        ;// run loop
        this.__runCommand(command, path.path)
        this.__activateWindow(path.hwnd)
    }

    /**
     * This function retrieves the duration of the desired file using ffmpeg
     * @param {String} filepath is the filepath of the file you wish to retrieve the duration of
     * @returns {String} returns the duration of the desired file as a string
     */
    __getDuration(filepath) {
        command := Format('ffprobe -i "{1}" -show_entries format=duration -v quiet -of csv="p=0"', filepath)
        value := (strPos := InStr(result := cmd.result(command), ".")) ? SubStr(result, 1, strPos-1) : result
        return value
    }

    /**
     * Attempts to trim the specified file by the input amount.
     * @param {String} path the location of the file being worked on
     * @param {Integer} startval the number of seconds into the file the user wishes to trim to
     * @param {Integer} durationval the number of seconds from the start value the user wishes to trim the file. If this value is omitted (or is 0) this function will assume you want the remainder of the track and only wish to trim the start value.
     * @param {Boolean} overwrite whether the file should be overwritten
     * @param {String} commands any further commands that will be appended to the command. The default command is `ffmpeg -ss {startval} -i "{filepath}" -t {durationval} {commands} "{outputfile}"`
     * @param {Boolean} runDir define whether the path will but run after the function executes
     */
    trim(path, startval := 0, durationval?, overwrite := false, commands := "", runDir := true) {
        pathobj := obj.SplitPath(path)
        outputFile := this.__getIndex(path)
        if !IsSet(durationval) || durationval = 0
            durationval := (this.__getDuration(path))- startval
        command := Format('ffmpeg -ss {1} -i "{3}" -t {2} {5} "{4}"', startval, durationval, path, outputFile, commands)
        cmd.run(,,, command)
        if overwrite {
            FileDelete(path)
            FileMove(outputFile, path)
        }
        if !runDir
            return
        this.__runDir(pathobj)
    }

    /**
     * returns the base command structure for `extractAudio()`
     *
     * base command is; `ffmpeg -i [filepath]`
     * @param {String} filepath the filepath of the file you are operating on
     */
    __baseCommandExtract(filepath) => baseCommand := Format('ffmpeg -i "{}"', filepath)

    /**
     * This function builds the remaining extract ffmpeg command based off the amount of audio streams present within the file
     * @param {String} filepath the filepath of the file you are operating on
     * @param {Integer} count the amount of audio streams present within the file
     * @param {Array} hzArr an array containing the sample rates of all audio streams
     */
    __buildExtractCommand(filepath, count, hzArr) {
        command := ""
        loop count {
            command := command Format('-map 0:a:{1} -f wav -b:a {2} -acodec pcm_s16le "{3}"', A_Index-1, hzArr[A_Index], this.__appendOutput(filepath, A_Index)) A_space
        }
        return command
    }

    /**
     * generates the output portion of the `extractAudio()` ffmpeg command
     * @param {String} filepath the filepath of the file you are operating on
     * @param {Integer} count the amount of audio streams present within the file
     */
    __appendOutput(filepath, count) {
        split := obj.SplitPath(filepath)
        if !DirExist(split.dir "\" split.NameNoExt)
            DirCreate(split.dir "\" split.NameNoExt)
        outputPath := split.dir "\" split.NameNoExt "\" split.NameNoExt "_" count ".wav"
        return outputPath
    }

    /**
     * This function determines the sample rate of all audio streams within a file
     * @param {String} filepath the filepath of the file you are operating on
     * @param {String} fallback the audio samplerate you wish for the function to fall back on if it cannot be automatically determined
     * @returns {Object}  .
     * ```
     * {
     * hzArr: ;Array containing all sample rates,
     * amount: ;integer detailing the amount of audio streams present
     * }
     * ```
     */
    __getFrequency(filepath, fallback := "48000") {
        try probecmd := cmd.result(Format('ffprobe -v quiet -show_streams -show_format -print_format json "{1}"', filepath))
        catch {
            ;// throw
            errorLog(UnsetError("File May not contain any audio streams", -1, filepath),,, true)
        }
        mp     := JSON.parse(probecmd)
        amount := mp["streams"].length - 1
        hzArr := []
        loop amount {
            try hzArr.Push(mp["streams"][A_Index+1]["sample_rate"])
            catch
                hzArr.Push(fallback)
        }
        return {hzArr: hzArr, amount: amount}
    }

    /**
     * Extracts all audio streams from a file and saves them as `.wav`
     * @param {String} filepath the filepath of the file you wish to extract the audio from
     * @param {String} samplerate the audio samplerate you wish for the function to fall back on if it cannot be automatically determined
     */
    extractAudio(filepath, samplerate := "48000") {
        split := obj.SplitPath(filepath)
        audioStreams := this.__getFrequency(filepath, samplerate)
        baseCommand := this.__baseCommandExtract(filepath)
        command     := baseCommand A_space this.__buildExtractCommand(filepath, audioStreams.amount, audioStreams.hzArr)
        cmd.run(,,, command)
    }

    __Delete() {
        this.__finished()
    }
}