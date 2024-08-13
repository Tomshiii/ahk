/**
 * Values of adobe versions that share their images with each other.
 * Versions being listed here do NOT ensure they are completely compatible with my scripts, I do not have the manpower to extensively test versions I do not use consistently.
 * The only versions that are actively tested against are the versions listed at the top of the respective class libraries in this repo
 * @param firstvalue is the NEW version
 * @param secondvalue is the version it's copying (so the ACTUAL folder)
 */
class adobeVers {
    Premiere := {
        ;// VER      || IMAGE VER    ||  SUBSEQUENT MINOR VERS
        22: Map(
            "v22.4",    "v22.3.1",
            "22.5",     "v22.3.1",
            "22.6",     "v22.3.1",
        ),
        23: Map(
            "v23.0",    "v22.3.1",
            "v23.1",    "v22.3.1",
            "v23.2",    "v22.3.1",
            "v23.3",    "v22.3.1",
            "v23.4",    "v22.3.1",
            "v23.5",    "v22.3.1",
            "v23.6",    "v22.3.1",      "v23.6.2", "v22.3.1", "v23.6.4", "v22.3.1", "v23.6.5", "v22.3.1",
        ),
        24: Map(
            "v24.0",    "v22.3.1",      "v24.0.3", "v22.3.1",
            "v24.1",    "v22.3.1",
            "v24.2",    "v22.3.1",      "v24.2.1", "v22.3.1",
            ; "v24.3",    "v22.3.1",
            ; "v24.4",    "v24.3",      ;// some UI changes occur here so this version has its own folder
            "v24.4.1", "v24.4",
            "v24.5",    "v24.4",
            ; "v24.6",    "v24.4",      ;// UI refresh might occur here, brand new images will need to be made by the user
        ),
        25: Map(
            "v25.0",     "v24.6" ;// UI refresh might actually happen here - 24.6 might be skipped or might not end up including the new UI
        )
    }
    AE := {
        ;// VER      || IMAGE VER    ||  SUBSEQUENT MINOR VERS
        23: Map(
            "v23.0",    "v22.6",
            "v23.1",    "v22.6",
            "v23.2",    "v22.6",        "v23.2.1", "v22.6",
            "v23.3",    "v22.6",
            "v23.4",    "v22.6",
            "v23.5",    "v22.6",
            "v23.6",    "v22.6",        "v23.6.2", "v22.6", "v23.6.5", "v22.6",
        ),
        24: Map(
            "v24.0",    "v22.6",        "v24.0.1", "v22.6", "v24.0.3", "v22.6",
            "v24.1",    "v22.6",
            "v24.2",    "v22.6",        "v24.2.1", "v22.6",
            "v24.3",    "v22.6",
            "v24.4",    "v22.6",        "v24.4.1", "v22.6",
            ; "v24.5",    "v22.6",      ;// UI refresh might occur here, brand new images will need to be made by the user
            "v24.6",    "v24.5",        ;// UI refresh might occur here instead of 24.5
        )
    }
    PS := {
        ;// VER      || IMAGE VER    ||  SUBSEQUENT MINOR VERS
        24: Map(
            "v24.0.1",  "v24.3",
            "v24.1",    "v24.3",        "v24.1.1", "v24.3",
            "v24.2",    "v24.3",        "v24.2.1", "v24.3",
            "v24.4.1",  "v24.3",
            "v24.5",    "v24.3",
            "v24.6",    "v24.3",
            "v24.7",    "v24.3",        "v24.7.1", "v24.3", "v24.7.2", "v24.3", "v24.7.3", "v24.3",
        ),
        25: Map(
            "v25.0",    "v24.3",
            "v25.1",    "v24.3",
            "v25.2",    "v24.3",
            "v25.3",    "v24.3",        "v25.3.1", "v24.3",
            "v25.4",    "v24.3",
            "v25.5",    "v24.3",        "v25.5.1", "v24.3",
            "v25.6",    "v24.3",
            "v25.7",    "v24.3",
            "v25.8",    "v24.3",
            "v25.9",    "v24.3",        "v25.9.1", "v24.3",
            "v25.10",   "v24.3",
            "v25.11",   "v24.3",
            "v25.12",   "v24.3",
        )
    }

    static maps := [this().Premiere, this().AE, this().PS]
    static which := ["Premiere", "AE", "Photoshop"]

    /**
     * Generates adobe symlink folders.
     * This function will only generate symlink folders for versions of adobe programs that you currently have installed - this is a failsafe to stop the cmd command
     * failing due to it growing too large. If the resulting string from this function is too large for 1 cmd command it will insert `|||` at the end of the string
     * that can then be strsplit by the calling code.
     * @param {String} imgsrchPath the directory path to the `ImageSearch` folder generally found within `Support Files`
     * @param {Boolean} symScript determines whether the function is being called from the main `CreateSymLink.ahk` script or not
     * @param {String} adobecmd passes in additional cmdline commands that will run before the symlink generation. Used within the main `CreateSymLink.ahk` script
     * @param {String} installPath provide an alternative installation path of your adobe programs default location is `A_ProgramFiles "\Adobe\"`
     * @returns {String} returns a long string containing the command to be sent to cmd to generate all symlinks.
     * ### _If the resulting string from this function is too large for 1 cmd command it will insert `|||` at the end of the string that can then be strsplit by the calling code._
     */
    static __generate(imgsrchPath, symScript := false, adobecmd := "", installPath := "") {
        execute := 1
        if !installPath
            installPath := A_ProgramFiles "\Adobe\"
        pr := Map(), ae := Map(), ps := Map()
        loop files installPath "*", "D" {
            premCheck := InStr(A_LoopFileName, "Adobe Premiere Pro 20"), aeCheck := InStr(A_LoopFileName, "Adobe After Effects 20"), psCheck := InStr(A_LoopFileName, "Adobe Photoshop 20")
            if !premCheck && !aeCheck && !psCheck
                continue
            if premCheck
                pr.Set(SubStr(A_LoopFileName, -2), 1)
            if aeCheck
                ae.Set(SubStr(A_LoopFileName, -2), 1)
            if psCheck {
                psYear := SubStr(A_LoopFileName, -2)
                ps.Set(Integer(psYear), 1)
                if !ps.Has(Integer(psYear)-1)
                    ps.Set(Integer(psYear)-1, 1)
                if !ps.Has(Integer(psYear)+1)
                    ps.Set(Integer(psYear)+1, 1)
            }
        }

        ;// this is the array containing the objects
        for k, v in this.maps {
            which := this.which[k]

            ;// this is accessing the objects individually
            ;// name in this instance is the version number ie. 23/24
            ;// val is the resulting map containing all the individual key, value pairs of the versions for that year
            for name, val in v.OwnProps() {
                switch which {
                    case "Premiere":
                        if !pr.Has(name)
                            continue
                    case "AE":
                        if !ae.Has(name)
                            continue
                    case "Photoshop":
                        if !ps.Has(Integer(name))
                            continue
                }

                ;// this is the individual versions
                for k2, v2 in val {
                    ;// will remove any symlinks before attempting to create it so that it doesn't error out
                    if DirExist(path := imgsrchPath "\" which "\" k2) && InStr(FileGetAttrib(path), "l") ;// checks to make sure it's still a symbolic link
                        DirDelete(path)
                    ;// build base command only if symScript is set to false - otherwise `CreateSymLink` builds its own initial command
                    if execute == 1 && symScript == false {
                        adobecmd := Format('mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}"', adobecmd, imgsrchPath, k2, v2, which)
                        execute++
                        continue
                    }
                    ;// checking to see if we need to break up the command bc of its length
                    if (!InStr(adobecmd, "|||") && (StrLen(adobecmd) + StrLen(Format(' && mklink /D "{1}\{4}\{2}" "{1}\{4}\{3}"', imgsrchPath, k2, v2, which))) >= 8191) ||
                        ((StrLen(Format('{1} && mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}"', StrLen(SubStr(adobecmd, InStr(adobecmd, "|||",,, -1))), imgsrchPath, k2, v2, which))) >= 8191) {
                        adobecmd := Format('{1} ||| mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}"', adobecmd, imgsrchPath, k2, v2, which)
                        continue
                    }
                    adobecmd := Format('{1} && mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}"', adobecmd, imgsrchPath, k2, v2, which)
                }
            }
        }
        return adobecmd
    }
}