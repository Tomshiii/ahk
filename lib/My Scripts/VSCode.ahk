; { \\ #Includes
#Include <KSA\Keyboard Shortcut Adjustments>
#Include <Classes\Apps\VSCode>
#Include <Classes\Apps\Discord>
#Include <Functions\delaySI>
; }

;vscodemsHotkey;
!a::VSCode.script(16) ;clicks on the `my scripts` script in vscode
;vscodechangeHotkey;
!c::VSCode.script(13) ;clicks on my `changelog` file in vscode
;vscodeTestHotkey;
!t::VSCode.script()
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