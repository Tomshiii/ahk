/************************************************************************
 * @description a class to contain often used functions to quickly and easily access common ffmpeg commands
 * @author tomshi
 * @date 2025/07/23
 * @version 1.1.6
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\tool>
#Include <Classes\cmd>
#Include <Classes\obj>
#Include <Classes\winGet>
#Include <Classes\errorLog>
#Include <Functions\useNVENC>
#Include <Other\JSON>
; }

class ffmpeg {
    doAlert := true

    /** generates a tooltip to alert the user the process has completed */
    __finished() => (this.doAlert=true) ? tool.tray({text: "ffmpeg process has finished", title: "ffmpeg process has completed!", options: 1}, 2000) : ""

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
     * @param {String} extOverride override the default extension
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
        checkPath := (SubStr(obj.dir, -1, 1) != "\") ? obj.dir "\" : ""
        if WinExist(obj.dir)
            WinActivate(obj.dir)
        else if WinExist(checkPath)
            WinActivate(checkPath)
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
     * @param {String} outputFileName? the desired output name of your file. leaving this variable blank will leave the name the same (which may fail as ffmpeg may not be able to output a file if that name is already taken)
     * @param {String} [codec="libx264"] the desired h26x encoder to use. defaults to `libx264`
     * @param {String} [preset="veryfast"] the desired h264 preset to use. defaults to `veryfast`
     * @param {String} [crf="17"] the desired crf value to use. defaults to `17`. If this parameter is set, `bitrate` must be set to false
     * @param {String} [bitrate=false] the deired bitrate value to use. Defaults to false. If this parameter is set, `crf` must be set to false
     * @param {Boolean} [useNVENC_Val=false] determines whether to use GPU encoding. If this parameter is set to `true` a few different conditions must be met; the `codec` parameter must also be set to `h26x_nvenc` where `x` is either `4` or `5`. When set to true `preset` must also be an `integer` between 12->18. The `crf` value is used in place for `-cq` instead as they use the same range and essentially achieve the same results.
     * @param {Boolean} [forceGPU=false] determines whether to attempt to use `nvenc` encoding whether or not a rudimentary internal function determines it shouldn't be possible. Using this option may cause problems if `nvenc` encoding really isn't available
     *
     * @returns `false` if the user sets `useNVENC` to true but doesn't have a nvidia gpu
     */
    reencode_h26x(videoFilePath, outputFileName?, codec := "libx264", preset := "veryfast", crf := "17", bitrate := false, useNVENC_Val := false, forceGPU := false) {
        if crf != false && bitrate != false {
            ;// throw
            errorLog(Error("CRF and Bitrate cannot be set at the same time. One parameter must be set to false"),,, 1)
            return
        }
        if (useNVENC_Val = true && !useNVENC()) && forceGPU = false
            return false
        qualParam := crf != false ? "-crf " crf : "-b:v " bitrate "k"
        if useNVENC_Val = true {
            codec := "h264_nvenc"
            qualParam := "-cq " crf
            if !IsInteger(preset) || (preset<12 || preset>18)
                preset := "17"
        }
        finalPath := obj.SplitPath(videoFilePath)
        finalFileName := IsSet(outputFileName) ? outputFileName : finalPath.NameNoExt
        ;// build command
        ;// ffmpeg -i input.mp4 -c:v libx264 -preset medium [-crf 17]/[-b:v 30000k] output.mp4
        ;// ffmpeg -i "{1}" -c:v h264_nvenc -preset 16 -cq 17 "{2}"
        ;// see all settings relating to nvenc; ffmpeg -h encoder=hevc_nvenc
        command := Format("ffmpeg -i `"{1}`" -c:v {5} -preset {3} {4} `"{2}.mp4`"", videoFilePath, finalPath.dir "\" finalFileName, preset, qualParam, codec)
        cmd.run(false, true, false, command)
    }

    /**
     * Uses ffmpeg to determine the framerate of a file
     * @param {String} filePath the directory path of the file you wish to check
     * @returns {Integer} either the framerate of the file or boolean `false` upon failure
     */
    __determineFrameRate(filePath) {
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
     * This function will return a map containing all file properties for the given stream of a file
     * @param {String} filepath the path of the file you wish to determine the channels for
     * @param {Integer} [stream=1] which stream you wish to return the properties for
     * @returns {Map} On success returns a map containing all file properties for the first `stream`
     */
    __getAudioStream(filepath, stream := 1) {
        command := Format('ffprobe -v quiet -show_streams -show_format -print_format json "{1}"', filepath)
        try probecmd := cmd.result(command)
        catch
            return false
        try {
            mp := JSON.parse(probecmd)
            return mp["streams"][stream]
        } catch
            return false
    }

    /**
     * Attempts to convert all files of the input type, to the desired type. You may notice this function flash a cmd window, that's ffmpeg determining the fps of the file it is operating on
     * @param {String} [path="A"] the path of the desired files. If no path is provided this parameter defaults to the active windows explorer window
     * @param {String} [from="mkv"] the filetype you wish to convert from
     * @param {String} [to="mp4"] the filetype you wish to convert to
     * @param {Integer} [frameRate=60] the framerate you wish for the remux to obide by if ffmpeg cannot determine it (or it isn't an integer). This is important as otherwise a `60fps` file might end up remuxing as `60.0002fps` or something like that which has performance issues within NLE's like Premiere
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
                    frameRT := (!fps := this.__determineFrameRate(A_LoopFileFullPath)) ? frameRate : fps
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
     * @param {String} [path="A"] the desired path to excecute the loop. the active directory is used by default if no path is specified
     * @param {Object} options? an object to contain all necessary encoding options. The defaults are listed below.
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
     * @param {Integer} [startval=0] the number of seconds into the file the user wishes to trim to
     * @param {Integer} durationval? the number of seconds from the start value the user wishes to trim the file. If this value is omitted (or is 0) this function will assume you want the remainder of the track and only wish to trim the start value.
     * @param {Boolean} [overwrite=false] whether the file should be overwritten
     * @param {String} [commands=""] any further commands that will be appended to the command. The default command is `ffmpeg -ss {startval} -i "{filepath}" -t {durationval} {commands} "{outputfile}"`
     * @param {Boolean} [runDir=true] define whether the path will but run after the function executes
     */
    trim(path, startval := 0, durationval?, overwrite := false, commands := "", runDir := true) {
        pathobj := obj.SplitPath(path)
        outputFile := this.__getIndex(path)
        startval := (startval = "") ? 0 : startval
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
     * This function builds the remaining extract ffmpeg command based off the amount of audio streams present within the file. The returned command ends with A_Space
     * @param {String} filepath the filepath of the file you are operating on
     * @param {Integer} count the amount of audio streams present within the file
     * @param {Array} hzArr an array containing the sample rates of all audio streams
     */
    __buildExtractCommand(filepath, count, hzArr) {
        command := ""
        loop count {
            command := command Format('-map 0:a:{1} -f wav -b:a {2} -acodec pcm_s16le "{3}"', A_Index-1, hzArr[A_Index], this.__appendOutput(filepath, A_Index)) A_Space
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
     * @param {String} [fallback="48000"] the audio samplerate you wish for the function to fall back on if it cannot be automatically determined
     * @returns {Object}
     * ```
     * audio := ffmpeg().__getFrequency(filepath)
     * audio.hzArr  ;// Array containing all sample rates,
     * audio.amount ;// integer detailing the amount of audio streams present
     * ```
     */
    __getFrequency(filepath, fallback := "48000") {
        try probecmd := cmd.result(Format('ffprobe -v quiet -show_streams -show_format -print_format json "{1}"', filepath))
        catch {
            ;// throw
            errorLog(UnsetError("File May not contain any audio streams", -1, filepath),,, true)
        }
        try mp := JSON.parse(probecmd)
        catch {
            ;// throw
            errorLog(Error("Parsing JSON Data Failed"),,, true)
        }
        amount := 0
        hzArr := []
        loop mp["streams"].length {
            if mp["streams"][A_Index]["codec_type"] != "audio"
                continue
            amount++
            try hzArr.Push(mp["streams"][A_Index]["sample_rate"])
            catch
                hzArr.Push(fallback)
        }
        return {hzArr: hzArr, amount: amount}
    }

    /**
     * Extracts all audio streams from a file and saves them as `.wav`
     * @param {String} filepath the filepath of the file you wish to extract the audio from
     * @param {String} [samplerate="48000"] the audio samplerate you wish for the function to fall back on if it cannot be automatically determined
     */
    extractAudio(filepath, samplerate := "48000") {
        split := obj.SplitPath(filepath)
        audioStreams := this.__getFrequency(filepath, samplerate)
        baseCommand := this.__baseCommandExtract(filepath)
        command     := baseCommand A_space this.__buildExtractCommand(filepath, audioStreams.amount, audioStreams.hzArr)
        cmd.run(,,, command)
    }


    ;// one day I should really combine all of the adjustGain functions
    ;// I just can't be bothered for now
    /**
     * adjusts the gain of the selected file by the desired decibel amount
     * @param {String} filepath the filepath of the file you wish to extract the audio from
     * @param {String} dbVal the decibel value you wish to adjust the file by
     * @param {Boolean} [overwrite=false] whether the file should be overwritten
     */
    adjustGain_db(filepath, dbVal, overwrite := false) {
        if dbVal = 0 || dbVal = "0"
            return
        outputFile := this.__getIndex(filepath)
        command := Format('ffmpeg -i "{1}" -filter:a "volume={2}dB" "{3}"', filepath, dbVal, outputFile)
        cmd.run(,,, command)
        if overwrite {
            FileDelete(filepath)
            FileMove(outputFile, filepath)
        }
    }

    /**
     * Adjusts the gain of the selected file using `loudnorm` loudness normalisation
     * @param {String} filepath the filepath of the file you wish to extract the audio from
     * @param {String} [IL="-5"] integrated loudness target. Range is `-70.0` - `-5.0`. Default value is `-5`
     * @param {String} [TPL="-2"] maximum true peak. Range is `-9.0` - `+0.0`. Default value is `-2.0`
     * @param {String} [LRT="7"] loudness range target. Range is `1.0` - `50.0`. Default value is `7.0`
     * @param {Boolean} [overwrite=false] whether the file should be overwritten
     */
    adjustGain_loudnorm(filepath, IL := "-5", TPL := "-2", LRT := "7", overwrite := false) {
        outputFile := this.__getIndex(filepath)
        passOne := cmd.result(Format('ffmpeg -i "{}" -af "loudnorm=print_format=json" -f null -', filepath))
        RegExMatch(passOne, "\{([^}]*)\}", &passOne)
        passOneResult := JSON.parse(passOne[])
        command := Format('ffmpeg -i "{1}" -af "loudnorm=I={2}:TP={3}:LRA={4}:measured_I={5}:measured_TP={6}:measured_LRA={7}:measured_thresh={8}:offset={9}:linear=true:print_format=none" "{10}"', filepath, IL, TPL, LRT, passOneResult['input_i'], passOneResult['input_tp'], passOneResult['input_lra'], passOneResult['input_thresh'], passOneResult['target_offset'], outputFile)
        cmd.run(,,, command)
        if overwrite {
            FileDelete(filepath)
            FileMove(outputFile, filepath)
        }
    }

    /**
     * Adjusts the gain of the selected file using `dynAud` loudness normalisation
     * @param {String} filepath the filepath of the file you wish to extract the audio from
     * @param {Boolean} [overwrite=false] whether the file should be overwritten
     */
    adjustGain_dynAud(filepath, overwrite := false) {
        outputFile := this.__getIndex(filepath)
        command := Format('ffmpeg -i "{1}" -filter:a "dynaudnorm" "{2}', filepath, outputFile)
        cmd.run(,,, command)
        if overwrite {
            FileDelete(filepath)
            FileMove(outputFile, filepath)
        }
    }

    /**
     * determines if the given file is a video file or not
     * @param {String} path the full filepath of the file you wish to check
     */
    isVideo(path) {
        chkVid := cmd.result(Format('ffprobe -v error -select_streams v -show_entries stream=codec_type -of csv=p=0 "{1}"', path))
        if chkVid != "video"
            return false
        chkDur := cmd.result(Format('ffprobe -v error -select_streams v -show_entries stream=nb_frames,duration -of default=noprint_wrappers=1 "{1}"', path))
        chkResponse := StrSplit(chkDur, ["=", "`n"], '`r')
        response := Mip()
        for i, v in chkResponse {
            if Mod(i, 2) = 0
                continue
            response.Set(v, chkResponse[i+1])
        }
        duration := response.get("duration")
        nbframes := response.get("nb_frames")
        if duration = "N/A" || duration = "0" || duration = 0 || nbframes = "N/A" || nbframes < 1
            return false
        return true
    }

    __Delete() {
        this.__finished()
    }
}