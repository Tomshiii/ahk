/**
 * Checks if the passed string follows a URL pattern
 * @link https://www.autohotkey.com/boards/viewtopic.php?style=17&t=101579
 * @param {String} [url] the URL to check
 */
isURL(url) {
    if !RegExMatch(url, "^(https?://)?[\w/?=%.-]+\.[\w/&?=%.-]+$")
        return false
    return true
}