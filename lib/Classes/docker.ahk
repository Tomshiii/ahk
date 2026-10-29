/************************************************************************
 * @description a collection of commands to interact with docker
 * @author tomshi
 * @date 2026/10/30
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\cmd.ahk
; }

class docker {
    /**
     * Looks for docker.exe on PATH (and standard system locations)
     * @returns {Boolean}
     */
    static isInstalled() => (DllCall("SearchPathW", "ptr", 0, "str", "docker.exe", "ptr", 0, "uint", 0, "ptr", 0, "ptr", 0, "uint") > 0)

    /** @returns {Boolean} */
    static isRunning() => (InStr(this.__DockerGet("/_ping"), "200 OK") > 0)

    /**
     * Determines if a given container/service is running
     * @param {String} [project] the name of the project within docker
     * @param {String} [service] the name of the individual service to check for
     * @returns {boolean}
     */
    static isContainerRunning(project, service) {
        filters := '{"label":["com.docker.compose.project=' project '","com.docker.compose.service=' service '"]}'
        resp := this.__DockerGet("/containers/json?filters=" this.__UriEncode(filters))
        return (InStr(resp, '"Id"') > 0)
    }

    /**
     * Start a given docker container
     * @param {String} [project] the name of the project within docker
     * @param {String} [service] the name of the individual service to check for
     * @returns {boolean}
     */
    static startComposeService(project, service) {
        ok := true
        for id in this.__getComposeContainerIds(project, service)
            ok := (this.__DockerRequest("POST", "/containers/" id "/start") ~= "^\S+ (204|304)") && ok
        return ok
    }

    /**
     * Stop a given docker container
     * @param {String} [project] the name of the project within docker
     * @param {String} [service] the name of the individual service to check for
     * @returns {boolean}
     */
    static stopComposeService(project, service, timeoutSec := 10) {
        ok := true
        for id in this.__getComposeContainerIds(project, service)
            ok := (this.__DockerRequest("POST", "/containers/" id "/stop?t=" timeoutSec) ~= "^\S+ (204|304)") && ok
        return ok
    }

    /**
     * Restart a given docker container
     * @param {String} [project] the name of the project within docker
     * @param {String} [service] the name of the individual service to check for
     * @returns {boolean}
     */
    static restartComposeService(project, service, timeoutSec := 10) {
        ok := true
        for id in this.__getComposeContainerIds(project, service)
            ok := (this.__DockerRequest("POST", "/containers/" id "/restart?t=" timeoutSec) ~= "^\S+ 204") && ok
        return ok
    }

    /** AI generated function to interact with the docker named pipe */
    static __DockerGet(path) {
        for pipe in ["\\.\pipe\docker_engine", "\\.\pipe\dockerDesktopLinuxEngine"] {
            h := DllCall("CreateFileW", "str", pipe, "uint", 0xC0000000  ; GENERIC_READ|WRITE
                , "uint", 0, "ptr", 0, "uint", 3, "uint", 0, "ptr", 0, "ptr")  ; OPEN_EXISTING
            if (h = -1)
                continue

            req := "GET " path " HTTP/1.0`r`nHost: docker`r`n`r`n"
            buf := Buffer(StrPut(req, "UTF-8") - 1)
            StrPut(req, buf, "UTF-8")
            DllCall("WriteFile", "ptr", h, "ptr", buf, "uint", buf.Size, "uint*", &written := 0, "ptr", 0)

            resp := ""
            chunk := Buffer(65536)
            while DllCall("ReadFile", "ptr", h, "ptr", chunk, "uint", 65536, "uint*", &n := 0, "ptr", 0) && n
                resp .= StrGet(chunk, n, "UTF-8")

            DllCall("CloseHandle", "ptr", h)
            return resp
        }
        return ""
    }

    /** AI generated function to interact with the docker named pipe to make a request */
    static __dockerRequest(method, path) {
        for pipe in ["\\.\pipe\docker_engine", "\\.\pipe\dockerDesktopLinuxEngine"] {
            h := DllCall("CreateFileW", "str", pipe, "uint", 0xC0000000
                , "uint", 0, "ptr", 0, "uint", 3, "uint", 0, "ptr", 0, "ptr")
            if (h = -1)
                continue

            req := method " " path " HTTP/1.0`r`nHost: docker`r`nContent-Length: 0`r`n`r`n"
            buf := Buffer(StrPut(req, "UTF-8") - 1)
            StrPut(req, buf, "UTF-8")
            DllCall("WriteFile", "ptr", h, "ptr", buf, "uint", buf.Size, "uint*", &written := 0, "ptr", 0)

            resp := ""
            chunk := Buffer(65536)
            while DllCall("ReadFile", "ptr", h, "ptr", chunk, "uint", 65536, "uint*", &n := 0, "ptr", 0) && n
                resp .= StrGet(chunk, n, "UTF-8")

            DllCall("CloseHandle", "ptr", h)
            return resp
        }
        return ""
    }

    /** Returns array of container IDs for a compose service (all=true includes stopped ones) */
    static __getComposeContainerIds(project, service) {
        filters := '{"label":["com.docker.compose.project=' project '","com.docker.compose.service=' service '"]}'
        resp := this.__DockerRequest("GET", "/containers/json?all=true&filters=" this.__UriEncode(filters))
        ids := []
        pos := 1
        while RegExMatch(resp, '"Id":"([0-9a-f]{64})"', &m, pos) {
            ids.Push(m[1])
            pos := m.Pos + m.Len
        }
        return ids
    }

    /** AI generated function to format respose from named pipe */
    static __UriEncode(str) {
        buf := Buffer(StrPut(str, "UTF-8") - 1)
        StrPut(str, buf, "UTF-8")
        out := ""
        loop buf.Size {
            b := NumGet(buf, A_Index - 1, "UChar")
            if (b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122)
                || b = 45 || b = 46 || b = 95 || b = 126  ; - . _ ~
                out .= Chr(b)
            else
                out .= Format("%{:02X}", b)
        }
        return out
    }
}