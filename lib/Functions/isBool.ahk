isBool(check) {
    if (!IsInteger(check) && Type(check) != "string") || (check != 1 && check != 0) && (check != "true" && check != "false")
        return false
    return true
}