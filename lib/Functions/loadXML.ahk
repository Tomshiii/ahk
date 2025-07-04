/**
 * takes an xml formatted string and returns a comobject
 * @param {String} xml the `fileread` xml file
 * @returns {Object} returns a comobject
 */
loadXML(xml) {
    xmldoc := ComObject("MSXML2.DOMDocument.6.0")
    xmldoc.async := false
    xmldoc.loadXML(xml)
    return xmldoc
}