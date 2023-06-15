; { \\ #Includes
#Include <Classes\cmd>
#Include <GUIs\tomshiBasic>
; }

;// manually remapping my nas is annoying so here's a script to do it for me

class drivePicker extends tomshiBasic {
    __New() {
        super.__New(,,, "Pick Drive")
        this.AddText("Section", "Network Location: ")
        this.AddEdit("xs+120 ys-3 w150", this.networkLocation).OnEvent("Change", this.__setNetLocation.Bind(this))
        this.AddText("xs Section", "Drive Location: ")
        this.AddDropDownList("xs+120 ys-3 Sort w150 Choose" this.driveLocation, this.__generateLetterArr()).OnEvent("Change", this.__setDriveLocation.Bind(this))
        this.AddButton("xs+210", "Submit").OnEvent("Click", this.__mapDrive.Bind(this))

        this.show()
    }

    networkLocation := "\\192.168.20.x\y"
    driveLocation   := 1

    __setNetLocation(guiObj, *)   => this.networkLocation := guiObj.Value
    __setDriveLocation(guiObj, *) => this.driveLocation := guiObj.Value

    __generateLetterArr() {
        arr := []
        mappedList := this.__inUse()
        loop 26 {
            indexLetter := Chr(64+A_Index)
            toPush := mappedList.Has(indexLetter) ? indexLetter ": " mappedList.Get(indexLetter) : indexLetter ":"
            arr.Push(toPush)
        }
        return arr
    }

    __inUse() {
        drives := Map()
        driveList := cmd.result("net use")
        loop {
            if !colon := InStr(driveList, ":",,, A_Index)
                break
            letter := SubStr(driveList, colon-1, 1)
            path   := SubStr(driveList, backslash := InStr(driveList, "\\",, colon, 1), InStr(driveList, A_Space,, backslash, 1)-backslash)
            drives.Set(letter, path)
        }
        return drives
    }

    __mapDrive(*) {
        ;// net use N: /delete
        ;// net use N: \\192.168.20.5\storage
        cmd.run(,, Format("net use {}: /delete", Chr(64+this.driveLocation)))
        cmd.run(,, Format("net use {}: {}", Chr(64+this.driveLocation), this.networkLocation))
        this.Destroy()
    }
}

drivePicker()