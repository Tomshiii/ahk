# <> Release 2.18.x - 

## Functions
- ✅ Fixed `rbuttonPrem().movePlayhead()` still throwing under certain circumstances
- ✅ Fixed `ffmpeg.reencode_h26x()` & `encodeGUI()` using incorrect `nvenc` `preset` value range
- ✅ Fixed `determineAdobeVer()` potentially determining `Beta` information for `Photoshop` even if `IsBeta` is disabled
    - ✅ Fixes `KSA` potentially failing to find correct shortcuts

### 📝 `ytdlp {`
- ✅ Fixed class using incorrect default `nvenc` `preset` value
- ✅ Fixed `download()` leaving some files with no extension

## KSA
- ❗ Now supports `v27.0+`
- ✅ Fixed failing to set shortcuts if `IsBeta` was enabled
- ✏️ Added `closePanel`

## PremiereRemote
- ✏️ Added `matchSelectedClipsToLowestTrack()` as a `UXP` function