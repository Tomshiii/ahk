/**
 * generate GUIDs
 * @link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=38822
 */
CreateGUID() {
    shellobj := ComObject("Scriptlet.TypeLib")
    return shellobj.GUID
}