/**
 * Values of adobe versions that share their images with each other.
 * Versions being listed here do NOT ensure they are completely compatible with my scripts, I do not have the manpower to extensively test version I do not use consistently
 * @param firstvalue is the NEW version
 * @param secondvalue is the version it's copying (so the ACTUAL folder)
 */
class adobeVers {
    Premiere := Map(
        "v23.0",    "v22.3.1",
        "v23.1",    "v22.3.1",
        "v23.2",    "v22.3.1",
        "v23.3",    "v22.3.1",
        "v23.4",    "v22.3.1",
        "v23.5",    "v22.3.1",
        "v23.6",    "v22.3.1",
        "v24.0",    "v22.3.1",
        "v24.1",    "v22.3.1",
    )
    AE := Map(
        "v23.0",    "v22.6",
        "v23.1",    "v22.6",
        "v23.2",    "v22.6",
        "v23.2.1",  "v22.6",
        "v23.3",    "v22.6",
        "v23.4",    "v22.6",
        "v23.5",    "v22.6",
        "v23.6",    "v22.6",
        "v24.0",    "v22.6",
        "v24.0.1",    "v22.6",
    )
    PS := Map(
        "v24.0.1",  "v24.3",
        "v24.1",    "v24.3",
        "v24.1.1",  "v24.3",
        "v24.2",    "v24.3",
        "v24.2.1",  "v24.3",
        "v24.4.1",  "v24.3",
        "v24.5",    "v24.3",
        "v24.6",    "v24.3",
        "v24.7",    "v24.3",
        "v24.7.1",  "v24.3",
        "v25.0",    "v24.3",
    )

    static maps := [this().Premiere, this().AE, this().PS]
    static which := ["Premiere", "AE", "Photoshop"]

    /**
     * Generates adobe symlink folders
     * @param {String} imgsrchPath the directory path to the `ImageSearch` folder generally found within `Support Files`
     * @param {Boolean} symScript determines whether the function is being called from the main `CreateSymLink.ahk` script or not
     * @param {String} adobecmd passes in additional cmdline commands that will run before the symlink generation. Used within the main `CreateSymLink.ahk` script
     */
    static __generate(imgsrchPath, symScript := false, adobecmd := "") {
        execute := 1
        for k, v in this.maps {
            which := this.which[k]
            for k2, v2 in v {
                ;// will remove any symlinks before attempting to create it so that it doesn't error out
                if DirExist(path := imgsrchPath "\" which "\" k2) && InStr(FileGetAttrib(path), "l") ;// checks to make sure it's still a symbolic link
                    DirDelete(path)
                if execute == 1 && symScript == false
                    adobecmd := Format('mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}" ', adobecmd, imgsrchPath, k2, v2, which)
                else
                    adobecmd := Format('{1} && mklink /D "{2}\{5}\{3}" "{2}\{5}\{4}" ', adobecmd, imgsrchPath, k2, v2, which)
                execute++
            }
        }
        return adobecmd
    }
}