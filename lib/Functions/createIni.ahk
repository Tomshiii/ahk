;// generating a baseline settings.ini file

/**
 * @param {params1} installLocation (usually A_MyDocuments "\tomshi")
 * @param {params2-26} settingsIni these are the settings.ini entries in order
 */
createIni(params*) {
    if !DirExist(params[1])
        DirCreate(params[1])
    if FileExist(params[1] "\settings.ini")
        FileDelete(params[1] "\settings.ini")
    FileAppend(Format("
    (
        [Settings]
        update check={}
        beta update check={}
        dark mode={}
        run at startup={}
        autosave check checklist={}
        tooltip={}
        checklist tooltip={}
        checklist wait={}

        [Adjust]
        adobe GB={}
        adobe FS={}
        autosave MIN={}
        game SEC={}
        multi SEC={}
        prem year={}
        ae year={}
        premVer={}
        aeVer={}
        psVer={}
        resolveVer={}

        [Track]
        adobe temp={}
        working dir={}
        first check={}
        block aware={}
        monitor alert={}
        version={}
    )", params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], params[10], params[11], params[12], params[13], params[14], params[15], params[16], params[17], params[18], params[19], params[20], params[21], params[22], params[23], params[24], params[25], params[26])
    , params[1] "\settings.ini")
}