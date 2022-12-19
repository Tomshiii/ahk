; { \\ #Includes
#Include <Functions\getHTML>
; }

/**
 * Return the title of a HTML page as a windows file
 * @param {String} url the url you wish to retrieve the title for
 * @param {Boolean} sanitise Whether you want the returned title to be stripped of illegal filename chars.
 * @param {String} replace What you want the chars to be replaced with
 * @param {Variadic} params If you wish to specify exactly what gets replaced, fill out any remaining paramaters
 * @returns {String} the final title
 */
getHTMLTitle(url, sanitise := true, replace := "_", params*) {
    var := getHTML(url)
    RegExMatch(var, "is)<title>\K(.*?)</title>", &sTitle)
    if !sanitise
        return sTitle[1]
    ;// sanitising title of invalid filename characters
    if RegExMatch(sTitle[1], "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
        {
            variable := 0
            loop {
                if A_Index = 1
                    {
                        RegExMatch(sTitle[1], "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
                        for val in match
                            URLTitle := StrReplace(sTitle[1], val, replace,,, 1)
                    }
                else if A_Index > 1
                    {
                        if !RegExMatch(URLTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
                            break
                        if (A_Index -1) > params.Length
                            params.InsertAt(variable, replace)
                        for val in match
                            {
                                URLTitle := StrReplace(URLTitle, val, params[variable],,, 1)
                            }
                    }
                variable++
            }
        }
    return URLTitle ?? sTitle[1]
}