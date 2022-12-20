; { \\ #Includes
#Include <Functions\getHTML>
; }

/**
 * Return the title of a HTML page as a windows file.
 * @param {String} url the url you wish to retrieve the title for
 * @param {Boolean} sanitise Whether you want the returned title to be stripped of illegal filename chars.
 * @param {String} replace What you want the chars to be replaced with
 * @param {Variadic} params If you wish to specify exactly what gets replaced, fill out any remaining paramaters. If any of these variables are set, `replace` acts as the FIRST replacement - the "first" `params` replacement will be the second replacement, etc. If you do not fill enough paramaters the function will default back to the value of `replace`.
 * @returns {String} the final title
 */
getHTMLTitle(url, sanitise := true, replace := "_", params*) {
    ;// checking to ensure a url was passed - found here: https://www.autohotkey.com/boards/viewtopic.php?style=17&t=101579
    if !RegExMatch(url, "^(https?://)?[\w/?=%.-]+\.[\w/&?=%.-]+$")
        return false
    var := getHTML(url)
    RegExMatch(var, "is)<title>\K(.*?)</title>", &sTitle)
    if !sanitise
        return sTitle[1]
    params.InsertAt(1, replace)
    ;// sanitising title of invalid filename characters
    if RegExMatch(sTitle[1], "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
        {
            URLTitle := sTitle[1]
            loop {
                if !RegExMatch(URLTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", &match)
                    break
                if A_Index > params.Length
                    params.InsertAt(A_Index, replace)
                URLTitle := RegExReplace(URLTitle, "\\|\/|:|\*|\?|\`"|<|>|\|", params[A_Index],, 1)
            }
        }
    return URLTitle ?? sTitle[1]
}