; { \\ #Includes
#Include <Functions\errorLog>
; }

class clients {
    static chloe := "Baeginning"
    static d0yle := "D0yle"
    static alex :=  "alexandralynne"
}

openSocials(which) {
    if (which != "youtube" && which != "twitch") || Type(which) != "string"
        {
            ;// throw
            errorLog(ValueError("Incorrect value in Parameter #1", -1, which)
                        , A_ThisFunc "()",,, 1)
        }
    if !WinExist(Editors.Premiere.winTitle) && !WinExist(Editors.AE.winTitle)
        {
            errorLog(Error("Editor not currently open", -1)
                        , A_ThisFunc "()",, 1)
            return
        }
    client := WinGet.ProjClient()
    whichClient := unset
    ;// attempt to reference the class
    ;// this value might not exist so we have to put it in a try to avoid throwing an error
    ;// if the value doesn't exist we can default back to the project clientname
    try {
        whichClient := clients.%client%
    }
    if !IsSet(whichClient)
        whichClient := client
    switch which {
        case "youtube":
            link := "https://www.youtube.com/@" whichClient "/videos"
            title := whichClient A_Space "- YouTube"
        case "twitch":
            link := "https://www.twitch.tv/" whichClient "/videos"
            title := whichClient "'s Videos - Twitch"
    }
    ;// if a client has a different handle
    ;// combine this example and the switch above
    /* switch which {
        case "youtube":
            if client = "x"
                client := "y"
        case "twitch":
            if client = "x"
                client := "z"
    } */
    if WinExist(title)
        {
            WinActivate()
            return
        }
    Run(link)
}