/************************************************************************
 * @description a class designed to minimise the need to interact with the commandline with highly specific rclone commands I require for work tasks. This is not intented for use outside of myself, it likely will not be useful
 * @author tomshi
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Functions\base64Encode.ahk
; }

class rclone {
    static sshKey  := "C:\Users\Tom\.ssh\qnap_id"
    static sshHost := "Tom@169.254.112.150"

    ; shared bash prelude: resolve_path <relative path under ROOT> <allow_missing 0|1>
    ; sets $real to the true gdrive path (leading slash) built from names rclone returns
    static cmdResolveFn := "
    (
RC=/share/CACHEDEV1_DATA/tools/rclone/rclone
CONF=/share/CACHEDEV1_DATA/tools/rclone/rclone.conf
LOG=/share/CACHEDEV1_DATA/rclone.log
ROOT='gdrive:2. Videos/1. The Boys'
norm() { printf '%s' "$1" | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9]+/ /g; s/^ //; s/ $//'; }
resolve_path() {
  real=""; missing=0
  while IFS= read -r seg; do
    [ -z "$seg" ] && continue
    if [ "$missing" = 1 ]; then real="$real/$seg"; continue; fi
    want=$(norm "$seg")
    hit=""; count=0
    while IFS= read -r e; do
      name="${e%/}"
      [ -z "$name" ] && continue
      if [ "$name" = "$seg" ]; then hit="$name"; count=1; break; fi
      if [ "$(norm "$name")" = "$want" ]; then hit="$name"; count=$((count+1)); fi
    done <<< "$($RC lsf "$ROOT$real" --config $CONF 2>/dev/null)"
    if [ "$count" -eq 0 ] && [ "$2" = 1 ]; then
      echo "CREATING NEW '$seg' under '$ROOT$real'" >> $LOG
      missing=1; real="$real/$seg"; continue
    fi
    if [ "$count" -ne 1 ]; then
      echo "RESOLVE FAILED ($count matches) at '$seg' under '$ROOT$real'" >> $LOG
      return 1
    fi
    real="$real/$hit"
  done <<< "$(printf '%s' "$1" | tr '/' '\n')"
}
    )"

    ; case 1: NAS folder -> gdrive folder (destination may not exist yet)
    ; @@SRC@@ = full NAS source path, @@DEST@@ = gdrive path after "1. The Boys/"
    static cmdSyncDirBody := "
    (
resolve_path '@@DEST@@' 1 || exit 1
trap '' HUP
$RC copy '@@SRC@@' "$ROOT$real" --config $CONF --transfers 4 --checkers 8 --drive-chunk-size 128M --log-level INFO --log-file $LOG --bwlimit 300M --exclude '_proxy/**' --exclude '_prores/**' --exclude 'proxy/**' --exclude 'Monitor Baackup/**' --exclude 'Monitor Backup/**' --exclude 'MONITOR BACKUP/**' &
    )"

    ; case 2: gdrive file -> NAS file (source must exist)
    ; @@SRC@@ = gdrive path after "1. The Boys/", @@DEST@@ = full NAS destination path
    static cmdCopyFileBody := "
    (
resolve_path '@@SRC@@' 0 || exit 1
trap '' HUP
$RC copyto "$ROOT$real" '@@DEST@@' --config $CONF --drive-chunk-size 128M --log-level INFO --log-file $LOG --bwlimit 300M &
    )"

    static __q(s) => StrReplace(s, "'", "'\''")   ; escapes ' for use inside single quotes

    static __build(body, src, dest) {
        script := this.cmdResolveFn "`n" body
        script := StrReplace(script, "@@SRC@@", this.__q(src))
        script := StrReplace(script, "@@DEST@@", this.__q(dest))
        return script
    }

    static __formatSSH(command) {
        b64 := base64Encode(command)
        return Format('ssh -i "{1}" {2} "echo {3} | base64 -d | bash"', this.sshKey, this.sshHost, b64)
    }

    static __removeFile(fullPath) {
        if !InStr(FileExist(fullPath), "D") {
            SplitPath(fullPath,, &nFullPath)
            return nFullPath
        }
        return fullPath
    }

    static formatCommand(NAS_FullPath, gdrive_FullPath, which, altshare := "CACHEDEV1_DATA/storage") {
        gString := "1. The Boys\"
        switch which {
            case (1, "1"):
                nDir := this.__removeFile(NAS_FullPath)
                gDir := this.__removeFile(gdrive_FullPath)
                nRel := StrReplace(SubStr(nDir, 4), "\", "/")
                gRel := StrReplace(SubStr(gDir, InStr(gDir, gString) + StrLen(gString)), "\", "/")
                script := this.__build(this.cmdSyncDirBody, "/share/" altshare "/" nRel, gRel)
                return this.__formatSSH(script)
            case (2, "2"):
                gRel := StrReplace(SubStr(gdrive_FullPath, InStr(gdrive_FullPath, gString) + StrLen(gString)), "\", "/")
                nRel := StrReplace(SubStr(NAS_FullPath, 4), "\", "/")
                script := this.__build(this.cmdCopyFileBody, gRel, "/share/" altshare "/" nRel)
                return this.__formatSSH(script)
        }
    }
}