; { \\ #Includes
#Include <GUIs\tomshiBasic>
; }

class partDL extends tomshiBasic {
    __New() {
        Title := "Download Part"
        super.__New(,,, Title)
        this.AddText("Wrap w280", "Please provide the timecode that all content you wish to download sits within.")

        loop 2 {
            this.AddText(((A_Index = 1) ? "" : "xs y+15 ") "Section", (A_Index = 1) ? "Start Timecode:   H" : "End Timecode:    H")
            this.AddEdit("xs+120 ys-3 w50")
            this.AddUpDown("vH" A_Index " Range0-24 ", 0)

            this.AddText("x+10 ys", "M")
            this.AddEdit("x+5 ys-3 w50")
            this.AddUpDown("vM" A_Index " Range0-59 ", 0)

            this.AddText("x+10 ys", "S")
            this.AddEdit("x+5 ys-3 w50")
            this.AddUpDown("vS" A_Index " Range0-59 ", 0)
        }

        this.AddButton("y+10 xp-10 vsub", "Submit")
        this["sub"].OnEvent("Click", this.__sub.Bind(this))

        super.show("w350 h160")
        WinWaitClose(Title)
    }
    value := ""

    __sub(*) {
        this.value := (Format("{:02}", this["H1"].value) ":" Format("{:02}", this["M1"].value) ":" Format("{:02}", this["S1"].value) "-" Format("{:02}", this["H2"].value) ":" Format("{:02}", this["M2"].value) ":" Format("{:02}", this["S2"].value))
        if this.value == "00:00:00-00:00:00"
            this.value := ""
        this.Hide()
    }

    __Delete() {
        this.Destroy()
    }
}