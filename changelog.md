# <> Release 2.7.x -
- All `lib`/`function` files now get included from the user library. This is accomplished by creating a `SymLink` in `A_MyDocuments \AutoHotkey\` that links back to `..\lib`. This SymLink is created either during the release install process or by the user running `..\Support Files\Release Assets\CreateSymLink.ahk`
- `ptf.files[]` changed to instead invoke the `__Item` meta function to simply become; `ptf[]`

## > Functions
- Add `vscode` to `class browser`

`settingsGUI()`
- Fixed not all options showing
- Fixed `autosave save rate` changing `adobe fs check`

## > Other Changes
- Fix double key name in `KSA.ini`
- Changed `convert2x.ahk` scripts to function `convert2()`
    - Will now run `A_ComSpec` instead of calling cmd from the explorer window as doing so in win11 opens the new terminal which is incredibly difficult to detect with ahk
- Moved `HotkeyReplacer.ahk` & `Getting Started_readme.md` => `..\Support Files\Release Assets\`
    - Added `releaseGUI.ahk` to provide the user a few options after running the latest release `.exe`

`right click premiere.ahk`
- Fixed bug that caused `XButton1/2` to get stuck
- Fixed bug that would cause macro to lag & get stuck within a loop that constantly spammed `Move Playhead to Cursor`