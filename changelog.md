# <> Release 2.20.x - 

## Functions
- 📋 `prem.__isUXPInstalled()` will now check that; the `ccx` extension has been installed, and that `docker` is installed

### 📝 `cmd {`

📍 `httpGet()`
- 📋 Now accepts parameters `retries`/`timeoutMs`
    - Now reattempts retrieving the data by default under certain circumstances

### 📝 `notifyExt {`

📍 `showIfNotExist()`
- ✅ Fixed always using a duration of `8`
- ✅ Fixed clicking the GUI to close it not restarting the duration