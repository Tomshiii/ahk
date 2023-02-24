# <> Release 2.10.1.1 - Hotfix
- Fix installation erroring out due to `errorLog()` not being defined

## > Functions
- `prem.zoom()` now has a 400ms delay before attempting to change the current zoom. This allows the function to count how many times you press the activation hotkey before attempting a zoom
- `obj.imgSrch` & `checkImg()` now take their `x/y` coordinates as an object instead of individual paramaters

## > Other Changes
- Add `resetAEtrans.ahk`