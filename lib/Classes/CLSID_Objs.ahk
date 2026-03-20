/************************************************************************
 * @description
 * @author tomshi
 * @date 2026/05/05
 * @version 1.1.15
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Other\ObjRegisterActive.ahk
#Include Other\createGUID.ahk
#Include Classes\Mip.ahk
#Include Classes\winExt.ahk
#Include Classes\errorLog.ahk
#Include Classes\notifyExt.ahk
#Include Other\Mutex.ahk
#Include Other\Notify\Notify.ahk
#Include Functions\detect.ahk
; }

class CLSID_Objs {
    ;// this shouldn't be `static __New()` -- otherwise apps like `multi-dl.ahk` will throw simply for having it included through other libs
    static checkCoreFunc() {
        if A_ScriptName = "Core Functionality.ahk"
            return
        if !winExt.ExistRegex("Core Functionality.ahk",,,, true) {
            if this.errorWinExist() = true {
                Notify.Show(, A_ScriptName " will close as Core Functionality.ahk is not opened.", 'C:\Windows\System32\shell32.dll|icon153',,, 'dur=4 bc=0x3E0000 bdr=Red show=Fade@250 hide=Fade@250 maxW=400')
                sleep 4000
                ExitApp()
            }
            else
                throw Error("Core Functionality.ahk isn't running.", -2)
        }
    }
    static generateCLSID() => CreateGUID()
    static errorWinExist() {
        list := WinGetList(".ahk ahk_class #32770")
        found := false
        for _, v in list {
            txt := WinGetText(v)
            if !InStr(txt, "Error: Core Functionality.ahk isn't running.")
                continue
            found := true
            break
        }
        return found
    }

    static __Item := Mip(
        "prem",            "{0A2B6915-DEEE-4BF4-ACF4-F1AF9CDC5468}",
        "UserSettings",    "{AC89B835-1CD6-4CC3-AFCC-56360FD5116F}",
        "determineUIA",    "{6A7B49B5-8947-488D-ABDD-4BC7FFA60B12}",
        "KSA",             "{A6A98BC1-C523-4F2E-8CB9-839106A6C8E1}",
        "Loading",         "{DFEF77D2-D0BE-4F54-BAF8-D0B456F6D959}",
        "determineActive", "{FB43A603-D55E-4615-8558-2BF1644CD4EC}"
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
                        /* if Notify.Exist("mutexLock_" clsid)
                            try Notify.Destroy("mutexLock_" clsid) */
                        mtx.Release()
                        notifyExt.destroyDupes("mutexLock_" clsid)
                    }
                case WAIT_TIMEOUT:
                    notifyExt.showIfNotExist("mutexLock_" clsid,, 'Timeout waiting for lock on: ' objName, 'icon!', 'Speech Off',, 'dur=6 bdr=Yellow maxW=400')
                    errorLog(TimeoutError('Timeout waiting for lock on: ' objName, -2))
                    sleep 500
                    return false
                case WAIT_FAILED:
                    errorLog(TimeoutError('Failed waiting for lock on: ' objName, -2))
                    throw OSError('Failed waiting for lock on: ' objName, -2)
                    ; ExitApp()
            }
        } catch as e {
            throw e
        } finally {
            try mtx.Close()
        }
    }

    /** syntatic sugar to call `clsid_objs.load()`, clone the object, the sever the connection to the original object */
    static clone(clsid, inClass := true) {
        Critical('On')
        this.checkCoreFunc()
        try baseObj := this.load(clsid, inClass)
        catch {
            return false
        }
        clonedObj := baseObj.clone()
        baseObj := ""
        Critical('Off')
        return clonedObj
    }
}

; A_Clipboard := CLSID_Objs.generateCLSID()