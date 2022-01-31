;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9

; ===========================================================================================================================================
;
;		Windows Scripts \\ Last updated: v2.9
;
; ===========================================================================================================================================
/* youMouse()
 a function to skip in youtube
 @param tenS is the hotkey for 10s skip in your direction of choice
 @param fiveS is the hotkey for 5s skip in your direction of choice
 */
 youMouse(tenS, fiveS)
 {
     if A_PriorKey = "Mbutton" ;ensures the hotkey doesn't fire while you're trying to open a link in a new tab
         return
     if WinExist("YouTube")
     {
         lastactive := WinGetID("A") ;fills the variable [lastavtive] with the ID of the current window
         WinActivate() ;activates Youtube if there is a window of it open
         sleep 25 ;sometimes the window won't activate fast enough
         if GetKeyState(longSkip, "P") ;checks to see if you have a second key held down to see whether you want the function to skip 10s or 5s. If you hold down this second button, it will skip 10s
             SendInput(%&tenS%)
         else
             SendInput(%&fiveS%) ;otherwise it will send 5s
         WinActivate(lastactive) ;will reactivate the original window
     }
 }
 
 /* monitorWarp()
  warp anywhere on your desktop
  */
 monitorWarp(x, y)
 {
     coords()
     MouseMove(%&x%, %&y%, 2) ;I need the 2 here as I have multiple monitors and things can be funky moving that far that fast. random ahk problems. Change this if you only have 1/2 monitors and see if it works fine for you
 }
 
 /* moveWin()
  A function that will check to see if you're holding the left mouse button, then move any window around however you like
  @param key is what key(s) you want the function to press to move a window around (etc. #Left/#Right)
  */
  moveWin(key)
  {
     if WinActive("ahk_class CabinetWClass") ;this if statement is to check whether windows explorer is active to ensure proper right click functionality is kept
         {
             if A_ThisHotkey = "RButton"
                 {
                     if not GetKeyState("LButton", "P") ;checks to see if the Left mouse button is held down, if it isn't, the below code will fire. This is here so you can still right click and drag
                         {
                             SendInput("{RButton Down}")
                             KeyWait("RButton")
                             SendInput("{RButton Up}")
                             return
                         }
                 }
         }
     if not GetKeyState("LButton", "P") ;checks for the left mouse button as without this check the function will continue to work until you click somewhere else
         {
             SendInput("{" A_ThisHotkey "}")
             return
         }
     else
         {
             window := WinGetTitle("A") ;grabs the title of the active window
             SendInput("{LButton Up}") ;releases the left mouse button to stop it from getting stuck
             if A_ThisHotkey = minimiseHotkey ;this must be set to the hotkey you choose to use to minimise the window
                 WinMinimize(window)
             if A_ThisHotkey = maximiseHotkey ;this must be set to the hotkey you choose to use to maximise the window
                 WinMaximize(window)
             SendInput(%&key%)
         }
  }
 
 ; ===========================================================================================================================================
 ;
 ;		discord \\ Last updated: v2.9.2
 ;
 ; ===========================================================================================================================================
 /* disc()
  This function uses an imagesearch to look for buttons within the right click context menu as defined in the screenshots in \ahk\ImageSearch\disc[button].png
  @param button in the png name of a screenshot of the button you want the function to press
  */
 disc(button)
 ;NOTE THESE WILL ONLY WORK IF YOU USE THE SAME DISPLAY SETTINGS AS ME (otherwise you'll need your own screenshots.. tbh you'll probably need your own anyway). YOU WILL LIKELY NEED YOUR OWN SCREENSHOTS AS I HAVE DISCORD ON A VERTICAL SCREEN SO ALL MY SCALING IS WEIRD
 ;dark theme
 ;chat font scaling: 20px
 ;space between message groups: 16px
 ;zoom level: 100
 ;saturation; 70%
 ;ensure this function only fires if discord is active ( #HotIf WinActive("ahk_exe Discord.exe") ) - VERY IMPORTANT
 {
     KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
     coordw() ;important to leave this as window as otherwise the image search function will fail to find things
     MouseGetPos(&x, &y)
     WinGetPos(,, &width, &height, "A") ;gets the width and height to help this function work no matter how you have discord
     blockOn()
     click("right") ;this opens the right click context menu on the message you're hovering over
     sleep 50 ;sleep required so the right click context menu has time to open
     if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% + "400", "*2 " Discord %&button%) ;searches for the button you've requested
             MouseMove(%&xpos%, %&ypos%)
     else
         {
             sleep 500 ;this is a second attempt incase discord was too slow and didn't catch the button location the first time
             if ImageSearch(&xpos, &ypos, %&x% - "200", %&y% -"400",  %&x% + "200", %&y% + "400", "*2 " Discord %&button%)
                 MouseMove(%&xpos%, %&ypos%) ;Move to the location of the button
             else ;if everything fails, this else will trigger
                 {
                     MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
                     blockOff()
                     toolFind("the requested button", "2000") ;useful tooltip to help you debug when it can't find what it's looking for
                     return
                 }
         }
     Click
     sleep 100
     if A_ThisHotkey = replyHotkey ;SET THIS ACTIVATION HOTKEY IN THE KEYBOARD SHORTCUTS.ini FILE
         {
             if ImageSearch(&xdir, &ydir, 0, %&height%/"2", %&width%, %&height%, "*2 " Discord "DiscDirReply.bmp") ;this is to get the location of the @ notification that discord has on by default when you try to reply to someone. if you prefer to leave that on, remove from the above sleep 100, to the last else below. The coords here are to search the entire window (but only half the windows height) - (that's what the WinGetPos is for) for the sake of compatibility. if you keep discord at the same size all the time (or have monitors all the same res) you can define these coords tighter if you wish but it isn't really neccessary.
                 {
                     MouseMove(%&xdir%, %&ydir%) ;moves to the @ location
                     Click
                     MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
                     blockOff()
                 }
             else
                 {
                     MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
                     blockOff()
                     toolFind("the @ ping button`nor you're in a DM", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
                     return
                 }
         }
     else
         {
             MouseMove(%&x%, %&y%) ;moves the mouse back to the original coords
             blockOff()
         }
 }
 
 /*
  This function will toggle the location of discord's window position
  */
 discLocation()
 {
     position0 := 4480, -123, 1081, 1537 ;we use position0 as a reference later to compare against another value. This is the same coordinates as disc0() down below, make sure you change THEM BOTH
     position1 := -1080, 75, 1080, 1537 ;we use position1 as a reference later to compare against another value. This is the same coordinates as disc1() down below, make sure you change THEM BOTH
     disc0() { ;define your first (defult) position here
         WinMove(4480, -123, 1081, 1537, "ahk_exe Discord.exe")
     }
     disc1() { ;define your second position here
         WinMove(-1080, 75, 1080, 1537, "ahk_exe Discord.exe")
     }
     try { ;this try is here as if you close a window, then immediately try to fire this function there is no "original" window
         original := WinGetID("A")
     } catch as e {
         toolCust("you tried to assign a closed`n window as the last active", "4000")
         SendInput("{Click}")
         return
     }
     static toggle := 0 ;this is what allows us to toggle discords position
     if not WinExist("ahk_exe Discord.exe")
         {
             run("C:\Users\" A_UserName "\AppData\Local\Discord\Update.exe --processStart Discord.exe") ;this will run discord
             WinWait("ahk_exe Discord.exe")
             sleep 1000
             WinActivate("ahk_exe Discord.exe")
             result := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
             if result = position0 ;here we are comparing discords current position to one of the values we defined above
                 {
                     toggle := 0
                     return
                 }
             if result = position1 ;here we are comparing discords current position to one of the values we defined above
                 {
                     toggle := 1
                     return
                 }
             if !(result = position0 or result = position1) ;here we're saying if it isn't in EITHER position we defined above, move it into a position
                 {
                     toggle := 0
                     disc0()
                     return
                 }
             return
         }
     WinActivate("ahk_exe Discord.exe")
     startLocation := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord
     if toggle < 1
         {
             toggle += 1
             disc0()
             newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
             if newPos = startLocation ;so we can compare and ensure it has moved
                 disc1()
             return
         }
     if toggle = 1
         {
             toggle -= 1
             disc1()
             newPos := WinGetPos(&X, &Y, &width, &height, "A") ;this will grab the x/y and width/height values of discord AGAIN
             if newPos = startLocation ;so we can compare and ensure it has moved
                 disc0()
             return
         }
     if toggle > 1 or toggle < 0 ;this is here just incase the value ever ends up bigger/smaller than it's supposed to
         {
             toggle := 0
             toolCust("stop spamming the function please`nthe functions value was to large/small", "1000")
             return
         }
     try { ;this is here once again to ensure ahk doesn't crash if the original window doesn't actual exist anymore
         WinActivate(original)
     } catch as e {
         toolCust("couldn't find original window", "2000")
         return
     }
 }