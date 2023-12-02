# <> Release 2.13.3 - Hotfix
This release acts as a hotfix to yesterdays... hotfix. A few issues silently lingered that I feel warrant a speedy release this time around.

## > Functions
- Fixed `getHTMLTitle()` no longer correctly returning `Twitch` titles
- Fixed `ytdlp.reencode()` throwing in certain conditions if attempting to operate on a file with no file extension

`settingsGUI()`
- Actually fixed not saving `Adobe` `version` changes
- `Adjust` values now have adjusted limits

## > Other Changes
- `ptf.MyDir` now uses the drive letter of the working directory by default