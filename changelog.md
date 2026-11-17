# <> Release 2.21.0.1 - Hotfix

## Functions
- ✏️ Added `CONST {`
- ✅ Fixed `prem.isEditTabActive()` failing with windows scale other than `100%`
- ✅ Fixed `vscode.__isInstalled()` returning false erroneously

### 📝 `PremiereRemote`
- ✅ Fixed `custom/setZeroPoint()` throwing when already set

## Other Changes
- ✅ Fixed `resetBuild.ahk` always adding a `de.sebinside.premiereremote_3.0.0` folder
- ✅ Fixed issues during installation;
    - Installation will now abort early if `docker` is not installed
    - Installer should no longer get stuck in a state where it fails and then cannot try again
- 📋 Installer will now show more information without throwing if installing `PremiereRemote`/`AERemote` fails

🔗 `install_PremiereRemoteUXP.ahk`
    - Will now prompt the user to close `Premiere` if it is open
    - Will now set required registry values

🔗 `mult-dl.ahk`
###### *(v1.5.3 -> v1.5.4)*
- ✅ Fixed script throwing if `PremiereRemote` wasn't installed