/**
 * This function turns a literal string "true" into 1
 * else returns 0
 * This is to turn ini values into proper boolean values
 * @param {String} var
 * @returns {Boolean}
 */
trueOrfalse(var)
{
    if !(var is String) || var != "true"
        return 0
    return 1
}