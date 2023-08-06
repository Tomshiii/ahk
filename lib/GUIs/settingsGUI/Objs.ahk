#Include <Classes\Settings2>
#Include <Classes\tool>
#Include <GUIs\tomshiBasic>

allSettings := allSettings().generateAll()

class chkboxMethods  {
    __updateCheck(updateCheckGuiObj, betaGuiObj, *) {
        switch updateCheckGuiObj.Value {
            case 1: ;true
                allSettings.update_check := true
                updateCheckGuiObj.ToolTip := SettingsObjs.updateCheck.toolT.true
                if allSettings.beta_update_check = true
                    betaGuiObj.Value := 1
            case -1: ;false
                allSettings.update_check := false
                updateCheckGuiObj.ToolTip := SettingsObjs.updateCheck.toolT.false
                if allSettings.beta_update_check = true
                    betaGuiObj.Value := 1
            case 0: ;stop
                betaGuiObj.Value := 0
                allSettings.update_check := "stop"
                updateCheckGuiObj.ToolTip := SettingsObjs.updateCheck.toolT.stop
        }
    }

    __betaUpdate(updateCheckGuiObj, betaUpdateGuiObj, *) {
        switch betaUpdateGuiObj.Value {
            case 1 && (updateCheckGuiObj.Value != 0):
                betaStart := true
                allSettings.General_betaUpdateCheck := true
            default:
                betaUpdateGuiObj.Value := 0
                betaStart := false
                allSettings.General_betaUpdateCheck := false
        }
    }

    __darkMode(darkModeGuiObj, *) {
        tool.Cust("")
        allSettings.dark_mode := (darkModeGuiObj.Value = 1) ? true : false
        darkModeGuiObj.ToolTip := (darkModeGuiObj.Value = 1) ? SettingsObjs.darkMode.toolT.true : SettingsObjs.darkMode.toolT.false
        if (darkModeGuiObj.Value = 1)
            {
                tool.Cust(SettingsObjs.darkMode.toolT.true, 2000)
                goDark()
                return
            }
        ;// dark mode is false
        tool.Cust(SettingsObjs.darkMode.toolT.false, 2000)
        goDark(false, "Light")
    }
}

class SettingsObjs {
    static updateCheck := {
        state: allSettings.General_updateCheck,
        method: ObjBindMethod(chkboxMethods(), '__updateCheck'),

        toolT: {
            true: "Scripts will check for updates",
            false: "Scripts will still check for updates but will not present the user`nwith a GUI when an update is available",
            stop: "Scripts will NOT check for updates"
        }
    }

    static betaUpdateCheck := {
        state: allSettings.General_betaUpdateCheck,
        method: ObjBindMethod(chkboxMethods(), '__betaUpdate'),
    }

    static darkMode := {
        state: allSettings.General_darkMode,
        method: ObjBindMethod(chkboxMethods(), '__darkMode'),

        toolT: {
            true: "A dark theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect",
            false: "A lighter theme will be applied to certain GUI elements wherever possible.`nThese GUI elements may need to be reloaded to take effect",
            disabled: "The users OS version is too low for this feature"
        }
    }
}
