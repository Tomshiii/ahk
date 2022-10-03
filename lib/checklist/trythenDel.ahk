/**
 * This function is called when the contents of the current checklist.ini file needs to be read and then regenerated
 * @param {any} which dictates what version is written in the .ini file
 */
trythenDel(which)
    {
        try {
            FP := IniRead(checklist, "Checkboxes", "FirstPass", "0")
            SP := IniRead(checklist, "Checkboxes", "SecondPass", "0")
            TW := IniRead(checklist, "Checkboxes", "TwitchOverlay", "0")
            YT := IniRead(checklist, "Checkboxes", "YoutubeOverlay", "0")
            TR := IniRead(checklist, "Checkboxes", "Transitions", "0")
            SFX := IniRead(checklist, "Checkboxes", "SFX", "0")
            MU := IniRead(checklist, "Checkboxes", "Music", "0")
            PT := IniRead(checklist, "Checkboxes", "Patreon", "0")
            INTR := IniRead(checklist, "Checkboxes", "Intro", "0")
            TI := IniRead(checklist, "Info", "time", "0")
            TOOL := IniRead(checklist, "Info", "tooltip", "1")
            DARK := IniRead(checklist, "Info", "dark", "1")
            VER := IniRead(checklist, "Info", "ver")
        }
        FileDelete(checklist)
        FileAppend("[Checkboxes]`nFirstPass=" FP "`nSecondPass=" SP "`nTwitchOverlay=" TW "`nYoutubeOverlay=" YT "`nTransitions=" TR "`nSFX=" SFX "`nMusic=" MU "`nPatreon=" PT "`nIntro=" INTR "`n[Info]`ntime=" TI "`ntooltip=" TOOL "`ndark=" DARK "`nver=", checklist)
        if which = "VER"
            FileAppend(VER, checklist)
        if which = "version"
            FileAppend(version, checklist)
    }