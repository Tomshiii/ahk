; { \\ #Includes
#Include rclone.ahk
#Include '%A_Appdata%\tomshi\lib'
; }

cmd.run(, false, false, rclone.__formatSSH('killall rclone'),, "Hide")