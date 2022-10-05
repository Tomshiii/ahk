
/**
 * This function takes care of generating the required checklist.ini file
 * @param {any} filelocation is the dir location we pass in so the function knows where to generate the file
 * @param {everything else} - is for `trythenDel()` to be able to pass its required values in without needing to copy this code. Omitt in every other occasion
 */
generateINI(filelocation, FP := 0, SP := 0, TW := 0, YT := 0, TR := 0, SFX := 0, MU := 0, PT := 0, INTR := 0, TI := 0, TOOL := 1, DARK := 1, VER := version) => FileAppend("[Checkboxes]`nFirst Pass=" FP "`nSecond Pass=" SP "`nTwitch Overlay=" TW "`nYoutube Overlay=" YT "`nTransitions=" TR "`nSFX=" SFX "`nMusic=" MU "`nPatreon=" PT "`nIntro=" INTR "`n[Info]`ntime=" TI "`ntooltip=" TOOL "`ndark=" DARK "`nver=" VER, filelocation)