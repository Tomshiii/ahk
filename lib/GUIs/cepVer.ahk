; { \\ #Includes
#Include <GUIs\tomshiBasic>
; }

class cepVer extends tomshiBasic {
    __New() {
        super.__New(,, "AlwaysOnTop", this.titleVar)
        this.AddText("Wrap w300", "Which versions of Premiere would you like to enable unsigned extensions for?")
        for k, v in this.Versions {
            this.AddCheckbox(((A_Index = 1) ? "Section" : "") A_Space "v" StrReplace(k, A_Space, "_"), k)
        }
        this.AddButton("ys xs+210", "select").OnEvent("Click", this.selectVers.Bind(this))
        this.show("w300")
    }

    titleVar := "Which Versions would you like to enable?"
    Versions := Map(
        "< v24", "11",
        "v25+",  "12"
    )

    selectVers(*) {
        for k, v in this.Versions {
            if this[StrReplace(k, "_", A_Space)].Value = 1 {
                if !RegRead("HKEY_CURRENT_USER\Software\Adobe\CSXS." v, "PlayerDebugMode", 0)
                    RegWrite("1", "REG_SZ", "HKEY_CURRENT_USER\Software\Adobe\CSXS." v, "PlayerDebugMode")
            }
        }
        this.Destroy()
    }
}