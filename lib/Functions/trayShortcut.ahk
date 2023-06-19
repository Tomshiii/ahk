/**
 * This function is used to insert the "Run at Startup" traymenu item
 * @param {Integer} num the position you wish to insert the traymenu item. defaults to `8`
 * @param {String} name what you wish the traymenu to be called. defaults to `Run at Startup`
 */
startupTray(num := 8, name := "Run at Startup") {
    shortcutLink := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\" A_ScriptName " - Shortcut.lnk"
    A_TrayMenu.Insert(num "&", name, trayShortcut.Bind(shortcutLink, name))
    if (FileExist(shortcutLink))
        A_TrayMenu.Check(name)
}

/**
 * This function handles what happens when the menu option is clicked
 * @param {String} shortcutLink the path link to the startup folder
 * @param {String} ctrl what the traymenu option is called. defaults to `Run at Startup`
 */
trayShortcut(shortcutLink := A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\" A_ScriptName " - Shortcut.lnk", ctrl := "Run at Startup", *) {
    togVal := (FileExist(shortcutLink)) ? true : false
    switch togVal {
        case 0:
            if FileExist(A_AppData "\Microsoft\Windows\Start Menu\Programs\Startup\PC Startup.ahk - Shortcut.lnk") {
                MsgBox(Format("
                (
                    This script may already be running at startup due to ``PC Startup.ahk``.
                    This can be removed via ``settingsGUI()`` or by removing the file manually.

                    Please check the windows startup folder if you require clarification.
                )"))
            }
            FileCreateShortcut(A_ScriptFullPath, shortcutLink)
            A_TrayMenu.Check(ctrl)
        case 1:
            if FileExist(shortcutLink)
                FileDelete(shortcutLink)
            A_TrayMenu.Uncheck(ctrl)
    }
}