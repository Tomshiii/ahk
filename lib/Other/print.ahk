; { \\ #Includes
#Include <Other\JSON>
; }

/**
 * Prints to the debug window.
 * This function is from thqby but has been slightly modified. It can be found:
 *
 * https://github.com/thqby/ahk2_lib/blob/master/print.ahk
 *
 * And requires:
 *
 * https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk
 * @param {Map/Array/Object/String} i is what you wish to be printed to the debug window
 */
print(i) {
    switch (o := '', Type(i)) {
    case 'Map', 'Array', 'Object':
        o := JSON.stringify(i)
    default:
        try o := String(i)
    }
	try FileAppend(o "`n", "*", "utf-8")
}