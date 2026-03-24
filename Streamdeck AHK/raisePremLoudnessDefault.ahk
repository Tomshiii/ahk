#Include "%A_Appdata%\tomshi\lib"
#Include Classes\CLSID_Objs.ahk

;// this script changes the Essential Sound Loudness default from -23 LUFs to -14 LUFs to be more inline with youtube

str := '{"DefaultLoudness":{"type":"float","value":-23}'
repString := StrReplace(str, "-23", "-14")

UserSettings := CLSID_Objs.clone("UserSettings")
year := SubStr(UserSettings.premVer, 2, 4) ;// eg v26.0.2
path := A_MyDocuments "\Adobe\Premiere Pro\" year "\Profile-" A_UserName "\Settings\EssentialSound\Default\dialog\(Config).essentialsound"
pathAppdata := A_AppData "\Adobe\Premiere Pro\" year "\EssentialSound\Default\dialog\(Config).essentialsound"

__create(path)
__create(pathAppdata)

__create(path) {
    SplitPath(path,, &dir,, &name)
    FileAppend(StrReplace(FileRead(path), str, repString,,, 1), dir "\" name "_temp")
    FileMove(dir "\" name "_temp", path, true)
}