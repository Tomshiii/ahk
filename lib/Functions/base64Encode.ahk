Base64Encode(pString) {
    length := StrPut(pString, "UTF-8") - 1
    bin := Buffer(length, 0)
    StrPut(pString, bin, length, "UTF-8")

    DllCall("crypt32.dll\CryptBinaryToStringA"
        , "ptr", bin, "uint", length, "uint", 0x40000001, "ptr", 0, "uint*", &base64Length := 0)

    base64 := Buffer(base64Length, 0)
    DllCall("crypt32.dll\CryptBinaryToStringA"
        , "ptr", bin, "uint", length, "uint", 0x40000001, "ptr", base64, "uint*", &base64Length)

    return StrGet(base64, "UTF-8")
}