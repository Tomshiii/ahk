# <> Release 2.7.x -
All `lib`/`function` files now get included from the user library. This is accomplished by creating a `SymLink` in `A_MyDocuments \AutoHotkey\` that links back to `..\lib`. This SymLink is created either during the release install process or by the user running `..\Support Files\CreateSymLink.ahk`

## > Other Changes
- Fix double key name in `KSA.ini`
- Fix `right click premiere.ahk` causing `XButton1/2` to get stuck
- Changed `convert2x.ahk` scripts to function `convert2()`
    - Will now run `A_ComSpec` instead of calling cmd from the explorer window as doing so in win11 opens the new terminal which is incredibly difficult to detect with ahk