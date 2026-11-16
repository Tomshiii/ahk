# <> Release 2.21.x - 

## Functions
- ✅ Fixed `prem.isEditTabActive()` failing with windows scale other than `100%`
- ✅ Fixed `vscode.__isInstalled()` returning false erroneously

## Other Changes
- ✅ Fixed issues during installation
    - Installation will now abort early if `docker` is not installed
    - Installer should no longer get stuck in a state where it fails and then cannot try again
    - `install_PremiereRemoteUXP.ahk` will now prompt the user to close `Premiere` if it is open

🔗 `mult-dl.ahk`
###### *(v1.5.3 -> v1.5.4)*
- ✅ Fixed script throwing if `PremiereRemote` wasn't installed