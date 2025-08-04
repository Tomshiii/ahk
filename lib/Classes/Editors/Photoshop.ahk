/************************************************************************
 * @description A library of useful Photoshop functions to speed up common tasks
 * Last tested in the version of Photoshop listed below
 * @psVer 26.9
 * @author tomshi
 * @date 2025/08/04
 * @version 1.2.2
 ***********************************************************************/

; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\block>
#Include <Classes\coord>
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\keys>
#Include <Classes\errorLog>
#Include <Other\UIA\UIA>
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
            SendInput(KSA.selectiontool) ;if you are, it'll press v to go to the selection tool
        if ImageSearch(&xdec, &ydec, 60, 30, 744, 64, "*5 " ptf.Photoshop "InTransform.png") && !ImageSearch(&x, &y, 60, 30, 744, 64, "*5 " ptf.Photoshop image) ;checks to see if you're already in the free transform window
            {
                block.Off()
                errorLog(Error("Was unable to find the value the user wished to adjust"),, 1)
                keys.allWait()
                return
            }
        else
            {
                SendInput(KSA.freeTransform) ;if you aren't in the free transform it'll simply press your hotkey to get you into it. check the ini file to adjust this hotkey
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
     * @param {String} filetype is the name of the ext of the filetype you wish to set your file to. eg. `png`/`jpg`
     */
    static Type(filetype)
    {
        if !WinExist("Save a Copy" A_Space "ahk_class #32770")
            return false
        AdobeEl := UIA.ElementFromHandle("Save a Copy" A_Space "ahk_class #32770",, false)
        coord.w()
        sleep 200 ;photoshop is slow as hell, if you notice it missing the png drop down you may need to increase this delay
        fileComboBox := {Type: "50003 (ComboBox)", Name: "Save as type:", LocalizedType: "combo box", AutomationId: "FileTypeControlHost", ClassName: "AppControlHost"}
        try {
            switch filetype {
                case "png": __doSwap(AdobeEl, "PNG (*.PNG;*.PNG)")
                case "jpg", "jpeg": __doSwap(AdobeEl, "JPEG (*.JPG;*.JPEG;*.JPE)")
            }
        } catch {
            Notify.Show(, 'Failed to set the correct filetype. Try again later.', 'C:\Windows\System32\imageres.dll|icon94', 'Windows Balloon',, 'theme=Dark bdr=Red maxW=400')
            return false
        }

        __doSwap(el, value) {
            el.WaitElement(fileComboBox, 1500).Expand()
            el.WaitElement({Type: '50007 (ListItem)', Name: value, LocalizedType: "list item"}, 1500).ControlClick()
        }
    }
}
