; { \\ #Includes
#Include <Functions\getHTML>
; }

/**
 * Return the title of a HTML page as a windows file
 * @param {String} url the url you wish to retrieve the title for
 * @returns {string}
 */
getHTMLTitle(url, sanitise := true) {
    var := getHTML(url)
    RegExMatch(var, "is)<title>\K(.*?)</title>", &sTitle)
    if !sanitise
        return sTitle[1]
    URLTitle := StrReplace(sTitle[1],":", "_")
    return URLTitle
}