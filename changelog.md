# <> Release 2.7.x -
All `lib`/`function` files now get included from the user library. This is accomplished by creating a `SymLink` in `A_MyDocuments \AutoHotkey\` that links back to `..\lib`. This SymLink is created either during the release install process or by the user running `..\Support Files\CreateSymLink.ahk`

## > Other Changes
- Fix double key name in `KSA.ini`
