# <> Release 2.15.5.1 - Hotfix
This version is a hotfix to address;
- A bug during the installation process that caused `installPackagesGUI` to throw if attempting to install `PremiereRemote`
- `PremiereRemote v2.2.0` support

## Functions
- ✅ Fixed `prem.numpadGain()` from potentially inputting `NaN` values

## Other Changes
- `installPackagesGUI` during installation can now optionally update `PremiereRemote` `.tsx` files during the install flow so the user does not need to manually run `replacePremRemote.ahk`