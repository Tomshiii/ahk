A collection of python scripts designed to remap vertical mice that offer terrible remapping support out of the box, as well as offering proper key `down`/`up` support.
***

### Table of Contents:
* [Setup](#Setup)
* [E9Pro.py](#E9Pro.py)
* [E9Pro_set.py](#E9Pro_set.py)
* [Logi_MX_Vert.py](#Logi_MX_Vert.py)
***

# Setup

> [!Important]
> Python `3.13` is used as `hidapi` doesn't (at time of writing) offer a prebuilt wheel for `3.15` and attempting to install it will require a C++ compiler.

```ps
winget install Python.Python.3.13
py -3.13 -m pip install hidapi
```

All scripts talk to the mouse over `HID`, so any software that is also talking to the mouse (the vendor's configurator, `Logi Options+`, `Mouser`, etc) should be closed before running them.

All scripts are called the same way and any user configuration is done by editing the values at the top of the relevant `.py` file.
```ahk
cmd.run(, false,, Format('py -3.13 "{1}" {2}', ptf.SupportFiles "\Mouse Stuff\<script>.py", "<parameters>"),, "Hide")
```
***

# E9Pro.py
Writes a button layout directly to the `SOLAKAKA E9 Pro` so each button sends the key you choose. Because the mouse sends real keyboard events, holding a button holds the key and releasing it releases the key. The layout is written to the mouse itself and does not need a script running in the background.

Works while connected by cable or by the `2.4GHz` dongle.

```ahk
cmd.run(, false,, Format('py -3.13 "{1}" {2}', ptf.SupportFiles "\Mouse Stuff\E9Pro.py", ""),, "Hide")
```

#### *parameters*
Type: *String*
> - `""` - Writes the layout defined in the `MAPPING` table at the top of the file.
> - `factory` - Resets **all** buttons to their factory functions, ignoring `MAPPING`.

> [!Warning]
> - Remapped buttons will **no longer** perform their original function. This includes `dpi_up`/`dpi_down`, `forward`/`back` and the wheel slots.
> - Pressing `Save` in the vendor's web configurator will overwrite the layout with its own. Re-run the script afterwards.
> - The mouse **does not** accept two regular keys in a single slot (ie. `f23+f13`). Each slot is one key plus (optionally) modifiers.
***

## <u>`factory`</u>
Resets the mouse's button layout to the factory defaults. The `MAPPING` table is ignored entirely, so every slot is rewritten, including any you never remapped.
```ahk
cmd.run(, false,, Format('py -3.13 "{1}" {2}', ptf.SupportFiles "\Mouse Stuff\E9Pro.py", "factory"),, "Hide")
```

The factory layout is:
| Slot | Function |
| --- | --- |
| `btn0` - `btn6` | Keys `0` - `6` |
| `forward` / `back` | Forward / Back |
| `windesk` | `Win + D` |
| `dpi_up` / `dpi_down` | `DPI +` / `DPI -` |
| `left` / `right` / `middle` | Left / right / middle click |
| `wheel_up` / `wheel_down` | Scroll wheel up / down |

> [!Note]
> This only resets the button layout. DPI, polling rate, lighting and the other settings are controlled by [`E9Pro_set.py`](#E9Pro_set.py) and are left alone.
***

## <u>`MAPPING`</u>
The table at the top of `E9Pro.py`. Each entry is `"slot": "action"`. Any slot you leave out stays at its factory function.
```py
MAPPING = {
    "btn0": "ralt+f13", "btn1": "ralt+f14",
    "forward": "ralt+f20",
    "dpi_up": "mouse:forward",
}
```

#### Slots
| Slot | Factory function |
| --- | --- |
| `btn0` - `btn6` | Thumb buttons `0` - `6` (numbered as they are in the configurator) |
| `forward` | Forward |
| `back` | Back |
| `windesk` | `Win + D` |
| `dpi_up` | `DPI +` |
| `dpi_down` | `DPI -` |
| `left` / `right` / `middle` | Left / right / middle click |
| `wheel_up` / `wheel_down` | Scroll wheel up / down |

#### Actions
| Action | Example | Description |
| --- | --- | --- |
| Key | `"f13"`, `"a"`, `"5"` | A single key. Letters `a-z`, digits `0-9` & `F1-F24` are supported. |
| Key + modifiers | `"ralt+f13"`, `"ctrl+shift+f14"` | A single key plus any number of modifiers: `ctrl`, `shift`, `alt`, `win`, `rctrl`, `rshift`, `ralt`, `rwin`. |
| Mouse button | `"mouse:forward"` | One of `left`, `right`, `middle`, `back`, `forward`, `wheelup`, `wheeldown`. |
| DPI | `"dpi+"`, `"dpi-"` | The mouse's built in DPI up/down. |

> [!Tip]
> `F13` - `F24` (optionally with a rarely used modifier like `ralt`) make ideal activation keys as almost nothing else uses them.
***

# E9Pro_set.py
Adjusts the other settings on the `SOLAKAKA E9 Pro` that the vendor's web configurator exposes. Like the button layout, these settings are written to the mouse and do not need a script running in the background.

```ahk
cmd.run(, false,, Format('py -3.13 "{1}" {2}', ptf.SupportFiles "\Mouse Stuff\E9Pro_set.py", "dpi 1600"),, "Hide")
```

## <u>`dpi`</u>
Selects a DPI preset or sets a custom value.
```ps
py -3.13 E9Pro_set.py dpi [value]
```
#### *value*
Type: *Integer*
> - `0` - `5` - Activates one of the six presets defined in `DPI_PRESETS` at the top of the file.
> - `200` - `36000` - Writes the value into the preset slot defined by `CUSTOM_SLOT` (default `1`) and activates it. Rounded to the nearest `50`.

> [!Note]
> Every `dpi` call rewrites the whole preset list from `DPI_PRESETS`, except for the custom value being set. Preset values must be multiples of `50`.
***

## <u>`rate`</u>
Sets the polling rate.
```ps
py -3.13 E9Pro_set.py rate [hz]
```
#### *hz*
Type: *Integer*
> One of `125`, `250`, `500`, `1000`, `2000`, `4000`, `8000`. Defaults to `1000`.

> [!Caution]
> Very high polling rates can cause stutter on some systems and will drain the battery faster when wireless.
***

## <u>`lights`</u>
Sets the RGB lighting effect.
```ps
py -3.13 E9Pro_set.py lights [effect]
```
#### *effect*
Type: *String | Integer*
> One of the following (or the matching number). Defaults to `off`.
```
off (0)           spectral (1)     respiratory (2)   streaming (3)    breathing (4)
wave (5)          meteor (6)       coverage (7)      stars (8)        explosion (9)
```
***

## <u>`power`</u>
Writes the power management settings defined at the top of the file.
```ps
py -3.13 E9Pro_set.py power
```
> - `SLEEP_MINUTES` *(Integer)* - Time until the mouse sleeps, `1` - `20`.
> - `KEEP_MOTION_WAKE` *(`1`/`0`)* - The `Keep motion wake up` toggle.
> - `LIGHTS_OFF_WHILE_MOVING` *(`1`/`0`)* - The `Lighting off while mouse move` toggle.

> [!Note]
> All three values are written together. Set all of them as you want them.
***

## <u>`sensor`</u>
Writes the sensor settings defined at the top of the file.
```ps
py -3.13 E9Pro_set.py sensor
```
> - `ANGLE_SNAP` *(`1`/`0`)*
> - `MOTION_SYNC` *(`1`/`0`)*
> - `RIPPLE_CONTROL` *(`1`/`0`)*

> [!Note]
> The configurator doesn't explain these options. All three values are written together.
***

## <u>`status`</u>
Read only. Waits for the mouse's periodic status report (roughly every 5 seconds) and prints the decoded values (polling rate code, battery, light mode) along with the raw bytes. Writes nothing to the mouse.
```ps
py -3.13 E9Pro_set.py status
```
***

## <u>`battery`</u>
Prints the mouse's current battery percentage (eg. `99%`). Read only. Waits for the mouse's next periodic status report, so may take up to `5s` to respond.
```ps
py -3.13 E9Pro_set.py battery
```
***

# Logi_MX_Vert.py
Allows the buttons on the `Logitech MX Vertical` to send keys with proper `down`/`up` behaviour. Logitech's own software only fires a single press, so this script instead takes over the buttons over `HID++` and sends the key on press and releases it when you let go.

Works while connected by cable or via the `2.4GHz` Unifying receiver.

```ahk
cmd.run(, false,, Format('py -3.13 "{1}" {2}', ptf.SupportFiles "\Mouse Stuff\Logi_MX_Vert.py", ""),, "Hide")
```

#### *parameters*
Type: *String*
> - `""` - Maps the buttons defined in the `MAPPING` table at the top of the file.

> [!Important]
> - Unlike the `E9 Pro`, this script **must keep running** for the remap to work. Closing it hands the buttons back to their original function. It will retry automatically if the mouse sleeps or disconnects.
> - Because it is launched with `"Hide"` there is no window to close. End the python process (or use `ProcessClose`) to stop it.
> - `Logi Options+` (and similar tools like `Mouser`) must be closed or they will compete for the buttons.
***

## <u>`MAPPING`</u>
Each entry is `control ID: "action"`. Actions use the same key/modifier syntax as [`E9Pro.py`](#Actions) (single keys & `F1-F24`, plus optional modifiers like `ralt+f13`).
```py
MAPPING = {
    0x00FD: "ralt+f18",   # DPI button
    0x0052: "ralt+f13",   # middle click
    0x0053: "ralt+f14",   # back
    0x0056: "ralt+f15",   # forward
}
```

#### Buttons
| Control ID | Button |
| --- | --- |
| `0x00FD` | DPI button |
| `0x0052` | Middle click |
| `0x0053` | Back |
| `0x0056` | Forward |

> [!Note]
> Left and right click cannot be remapped (the mouse doesn't allow it) and the scroll wheel is not available through this method.
***