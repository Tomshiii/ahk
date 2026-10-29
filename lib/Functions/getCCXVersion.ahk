; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }
getExtensionVersion(extName := "PremiereRemote") {
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
            if RegExMatch(json, '"version"\s*:\s*"([^"]+)"', &m)
                return m[1]
        }
    }
    return ""
}

/**
Original version, required elevation or would stall for minutes

getExtensionVersion(workDir := A_ProgramFiles "\Common Files\Adobe\Adobe Desktop Common\RemoteComponents\UPI\UnifiedPluginInstallerAgent", extName := "PremiereRemote") {
	RegExEscape(str) => RegExReplace(str, "[\\.*?+\[\]{}|()^$]", "\$0")
    output := cmd.result('.\UnifiedPluginInstallerAgent.exe /list "Premiere Pro"',,, workDir)

    pattern := "m)^\s*\w+\s+" . RegExEscape(extName) . "\s+(\S+)\s*$"
    if RegExMatch(output, pattern, &m)
        return m[1]
    return ""
}