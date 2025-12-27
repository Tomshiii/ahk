/************************************************************************
 * @description
 * @author tomshi
 * @date 2025/12/27
 * @version 1.0.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Other\ObjRegisterActive.ahk
#Include Other\createGUID.ahk
#Include Classes\Mip.ahk
#Include Functions\detect.ahk
; }

class CLSID_Objs {
    static generateCLSID() => CreateGUID()

    static __Item := Mip(
        "prem",            "{0A2B6915-DEEE-4BF4-ACF4-F1AF9CDC5468}",
        "uiaCheckRunning", "{DCEE88EC-9327-44CF-9D2A-5BC47C624E0E}",
        "UserSettings",    "{AC89B835-1CD6-4CC3-AFCC-56360FD5116F}",
        "premUIA",         "{6A7B49B5-8947-488D-ABDD-4BC7FFA60B12}"
        ; "ptf",             "{115D24DB-2C25-4FD4-9D76-9B95B43BF9FB}"
    )

    static load(clsid, inClass := true) {
        return ComObjActive(((inClass = true) ? CLSID_Objs[clsid] : clsid))
    }
}