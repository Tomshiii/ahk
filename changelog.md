# <> Release 2.14.x - 

## Functions
- Fixed `run at startup` checkbox in `settingsGUI()` throwing
- Added `startup.updatePackages()` to check for updates with the user's respective Package Manager
> [!Note]
> The code for this function (especially the portion that sends the command to actually update packages) is specifically designed for `Chocolatey`. While there are paramaters for the function to customise it for your package manager of choice, it may not function completey as intend. Feel free to open an issue/pr detailing as much as you can if you encounter any issues.
- `premUIA_Values().__setNewVal()` now prompts the user to reload scripts
- `prem.numpadGain()` should now move clips on the timeline less often