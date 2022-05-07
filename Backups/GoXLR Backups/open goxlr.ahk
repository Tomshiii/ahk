SetWorkingDir(A_ScriptDir)
drive := IniRead(A_WorkingDir "\readme.ini", "INFO", "drive letter")

Run(drive ":\Program Files\User\Documents\GoXLR")