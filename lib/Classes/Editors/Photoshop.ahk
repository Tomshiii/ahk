/************************************************************************
 * @description A library of useful Photoshop functions to speed up common tasks
 * Last tested in the version of Photoshop listed below
 * @psVer 27.1
 * @author tomshi
 * @date 2026/09/25
 * @version 1.3.7
 ***********************************************************************/

; { \\ #Includes
#Include "%A_Appdata%\tomshi\lib"
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\block.ahk
#Include Classes\coord.ahk
#Include Classes\ptf.ahk
#Include Classes\tool.ahk
#Include Classes\keys.ahk
#Include Classes\errorLog.ahk
#Include Classes\notifyExt.ahk
#Include Other\UIA\UIA.ahk
#Include Other\Notify\Notify.ahk
; }

class PS {

    static exeTitle := Editors.Photoshop.winTitle
    static winTitle := this.exeTitle
    static class := Editors.Photoshop.class
    static path := ptf["Photoshop"]

    /**
     * A function to warp to one of a photos values within Photoshop (scale , x/y, rotation) click and hold it so the user can drag to increase/decrease.
     * @param {String} image is the png name of the image that imagesearch will use
     */
    static Prop(image)
    {
        coord.s()
        MouseGetPos(&xpos, &ypos)
        coord.w()
        block.On()
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "text2.png") ;checks to see if you're typing
            SendInput("^{Enter}")
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "text.png") ;checks to see if you're in the text tool
            SendInput(KSA.ps.selectiontool) ;if you are, it'll press v to go to the selection tool
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "InTransform.png") && !ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " ptf.Photoshop image) ;checks to see if you're already in the free transform window
            {
                block.Off()
                errorLog(Error("Was unable to find the value the user wished to adjust"),, 1)
                keys.allWait()
                return
            }
        else
            {
                SendInput(KSA.ps.freeTransform) ;if you aren't in the free transform it'll simply press your hotkey to get you into it. check the ini file to adjust this hotkey
                tool.Cust("we must wait for photoshop`nbecause it's slow as hell")
                sleep 300 ;photoshop is slow
                if !ImageSearch(&x, &y, 111, 30, 744, 64, "*5 " ptf.Photoshop image)
                    {
                        MouseMove(xpos, ypos)
                        block.Off()
                        errorLog(Error("Was unable to find the value the user wished to adjust"),, 1)
                        keys.allWait()
                        return
                    }
            }
        MouseMove(x, y) ;moves to the position variable
        sleep 100 ;this sleep is necessary for the "tap" functionality below (in the 'else') to work
        SendInput("{Click Down}")
        if !GetKeyState(A_ThisHotkey, "P") ;since we're in photoshop here, we'll simply make the "tap" functionality have ahk hit enter twice so it exits out of the free transform
            {
                Click("{Click Up}")
                MouseMove(xpos, ypos)
                SendInput("{Esc}")
                block.Off()
                return
            }
        block.Off()
        keys.allWait()
        SendInput("{Click Up}")
        MouseMove(xpos, ypos)
    }

    /**
     * When you try and save a copy of something in photoshop, it defaults to psd, this is a function to instantly pick the actual filetype you want.
     *
     * ### This function *requires* UIA
     * @param {String} filetype is the name of the ext of the filetype you wish to set your file to. eg. `png`/`jpg`. Accepts;
     * ```
- "png"
- "jpg", "jpeg"
- "psd"
- "psb"
- "avif"
- "bmp"
- "dicom", "dcm"
- "eps"
- "gif"
- "iff"
- "jpg 2000", "jpeg 2000"
- "jpg stereo", "jpeg stereo"
- "jpg xl", "jpeg xl"
- "mpo"
- "pcx"
- "pdf"
- "raw"
- "pixar"
- "portable bitmap", "pbm"
- "scitex"
- "substance 3d", "substance3d"
- "targa", "tga"
- "tiff", "tif"
- "webp"
- "dcs 1.0", "dcs1", "Photoshop DCS 1.0"
- "dcs 2.0", "dcs2", "Photoshop DCS 2.0"
     * ```
     */
    static Type(filetype)
    {
        title := "Save a Copy" A_Space "ahk_class #32770 ahk_exe Photoshop.exe"
        if !WinExist(title)
            return false
        AdobeEl := UIA.ElementFromHandle(title,, false)
        fileComboBox := {Name: "Save as type:", Type:50003, AutomationId: "FileTypeControlHost", ClassName: "AppControlHost"}
        try {
            switch filetype, false {
                case "png": __doSwap(AdobeEl, "PNG (*.PNG;*.PNG)")
                case "jpg", "jpeg": __doSwap(AdobeEl, "JPEG (*.JPG;*.JPEG;*.JPE)")
                case "psd": __doSwap(AdobeEl, "Photoshop (*.PSD;*.PDD;*.PSDT)")
                case "psb": __doSwap(AdobeEl, "Large Document Format (*.PSB)")
                case "avif": __doSwap(AdobeEl, "AVIF (*.AVIF)")
                case "bmp": __doSwap(AdobeEl, "BMP (*.BMP;*.RLE;*.DIB)")
                case "dicom", "dcm": __doSwap(AdobeEl, "Dicom (*.DCM;*.DC3;*.DIC)")
                case "eps": __doSwap(AdobeEl, "Photoshop EPS (*.EPS)")
                case "gif": __doSwap(AdobeEl, "GIF (*.GIF)")
                case "iff": __doSwap(AdobeEl, "IFF Format (*.IFF;*.TDI)")
                case "jpg 2000", "jpeg 2000": __doSwap(AdobeEl, "JPEG 2000 (*.JPF;*.JPX;*.JP2;*.J2C;*.J2K;*.JPC)")
                case "jpg stereo", "jpeg stereo": __doSwap(AdobeEl, "JPEG Stereo (*.JPS)")
                case "jpg xl", "jpeg xl": __doSwap(AdobeEl, "JPEG XL (*.JXL)")
                case "mpo": __doSwap(AdobeEl, "Multi-Picture Format (*.MPO)")
                case "pcx": __doSwap(AdobeEl, "PCX (*.PCX)")
                case "pdf": __doSwap(AdobeEl, "Photoshop PDF (*.PDF;*.PDP)")
                case "raw": __doSwap(AdobeEl, "Photoshop Raw (*.RAW)")
                case "pixar": __doSwap(AdobeEl, "Pixar (*.PXR)")
                case "portable bitmap", "pbm": __doSwap(AdobeEl, "Portable Bit Map (*.PBM;*.PGM;*.PPM;*.PNM;*.PFM;*.PAM)")
                case "scitex": __doSwap(AdobeEl, "Scitex CT (*.SCT)")
                case "substance 3d", "substance3d": __doSwap(AdobeEl, "Substance 3D Viewer (*.ASD;*.GLB;*.GLTF;*.USD;*.USDA;*.USDC;*.USDZ;*.FBX;*.OBJ;*.PLY;*.3MF;*.SAT;*.3DS;*.DWF;*.DWFX;*.IPT;*.EXP;*.CGR;*.DAE;*.PRT;*.IGS;*.IGES;*.X_B;*.X_T;*.PRC;*.RFA;*.3DM;*.PAR;*.STL;*.STP;*.STEP;*.U3D;*.WRL;*.VRML)")
                case "targa", "tga": __doSwap(AdobeEl, "Targa (*.TGA;*.VDA;*.ICB;*.VST)")
                case "tiff", "tif": __doSwap(AdobeEl, "TIFF (*.TIF;*.TIFF)")
                case "webp": __doSwap(AdobeEl, "WebP (*.WEBP)")
                case "dcs 1.0", "dcs1", "Photoshop DCS 1.0": __doSwap(AdobeEl, "Photoshop DCS 1.0 (*.EPS)")
                case "dcs 2.0", "dcs2", "Photoshop DCS 2.0": __doSwap(AdobeEl, "Photoshop DCS 2.0 (*.EPS)")
            }
        } catch {
            notifyExt.showIfNotExist("psFailedFileType",, 'Failed to set the correct filetype. Try again later.', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Balloon',, 'theme=Dark bdr=Red maxW=400')
            return false
        }

        __doSwap(el, value) {
            cBox := el.FindElement(fileComboBox)
            if cBox.value = value {
                notifyExt.showIfNotExist("psSameFileType",, 'Filetype already selected.', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Balloon',, 'theme=Dark maxW=400')
                return
            }
            el.WaitElement(fileComboBox, 1500).Expand()
            el.WaitElement({Type: 50007, Name: value}, 1500).Select()
            el.WaitElement({Name:"File name:", Type:50004}, 1000).SetFocus()
        }
    }
}