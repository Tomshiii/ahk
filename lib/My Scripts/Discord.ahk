; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\Apps\Discord>
; }

;disceditHotkey;
SC03A & e::discord.button("edit") ;edit the message you're hovering over
;discreplyHotkey;
SC03A & r::discord.button("reply") ;reply to the message you're hovering over ;this reply hotkey has specific code just for it within the function. This activation hotkey needs to be defined in Keyboard Shortcuts.ini in the [Hotkeys] section
;discreactHotkey;
SC03A & a::discord.button("react") ;add a reaction to the message you're hovering over
;discdeleteHotkey;
SC03A & d::discord.button("delete") ;delete the message you're hovering over. Also hold shift to skip the prompt
^+t::try Run(ptf["DiscordTS"]) ;opens discord timestamp program [https://github.com/TimeTravelPenguin/DiscordTimeStamper]


;discitalicHotkey;
*::discord.surround("*")
;discBacktickHotkey;
`::discord.surround("``")
;discParenthHotkey;
(::discord.surround("()")

;discserverHotkey;
F1::discord.Unread("servers") ;will click any unread servers
;discmsgHotkey;
F2::discord.Unread("channels") ;will click any unread channels
;discdmHotkey;
F3::discord.DMs()