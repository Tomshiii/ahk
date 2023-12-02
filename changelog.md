# <> Release 2.13.x - 

## > Functions
- Fixed `getHTMLTitle()` no longer correctly returning `Twitch` titles
- Fixed `ytdlp.reencode()` throwing in certain conditions if attempting to operate on a file with no file extension
- Fixed `settingsGUI()` not saving Adobe version changes
- `Adjust` values in `settingsGUI()` now have adjusted and codable limits

## > Other Changes
- `ptf.MyDir` now uses the drive letter of the working directory by default