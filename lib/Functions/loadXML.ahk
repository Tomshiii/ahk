/**
 * takes an xml formatted string and returns a comobject
 * @param {String} xml the `fileread` xml file
 * @returns {Object} returns a comobject
 */
loadXML(xml) {
    try {
        xmldoc := ComObject("MSXML2.DOMDocument.6.0")
        xmldoc.async := false
        xmldoc.loadXML(xml)
        return xmldoc
    } catch {
        errorLog(TargetError("Failed to read xml file. File may be busy or damaged."))
        return false
    }
}