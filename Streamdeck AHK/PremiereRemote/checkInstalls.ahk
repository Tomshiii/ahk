#Include <Classes\cmd>
#Include <Other\Notify\Notify>

;// this script is just to check the current install for any files that need fixing
;// this can be helpful if you're experiencing PremiereRemote randomly crashing, or other extensions crashing alongside PremiereRemote (I recently experienced this with Premiere Composer by Mr Horse)

dir     := A_AppData "\Adobe\CEP\extensions\PremiereRemote\"
command := "npm i"

Notify.Show(, 'Checking npm files. Close first cmd window when it is finished to continue!', 'C:\Windows\System32\imageres.dll|icon8',,, 'dur=6 pos=BC bdr=0x75AEDC')
cmd.run(, true, true, command, dir "\client")
cmd.run(, true, true, command, dir "\host")