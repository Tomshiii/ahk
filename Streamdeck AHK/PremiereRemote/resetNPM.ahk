#Include <Classes\cmd>

;// this script is just to rebuild the webserver for `PremiereRemote` as
;// any time you change anything in the `index` file, you need to rebuild it

dir     := A_AppData "\Adobe\CEP\extensions\PremiereRemote\host\"
command := "npm run build"

cmd.run(,,1, command, dir)