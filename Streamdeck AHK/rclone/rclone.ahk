/************************************************************************
 * @description a class designed to minimise the need to interact with the commandline with highly specific rclone commands I require for work tasks. This is not intented for use outside of myself, it likely will not be useful
 * @author tomshi
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
#Include Classes\clip.ahk
; }

class rclone {
    static sshKey  := "C:\Users\Tom\.ssh\qnap_id"
    static sshHost := "Tom@169.254.112.150"

    /**
     * @param `{1}` - NAS folder
     * @param `{2}` - gdrive folder AFTER `1. The Boys`
     */
    static cmdSyncDir := '(trap `'`' HUP; /share/CACHEDEV1_DATA/tools/rclone/rclone copy \"/share/{3}/{1}\" \"gdrive:2. Videos/1. The Boys/{2}\" --config /share/CACHEDEV1_DATA/tools/rclone/rclone.conf --transfers 4 --checkers 8 --drive-chunk-size 128M --log-level INFO --log-file /share/CACHEDEV1_DATA/rclone.log --bwlimit 300M --exclude \"_proxy/**\" --exclude \"proxy/**\" --exclude \"Monitor Baackup/**\" --exclude \"Monitor Backup/**\" --exclude \"MONITOR BACKUP/**\") &'



    /**
     * @param `{1}` gdrive folder & FILENAME
     * @param `{2}` NAS folder & FILENAME
     */
    static cmdCopyFile := '(trap `'`' HUP; /share/CACHEDEV1_DATA/tools/rclone/rclone copyto \"gdrive:2. Videos/1. The Boys/{1}\" \"/share/{3}/{2}\" --config /share/CACHEDEV1_DATA/tools/rclone/rclone.conf --drive-chunk-size 128M --log-level INFO --log-file /share/CACHEDEV1_DATA/rclone.log --bwlimit 300M) &'

    static __removeFile(fullPath) {
        if !InStr(FileExist(fullPath), "D") {
            SplitPath(fullPath,, &nFullPath)
            return nFullPath
        }
        return fullPath
    }
    static __formatSSH(command) => Format('ssh -i "{}" {} "{}"', this.sshKey, this.sshHost, command)
    /**
     * @param {String} [NAS_FullPath]
     * @param {String} [gdrive_FullPath]
     * @param {Integer} [which] `1` - From NAS to gdrive, `2` - From gdrive to NAS
     */
    static formatCommand(NAS_FullPath, gdrive_FullPath, which, altshare := "CACHEDEV1_DATA/storage") {
        gString := "1. The Boys\"
        gPath   := SubStr(gdrive_FullPath, InStr(gdrive_FullPath, gString)+StrLen(gString))
        nPath   := SubStr(NAS_FullPath, 4)
        switch which {
            case 1:
                nCommand := StrReplace(SubStr(nPath := this.__removeFile(NAS_FullPath), 4), "\", "/")
                gCommand := StrReplace(SubStr(gPath := this.__removeFile(gdrive_FullPath), InStr(gPath, gString)+StrLen(gString)), "\", "/")
                normalCommand := format(this.cmdSyncDir, nCommand, gCommand, altshare)
                return this.__formatSSH(normalCommand)
            case 2:
                normalCommand := Format(this.cmdCopyFile, StrReplace(gPath, "\", "/"), StrReplace(nPath, "\", "/"), altshare)
                return this.__formatSSH(normalCommand)
        }
    }
}