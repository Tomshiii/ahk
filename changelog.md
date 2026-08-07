# <> Release 2.18.3 - Premiere v27.0+ Support
Version `27.0` of `Premiere` brings some changes to the keyboard shortcut files that broke compatibility with my repo.  
This release fixes those issues, as well as some overdue shortcomings of the recent `KSA` refactor<sup>[[1]](<https://github.com/Tomshiii/ahk/releases/tag/v2.18.0>)</sup> to fix the incompatibility with my repo and the `Beta` versions of the adobe apps.

## Functions
- ✅ Fixed `rbuttonPrem().movePlayhead()` still throwing under certain circumstances
- ✅ Fixed `ffmpeg.reencode_h26x()` & `encodeGUI()` using incorrect `nvenc` `preset` value range
- ✅ Fixed `determineAdobeVer()` potentially determining `Beta` information for `Photoshop` even if `IsBeta` is disabled
    - ✅ Fixes `KSA` potentially failing to find correct shortcuts
- ✅ Fixed `isBool()` returning `true` for any string

### 📝 `prem {`
- ✅ Fixed `__remoteUXP()` throwing instead of returning values
- ✏️ Added `isTrimModeActive()`
- 📋 `delayPlayback()` now accepts parameter `closeTrim`
- 📋 `isClipSelected()` no longer uses `UIA` values and just relies on the api
- 📋 `valuehold()`, `manInput()` & `gain()` no longer require `ImageSearch` and entirely rely on `UIA` for even greater reliability

### 📝 `ytdlp {`
- ✅ Fixed class using incorrect default `nvenc` `preset` value
- ✅ Fixed `download()` leaving some files with no extension

## KSA
- ❗ Now supports `v27.0+`
- ✅ Fixed failing to set shortcuts if `IsBeta` was enabled
- ✏️ Added `closePanel`

## PremiereRemote
- ✏️ Added `matchSelectedClipsToLowestTrack()` as a `UXP` function
- ✏️ Added `isSelectedAudio()`

## Other Changes
- ❌ Removed `effctrlAudio.png`, `effctrlAudio1.png`, `effCtrlCollapse.png`, `reset.png`, `reset_2.png`