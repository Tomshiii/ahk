;Add games here! you can get this info using WindowSpy that comes with ahk or you can activate `settingsGUI()` (default hotkey is #F1::) while you have the game active, then press the "add game to `gameCheck()`" button. It will attemp to add you game to this list automatically.
;Format: `GameTitle ahk_exe game.exe`
GroupAdd("games", "Minecraft ahk_exe javaw.exe") ;minecraft
GroupAdd("games", "Terraria ahk_exe Terraria.exe") ;terraria
GroupAdd("games", "Overwatch ahk_exe Overwatch.exe") ;overwatch
GroupAdd("games", "Sector's Edge ahk_exe sectorsedge.exe") ;sectorsedge
GroupAdd("games", "Left 4 Dead 2 ahk_exe left4dead2.exe") ;lfd2
GroupAdd("games", "Stardew Valley ahk_exe Stardew Valley.exe")
GroupAdd("games", "Just Cause 3 ahk_exe JustCause3.exe")
GroupAdd("games", "Halo: The Master Chief Collection   ahk_exe MCC-Win64-Shipping.exe")
; -- leave this line it gets used and is needed in settingsGUI()