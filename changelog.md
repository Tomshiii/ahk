# <> Release 2.21.0.2 - Hotfix

## Functions
- ✅ Fixed `prem.isEditTabActive()` and `premUIA_Values.__setAllPanes()` failing in `Premiere` versions below `27.0`

## Other Changes
- ✅ Fixed `installPremRemote.ahk` not running `pnpm install` causing errors during installation
- ✅ Fixed `update_PremiereRemoteUXP.ahk` failing to run `install_PremiereRemoteUXP.ahk` causing errors during installation
- ✅ Fixed `uninstall_PremiereRemoteUXP.ahk` potentially leaving plugins installed
- ✅ Fixed `Core Functionality.ahk` causing elevated scripts to immediately throw
    - Elevated scripts will still **not** be able to communicate with `Core Functionality.ahk`