/************************************************************************
 * @description A class to enable easy file/outputdebug based logging
 * @author tomshi
 * @date 2023/07/04
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include <Classes\ptf>
#Include <Other\print>
; }

class log {

    /**
     * @param {String} dateTime any string you wish to appear before your log message. Defaults to `YYYY_MM_DD -- HH:MM:SS.MS : `
     * @param {Boolean} print whether you wish for the error to be send to the debug stream via `print()`. defaults to `true`
     * @param {String} fileLocation the location (including filename/extension) of the file you wish to log to. Defaults to `ptf.Logs "\Other Logs\YYYY_MM_DD.txt"`)
     */
    __New(dateTime?, print?, fileLocation?) {
        this.dateTime     := IsSet(dateTime)     ? dateTime     : this.dateTime
        this.print        := IsSet(print)        ? print        : this.print
        this.fileLocation := IsSet(fileLocation) ? fileLocation : this.fileLocation
    }


    dateTime := Format("{}_{}_{} -- {}:{}:{}.{} : ", A_YYYY, A_Mon, A_DD, A_Hour, A_Min, A_Sec, A_MSec)
    static dateTime {
        set => this.dateTime := value
        get => this
    }

    fileLocation := ptf.Logs "\Other Logs\" Format("{}_{}_{}.txt", A_YYYY, A_Mon, A_DD)
    static fileLocation {
        set => this.fileLocation := value
        get => this
    }

    print := true
    static print {
        set => this.print := value
        get => this
    }

    /**
     * Append an output to the desired location
     * @param {String} errorMsg the desired message
     */
    Append(errorMsg) {
        FileAppend(this.dateTime errorMsg "`n", this.fileLocation)

        if !this.print
            return
        print(this.dateTime errorMsg)
    }

    /**
     * Change the format of the date/time at the beginning of each log.
     * @param {String} newFormat the new string you wish to be appended before each log message
     */
    SetDateTime(newFormat) => this.dateTime := newFormat

    /**
     * Change the output file location of the log.
     * @param {String} location the new file location you wish to log to.
     */
    SetFileLocation(location) => this.fileLocation := location
}