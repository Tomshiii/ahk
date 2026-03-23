# <> Release 2.17.x - 

## Functions
- 📋 `prem.__remoteFunc()` will now alert the user if it is waiting for the socket connection to load and abort early to avoid unnecessary errors

## Other Changes
- ✅ Fixed `Premiere_RightClick.ahk` causing a bunch of `PremiereRemote` errors if initiated too quickly after a reload
- 📋 `Core Functionality.ahk` will now throw if the current directory does not match the install directory