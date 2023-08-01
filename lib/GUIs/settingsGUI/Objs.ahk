#Include <Classes\Settings2>
#Include <GUIs\tomshiBasic>

allSettings := UserSettings().generateAll()

class chkboxMethods  {
    __updateCheck(*) {
        MsgBox()
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
}
