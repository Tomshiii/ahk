Base64Decode(pString) {
    DllCall("crypt32.dll\CryptStringToBinaryA"
        , "astr", pString, "uint", 0, "uint", 0x1
        , "ptr", 0, "uint*", &outLength := 0, "ptr", 0, "ptr", 0)
    bin := Buffer(outLength + 1, 0)
    DllCall("crypt32.dll\CryptStringToBinaryA"
        , "astr", pString, "uint", 0, "uint", 0x1
        , "ptr", bin, "uint*", &outLength, "ptr", 0, "ptr", 0)

    return StrGet(bin, "UTF-8")
}