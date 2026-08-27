; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
; }

cmd.run(, false, true, rclone.__formatSSH('tail -f /share/CACHEDEV1_DATA/rclone.log'))