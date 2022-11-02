# Resolve
These functions may seem either less polished, less logical, or not as optimal as their Premiere counterparts - I don't use resolve, so I haven't had a lot of time to find edge cases, or to find problems that need solving. Think of these functions as a starting place for you to expand on and improve. A lot of these functions were just created in a rush and as such throughout this wiki you may see me confused at a few things - I can only assume I did things for a reason (but more than likely it was just an initial silly decision that I never got around to fixing).

If you do find the time to improve any of these functions, feel free to try and Pull Request them back to the original repo for others to take advantage of!

## `Rscale()`
This function allows you to quickly set the scale of a video
```
Rscale( [value, property, plus] )
```
#### value
Type: Integer
> This parameter is he number you want to type into the text field (100% in reslove requires a 1 here for example)

#### property
Type: String - Filename
> The filename of the property itself - ie. `zoom` NOT `zoom.png` or `zoom2`. Will require screenshots of said property in the appropriate ImageSearch folder.

#### plus
Type: Integer
> This parameter is described as being - The pixel value you wish to add to the x value to grab the respective value you want to adjust.
> But in all 3 instances I used this in, in `Resolve_Example.ahk` I had this value at `60` so unsure if this variable is useful
***

## `rfElse()`
This function is a relic from the early days of me creating examples for Resolve and is described as - A function that gets nested in the resolve valuehold script.
```
rfElse( [data] )
```
#### data
Type: Integer
> This parameter is described as being - what the script is typing in the text box to reset its value
***

## `rvalhold()`
This function will warp to the desired value of the current track (`scale`, `x/y`, `rotation`, etc), then click and hold it so the user can drag to increase/decrease the value. Tapping the button you assign this function will reset the desired value.
```
rvalhold( [property, plus, rfelseval] )
```
#### property
Type: String - Filename
> The filename of the property itself - ie. `scale` NOT `scale.png` or `scale2`. Will require screenshots of said property in the appropriate ImageSearch folder.

#### plus
Type: Integer
> This parameter is described as being - The pixel value you wish to add to the x value to grab the respective value you want to adjust.
> This parameter could probably be replaced with an alternative method, ie. A pixelsearch/more robust imagesearch

#### rfelseval
Type: Integer
> This parameter is the value you wish to pass into `rfesle()`
***

## `REffect()`
This function will apply an effect to the clip you're hovering over.
```
REffect( [folder, effect] )
```
#### folder
Type: String - Filename
> The filename of the drop down sidebar option itself (in the effects window) - ie. `openfx` NOT `openfx.png` or `openfx2`. Will require screenshots of said property in the appropriate ImageSearch folder.

#### effect
Type: String
> This parameter is the name of the effect you want this function to type into the search box

This function also requires additional images for a large amount of checks to ensure the proper windows are open.

This function will, in order;

1. Check to see if the effects window is open on the left side of the screen
2. Check to make sure the effects sidebar is expanded
3. Ensure you're clicked on the appropriate drop down
4. Open or close/reopen the search bar
5. Search for your effect of choice, then drag back to the click you were hovering over originally
***

## `rflip()`
This function will search for and press the horizontal/vertical flip button within Resolve
```
rflip( [button] )
```
#### button
Type: String - Filename
> The filename of the direction itself (horizontal/veritcal) - ie. `horizontal` NOT `horizontal.png` or `horizontal2`. Will require screenshots of said property in the appropriate ImageSearch folder.
***

## `rgain()`
This function allows you to adjust the gain of the selected clip within Resolve similar to my gain macros in premiere. You can't pull this off quite as fast as you can in premiere, but it's still pretty useful.
```
rgain( [value] )
```
#### value
Type: Integer/Float
> This parameter is how much you want the gain to be adjusted by.