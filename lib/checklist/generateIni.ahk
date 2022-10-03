
/**
 * This function takes care of generating the required checklist.ini file
 * @param {any} filelocation is the dir location we pass in so the function knows where to generate the file
 */
generateINI(filelocation) => FileAppend("[Checkboxes]`nFirst Pass=0`nSecond Pass=0`nTwitch Overlay=0`nYoutube Overlay=0`nTransitions=0`nSFX=0`nMusic=0`nPatreon=0`nIntro=0`n[Info]`ntime=0`ntooltip=1`ndark=1`nver=" version, filelocation)