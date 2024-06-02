# <> Release 2.14.x - 

## Functions
- Wrapped all uses of `JSON.Parse()` in `try` blocks to hopefully stop some instances of the script locking up in the event that it doesn't retrieve the data it needs
- `winget.PremName()` & `winget.AEName()` now accept parameter `ttips` to determine whether tooltips will display if the window titles cannot be determined