; { \\ #Includes
#Include <Classes\Settings>
#Include <Classes\ptf>
#Include <Classes\dark>
; }

/**
 * This class is to provide a basic template for all GUIs I create to maintain a consistent theme
 *
 * @param [FontSize=11] allows you to pass in a custom default GUI font size.
 * @param [FontWeight=500] allows you to pass in a custom default GUI font weight.
 * @param [options=?] allows you to pass in all GUI options that you would normally pass to a GUI.
 * @param [title=""] allows you to pass in a title for the GUI.
 */
class tomshiBasic extends Gui {
    __New(FontSize := 11, FontWeight := 500, options?, title := "") {
        super.__new(options?, title, this)
        this.BackColor := this.LightColour
        this.SetFont("S" FontSize " W" FontWeight, "Segoe UI Variable") ;// sets the size of the font
        this.AddButton("Default W0 H0 X8 Y0", "_") ;// creates an invisible button to take focus away from the first defined ctrl
        this.UserSettings := UserPref()
        if this.UserSettings.dark_mode = true {
            dark.titleBar(this.Hwnd) ;// automatically make the titlebar darkmode if the setting is enabled
            dark.menu() ;// automatically make any menu dropdowns darkmode if the setting is enabled
            this.BackColor := "0x" this.DarkColour
        }
    }

    UserSettings := ""
    LightColour := "F0F0F0"
    DarkColour := "d4d4d4"

    /**
     * Extends the default `show()` method to automatically make all buttons dark mode if the setting is enabled
     * @param {String} params? is any normal settings you'd pass to GUI.show()
     * @param {Object} darSettings? is an object containing any custom settings you'd usually pass to `dark.allButtons()`
     */
    show(params?, darkSettings?) {
        if this.UserSettings.dark_mode = true {
            if !IsSet(darkSettings)
                darkSettings := {default: true}
            dark.allButtons(this,, darkSettings?)
        }
        super.Show(params?)
    }
}