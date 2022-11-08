# <> Release 2.7 - Class Variables
`class ptf {` *(point to file)*
- Replace `ImageSearch` `global variables` with class path variables
- Add as many directory locations as possible as class variables
- Add as many file locations as possible as a `Map()`; `files`

To call a dir;
```autohotkey
ptf.VariableName
eg. ptf.ImgSearch ; links to `A_WorkingDir "\ImageSearch"`
```
To call a file;
```autohotkey
ptf.files["key name"]
eg. ptf.files["settings"] ; links to `A_MyDocuments "\tomshi\settings.ini"`
```

`class browser {`
- Replace all references to browser wintitles & classes with Map variables

To call a browser winTitle
```autohotkey
browser.winTitle["browsername"]
eg. browser.winTitle["firefox"] ; calls `ahk_exe firefox.exe`
```

To call a browser class
```autohotkey
browser.class["browsername"]
eg. browser.class["firefox"] ; calls `ahk_class MozillaWindowClass`
```

## > My Scripts
- `^AppsKey:: ;ahksearchHotkey;` will now attempt to check the tab the user opened to see if an error page opened instead.
- Added `#F12:: ;panicExitHotkey;` to run `reload_reset_exit("exit")`
- Added `SC03A & F5:: refreshWinHotkey` to refresh the current active window.

`#c:: ;centreHotkey;` 
- Will now ensure the `monitor` object is actually set before continuing to stop errors
- Fixed bug where if the window was overlapping between a vertical and a horizontal monitor, it would error and fail to center the window

## > Functions
- `reload_Reset()` changed to `reload_reset_exit()` and can now close all active ahk scripts
- `tomshiBasic()` can now pass in font size/weight settings
- `hotkeysGUI()` now uses objects, maps & Arrays to define its values
- `updateChecker()` will now correctly stop itself checking for an update when the user has selected that as their setting
- `settingsGUI()` can now adjust the `Year` version of `After Effects & Premiere Pro` these scripts look for

`activeScripts()`
- Fixed being unable to relaunched if closed with `x` windows button
- Checkboxes, images, and `OnEvents` all generated automatically via a loop instead of manually assigning variables

`refreshWin()`
- Can now determine the filepath of `notepad` & `explorer.exe` windows if the user passes `"A"` to both parameters of the function
    - Added `CapsLock & F5:: ;refreshWinHotkey;` to do that
- Now has fallback code if the window fails to close/reopen & will no longer hang

## > Other Changes
- Removed a lot of lingering `location` variables from `Streamdeck AHK` scripts
- Removed reduntant version tracking of some scripts

`checklist.ahk`
- Can now better handle more than the default amount of checkboxes
- Changed `msgboxName()` to `change_msgButton()` to stop incorrect autocomplete in VSCode
- `About` & `Hours Worked` GUI now follow dark mode settings
- Removed duplicate dark mode functions from `menubar.ahk`
- Will now better handle generating more than 16 checkboxes
- Will now better handle numbers larger than 99h
    - Now has a maximum of `999.999` hours
- Fixed bug causing error on close of window

> `Menu Bar`
- Can now add checkboxes through the `File Menu`
- Can now open the Project folder through the `File Menu`