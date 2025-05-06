; { \\ #Includes
#Include Vers.ahk
; }

/**
 * Values of adobe versions that share their images with each other.
 * Versions being listed here do NOT ensure they are completely compatible with my scripts, I do not have the manpower to extensively test versions I do not use consistently.
 * The only versions that are actively tested against are the versions listed at the top of the respective class libraries in this repo
 * @param firstvalue is the NEW version
 * @param secondvalue is the version it's copying (so the ACTUAL folder)
 */
class adobeVers {
    Premiere := {
        22: premVers.v22,
        23: premVers.v23,
        24: premVers.v24,
        25: premVers.v25
    }
    AE := {
        23: aeVers.v23,
        24: aeVers.v24,
        25: aeVers.v25
    }
    PS := {
        ;// to keep the version list short I'll periodically reduce the amount of versions it creates.
        ;// uncomment them if you use a version in here
        ;// however, a note: the `deleteAdobeSyms.ahk` script will now similarly no longer delete these symlink folders
        ;// so if you've already installed my repo before, you'll need to manually delete them

        ; 24: psVers.v24,
        25: psVers.v25,
        26: psVers.v26
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
                /* if !ps.Has(Integer(psYear)-1)
                    ps.Set(Integer(psYear)-1, 1) */
                if !ps.Has(Integer(psYear)+1)
                    ps.Set(Integer(psYear)+1, 1)
            }
        }
        ;// since the beta cycle usually eventually ends up a version number ahead of what the current years is, we need to check if the beta folder exists
        ;// and if it does, add a number +1 from the current year, otherwise beta versions will not show in the selector
        if DirExist(installPath "Adobe Premiere Pro (Beta)") && !DirExist(installPath "Adobe Premiere Pro 20" SubStr((A_YYYY+1), -2))
            pr.Set(SubStr((A_YYYY+1), -2), 1)
        if DirExist(installPath "Adobe After Effects (Beta)") && !DirExist(installPath "Adobe After Effects 20" SubStr((A_YYYY+1), -2))
            ae.Set(SubStr((A_YYYY+1), -2), 1)

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
                    if (!InStr(adobecmd, "|||") && (StrLen(adobecmd) + StrLen(Format(' && mklink /D "{1}\{4}\{2}" "{1}\{4}\{3}"', imgsrchPath, k2, v2, which))) >= 8160) ||
                        ((StrLen(Format('{1} && mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}"', imgsrchPath, k2, v2, which)) + StrLen(SubStr(adobecmd, InStr(adobecmd, "|||",,, -1)))) >= 8160) {
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