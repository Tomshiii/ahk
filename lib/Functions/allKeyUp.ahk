; { \\ #Includes
#Include <Classes\tool>
; }

/**
 * This function loops through as many possible SC and vk keys and sends the {Up} keystroke for it.
 * Originally from: 東方永夜抄#4008 in the ahk discord
 * this link may die: https://discord.com/channels/115993023636176902/1057690143231840347/1057704109408522240
 */
allKeyUp() {
    loop 128 {
        which := Format("sc{:x}", A_Index)
        Send "{Blind}{" which " Up}"
        ToolTip("Sending " GetKeyName(which) " Up")
    }
    loop 256 {
        which := Format("vk{:x}", A_Index)
        Send "{" which " Up}"
        ToolTip("Sending " GetKeyName(which) " Up")
    }
    tool.Cust("Sending {Up} commands complete")
}