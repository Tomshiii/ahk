# Error Logs
This folder will contain any generated error logs to help the user determine where scripts are going wrong if they happen to miss the tooltips as sometimes multiple can be generated, or they can contain information that just flashes by too fast.

Log files will be laid out like so;

```
HH:MM:SS.MS // `Function/hotkey` encountered the following error: `Error` // Script: `Script Name`, Line: `Line Number`

01:28:31.951 // `^+w` encountered the following error: "Couldn't find the dm button" // Script: `My Scripts.ahk`, Line: 876
01:31:00.548 // `movepreview` encountered the following error: "Couldn't find the motion tab" // Script: `QMK Keyboard.ahk` (might be incorrect if launching macro from secondary keyboard), Line: 712
```