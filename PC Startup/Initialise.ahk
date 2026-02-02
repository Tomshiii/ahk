if !FileExist(A_Appdata "\tomshi\installDir")
    return
installDir := FileRead(A_Appdata "\tomshi\installDir")

Run(installDir "\Core Functionality.ahk")
sleep 250

;// run any user scripts