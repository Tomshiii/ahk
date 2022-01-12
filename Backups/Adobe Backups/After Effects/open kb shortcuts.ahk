SetWorkingDir(A_ScriptDir)
drive := IniRead(A_WorkingDir "\readme.ini", "INFO", "drive letter")
version := IniRead(A_WorkingDir "\readme.ini", "INFO", "version")

Run(drive ":\Users\" A_UserName "\AppData\Roaming\Adobe\After Effects\" version "\aeks")