# <> Release 2.20.x - 

## Functions
- 📋 `prem.__isUXPInstalled()` will now check that; the `ccx` extension has been installed, and that `docker` is installed

### 📝 `discord {`
- 📋 `button()` now makes use of `Toggle()`/`Invoke()` `UIA` functions instead of relying on `ControlClick()`

📍 `Unread()`
- ✅ Fixed function failing when param `which` = `"servers"`
- 📋 Now makes use of `Invoke()` `UIA` function instead of relying on `ControlClick()`

### 📝 `cmd {`
📍 `httpGet()`
- 📋 Now accepts parameters `retries`/`timeoutMs`
    - Now reattempts retrieving the data by default under certain circumstances

### 📝 `notifyExt {`
📍 `showIfNotExist()`
- ✅ Fixed always using a duration of `8` if passed in caps; ie. `DUR=`
- ✅ Fixed clicking the GUI to close it not restarting the duration

## Other Changes
- 📋 `uninstall_PremiereRemoteUXP.ahk` will now attempt to delete any stale, leftover directories

🔗 `mult-dl.ahk`
###### *(v1.3.14 -> v1.4.0)*
- ✅ Fixed always prompting for updates even when none were available
- 📋 Comma delimited list of URLs added to `Multi` will now work if individually encased in `"`
- 📋 `Multi` tab now shows progress bars
- 📋 `change` button will now be disabled during downloads