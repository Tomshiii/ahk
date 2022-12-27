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
    static Length := 5

    static control := [this.adTemp.control, this.adfs.control, this.autoSave.control, this.gameCk.control, this.MIC.control]

    static EditPos := [this.adTemp.EditPos, this.adFS.EditPos, this.autosave.EditPos, this.gameCk.EditPos, this.MIC.EditPos]

    static scriptText := [this.adTemp.scriptText, this.adFS.scriptText, this.autoSave.scriptText, this.gameCk.scriptText, this.MIC.scriptText]

    static textPos := [this.adTemp.textPos, this.adFS.textPos, this.autoSave.textPos, this.gameCk.textPos, this.MIC.textPos]

    static otherText := [this.adTemp.otherText, this.adFS.otherText, this.autoSave.otherText, this.gameCk.otherText, this.MIC.otherText]

    static otherTextPos := [this.adTemp.otherTextPos, this.adFS.otherTextPos, this.autoSave.otherTextPos, this.gameCk.otherTextPos, this.MIC.otherTextPos]

    static iniInput := [this.adTemp.iniInput, this.adFS.iniInput, this.autoSave.iniInput, this.gameCk.iniInput, this.MIC.iniInput]

    static colour := [this.adTemp.colour, this.adFS.colour, this.autoSave.colour, this.gameCk.colour, this.MIC.colour]

    static textControl := [this.adTemp.textControl, this.adFS.textControl, this.autoSave.textControl, this.gameCk.textControl, this.MIC.textControl]

    static Bind := [this.adTemp.Bind, this.adFS.Bind, this.autoSave.Bind, this.gameCk.Bind, this.MIC.Bind]
}