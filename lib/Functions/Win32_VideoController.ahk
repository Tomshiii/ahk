; { \\ #Includes
#Include <Classes\Mip>
;

/**
 * returns information about the user's GPU
 * @author jNizM
 * @link https://www.autohotkey.com/board/topic/44534-way-to-retrieve-system-information/page-2
 * @returns {Object} `Manufacturer`, `Model`
 */
Win32_VideoController() {
    returnMap:= Mip()
    for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_VideoController") {
        if !returnMap.Has(objItem.AdapterCompatibility)
            returnMap.Set(objItem.AdapterCompatibility, true)
        if !returnMap.Has(objItem.Description) {
            returnMap.Set(objItem.Description, true)
        }
    }
    return returnMap
}