A list of Adobe function definitions, complete with examples

***

### Table of Contents:
* [After Effects](#After-Effects)
* [Photoshop](#Photoshop)
* [Premiere](#Premiere)
***

# After Effects

## `aevaluehold()`
A function to warp to one of a videos values within After Effects (`scale` , `x/y`, `rotation`, etc) and click and hold it so the user can drag to increase/decrease.

Tapping the button will reset the property.
```
aevaluehold( [button, property, {optional}] )
```
#### button
Type: String/variable - Hotkey

> The hotkey within after effects that's used to open up the property you wish to adjust.

#### property
Type: String - Filename

> The filename of the property itself - ie. `scale` NOT `scale.png` or `scale2`. Will require screenshots of said property in the appropriate ImageSearch folder.

#### optional
Type: Integer

> This parameter is for when you need the mouse to move extra coords over on the `x axis` to avoid the first "blue" text for some properties. This parameter can be omitted.


The user must hover over the clip of choice before activating this function.
***

## `aePreset()`
This function will drag and drop the effect of your choice onto a clip.
```
aePreset( [preset] )
```
#### preset
Type: String

> The name of your preset/effect that you wish to drag onto your clip.

The user must hover over the clip of choice before activating this function.
***

## `aeScaleAndPos()`
This function allows the user to quickly begin keyframing the scale & position values. Simply hover over the desired track and activate this function.
***

## `motionBlur()`
This function will open up the composition settings window within After Effects, navigate its way to the "advanced" tab, find "shuttle angle" and increase it to a value of 360.
***

## `aetimeline()`
*A weaker version of [`right click premiere.ahk`](https://github.com/Tomshiii/ahk/wiki/right-click-premiere.ahk)*

This function will gather the coordinates of the After Effects timeline and store them, then it will allow the user to move the playhead at the press of a button. Set this button to something quick to access like a mouse button (`Xbutton1/2`) or if you wish to use the keyboard, something a little more obscure like `Ctrl + Capslock`.
***

# Photoshop

## `psProp()`
This function will warp the mouse to one of a photo's values (`scale`, `x/y`, `rotation`, etc), click and hold it so the user can drag to increase/decrease the value, then return once the user let's go.

Tapping the button will reset the property.
```
psProp( [image] )
```
#### image
Type: String - Image name
> This parameter is the filename of the property itself & the file extenstion - ie. `scale.png` NOT `scale`. Will require screenshots of said property in the appropriate ImageSearch folder.
***

## `psSave()`
This function is to speed through the twitch emote saving process within photoshop - adjusting the image size and saving all 3 sizes.
***

## `psType()`
This function is to quickly select a different file extension during the file saving process. When you try and save a copy of something in photoshop, it defaults to psd, this is a function to instantly pick the actual filetype you want.
```
psType( [filetype] )
```
#### filetype
Type: String - Filename
> This parameter is the filename of the filetype you wish to save as itself - ie. `png`. Will require screenshots of said filetype in the appropriate ImageSearch folder.

# Premiere

## `preset()`
This function will drag and drop any previously saved preset onto the clip you're hovering over. Your saved preset MUST be in a folder for this function to work. This function contains custom code if the preset is called `loremipsum` and is intended for creating a custom text label and then dragging your preset on top of it.

Your preset must also be in it's own folder like so;

![image](https://user-images.githubusercontent.com/53557479/202047497-89570bbb-7455-4ef8-8b4d-39739c702e9e.png)
```
preset( [item] )
```
#### item
Type: String
> This parameter is the name of the preset you wish to drag onto your desired clip. Try to use names that will result in only one item appearing in the list after doing a search in the effects panel.
***

## `fxSearch()`
This function is to highlight the `effects` window and highlight the search box to allow manual typing.
***

## `zoom()`
This function on first run will ask you to select a clip with the exact zoom you wish to use for the current session. Any subsequent activations of the script will simply zoom the current clip to that zoom amount (and `x/y` position). You can reset this zoom by refreshing the script. There are also hard coded values within this script that look for the names of clients within the title of the current project.
***

## `valuehold()`
This function will warp to the desired value of the current track (`scale`, `x/y`, `rotation`, etc), then click and hold it so the user can drag to increase/decrease the value. Tapping the button you assign this function will reset the desired value.
```
valuehold( [filepath, {optional}] )
```
#### filepath
Type: String - filename
> The filename of the property itself - ie. `scale` NOT `scale.png` or `scale2`. Will require screenshots of said property in the appropriate ImageSearch folder.

#### optional
Type: Integer
> This value is used to add extra `x axis` movement to avoid the first "blue" text for some properties. This parameter can be omitted.
***

## `audioDrag()`
This function pulls an audio file out of a separate bin (called `sfx`) from the project window and back to the cursor.

If `sfxName` is "bleep" there is extra code that allows you to manually cut the length you want it to be, then move it to your track of choice.
```
audioDrag( [sfxName] )
```
#### sfxName
Type: String
> This parameter is the name of whatever sound you want the function to pull onto the timeline

If `sfxName` is "bleep", after the function has pulled it to the timeline, pressing `1-9` will decide which track the function will move the clip to. This function requires images in the appropriate ImageSearch folder
***

## `wheelEditPoint()`
This function allows you to move back and forth between edit points from anywhere in premiere
```
wheelEditPoint( [direction] )
```
#### direction
Type: String/Variable - Hotkey
> This parameter is hotkey within premiere for the direction you want it to go in relation to "edit points"
***

## `movepreview()`
This function is to adjust the framing of a video within the preview window in premiere pro. Let go of this hotkey to confirm, simply tap this hotkey to reset values. This function mimics what happens either when you double click the preview window, or when you click the "motion" button in a video's "effect control" window
***

## `reset()`
This function moves the cursor to the reset button to reset the "motion" effects
***

## `gain()`
This function is to increase/decrease gain for the current clip. This function will check to ensure the timeline is in focus and a clip is selected.
```
gain( [amount] )
```
#### amount
Type: Integer/Float
> This parameter is the value you want the gain to adjust (eg. -2, 6, etc)
***

## `mouseDrag()`
Press a button (ideally a mouse button), this function then changes to the "hand tool" and clicks so you can drag and easily move along the timeline, then it will swap back to the tool of your choice (selection tool for example).

This function will (on first use) check the coordinates of the timeline and store them, then on subsequent uses ensures the mouse position is within the bounds of the timeline before firing - this is useful to ensure you don't end up accidentally dragging around UI elements of Premiere.
```
mousedrag( [premtool, toolorig] )
```
#### premtool
Type: String/Variable - Hotkey
> This parameter is the hotkey you want the script to input to swap TO (ie, hand tool, zoom tool, etc). (consider using KSA values).

#### toolorig
Type: String/Variable - Hotkey
> This parameter is the hotkey you want the script to input to bring you back to your tool of choice (consider using KSA values).

I find this function is best used bound to a mouse button (`Xbutton1/2`)