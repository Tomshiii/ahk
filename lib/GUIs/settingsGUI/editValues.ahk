class set_Edit_Val {
    static adTemp := {
        control: "adobeTemp",                EditPos: "Section xs+223 ys",
        scriptText: "``adobeTemp()``",       textPos: "X+5 Y+-20",
        otherText: " limit (GB)",            otherTextPos: "X+1",
        iniInput: "adobe GB",                colour: "cd53c3c",
        textControl: "adobeTempText",        Bind: "--"
    }
    static adFS := {
        control: "adobeFS",                              EditPos: "xs Y+10",
        scriptText: "``adobe fullscreen check.ahk``",    textPos: "X+5 Y+-28",
        otherText: " check rate (sec)",                  otherTextPos: "Y+-1",
        iniInput: "adobe FS",                            colour: "cd53c3c",
        textControl: "adobeFSText",                      Bind: "adobe fullscreen check.ahk"
    }
    static autoSave := {
        control: "autoSave",                  EditPos: "xs Y+2",
        scriptText: "``autosave.ahk``",       textPos: "X+5 Y+-20",
        otherText: " save rate (min)",        otherTextPos: "X+1",
        iniInput: "autosave MIN",                 colour: "c4141d5",
        textControl: "autoSaveText",          Bind: "autosave.ahk"
    }
    static gameCk := {
        control: "gameCheck",                  EditPos: "xs Y+10",
        scriptText: "``gameCheck.ahk``",       textPos: "X+5 Y+-20",
        otherText: " check rate (sec)",        otherTextPos: "X+1",
        iniInput: "game SEC",                  colour: "c328832",
        textControl: "gameCheckText",          Bind: "gameCheck.ahk"
    }
    static MIC := {
        control: "MIC",                                 EditPos: "xs Y+12",
        scriptText: "``Multi-Instance Close.ahk``",     textPos: "X+5 Y+-28",
        otherText: " check rate (sec)",                 otherTextPos: "Y+-1",
        iniInput: "multi SEC",                          colour: "c983d98",
        textControl: "MICText",                         Bind: "Multi-Instance Close.ahk"
    }
    static premYear := { ;these two have code that references them as the 6th AND 7th LOOP, IF YOU PUT SOMETHING BEFORE THESE TWO, YOU NEED TO CHANGE IT IN set_Edit_Val.num AND THEN ADJUST IT'S GENERATION IN SETTINGSGUI() OR IT WON'T WORK
        control: "premYear",                          EditPos: "xs Y+10",
        scriptText: "Adobe Premiere Year",            textPos: "X+5 Y+-20",
        iniInput: "prem year",                        colour: "c8644c7",
        textControl: "premYearText",                  Bind: "--"
    }
    static aeYear := {
        control: "aeYear",                          EditPos: "xs Y+10",
        scriptText: "Adobe After Effects Year",     textPos: "X+5 Y+-20",
        iniInput: "ae year",                        colour: "c393665",
        textControl: "aeYearText",                  Bind: "--"
    }
    static Length := 7

    static control := [this.adTemp.control, this.adfs.control, this.autoSave.control, this.gameCk.control, this.MIC.control, this.premYear.control, this.aeYear.control]

    static EditPos := [this.adTemp.EditPos, this.adFS.EditPos, this.autosave.EditPos, this.gameCk.EditPos, this.MIC.EditPos, this.premYear.EditPos, this.aeYear.EditPos]

    static scriptText := [this.adTemp.scriptText, this.adFS.scriptText, this.autoSave.scriptText, this.gameCk.scriptText, this.MIC.scriptText, this.premYear.scriptText, this.aeYear.scriptText]

    static textPos := [this.adTemp.textPos, this.adFS.textPos, this.autoSave.textPos, this.gameCk.textPos, this.MIC.textPos, this.premYear.textPos, this.aeYear.textPos]

    static otherText := [this.adTemp.otherText, this.adFS.otherText, this.autoSave.otherText, this.gameCk.otherText, this.MIC.otherText,"null","null"]

    static otherTextPos := [this.adTemp.otherTextPos, this.adFS.otherTextPos, this.autoSave.otherTextPos, this.gameCk.otherTextPos, this.MIC.otherTextPos,"null","null"]

    static iniInput := [this.adTemp.iniInput, this.adFS.iniInput, this.autoSave.iniInput, this.gameCk.iniInput, this.MIC.iniInput, this.premYear.iniInput, this.aeYear.iniInput]

    static colour := [this.adTemp.colour, this.adFS.colour, this.autoSave.colour, this.gameCk.colour, this.MIC.colour, this.premYear.colour, this.aeYear.colour]

    static textControl := [this.adTemp.textControl, this.adFS.textControl, this.autoSave.textControl, this.gameCk.textControl, this.MIC.textControl, this.premYear.textControl, this.aeYear.textControl]

    static Bind := [this.adTemp.Bind, this.adFS.Bind, this.autoSave.Bind, this.gameCk.Bind, this.MIC.Bind, this.premYear.Bind, this.aeYear.Bind]

    static num := ["null","null","null","null","null", 6, 7] ;PREM AND AE
}