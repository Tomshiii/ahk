/**
 * Checks the current version value for an `alpha`, `beta`, or `pre` tag and ensures it's formatted correctly so `VerCompare` will work as expected
 */
formatPreReleaseTag(value) {
    workingVal := value
    switch {
        case InStr(workingVal, "beta"):  workingVal := StrReplace(workingVal, "beta", "-b.")
        case InStr(workingVal, "alpha"): workingVal := StrReplace(workingVal, "alpha", "-a.")
        case InStr(workingVal, "pre"):   workingVal := StrReplace(workingVal, "pre", "-p.")
    }
    return workingVal
}