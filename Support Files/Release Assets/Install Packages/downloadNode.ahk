downloadNode(dlDest) {
    ; Get latest LTS version string
    version := ""
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", "https://nodejs.org/dist/index.json", false)
    whr.Send()
    ; Parse out first LTS version - find "lts" that isn't false
    json := whr.ResponseText
    ; crude but effective extraction
    RegExMatch(json, '"version":"(v[\d.]+)"[^}]+"lts":"', &m)
    version := m[1]

    url := "https://nodejs.org/dist/" . version . "/node-" . version . "-x64.msi"
    dest := dlDest
    Download(url, dest)
}