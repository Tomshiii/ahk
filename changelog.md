# <> Release 2.14.x - 

## Functions
- Fixed `rbuttonPrem().movePlayhead()` performing slowly under certain circumstances
- Fixed `slack.__expandingLoop()` throwing

`prem {`
- Fixed `delayPlayback()` setting its timer when the timeline wasn't the active window (which would make typing text a little difficult)
- `Previews()` will now check to see if a save is necessary instead of always saving

## Other Changes
- `render and replace.ahk` will now check to see if a save is necessary instead of always saving