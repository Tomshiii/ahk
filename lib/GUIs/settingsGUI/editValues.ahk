class set_Edit_Val {
    static init() => this().__defControls(this)
    __defControls(cls) {
        for v in this.objs {
            for name, val in v.OwnProps() {
                cls.%name%.Push(val)
            }
        }
    }

    adTemp := {
        control: "adobeTemp",                EditPos: "Section xs+230 ys",
        scriptText: "``adobeTemp()``",       textPos: "X+5 Y+-20",
        otherText: " limit (GB)",            otherTextPos: "X+1",
        iniInput: "adobe GB",                colour: "cd53c3c",
        textControl: "adobeTempText",        Bind: "--",
        objName: "--",                       UpDownOpt: "Range1-999"
    }
    adFS := {
        control: "adobeFS",                              EditPos: "xs Y+10",
        scriptText: "``adobe fullscreen check.ahk``",    textPos: "X+5 Y+-28",
        otherText: " check rate (sec)",                  otherTextPos: "Y+-1",
        iniInput: "adobe FS",                            colour: "cd53c3c",
        textControl: "adobeFSText",                      Bind: "adobe fullscreen check.ahk",
        objName: "adobeCheck",                           UpDownOpt: "Range1-999"
    }
    autoSave := {
        control: "autoSave",                  EditPos: "xs Y+2",
        scriptText: "``autosave.ahk``",       textPos: "X+5 Y+-20",
        otherText: " save rate (min)",        otherTextPos: "X+1",
        iniInput: "autosave MIN",             colour: "c4141d5",
        textControl: "autoSaveText",          Bind: "autosave.ahk",
        objName: "autoSave",                  UpDownOpt: "Range1-60"
    }
    gameCk := {
        control: "gameCheck",                  EditPos: "xs Y+10",
        scriptText: "``gameCheck.ahk``",       textPos: "X+5 Y+-20",
        otherText: " check rate (sec)",        otherTextPos: "X+1",
        iniInput: "game SEC",                  colour: "c328832",
        textControl: "gameCheckText",          Bind: "gameCheck.ahk",
        objName: "--",                         UpDownOpt: "Range1-999"
    }
    premPrev := {
        control: "premPrev",                       EditPos: "xs Y+10",
        scriptText: "``swapPreviousSequence()``",  textPos: "X+5 Y+-20",
        otherText: " check rate (sec)",            otherTextPos: "X+1",
        iniInput: "premPrevSeqDelay",              colour: "c753288",
        textControl: "premPrevText",               Bind: "",
        objName: "--",                             UpDownOpt: "Range1-60"
    }
    MIC := {
        control: "MIC",                                 EditPos: "xs Y+12",
        scriptText: "``Multi-Instance Close.ahk``",     textPos: "X+5 Y+-28",
        otherText: " check rate (sec)",                 otherTextPos: "Y+-1",
        iniInput: "multi SEC",                          colour: "c983d98",
        textControl: "MICText",                         Bind: "Multi-Instance Close.ahk",
        objName: "--",                                  UpDownOpt: "Range1-999"
    }

    objs := [this.adTemp, this.adFS, this.autoSave, this.gameCk, this.premPrev, this.MIC]
    static control := []
    static EditPos := []
    static scriptText := []
    static textPos := []
    static otherText := []
    static otherTextPos := []
    static iniInput := []
    static colour := []
    static textControl := []
    static bind := []
    static objName := []
    static UpDownOpt := []
}