#SingleInstance Force
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\coord>
; }
;this script was used during the debugging process of the refactored `autosave.ahk` in Release v2.8

loop {
    if !WinExist(Editors.Premiere.winTitle)
        {
            sleep 3000
            continue
        }
    classs := WinGetTitle(editors.Premiere.class)
    saveCheckClass := SubStr(classs, -1, 1)
    if saveCheckClass = ""
        saveCheckClass := "--"
    if classs != ""
        classs := "contains data"
    if saveCheckClass != "*" && saveCheckClass != "--"
        saveCheckClass := "no save needed"


    title := WinGetTitle(editors.Premiere.winTitle)
    saveCheckTitle := SubStr(title, -1, 1)
    if saveCheckTitle = ""
        saveCheckTitle := "--"
    if title != ""
        title := "contains data"
    if saveCheckTitle != "*" && saveCheckTitle != "--"
        saveCheckTitle := "no save needed"
    x := Format("{:d}", (A_ScreenWidth*0.9))
    y := Format("{:d}", (A_ScreenHeight/15))

    tool.Cust("
    (
        Class:
    )" A_Space classs "
    (

        Save Check:
    )" A_Space saveCheckClass "
    (
        `nTitle:
    )" A_Space title "
    (

        Save Check:
    )" A_Space saveCheckTitle

    , 3.0,, x, y)
    tool.Wait()
}