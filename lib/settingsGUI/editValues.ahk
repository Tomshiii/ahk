adTemp := {
    control: "adobeTemp",                EditPos: "Section xs+223 ys",
    scriptText: "``adobeTemp()``",       textPos: "X+5 Y+-20",
    otherText: " limit (GB)",            otherTextPos: "X+1",
    iniInput: "adobe GB",                colour: "cd53c3c",
    textControl: "adobeTempText",        Bind: "--"
}
adFS := {
    control: "adobeFS",                              EditPos: "xs Y+10",
    scriptText: "``adobe fullscreen check.ahk``",    textPos: "X+5 Y+-28",
    otherText: " check rate (sec)",                  otherTextPos: "Y+-1",
    iniInput: "adobe FS",                            colour: "cd53c3c",
    textControl: "adobeFSText",                      Bind: "adobe fullscreen check.ahk"
}
autoSave := {
    control: "autoSave",                  EditPos: "xs Y+2",
    scriptText: "``autosave.ahk``",       textPos: "X+5 Y+-20",
    otherText: " save rate (min)",        otherTextPos: "X+1",
    iniInput: "adobe FS",                 colour: "c4141d5",
    textControl: "autoSaveText",          Bind: "autosave.ahk"
}
gameCk := {
    control: "gameCheck",                  EditPos: "xs Y+10",
    scriptText: "``gameCheck.ahk``",       textPos: "X+5 Y+-20",
    otherText: " check rate (sec)",        otherTextPos: "X+1",
    iniInput: "game SEC",                  colour: "c328832",
    textControl: "gameCheckText",          Bind: "gameCheck.ahk"
}
MIC := {
    control: "MIC",                                 EditPos: "xs Y+10",
    scriptText: "``Multi-Instance Close.ahk``",     textPos: "X+5 Y+-28",
    otherText: " check rate (sec)",                 otherTextPos: "Y+-1",
    iniInput: "multi SEC",                          colour: "c983d98",
    textControl: "MICText",                         Bind: "Multi-Instance Close.ahk"
}
premYear := { ;these two have code that references them as the 6th AND 7th LOOP, CHANGE IT IN set_Edit_Val.num OR IT WON'T WORK
    control: "premYear",                          EditPos: "xs Y+10",
    scriptText: "Adobe Premiere Year",            textPos: "X+5 Y+-20",
    iniInput: "prem year",                        colour: "c8644c7",
    textControl: "premYearText",                  Bind: "--"
}
aeYear := {
    control: "aeYear",                          EditPos: "xs Y+10",
    scriptText: "Adobe After Effects Year",     textPos: "X+5 Y+-20",
    iniInput: "ae year",                        colour: "c393665",
    textControl: "aeYearText",                  Bind: "--"
}

class set_Edit_Val {
    static Length := 7

    static control := [adTemp.control, adfs.control, autoSave.control, gameCk.control, MIC.control, premYear.control, aeYear.control]

    static EditPos := [adTemp.EditPos, adFS.EditPos, autosave.EditPos, gameCk.EditPos, MIC.EditPos, premYear.EditPos, aeYear.EditPos]

    static scriptText := [adTemp.scriptText, adFS.scriptText, autoSave.scriptText, gameCk.scriptText, MIC.scriptText, premYear.scriptText, aeYear.scriptText]

    static textPos := [adTemp.textPos, adFS.textPos, autoSave.textPos, gameCk.textPos, MIC.textPos, premYear.textPos, aeYear.textPos]

    static otherText := [adTemp.otherText, adFS.otherText, autoSave.otherText, gameCk.otherText, MIC.otherText]

    static otherTextPos := [adTemp.otherTextPos, adFS.otherTextPos, autoSave.otherTextPos, gameCk.otherTextPos, MIC.otherTextPos]

    static iniInput := [adTemp.iniInput, adFS.iniInput, autoSave.iniInput, gameCk.iniInput, MIC.iniInput, premYear.iniInput, aeYear.iniInput]

    static colour := [adTemp.colour, adFS.colour, autoSave.colour, gameCk.colour, MIC.colour, premYear.colour, aeYear.colour]

    static textControl := [adTemp.textControl, adFS.textControl, autoSave.textControl, gameCk.textControl, MIC.textControl, premYear.textControl, aeYear.textControl]

    static Bind := [adTemp.Bind, adFS.Bind, autoSave.Bind, gameCk.Bind, MIC.Bind, premYear.Bind, aeYear.Bind]

    static num := ["null","null","null","null","null", 6, 7] ;PREM AND AE
}