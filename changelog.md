# <> Release 2.7.x -
- All `lib`/`function` files now get included from the user library. This is accomplished by creating a `SymLink` in `A_MyDocuments \AutoHotkey\` that links back to `..\lib`. This SymLink is created either during the release install process or by the user running `..\Support Files\Release Assets\CreateSymLink.ahk`
- `ptf.files[]` changed to instead invoke the `__Item` meta function to simply become; `ptf[]`
- All files now contain their required `#Includes` instead of using one script to include everything
    - This helps make it clear what scripts require what

### New Classes;

`VSCode {`
- All VSCode functions now a class
- VSCode class separated out into it's own file `..\lib\Apps\VSCode.ahk`

`Discord {`
- All Discord functions now a class
- Discord class separated out into it's own file `..\lib\Apps\Discord.ahk`

`switchTo {`
- All `switchToX()` functions now a class

`Prem {`, `AE {`, `PS {`, `Resolve {`
- All Editor functions turned into classes
- Editor lib files moved from `..\lib\Functions\` to `..\lib\Functions\Editors\`

## > Functions
- Add `vscode` to `class browser`
- Add class `Editors` to contain `winTitle` and `class` information of `NLEs`
- Moved `getScriptRelease()` from `Startup.ahk` => `General.ahk`
- Moved `moveWin()`, `moveTab()` & `moveXorY()` from `Windows.ahk` => `Move.ahk` under class `Move {`

`settingsGUI()`
- Fixed not all options showing
- Fixed `autosave save rate` editbox changing `adobe fs check`
- Fixed scripts not reloading when their respective setting is changed
- Opening the `settings.ini` will now move the notepad window right next to `settingsGUI()`

## > My Scripts
- `^SPACE:: ;alwaysontopHotkey;` will now attempt to produce a tooltip to tell the user which state the window is being changed too

## > autosave
- Refactored entire script
    - No longer needs to activate the window
    - Uses `ControlSend()` if window isn't active

## > Other Changes
- Fix double key name in `KSA.ini`
- Changed `convert2x.ahk` scripts to function `convert2()`
    - Will now run `A_ComSpec` instead of calling cmd from the explorer window as doing so in win11 opens the new terminal which is incredibly difficult to detect with ahk
- Moved `HotkeyReplacer.ahk` & `Getting Started_readme.md` => `..\Support Files\Release Assets\`
    - Added `releaseGUI.ahk` to provide the user a few options after running the latest release `.exe`
- Moved a few old scripts to => `..\Backups\Old Scripts\`
- Moved `newWin()` from `QMK.ahk` => `Windows.ahk 'class switchTo {'`
- Fixed `Start new project.ahk` running `checklist.ahk`

`right click premiere.ahk`
- Fixed bug that caused `XButton1/2` to get stuck
- Fixed bug that would cause macro to lag & get stuck within a loop that constantly spammed `Move Playhead to Cursor`