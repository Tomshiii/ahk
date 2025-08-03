/**
 * Returns a fully qualified path
 * @link https://www.autohotkey.com/boards/viewtopic.php?t=120582&p=535232
 * @author SKAN
 * @param {String} path the path to your desired file/path
 * @returns {String} the path
 */
pathU(path) {
    OutFile := Format("{:260}", "")
    DllCall("Kernel32\GetFullPathNameW", "str", path, "uint",260, "str", OutFile, "ptr", 0)
    ; DllCall("Shell32\PathYetAnotherMakeUniqueName", "str", OutFile, "str", OutFile, "ptr", 0, "ptr", 0)
    return OutFile
}