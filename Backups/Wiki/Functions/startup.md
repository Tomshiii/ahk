A list of `My Scripts.ahk` Startup Functions complete with definitions.

These functions are run at the beginning of `My Scripts.ahk` and perform a bunch of tasks to either complete the experience of my scripts, or to perform some useful tasks.

You will see the variable `MyRelease` passed into a lot of these functions - they require the latest version to perform their tasks/checks so we pass it into them so we don't need to manually change that code every release.
***

## `generate()`
This function will generate the settings.ini file if it doesn't already exist as well as regenerating it every new release to ensure any new .ini values are added without breaking anything.

*Do note if you're pulling commits from the `dev` branch of this repo and I add something to this `settings.ini` file & you pull the commit before a new release, this function will not generate a new file for you and you may encounter errors. You can get around this by manually lowering the "version" number in the `settings.ini` file and then running `My Scripts.ahk` or alternatively just waiting for prereleases.*
```
generate( [MyRelease] )
```
#### MyRelease
Type: String/Variable
> The current release version. We pass this value into the function to cut the need to update code values every release.
***

## `getScriptRelease()`
A function to return the most recent version of my scripts on github. This does NOT use the API and instead downloads a `.atom` of the release page and searches for a certain string to get either the latest full release, or the latest prerelease.
```
getScriptRelease( [{beta}, &changeVer] )
```
#### beta
Type: Boolean
> A `true/false` to determine if you want this function to check for a full release, or a prerelease. Can be omitted.

#### &changeVer
Type: VarRef
> Determines which changelog to show in `updateChecker()` GUI. Either returns "main" or "beta".

### Return Value
> This function returns a string containing the latest version number.
***

## `updateChecker()`
This function will (on script startup, NOT a reload of the script) check which version of the script you're running, cross reference that with the latest release on github and alert the user if there is a newer release available with a prompt to download it. The GUI will offer the user the ability to see the changelog for the latest release, if they chose to do so, the latest release page on github will be loaded in a [`WebView2`](https://github.com/thqby/ahk2_lib/tree/master/WebView2) window

Which branch the user wishes to check for (either beta, or main releases) can be determined by either right clicking on `My Scripts.ahk` in the task bar and clicking  `Settings`, or by accessing `settingsGUI()` (by default `#F1`).

This script will also perform a backup of the users current instance of the "ahk" folder this script resides in and will place it in the `\Backups` folder.
```
updateChecker( [MyRelease] )
```
#### MyRelease
Type: String/Variable
> The current release version. We pass this value into the function to cut the need to update code values every release.
***

## `firstCheck()`
This function checks to see if it is the first time the user is running the `My Scipts.ahk` script. If so, they are then given a GUI containing some general information regarding the script as well as a prompt to check out some useful hotkeys.
```
firstCheck( [MyRelease] )
```
#### MyRelease
Type: String/Variable
> The current release version. We pass this value into the function to cut the need to update code values every release.
***

## `oldError()`
This function will (on script startup, NOT a reload of the script) delete any `\ErrorLog` files older than 30 days.
***

## `adobeTemp()`
This function will (on script startup, NOT a reload of the script) delete any Adobe temp files when they're bigger than the specified amount (in GB). Adobe's "max" limits that you set within their programs is stupid and rarely chooses to work, this function acts as a sanity check.

The minimum value for this function can be adjusted by either right clicking on `My Scripts.ahk` in the task bar and clicking  `Settings`, or by accessing `settingsGUI()` (by default `#F1`).

It should be noted I have created a custom location for `After Effects'` temp files to go to so that they're in the same folder as `Premiere's` just to keep things in one place. You will either have to change this folder directory within the function to the actual default or set the cache location within After Effects to the same place.
```
adobeTemp( [MyRelease] )
```
#### MyRelease
Type: String/Variable
> The current release version. We pass this value into the function to cut the need to update code values every release.
***

## `locationReplace()`
Within my scripts I have a few hard coded references to the directory location I have these scripts. That however would be useless to another user who places them in another location.

To combat this scenario, this function on script startup will check the working directory (and compare it against the value in `settings.ini`) and if they aren't the same, change all instances of MY hard coded dir to the users current working directory.

This script will take note of the users A_WorkingDir and store it in `A_MyDocuments \tomshi\settings.ini` and will check it every launch to ensure location variables are always updated and accurate.
***

## `trayMen()`
This function will add right click tray menu items to "My Scripts.ahk" to toggle checking for updates as well as accessing a GUI to modify script settings.
***

## class libs {
`libs` is a collection of information relating to external lib files used by my scripts. It contains; The name, url & script path for each file.

This information is then looped through by `libUpdateCheck()`
***

## `libUpdateCheck()`
This function will (on script startup, NOT a reload of the script) loop through `class libs {` and ensure that all listed libs are up to date.

This function will first attempt to look for `@version` tags, but if none exist in the file it will simply compare the local file to the downloaded file.