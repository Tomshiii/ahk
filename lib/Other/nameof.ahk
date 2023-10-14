/**
 * Return the name of the variable passed into it
 * @param {VarRef} v the variable you wish to determine the name of
 * @author thqby
 * @link https://github.com/thqby/ahk2_lib/blob/master/nameof.ahk
 */
nameof(&v) => StrGet(NumGet(ObjPtr(&v) + 8 + 6 * A_PtrSize, 'ptr'), 'utf-16')