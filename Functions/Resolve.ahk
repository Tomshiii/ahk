;\\CURRENT SCRIPT VERSION\\This is a "script" local version and doesn't relate to the Release Version
;\\v2.9

/* Rscale()
 A function to set the scale of a video within resolve
 @param value is the number you want to type into the text field (100% in reslove requires a 1 here for example)
 @param property is the property you want this function to type a value into (eg. zoom)
 @param plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
 */
 Rscale(value, property, plus)
 {
     KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
     coordw()
     blockOn()
     SendInput(resolveSelectPlayhead)
     MouseGetPos(&xpos, &ypos)
     if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
         goto video
     else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
         {
             MouseMove(%&xi%, %&yi%)
             click ;this opens the inspector tab
             goto video
         }
     video:
     if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "video.png") ;if you're already in the video tab, it'll find this image then move on
         goto rest
     else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;if you aren't already in the video tab, this line will search for it
         {
             MouseMove(%&xn%, %&yn%)
             click ;"2196 139" ;this highlights the video tab
         }
     else
         {
             blockOff()
             MouseMove(%&xpos%, %&ypos%)
             toolFind("video tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     rest:
     if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% ".png") ;searches for the property of choice
         MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
     else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
         MouseMove(%&xz% + %&plus%, %&yz% + "5")
     else
         {
             blockOff()
             toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     click
     SendInput(%&value%)
     SendInput("{ENTER}")
     MouseMove(%&xpos%, %&ypos%)
     SendInput("{MButton}")
     blockOff()
 }
 
 /* rfElse()
  A function that gets nested in the resolve scale, x/y and rotation scripts
  @param data is what the script is typing in the text box to reset its value
  */
 rfElse(data)
 ;this function, as you can probably tell, doesn't use an imagesearch. It absolutely SHOULD, but I don't use resolve and I guess I just never got around to coding in an imagesearch.
 {
     SendInput("{Click Up}")
     sleep 10
     Send(%&data%)
     ;MouseMove, x, y ;if you want to press the reset arrow, input the windowspy SCREEN coords here then comment out the above Send^
     ;click ;if you want to press the reset arrow, uncomment this, remove the two lines below
     ;alternatively you could also run imagesearches like in the other resolve functions to ensure you always end up in the right place
     sleep 10
     Send("{Enter}")
 }
 
 /* REffect()
  A function to apply any effect to the clip you're hovering over within Resolve.
  @param folder is the name of your screenshots of the drop down sidebar option (in the effects window) you WANT to be active - both activated and deactivated
  @param effect is the name of the effect you want this function to type into the search box
  */
 REffect(folder, effect)
 ;This function will, in order;
 ;Check to see if the effects window is open on the left side of the screen
 ;Check to make sure the effects sidebar is expanded
 ;Ensure you're clicked on the appropriate drop down
 ;Open or close/reopen the search bar
 ;Search for your effect of choice, then drag back to the click you were hovering over originally
 {
     KeyWait(A_PriorKey) ;use A_PriorKey when you're using 2 buttons to activate a macro
     coordw()
     blockOn()
     MouseGetPos(&xpos, &ypos)
     if ImageSearch(&xe, &ye, effectx1, effecty1, effectx2, effecty2, "*1 " Resolve "effects.png") ;checks to see if the effects button is deactivated
         {
             MouseMove(%&xe%, %&ye%)
             SendInput("{Click}")
             goto closeORopen
         }
     else if ImageSearch(&xe, &ye, effectx1, effecty1, effectx2, effecty2, "*1 " Resolve "effects2.png") ;checks to see if the effects button is activated
         goto closeORopen
     else ;if everything fails, this else will trigger
         {
             blockOff()
             toolFind("the effects button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
 closeORopen:
     if ImageSearch(&xopen, &yopen, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve "open.png") ;checks to see if the effects window sidebar is open
         goto EffectFolder
     else if ImageSearch(&xclosed, &yclosed, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve "closed.png") ;checks to see if the effects window sidebar is closed
         {
             MouseMove(%&xclosed%, %&yclosed%)
             SendInput("{Click}")
             goto EffectFolder
         }
     else
         {
             blockOff()
             toolFind("open/close button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
 EffectFolder:
     if ImageSearch(&xfx, &yfx, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve %&folder% ".png") ;checks to see if the drop down option you want is activated
         goto SearchButton
     else if ImageSearch(&xfx, &yfx, effectx1, effecty1, effectx2, effecty2, "*2 " Resolve %&folder% "2.png") ;checks to see if the drop down option you want is deactivated
         {
             MouseMove(%&xfx%, %&yfx%)
             SendInput("{Click}")
             goto SearchButton
         }
     else ;if everything fails, this else will trigger
         {
             blockOff()
             toolFind("the fxfolder", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
 SearchButton:
     if ImageSearch(&xs, &ys, effectx1, effecty1 + "300", effectx2, effecty2, "*2 " Resolve "search2.png") ;checks to see if the search icon is deactivated
         {
             MouseMove(%&xs%, %&ys%)
             SendInput("{Click}")
             goto final
         }
     else if ImageSearch(&xs, &ys, 8, 8 + "300", effectx2, effecty2, "*2 " Resolve "search3.png") ;checks to see if the search icon is activated
         {
             MouseMove(%&xs%, %&ys%)
             SendInput("{Click 2}")
             goto final
         }
     else ;if everything fails, this else will trigger
         {
             blockOff()
             toolFind("search button", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
 final:
     sleep 50
     SendInput(%&effect%)
     MouseMove(0, 130,, "R")
     SendInput("{Click Down}")
     MouseMove(%&xpos%, %&ypos%, 2) ;moves the mouse at a slower, more normal speed because resolve doesn't like it if the mouse warps instantly back to the clip
     SendInput("{Click Up}")
     blockOff()
     return
 }
 
 /* rvalhold()
  A function to provide similar functionality within Resolve to my valuehold() function for premiere
  @param property refers to both of the screenshots (either active or not) for the property you wish to adjust
  @param plus is the pixel value you wish to add to the x value to grab the respective value you want to adjust
  @param rfelseval is the value you wish to pass to rfelse()
  */
 rvalhold(property, plus, rfelseval)
 {
     coordw()
     blockOn()
     SendInput(resolveSelectPlayhead)
     MouseGetPos(&xpos, &ypos)
     if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
         goto video
     else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
         {
             MouseMove(%&xi%, %&yi%)
             click ;this opens the inspector tab
             goto video
         }
     video:
     if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "video.png") ;if you're already in the video tab, it'll find this image then move on
         goto rest
     else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;if you aren't already in the video tab, this line will search for it
         {
             MouseMove(%&xn%, %&yn%)
             click ;"2196 139" ;this highlights the video tab
         }
     else
         {
             blockOff()
             MouseMove(%&xpos%, %&ypos%)
             toolFind("video tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     rest:
     ;MouseMove 2329, 215 ;moves to the scale value.
     if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% ".png") ;searches for the property of choice
         MouseMove(%&xz% + %&plus%, %&yz% + "5") ;moves the mouse to the value next to the property. This function assumes x/y are linked
     else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve %&property% "2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
         MouseMove(%&xz% + %&plus%, %&yz% + "5")
     else
         {
             blockOff()
             toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     sleep 100
     SendInput("{Click Down}")
     if GetKeyState(A_ThisHotkey, "P")
         {
             blockOff()
             KeyWait(A_ThisHotkey)
             SendInput("{Click Up}")
             MouseMove(%&xpos%, %&ypos%)
         }
     else
         {
             rfElse(%&rfelseval%) ;do note rfelse doesn't use any imagesearch information and just uses raw pixel values (not a great idea), so if you have any issues, do look into changing that
             MouseMove(%&xpos%, %&ypos%)
             SendInput("{MButton}")
             blockOff()
             return
         }
 }
 
 /* rflip()
  A function to search for and press the horizontal/vertical flip button within Resolve
  @param button is the png name of a screenshot of the button you wish to click (either activated or deactivated)
  */
 rflip(button)
 {
     coordw()
     blockOn()
     MouseGetPos(&xpos, &ypos)
     if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "videoN.png") ;makes sure the video tab is selected
         {
             MouseMove(%&xn%, %&yn%)
             click
         }
     if ImageSearch(&xh, &yh, propx1, propy1, propx2, propy2, "*5 " Resolve %&button% ".png") ;searches for the button when it isn't activated already
         {
             MouseMove(%&xh%, %&yh%)
             click
             MouseMove(%&xpos%, %&ypos%)
             blockOff()
             return
         }
     else if ImageSearch(&xho, &yho, propx1, propy1, propx2, propy2, "*5 " Resolve %&button% "2.png") ;searches for the button when it is activated already
         {
             MouseMove(%&xho%, %&yho%)
             click
             MouseMove(%&xpos%, %&ypos%)
             blockOff()
             return
         }
     else
         {
             blockOff()
             MouseMove(%&xpos%, %&ypos%)
             toolFind("desired button", "1000")
         }
 }
 
 /* rgain()
  A function that allows you to adjust the gain of the selected clip within Resolve similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful
  @param value is how much you want the gain to be adjusted by
  */
 rgain(value)
 {
     coordw()
     blockOn()
     SendInput(resolveSelectPlayhead)
     MouseGetPos(&xpos, &ypos)
     if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector.png")
         goto audio
     else if ImageSearch(&xi, &yi, inspectx1, inspecty1, inspectx2, inspecty2, "*2 " Resolve "inspector2.png")
         {
             MouseMove(%&xi%, %&yi%)
             click ;this opens the inspector tab
             goto audio
         }
     audio:
     if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "audio2.png") ;if you're already in the audio tab, it'll find this image then move on
         goto rest
     else if ImageSearch(&xn, &yn, vidx1, vidy1, vidx2, vidy2, "*5 " Resolve "audio.png") ;if you aren't already in the audio tab, this line will search for it
         {
             MouseMove(%&xn%, %&yn%)
             click ;"2196 139" ;this highlights the video tab
         }
     else
         {
             blockOff()
             MouseMove(%&xpos%, %&ypos%)
             toolFind("audio tab", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     rest:
     if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume.png") ;searches for the volume property
         MouseMove(%&xz% + "215", %&yz% + "5") ;moves the mouse to the value next to volume. This function assumes x/y are linked
     else if ImageSearch(&xz, &yz, propx1, propy1, propx2, propy2, "*5 " Resolve "volume2.png") ;if you've already adjusted values in resolve, their text slightly changes colour, this pass is just checking for that instead
         MouseMove(%&xz% + "215", %&yz% + "5")
     else
         {
             blockOff()
             toolFind("your desired property", "1000") ;useful tooltip to help you debug when it can't find what it's looking for
             return
         }
     SendInput("{Click 2}")
     A_Clipboard := ""
     ;sleep 50
     SendInput("^c")
     ClipWait()
     gain := A_Clipboard + %&value%
     SendInput(gain)
     SendInput("{Enter}")
     MouseMove(%&xpos%, %&ypos%)
     blockOff()
 }
 
 ; ===========================================================================================================================================
 ;
 ;		VSCode \\ Last updated: v2.9.6
 ;
 ; ===========================================================================================================================================
 /* vscode()
  A function to quickly naviate between my scripts. For this script to work [explorer.autoReveal] must be set to false in VSCode's settings (File->Preferences->Settings, search for "explorer" and set "explorer.autoReveal")
  @param script is the amount of pixels down the mouse must move from the collapse button to open the script I want.
 */
 vscode(script)
 {
     KeyWait(A_PriorKey)
     coordw()
     blockOn()
     MouseGetPos(&x, &y)
     if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "explorer.png") ;this imagesearch is checking to ensure you're in the explorer tab
         {
             MouseMove(%&xex%, %&yex%)
             SendInput("{Click}")
             MouseMove(%&x%, %&y%)
             sleep 50
         }
     SendInput(focusWork) ;vscode hides the buttons now all of a sudden.. thanks vscode
     sleep 50
     if ImageSearch(&xex, &yex, 0, 0, 460, 1390, "*2 " VSCodeImage "collapse.png") ;this imagesearch finds the collapse folders button, presses it twice, then moves across and presses the refresh button
         {
             MouseMove(%&xex%, %&yex%)
             SendInput("{Click 2}")
             MouseMove(-271, 40,, "R")
             SendInput("{Click}")
         }
     else
         {
             toolFind("the collapse folders button", "1000")
             blockOff()
             return
         }
     MouseMove(0, %&script%,, "R")
     SendInput("{Click}")
     MouseMove(%&x%, %&y%)
     SendInput(focusCode)
     blockOff()
 }