SetWorkingDir(A_ScriptDir)
drive := IniRead(A_WorkingDir "\readme.ini", "INFO", "drive letter")
version := IniRead(A_WorkingDir "\readme.ini", "INFO", "version")

Run(drive ":\Program Files\User\Documents\Adobe\Premiere Pro\" version "\Profile-" A_UserName "\Layouts")