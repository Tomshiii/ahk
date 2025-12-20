; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include KSA\Keyboard Shortcut Adjustments.ahk
#Include Classes\Apps\VSCode.ahk
#Include Classes\Apps\Discord.ahk
#Include Functions\delaySI.ahk
; }

;vscodemsHotkey;
!a::VSCode.script(15) ;clicks on the `my scripts` script in vscode
;vscodechangeHotkey;
!c::VSCode.script(12) ;clicks on my `changelog` file in vscode
;vscodeTestHotkey;
!t::VSCode.script()

!e::VSCode.script()

;vscodesearchHotkey;
$^f::VSCode.search()
;vscodecutHotkey;
$^x::VSCode.cut()
;vscodeCopyHotkey;
$^c::VSCode.copy()
;vscodeHideBarHotkey;
^b::delaySI(15, KSA.hideSideBar, KSA.hideActivityBar)
;vscodeAsterixHotkey;
; *::discord.surround("*")

!`::SendText('``n'), SendInput("{Right}")
^+d::SendText(Format("{}/{}/{}", A_YYYY, A_MM, A_DD))