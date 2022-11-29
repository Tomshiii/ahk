# <> Release 2.8 - Refactoring
This release is a massive overhaul of how things are layed out and structured in my repo - I may not cover everything in this changelog as so many massive structural changes have happened it's hard to note down everything without it getting too confusing.

The biggest changes;

- All `lib`/`function` files now get `#Included` from the `user library` (`A_MyDocuments \AutoHotkey\lib\`). This is accomplished by creating a `SymLink` in `A_MyDocuments \AutoHotkey\lib\` that links back to `..\lib` in this repo. This SymLink is created either during the release install process or by the user running `..\Support Files\Release Assets\CreateSymLink.ahk`
- `ptf.files[]` changed to instead invoke the `__Item` meta function to simply become; `ptf[]`
- `..\lib\` folder completely overhauled
    - `General.ahk` is removed and split apart
        - Multiple classes are now their own ahk files
        - A large chunk of functions are now their own ahk file
- All files now contain their required `#Includes` instead of using one script to include everything
    - This helps make it clear what scripts require what
    - Removes the need to include unnecessary scripts just because not doing so would generate an error

### New Classes;

`tool {`, `coord {`, `block {`
- All now their own respective class file

`VSCode {`
- All VSCode functions now a class
- VSCode class separated out into it's own file `..\lib\Classes\Apps\VSCode.ahk`

`Discord {`
- All Discord functions now a class
- Discord class separated out into it's own file `..\lib\Classes\Apps\Discord.ahk`

`switchTo {`
- All `switchToX()` functions now a class
- Created self contained function `Win()` to cut repeat code

`Prem {`, `AE {`, `PS {`, `Resolve {`
- All Editor functions turned into classes
- Editor lib files moved from `..\lib\Functions\` to `..\lib\Classes\Editors\`

This changelog doesn't cover everything + a few functions have been broken out into their own class files, check out the `..\lib\Classes\` folder (or the wiki!) to check them out yourself!

## > Functions
- Moved `class ptf {`, `class browser {`, `class Editors {` & the group assignments from `General.ahk` => `ptf.ahk`
    - Add `vscode` to `class browser`
    - Add class `Editors` to contain `winTitle` and `class` information of `NLEs`
    - Fix `chrome` & `edge` having incorrect `winTitle` values
- Moved `refreshWin()` from `General.ahk` => `Windows.ahk`
- `pauseautosave()` & `pausewindowmax()` combined into `pause.pause()`
- `fastWheel()` sends `PgUp/Dn` instead of `WheelUp/Down` because wheel events are laggy and dumb and I really hate them
- `getScriptRelease()` will now omit `spaces` & `<> html` tags in the event it returns more than just the version number
- Fix `libUpdateCheck()` incorrectly comparing versions
- `tool.Cust()` now sets tooltip coordmode to `screen` so custom passed `x/y` values don't default to window
- `winget.PremName()` will now check both the Premiere `winTitle` and `class` values as depending on the situation could yeild a blank string for either
- `VSCode.cut()` & `VSCode.copy()` functions will no longer attempt to fire if you're highlighting something not in the code window
- `winget.isFullscreen()` now returns `true/false` if the window is fullscreen or not instead of filling a variable

`activeScripts()`
- Now includes `textreplace.ahk`
- Now splits scripts into two columns

`settingsGUI()`
- Fixed not all options showing
- Fixed `autosave save rate` editbox changing `adobe fs check`
- Fixed scripts not reloading when their respective setting is changed
- Opening the `settings.ini` will now move the notepad window right next to `settingsGUI()`

## > My Scripts
- `^SPACE:: ;alwaysontopHotkey;` will now attempt to produce a tooltip to tell the user which state the window is being changed too
- `#c:: ;centreHotkey;` will now resize VLC so that it shows 16:9 videos with no letterboxing

## > QMK
- Cleaned up entire script
- Separated out all program key definitions to separate `.ahk` files and placed in `..\lib\QMK\` to help readability & maintainability

## > autosave
- Refactored entire script
    - No longer needs to activate the window
    - Uses `ControlSend()` if window isn't active
    - Fix tooltips glitching out

## > Other Changes
- Fix double key name in `KSA.ini`
- Changed `convert2x.ahk` scripts to function `convert2()`
- Fixed `Start new project.ahk` running `checklist.ahk` unnecessarily
    - Will now run `A_ComSpec` instead of calling cmd from the explorer window as doing so in `win11` opens the new terminal which is incredibly difficult to detect with ahk
- Moved `HotkeyReplacer.ahk` & `Getting Started_readme.md` => `..\Support Files\Release Assets\`
    - Added `releaseGUI.ahk` to provide the user a few options after running the latest release `.exe`
    - Added `generateUpdate.ahk` which is the script I use to generate the release `.exe`
- Moved a few old scripts to => `..\Backups\Old Code\`
- Moved `newWin()` from `QMK.ahk` => `class switchTo {`
- Moved `..\Changelogs` => `..\Backups\Changelogs`

`submodules`
- Add submodule of [`textreplace`](https://github.com/Tomshiii/textreplace) repo to `..\Support Files\textreplace\`
- Backup of the Wiki moved out of this repo => [`ahk_wiki`](https://github.com/Tomshiii/ahk_wiki) and then included via a submodule in `..\Backups\Wiki\`

`right click premiere.ahk`
- Fixed bug that caused `XButton1/2` to get stuck
- Fixed bug that would cause macro to lag & get stuck within a loop that constantly spammed `Move Playhead to Cursor`