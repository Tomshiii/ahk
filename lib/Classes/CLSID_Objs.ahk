/************************************************************************
 * @description
 * @author tomshi
 * @date 2026/03/03
 * @version 1.1.4
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Other\ObjRegisterActive.ahk
#Include Other\createGUID.ahk
#Include Classes\Mip.ahk
#Include Classes\winExt.ahk
#Include Classes\errorLog.ahk
#Include Other\Mutex.ahk
#Include Other\Notify\Notify.ahk
#Include Functions\detect.ahk
#Include Functions\notifyIfNotExist.ahk
; }

class CLSID_Objs {
    ;// this shouldn't be `static __New()` -- otherwise apps like `multi-dl.ahk` will throw simply for having it included through other libs
    static checkCoreFunc() {
        if A_ScriptName = "Core Functionality.ahk"
            return
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true) {
            throw Error("Core Functionality.ahk isn't running.", -2)
        }
    }
    static generateCLSID() => CreateGUID()

    static __Item := Mip(
        "prem",            "{0A2B6915-DEEE-4BF4-ACF4-F1AF9CDC5468}",
        "uiaCheckRunning", "{DCEE88EC-9327-44CF-9D2A-5BC47C624E0E}",
        "UserSettings",    "{AC89B835-1CD6-4CC3-AFCC-56360FD5116F}",
        "premUIA_Values",  "{6A7B49B5-8947-488D-ABDD-4BC7FFA60B12}",
        "Loading",         "{DFEF77D2-D0BE-4F54-BAF8-D0B456F6D959}"
    )

    /** a quick and dirty function to wait for `Core Functionality.ahk` to finish loading */
    static waitCoreFuncs(waitSec := 2) {
        delay := 16
        loop Round(((waitSec*1000)/delay)) {
            try loading := this.load("Loading")
            catch {
                sleep delay
                continue
            }
            if loading.isLoading = true
                continue
            return loading
        }
        return false
    }

    /**
     * Safely load an object with mutex locking
     * @param {String} [clsid] the clsid of the desired object. if `inClass` is set to `false` this param must be the entire clsid string (including `{`/`}`). ie, `"{0A2B6915-DEEE-4BF4-ACF4-F1AF9CDC5468}"`
     * @param {Boolean} [inClass=true] determine whether to use a known clsid value from an internal map
     * @param {Integer} timeout milliseconds to wait for lock (default 5000)
     */
    static load(clsid, inClass := true, timeout := 5000) {
        this.checkCoreFunc()
        objName := inClass ? clsid : "custom"
        mtx := Mutex({Name: "Global\CoreFunc_" objName})

        try {
            result := mtx.Wait(timeout)
            switch result {
                case WAIT_OBJECT_0, WAIT_ABANDONED:
                    try {
                        return ComObjActive(((inClass = true) ? CLSID_Objs[clsid] : clsid))
                    } finally {
                        mtx.Release()
                    }
                case WAIT_TIMEOUT:
                    notifyIfNotExist("mutexLock",, 'Timeout waiting for lock on: ' objName, 'icon!', 'Speech Off',, 'dur=6 bdr=Yellow maxW=400')
                    errorLog(TimeoutError('Timeout waiting for lock on: ' objName))
                    return false
                case WAIT_FAILED:
                    throw OSError()
            }
        } finally {
            mtx.Close()
        }
    }

    /** syntatic sugar to call `clsid_objs.load()`, clone the object, the sever the connection to the original object */
    static clone(clsid, inClass := true) {
        this.checkCoreFunc()
        baseObj := this.load(clsid, inClass)
        clonedObj := baseObj.clone()
        baseObj := ""
        return clonedObj
    }
}