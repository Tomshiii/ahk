; { \\ #Includes
#Include <Classes\cmd>
#Include <GUIs\tomshiBasic>
; }

;// manually remapping my nas is annoying so here's a script to do it for me
localIp := "\\192.168.20.x\y"

/**
 * A GUI designed to quickly and easily reassign mapped network locations.
 * @param {String} localIp the local ip you wish for the edit box to prefill to make life easier. Defaults to `\\192.168.20.x\y`
 */
class drivePicker extends tomshiBasic {
    __New(localIp) {
        this.networkLocation := localIp
        super.__New(,,, "Pick Drive")
        this.AddText("Section", "Network Location: ")
        this.AddEdit("xs+120 ys-3 w150 -WantReturn", this.networkLocation).OnEvent("Change", this.__setNetLocation.Bind(this))
        this.AddText("xs Section", "Drive Location: ")
        this.AddDropDownList("xs+120 ys-3 Sort w150 Choose" this.driveLocation, this.__driveList()).OnEvent("Change", this.__setDriveLocation.Bind(this))
        this.AddButton("xs+210 default", "Submit").OnEvent("Click", this.__mapDrive.Bind(this))

        this.show()
    }

    networkLocation := ""
    driveLocation   := 1

    __setNetLocation(guiObj, *)   => this.networkLocation := guiObj.Value
    __setDriveLocation(guiObj, *) => this.driveLocation   := guiObj.Value

    /**
     * retrieves a map containing all in use network drive locations, then turns tha tinto an array so the GUI dropdown list can use that information and visually how which drives are already in use.
     */
    __driveList() {
        driveMap := cmd.inUseDrives()
        drivesArr := []
        loop 26 {
            indexLetter := Chr(64+A_Index)
            toPush := driveMap.Has(indexLetter) ? indexLetter ": " driveMap.Get(indexLetter) : indexLetter ":"
            drivesArr.Push(toPush)
        }
        return drivesArr
    }

    /** rempats the desired drive to the specified ip address */
    __mapDrive(*) => (cmd.mapDrive(this.driveLocation, this.networkLocation), this.Destroy())
}

drivePicker(localIp)