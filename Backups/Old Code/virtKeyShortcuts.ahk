;// this code is what originally sparked the idea for `adobeKSA.ahk`

virtKey := 2147483693
val := Format("{:X}", virtKey)
MsgBox(GetKeyName("vk" SubStr(val, -2)))