/**
 * This function takes care of generating the required checklist.ini file
 * @param {String} filelocation is the dir location we pass in so the function knows where to generate the file
 * @param {everything else} vars is for `trythenDel()` to be able to pass its required values in without needing to copy this code. Omit in every other occasion
 */
generateINI(filelocation, FP := 0, SP := 0, TW := 0, YT := 0, TR := 0, SFX := 0, MU := 0, PT := 0, INTR := 0, TI := 0, TOOL := 1, DARK := 1, VER := version) => FileAppend(
    Format("
    (
        [Checkboxes]
        First Pass={}
        Second Pass={}
        Twitch Overlay={}
        Youtube Overlay={}
        Transitions={}
        SFX={}
        Music={}
        Patreon={}
        Intro={}
        [Info]
        time={}
        tooltip={}
        dark={}
        ver={}
    )"
    , FP, SP, TW, YT, TR, SFX, MU, PT, INTR, TI, TOOL, DARK, VER)
, filelocation)

