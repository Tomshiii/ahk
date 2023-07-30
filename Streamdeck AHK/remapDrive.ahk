; { \\ #Includes
#Include <Classes\cmd>
#Include <GUIs\tomshiBasic>
; }

;// you may notice the command prompt flash before this GUI opens
;// that is to simply retrieve a list of all currently mapped network drives so a dropdown list within the GUI
;// shows accurate information

;// manually remapping my nas is annoying so here's a script to do it for me
localIp := "\\192.168.20.x\y"

/**
 * A GUI designed to quickly and easily reassign mapped network locations.
 * @param {String} localIp the local ip you wish for the edit box to prefill to make life easier. Defaults to `\\192.168.20.x\y`
 */
class drivePicker extends tomshiBasic {
    __New(localIp) {
        this.networkLocation := localIp
        super.__New(,,, "Pick Drive Letter & Location")
        this.AddText("Section", "Network Location: ")
        this.AddEdit("xs+120 ys-3 w150 -WantReturn", this.networkLocation).OnEvent("Change", this.__setNetLocation.Bind(this))
        this.AddText("xs Section", "Drive Location: ")
        this.AddDropDownList("xs+120 ys-3 Sort w150 Choose" this.driveLocation, this.__driveList()).OnEvent("Change", this.__setDriveLocation.Bind(this))
        this.AddCheckbox("x+10 y+-20 Checked" this.persistentVal, "Persistent?").OnEvent("Click", (*) => this.persistentVal := !this.persistentVal)
        this.AddButton("xs+190 Section", "Map Drive").OnEvent("Click", this.__mapDrive.Bind(this))
        this.AddButton("xs-115 ys", "Delete Location").OnEvent("Click", (*) => cmd.deleteMappedDrive(this.driveLocation))

        this.show()
    }

    networkLocation := ""
    driveLocation   := 1
    persistentVal   := 1

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
    __mapDrive(*) => (cmd.mapDrive(this.driveLocation, this.networkLocation, this.persistentVal), this.Destroy())
}

drivePicker(localIp)