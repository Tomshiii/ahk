`GUI.ahk` contains all GUI functions not defined within another function.

It starts off by defining;

## class tomshiBasic {
`tomshiBasic` is a small class used to share a few settings across all GUIs in my scripts. This class helps me keep a relatively consistent GUI look across all my scripts, and in the event I want to ever change a setting it can be done here and be shared basically script wide.
```
MyGui := tomshiBasic( [{FontSize, FontWeight, options, title}] )
```
#### FontSize
Type: Number
> Allows you to pass in a custom default GUI font size. Defaults to 11, can be omitted.

#### FontWeight
Type: Integer
> Allows you to pass in a custom default GUI font weight. Defaults to 11, can be omitted.

#### options
Type: String
> Allows you to pass in all GUI options that you would normally pass to a GUI. Can be omitted.

#### title
Type: String
> Allows you to pass in a title for the GUI. Can be omitted.
***

## `settingsGUI()`
This GUI allows the user to adjust almost all user adjustable settings all within one place. It can be accessed by either pressing the activation hotkey (`#F1` by default) or by right clicking on the `My Scripts.ahk` tray icon in the task bar, then selecting `Settings`

![image](https://user-images.githubusercontent.com/53557479/201815307-d3f62dae-e52f-4f73-93fd-6f66fae2d97e.png)

> **settingsGUI() as of v2.7*

## class gameCheckGUI {

Within `settingsGUI()` is the ability to call another GUI, `gameCheckGUI` which is defined in a class in `..\settingsGUI\gameCheckGUI.ahk` and can be accessed by pressing the `Add game to 'gameCheck.ahk'` button within `settingsGUI()` or by right clicking on the `gameCheck.ahk` tray icon in the taskbar (although accessing it this way cannot autofill the edit boxes). This GUI is designed to allow the user to quickly add games to the `Game List.ahk` file that is read by `gameCheck.ahk`. When the user opens `settingsGUI()` it grabs the `winTitle` and `winProcess` of the active window and stores that information, if the user then opens `gameCheckGUI()` that information is prefilled into the edit boxes so the user can edit it accordingly.

![image](https://user-images.githubusercontent.com/53557479/199131020-e705d0b8-0629-4391-8b1d-3540c4598b8f.png)

> **gameCheckGUI() as of v2.6.1*
***

## `musicGUI()`
This GUI offers the user a selection of audio programs at their fingertips. This function is used within [`switchToMusic()`](https://github.com/Tomshiii/ahk/wiki/switchTo-Functions).

![image](https://user-images.githubusercontent.com/53557479/199143747-1ed038a3-b4ac-435e-9775-23f59eeca7c5.png)

> **musicGUI() as of v2.6.1*
***

## `hotkeysGUI()`
This function produces a GUI to remind the user of some helpful macros and their default hotkey combination.

![image](https://user-images.githubusercontent.com/53557479/199144856-6920ff9b-0c4b-4cb4-8ec1-13c5774e1eb1.png)

> **hotkeysGUI() as of v2.6.1*
***

## `todoGUI()`
This GUI is an informational GUI presented to the user as an option during their first time running `My Scripts.ahk` and is called from [`firstCheck()`](https://github.com/Tomshiii/ahk/wiki/Startup-Functions#firstcheck).

This GUI gives the user instructions on where to start with these scripts and is aimed at helping point the user in the right direction.

![image](https://user-images.githubusercontent.com/53557479/199145242-3fef436f-770f-4985-8085-ad816b043032.png)

> **todoGUI() as of v2.6.1pre2*
***

## `activeScripts()`
This GUI gives the user quick access to not only see which of my scripts are currently active, but also gives the user the ability to quickly close/open any of them at the click of a checkbox.

The scripts/checkboxes presented in this GUI are hard coded and not generated at runtime.

![image](https://user-images.githubusercontent.com/53557479/199145506-b79d5c5d-2cd0-46e3-82d4-10a0202c8946.png)

> **activeScripts() as of v2.6.1*