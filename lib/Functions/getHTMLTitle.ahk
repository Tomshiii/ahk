; { \\ #Includes
#Include <Classes\errorLog>
#Include <Functions\getHTML>
#Include <Functions\isURL>
; }

/**
 * Return the title of a HTML page as a windows file.
 * @param {String} url the url you wish to retrieve the title for
 * @param {Boolean} sanitise Whether you want the returned title to be stripped of illegal filename chars.
 * @param {String} replace What you want the chars to be replaced with
 * @param {Variadic} params If you wish to specify exactly what gets replaced, fill out any remaining paramaters. If any of these variables are set, `replace` acts as the FIRST replacement - the "first" `params` replacement will be the second replacement, etc. If you do not fill enough paramaters the function will default back to the value of `replace`.
 * @returns {String/Boolean} boolean `false` on failure or the final title
 */
getHTMLTitle(url, sanitise := true, replace := "_", params*) {
    if !isURL(url)
        return false
    var := getHTML(url)
    document := ComObject("HTMLfile")
    document.write(var)
    initialMatch := document.Title
    if initialMatch == "Twitch" {
        ;// twitch simply has "Twitch" as their html title and leaves the actual title in meta information
        try {
            RegExMatch(var, "is)<meta name=`"title`" content=`"\K(.*?)/>", &sTitle)
            initialMatch := SubStr(sTitle[1], 1, (InStr(sTitle[1], " - ",, -1)-1) - StrLen(sTitle[1]))
        }
    }
    if initialMatch = "" {
        RegExMatch(var, "is)<title>\K(.*?)</title>", &sTitle)
        try {
            initialMatch := sTitle[1]
        }
        if initialMatch = "" {
            errorLog(ValueError("Couldn't determine the title", -2),, 1)
            return false
        }
    }

    replaceChars := ["&#39;", "'", "&quot;", '＂']
    finalTitle := ""
    for ind, value in replaceChars
        {
            if A_Index/2 > (replaceChars.Length/2)
                break
            if Mod(A_Index, 2) == 0
                continue
            if ind = 1
                finalTitle := StrReplace(initialMatch, value, replaceChars.Get(ind+1, "_"))
            else
                finalTitle := StrReplace(finalTitle, value, replaceChars.Get(ind+1, "_"))
        }
    if !sanitise
        return finalTitle ?? initialMatch
    if finalTitle = ""
        finalTitle := initialMatch
    finalTitle := InStr(finalTitle, " - YouTube", 1,, 1) ? StrReplace(finalTitle, " - YouTube", "", 1,, 1) : finalTitle
    params.InsertAt(1, replace)
    ;// sanitising title of invalid filename characters
    if RegExMatch(finalTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
        {
            URLTitle := finalTitle
            loop {
                if !RegExMatch(URLTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
                    break
                if A_Index > params.Length
                    params.InsertAt(A_Index, replace)
                URLTitle := RegExReplace(URLTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", params[A_Index],, 1)
            }
        }
    return URLTitle ?? finalTitle
}