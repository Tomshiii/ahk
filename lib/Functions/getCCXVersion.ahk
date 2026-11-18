/**
 * Attempts to retrieve the currently installed `ccx` extension
 * @param [extName="PremiereRemote"] name of the extension you wish to search for
 * @param [returnDir=false] determines whether to return a string of the first installed version of the extension, or an object containing the version, and the dir path of the extension
 * @returns {String | Object}
 * ```
 * `""`                             ;// Not installed
 * `4.0.0`                          ;// `returnDir` = `false`
 * `{version: String, dir: String}` ;// `returnDir` = `true`
 * ```
 */
/* getExtensionVersion(extName := "PremiereRemote", returnDir := false) {
    roots := [
        EnvGet("CommonProgramFiles") "\Adobe\UXP\Plugins\External",  ; per-machine (UPI)
    ]

    for root in roots {
        if !DirExist(root)
            continue
        loop files root "\*", "D" {
            manifest := A_LoopFilePath "\manifest.json"
            if !FileExist(manifest)
                continue
            json := FileRead(manifest, "UTF-8")
            if !InStr(A_LoopFileName, extName)
                && !RegExMatch(json, '"(?:id|name)"\s*:\s*"' RegExReplace(extName, "[\\.*?+\[\]{}|()^$]", "\$0") '"')
                continue
            if RegExMatch(A_LoopFileName, "_([^_]+)$", &v)
                ver := v[1]
            else if RegExMatch(json, '"version"\s*:\s*"([^"]+)"', &m)
                ver := m[1]
            else
                continue
            return (returnDir = false ? ver : {version: ver, dir: root})
        }
    }
    return ""
} */

/**
 * Asks UPI which version of an extension is installed.
 * @param extName name of the extension, e.g. "PremiereRemote" or "AERemote"
 * @param prog    host app passed to `/list`; derived from `extName` when omitted
 * @returns {String} first listed version, or `""` if not installed
 */
getExtensionVersion(extName := "PremiereRemote", prog := "", workDir := EnvGet("CommonProgramFiles") "\Adobe\Adobe Desktop Common\RemoteComponents\UPI\UnifiedPluginInstallerAgent") {
    static progFor := Map("PremiereRemote", "Premiere Pro", "AERemote", "After Effects")
    RegExEscape(str) => RegExReplace(str, "[\\.*?+\[\]{}|()^$]", "\$0")

    if prog = ""
        prog := progFor.Get(extName, "Premiere Pro")

    output := cmd.result('.\UnifiedPluginInstallerAgent.exe /list "' prog '"',,, workDir)
    if RegExMatch(output, "m)^\s*\w+\s+" RegExEscape(extName) "\s+(\S+)\s*$", &m)
        return m[1]
    return ""
}