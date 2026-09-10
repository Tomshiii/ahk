/**
 * This class acts as an exceptionally basic way to return something other than `true`/`false`.
 * It should be noted this isn't an /actual/ null type; it is simply an object named null.
 *
 * As such;
 * ## ensure you are always directly comparing for null when a function returns null.
 * ```
 * ;// relying only on this is dangerous
 * ;// if func() is null ahk will just see it as truthy and will continue
 * if !func() {
 *
 * ;// better way to handle funcs that return null
 * f := func()
 * if !f || f == null
 * if f == null
 * ```
 */
class null {
    __New() {
        throw Error("null cannot be instantiated")
    }
    static ToString() => "null"
}