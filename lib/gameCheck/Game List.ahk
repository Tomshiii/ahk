;// Add games here!
;// You can get this info using WindowSpy that comes with ahk or you can activate `settingsGUI()` (default hotkey is #F1::) while you have the game active, then press `File >add game to `gameCheck.ahk`. It will attempt to add you game to this list automatically.
;// keep in mind that if the games title has any special characters in it (like a copyright symbol or anything like that) this script may not function correctly

;Format: `GameTitle ahk_exe game.exe`
GroupAdd("games", "Minecraft ahk_exe javaw.exe")
GroupAdd("games", "Terraria ahk_exe Terraria.exe")
GroupAdd("games", "Overwatch ahk_exe Overwatch.exe")
GroupAdd("games", "Sector's Edge ahk_exe sectorsedge.exe")
GroupAdd("games", "Left 4 Dead 2 ahk_exe left4dead2.exe")
GroupAdd("games", "Stardew Valley ahk_exe Stardew Valley.exe")
GroupAdd("games", "Just Cause 3 ahk_exe JustCause3.exe")
GroupAdd("games", "Halo: The Master Chief Collection   ahk_exe MCC-Win64-Shipping.exe")
GroupAdd("games", "BattleBit ahk_exe BattleBit.exe")
GroupAdd("games", "League of Legends ahk_exe League of Legends.exe")
GroupAdd("games", "FarCry ahk_exe FarCry6.exe")
GroupAdd("games", "LEGO ahk_exe streaming_client.exe")
GroupAdd("games", "Just Cause 2: Multiplayer Mod ahk_exe JustCause2.exe")
GroupAdd("games", "Just Cause 3 Multiplayer ahk_exe PlayJCMP.exe")
GroupAdd("games", "Outer Wilds ahk_exe OuterWilds.exe")
GroupAdd("games", "Black Mesa ahk_exe bms.exe")
GroupAdd("games", "Titanfall 2 ahk_exe Titanfall2.exe")
GroupAdd("games", "Halo Infinite ahk_exe HaloInfinite.exe")
GroupAdd("games", "Ratchet & Clank: Rift Apart ahk_exe RiftApart.exe")
; -- leave this line it gets used and is needed in settingsGUI()