; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Apps\VSCode>
#Include <Classes\Apps\Discord>
#Include <Functions\delaySI>
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