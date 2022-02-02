#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3 ;this script requires AutoHotkey v2.0
SetWorkingDir A_ScriptDir ;sets the scripts working directory to the directory it's launched from

;This file must be in the same directory as the folder v{Release} that you downloaded from github. 

global Release := "v2.3.1"
;find users myscripts file
selectfile := FileSelect("1",, "Select your local version of 'My Scripts.ahk'", "*.ahk")
myscripts_string := FileRead(selectfile)

replace_release := FileRead(A_WorkingDir "\" Release "\My Scripts.ahk")

;reloaderhotkey
reloader_foundpos := InStr(myscripts_string, "reloaderHotkey", 1,, 1)
reloader_findend := InStr(myscripts_string, ':',, reloader_foundpos, 2)
reloader_endpos := reloader_findend + 1
reloader_findbegin := InStr(myscripts_string, ";",, reloader_foundpos, 1)
reloader_begin := reloader_findbegin + 3
reloader_end := reloader_endpos - reloader_begin - 2
reloader_hotkey := SubStr(myscripts_string, reloader_begin, reloader_end)

IniWrite('"' reloader_hotkey '"', "userHotkeys.ini", "Windows", "reloader")




;suspenderHotkey
suspender_foundpos := InStr(myscripts_string, "suspenderHotkey", 1,, 1)
suspender_findend := InStr(myscripts_string, ':',, suspender_foundpos, 2)
suspender_endpos := suspender_findend + 1
suspender_findbegin := InStr(myscripts_string, ";",, suspender_foundpos, 1)
suspender_begin := suspender_findbegin + 3
suspender_end := suspender_endpos - suspender_begin - 2
suspender_hotkey := SubStr(myscripts_string, suspender_begin, suspender_end)

IniWrite('"' suspender_hotkey '"', "userHotkeys.ini", "Windows", "suspender")


;excelHotkey
excel_foundpos := InStr(myscripts_string, "excelHotkey", 1,, 1)
excel_findend := InStr(myscripts_string, ':',, excel_foundpos, 2)
excel_endpos := excel_findend + 1
excel_findbegin := InStr(myscripts_string, ";",, excel_foundpos, 1)
excel_begin := excel_findbegin + 3
excel_end := excel_endpos - excel_begin - 2
excel_hotkey := SubStr(myscripts_string, excel_begin, excel_end)

IniWrite('"' excel_hotkey '"', "userHotkeys.ini", "Launch Scripts", "excel")


;windowspyHotkey
windowspy_foundpos := InStr(myscripts_string, "windowspyHotkey", 1,, 1)
windowspy_findend := InStr(myscripts_string, ':',, windowspy_foundpos, 2)
windowspy_endpos := windowspy_findend + 1
windowspy_findbegin := InStr(myscripts_string, ";",, windowspy_foundpos, 1)
windowspy_begin := windowspy_findbegin + 3
windowspy_end := windowspy_endpos - windowspy_begin - 2
windowspy_hotkey := SubStr(myscripts_string, windowspy_begin, windowspy_end)

IniWrite('"' windowspy_hotkey '"', "userHotkeys.ini", "Launch Scripts", "windowspy")


;vscodeHotkey
vscode_foundpos := InStr(myscripts_string, "vscodeHotkey", 1,, 1)
vscode_findend := InStr(myscripts_string, ':',, vscode_foundpos, 2)
vscode_endpos := vscode_findend + 1
vscode_findbegin := InStr(myscripts_string, ";",, vscode_foundpos, 1)
vscode_begin := vscode_findbegin + 3
vscode_end := vscode_endpos - vscode_begin - 2
vscode_hotkey := SubStr(myscripts_string, vscode_begin, vscode_end)

IniWrite('"' vscode_hotkey '"', "userHotkeys.ini", "Launch Scripts", "vscode")


;streamdeckHotkey
streamdeck_foundpos := InStr(myscripts_string, "streamdeckHotkey", 1,, 1)
streamdeck_findend := InStr(myscripts_string, ':',, streamdeck_foundpos, 2)
streamdeck_endpos := streamdeck_findend + 1
streamdeck_findbegin := InStr(myscripts_string, ";",, streamdeck_foundpos, 1)
streamdeck_begin := streamdeck_findbegin + 3
streamdeck_end := streamdeck_endpos - streamdeck_begin - 2
streamdeck_hotkey := SubStr(myscripts_string, streamdeck_begin, streamdeck_end)

IniWrite('"' streamdeck_hotkey '"', "userHotkeys.ini", "Launch Scripts", "streamdeck")


;taskmangerHotkey
taskmanger_foundpos := InStr(myscripts_string, "taskmangerHotkey", 1,, 1)
taskmanger_findend := InStr(myscripts_string, ':',, taskmanger_foundpos, 2)
taskmanger_endpos := taskmanger_findend + 1
taskmanger_findbegin := InStr(myscripts_string, ";",, taskmanger_foundpos, 1)
taskmanger_begin := taskmanger_findbegin + 3
taskmanger_end := taskmanger_endpos - taskmanger_begin - 2
taskmanger_hotkey := SubStr(myscripts_string, taskmanger_begin, taskmanger_end)

IniWrite('"' taskmanger_hotkey '"', "userHotkeys.ini", "Launch Scripts", "taskmanger")


;wordHotkey
word_foundpos := InStr(myscripts_string, "wordHotkey", 1,, 1)
word_findend := InStr(myscripts_string, ':',, word_foundpos, 2)
word_endpos := word_findend + 1
word_findbegin := InStr(myscripts_string, ";",, word_foundpos, 1)
word_begin := word_findbegin + 3
word_end := word_endpos - word_begin - 2
word_hotkey := SubStr(myscripts_string, word_begin, word_end)

IniWrite('"' word_hotkey '"', "userHotkeys.ini", "Launch Scripts", "word")


;akhdocuHotkey
akhdocu_foundpos := InStr(myscripts_string, "akhdocuHotkey", 1,, 1)
akhdocu_findend := InStr(myscripts_string, ':',, akhdocu_foundpos, 2)
akhdocu_endpos := akhdocu_findend + 1
akhdocu_findbegin := InStr(myscripts_string, ";",, akhdocu_foundpos, 1)
akhdocu_begin := akhdocu_findbegin + 3
akhdocu_end := akhdocu_endpos - akhdocu_begin - 2
akhdocu_hotkey := SubStr(myscripts_string, akhdocu_begin, akhdocu_end)

IniWrite('"' akhdocu_hotkey '"', "userHotkeys.ini", "Launch Scripts", "akhdocu")


;ahksearchHotkey
ahksearch_foundpos := InStr(myscripts_string, "ahksearchHotkey", 1,, 1)
ahksearch_findend := InStr(myscripts_string, ':',, ahksearch_foundpos, 2)
ahksearch_endpos := ahksearch_findend + 1
ahksearch_findbegin := InStr(myscripts_string, ";",, ahksearch_foundpos, 1)
ahksearch_begin := ahksearch_findbegin + 3
ahksearch_end := ahksearch_endpos - ahksearch_begin - 2
ahksearch_hotkey := SubStr(myscripts_string, ahksearch_begin, ahksearch_end)

IniWrite('"' ahksearch_hotkey '"', "userHotkeys.ini", "Launch Scripts", "ahksearch")


;streamfoobarHotkey
streamfoobar_foundpos := InStr(myscripts_string, "streamfoobarHotkey", 1,, 1)
streamfoobar_findend := InStr(myscripts_string, ':',, streamfoobar_foundpos, 2)
streamfoobar_endpos := streamfoobar_findend + 1
streamfoobar_findbegin := InStr(myscripts_string, ";",, streamfoobar_foundpos, 1)
streamfoobar_begin := streamfoobar_findbegin + 3
streamfoobar_end := streamfoobar_endpos - streamfoobar_begin - 2
streamfoobar_hotkey := SubStr(myscripts_string, streamfoobar_begin, streamfoobar_end)

IniWrite('"' streamfoobar_hotkey '"', "userHotkeys.ini", "Launch Scripts", "streamfoobar")


;explorerbackHotkey
explorerback_foundpos := InStr(myscripts_string, "explorerbackHotkey", 1,, 1)
explorerback_findend := InStr(myscripts_string, ':',, explorerback_foundpos, 2)
explorerback_endpos := explorerback_findend + 1
explorerback_findbegin := InStr(myscripts_string, ";",, explorerback_foundpos, 1)
explorerback_begin := explorerback_findbegin + 3
explorerback_end := explorerback_endpos - explorerback_begin - 2
explorerback_hotkey := SubStr(myscripts_string, explorerback_begin, explorerback_end)

IniWrite('"' explorerback_hotkey '"', "userHotkeys.ini", "Other", "explorerback")


;showmoreHotkey
showmore_foundpos := InStr(myscripts_string, "showmoreHotkey", 1,, 1)
showmore_findend := InStr(myscripts_string, ':',, showmore_foundpos, 2)
showmore_endpos := showmore_findend + 1
showmore_findbegin := InStr(myscripts_string, ";",, showmore_foundpos, 1)
showmore_begin := showmore_findbegin + 3
showmore_end := showmore_endpos - showmore_begin - 2
showmore_hotkey := SubStr(myscripts_string, showmore_begin, showmore_end)

IniWrite('"' showmore_hotkey '"', "userHotkeys.ini", "Other", "showmore")



;vscodemsHotkey
vscodems_foundpos := InStr(myscripts_string, "vscodemsHotkey", 1,, 1)
vscodems_findend := InStr(myscripts_string, ':',, vscodems_foundpos, 2)
vscodems_endpos := vscodems_findend + 1
vscodems_findbegin := InStr(myscripts_string, ";",, vscodems_foundpos, 1)
vscodems_begin := vscodems_findbegin + 3
vscodems_end := vscodems_endpos - vscodems_begin - 2
vscodems_hotkey := SubStr(myscripts_string, vscodems_begin, vscodems_end)

IniWrite('"' vscodems_hotkey '"', "userHotkeys.ini", "Other", "vscodems")


;vscodefuncHotkey
vscodefunc_foundpos := InStr(myscripts_string, "vscodefuncHotkey", 1,, 1)
vscodefunc_findend := InStr(myscripts_string, ':',, vscodefunc_foundpos, 2)
vscodefunc_endpos := vscodefunc_findend + 1
vscodefunc_findbegin := InStr(myscripts_string, ";",, vscodefunc_foundpos, 1)
vscodefunc_begin := vscodefunc_findbegin + 3
vscodefunc_end := vscodefunc_endpos - vscodefunc_begin - 2
vscodefunc_hotkey := SubStr(myscripts_string, vscodefunc_begin, vscodefunc_end)

IniWrite('"' vscodefunc_hotkey '"', "userHotkeys.ini", "Other", "vscodefunc")


;vscodeqmkHotkey
vscodeqmk_foundpos := InStr(myscripts_string, "vscodeqmkHotkey", 1,, 1)
vscodeqmk_findend := InStr(myscripts_string, ':',, vscodeqmk_foundpos, 2)
vscodeqmk_endpos := vscodeqmk_findend + 1
vscodeqmk_findbegin := InStr(myscripts_string, ";",, vscodeqmk_foundpos, 1)
vscodeqmk_begin := vscodeqmk_findbegin + 3
vscodeqmk_end := vscodeqmk_endpos - vscodeqmk_begin - 2
vscodeqmk_hotkey := SubStr(myscripts_string, vscodeqmk_begin, vscodeqmk_end)

IniWrite('"' vscodeqmk_hotkey '"', "userHotkeys.ini", "Other", "vscodeqmk")


;vscodechangeHotkey
vscodechange_foundpos := InStr(myscripts_string, "vscodechangeHotkey", 1,, 1)
vscodechange_findend := InStr(myscripts_string, ':',, vscodechange_foundpos, 2)
vscodechange_endpos := vscodechange_findend + 1
vscodechange_findbegin := InStr(myscripts_string, ";",, vscodechange_foundpos, 1)
vscodechange_begin := vscodechange_findbegin + 3
vscodechange_end := vscodechange_endpos - vscodechange_begin - 2
vscodechange_hotkey := SubStr(myscripts_string, vscodechange_begin, vscodechange_end)

IniWrite('"' vscodechange_hotkey '"', "userHotkeys.ini", "Other", "vscodechange")


;pauseyoutubeHotkey
pauseyoutube_foundpos := InStr(myscripts_string, "pauseyoutubeHotkey", 1,, 1)
pauseyoutube_findend := InStr(myscripts_string, ':',, pauseyoutube_foundpos, 2)
pauseyoutube_endpos := pauseyoutube_findend + 1
pauseyoutube_findbegin := InStr(myscripts_string, ";",, pauseyoutube_foundpos, 1)
pauseyoutube_begin := pauseyoutube_findbegin + 3
pauseyoutube_end := pauseyoutube_endpos - pauseyoutube_begin - 2
pauseyoutube_hotkey := SubStr(myscripts_string, pauseyoutube_begin, pauseyoutube_end)

IniWrite('"' pauseyoutube_hotkey '"', "userHotkeys.ini", "Other", "pauseyoutube")


;disceditHotkey
discedit_foundpos := InStr(myscripts_string, "disceditHotkey", 1,, 1)
discedit_findend := InStr(myscripts_string, ':',, discedit_foundpos, 2)
discedit_endpos := discedit_findend + 1
discedit_findbegin := InStr(myscripts_string, ";",, discedit_foundpos, 1)
discedit_begin := discedit_findbegin + 3
discedit_end := discedit_endpos - discedit_begin - 2
discedit_hotkey := SubStr(myscripts_string, discedit_begin, discedit_end)

IniWrite('"' discedit_hotkey '"', "userHotkeys.ini", "Discord", "discedit")


;discreplyHotkey
discreply_foundpos := InStr(myscripts_string, "discreplyHotkey", 1,, 1)
discreply_findend := InStr(myscripts_string, ':',, discreply_foundpos, 2)
discreply_endpos := discreply_findend + 1
discreply_findbegin := InStr(myscripts_string, ";",, discreply_foundpos, 1)
discreply_begin := discreply_findbegin + 3
discreply_end := discreply_endpos - discreply_begin - 2
discreply_hotkey := SubStr(myscripts_string, discreply_begin, discreply_end)

IniWrite('"' discreply_hotkey '"', "userHotkeys.ini", "Discord", "discreply")


;discreactHotkey
discreact_foundpos := InStr(myscripts_string, "discreactHotkey", 1,, 1)
discreact_findend := InStr(myscripts_string, ':',, discreact_foundpos, 2)
discreact_endpos := discreact_findend + 1
discreact_findbegin := InStr(myscripts_string, ";",, discreact_foundpos, 1)
discreact_begin := discreact_findbegin + 3
discreact_end := discreact_endpos - discreact_begin - 2
discreact_hotkey := SubStr(myscripts_string, discreact_begin, discreact_end)

IniWrite('"' discreact_hotkey '"', "userHotkeys.ini", "Discord", "discreact")


;discdeleteHotkey
discdelete_foundpos := InStr(myscripts_string, "discdeleteHotkey", 1,, 1)
discdelete_findend := InStr(myscripts_string, ':',, discdelete_foundpos, 2)
discdelete_endpos := discdelete_findend + 1
discdelete_findbegin := InStr(myscripts_string, ";",, discdelete_foundpos, 1)
discdelete_begin := discdelete_findbegin + 3
discdelete_end := discdelete_endpos - discdelete_begin - 2
discdelete_hotkey := SubStr(myscripts_string, discdelete_begin, discdelete_end)

IniWrite('"' discdelete_hotkey '"', "userHotkeys.ini", "Discord", "discdelete")


;pngHotkey
png_foundpos := InStr(myscripts_string, "pngHotkey", 1,, 1)
png_findend := InStr(myscripts_string, ':',, png_foundpos, 2)
png_endpos := png_findend + 1
png_findbegin := InStr(myscripts_string, ";",, png_foundpos, 1)
png_begin := png_findbegin + 3
png_end := png_endpos - png_begin - 2
png_hotkey := SubStr(myscripts_string, png_begin, png_end)

IniWrite('"' png_hotkey '"', "userHotkeys.ini", "Photoshop", "png")


;jpgHotkey
jpg_foundpos := InStr(myscripts_string, "jpgHotkey", 1,, 1)
jpg_findend := InStr(myscripts_string, ':',, jpg_foundpos, 2)
jpg_endpos := jpg_findend + 1
jpg_findbegin := InStr(myscripts_string, ";",, jpg_foundpos, 1)
jpg_begin := jpg_findbegin + 3
jpg_end := jpg_endpos - jpg_begin - 2
jpg_hotkey := SubStr(myscripts_string, jpg_begin, jpg_end)

IniWrite('"' jpg_hotkey '"', "userHotkeys.ini", "Photoshop", "jpg")


;photopenHotkey
photopen_foundpos := InStr(myscripts_string, "photopenHotkey", 1,, 1)
photopen_findend := InStr(myscripts_string, ':',, photopen_foundpos, 2)
photopen_endpos := photopen_findend + 1
photopen_findbegin := InStr(myscripts_string, ";",, photopen_foundpos, 1)
photopen_begin := photopen_findbegin + 3
photopen_end := photopen_endpos - photopen_begin - 2
photopen_hotkey := SubStr(myscripts_string, photopen_begin, photopen_end)

IniWrite('"' photopen_hotkey '"', "userHotkeys.ini", "Photoshop", "photopen")


;photoselectHotkey
photoselect_foundpos := InStr(myscripts_string, "photoselectHotkey", 1,, 1)
photoselect_findend := InStr(myscripts_string, ':',, photoselect_foundpos, 2)
photoselect_endpos := photoselect_findend + 1
photoselect_findbegin := InStr(myscripts_string, ";",, photoselect_foundpos, 1)
photoselect_begin := photoselect_findbegin + 3
photoselect_end := photoselect_endpos - photoselect_begin - 2
photoselect_hotkey := SubStr(myscripts_string, photoselect_begin, photoselect_end)

IniWrite('"' photoselect_hotkey '"', "userHotkeys.ini", "Photoshop", "photoselect")


;photozoomHotkey
photozoom_foundpos := InStr(myscripts_string, "photozoomHotkey", 1,, 1)
photozoom_findend := InStr(myscripts_string, ':',, photozoom_foundpos, 2)
photozoom_endpos := photozoom_findend + 1
photozoom_findbegin := InStr(myscripts_string, ";",, photozoom_foundpos, 1)
photozoom_begin := photozoom_findbegin + 3
photozoom_end := photozoom_endpos - photozoom_begin - 2
photozoom_hotkey := SubStr(myscripts_string, photozoom_begin, photozoom_end)

IniWrite('"' photozoom_hotkey '"', "userHotkeys.ini", "Photoshop", "photozoom")


;aetimelineHotkey
aetimeline_foundpos := InStr(myscripts_string, "aetimelineHotkey", 1,, 1)
aetimeline_findend := InStr(myscripts_string, ':',, aetimeline_foundpos, 2)
aetimeline_endpos := aetimeline_findend + 1
aetimeline_findbegin := InStr(myscripts_string, ";",, aetimeline_foundpos, 1)
aetimeline_begin := aetimeline_findbegin + 3
aetimeline_end := aetimeline_endpos - aetimeline_begin - 2
aetimeline_hotkey := SubStr(myscripts_string, aetimeline_begin, aetimeline_end)

IniWrite('"' aetimeline_hotkey '"', "userHotkeys.ini", "After Effects", "aetimeline")


;aeselectionHotkey
aeselection_foundpos := InStr(myscripts_string, "aeselectionHotkey", 1,, 1)
aeselection_findend := InStr(myscripts_string, ':',, aeselection_foundpos, 2)
aeselection_endpos := aeselection_findend + 1
aeselection_findbegin := InStr(myscripts_string, ";",, aeselection_foundpos, 1)
aeselection_begin := aeselection_findbegin + 3
aeselection_end := aeselection_endpos - aeselection_begin - 2
aeselection_hotkey := SubStr(myscripts_string, aeselection_begin, aeselection_end)

IniWrite('"' aeselection_hotkey '"', "userHotkeys.ini", "After Effects", "aeselection")


;aenextframeHotkey
aenextframe_foundpos := InStr(myscripts_string, "aenextframeHotkey", 1,, 1)
aenextframe_findend := InStr(myscripts_string, ':',, aenextframe_foundpos, 2)
aenextframe_endpos := aenextframe_findend + 1
aenextframe_findbegin := InStr(myscripts_string, ";",, aenextframe_foundpos, 1)
aenextframe_begin := aenextframe_findbegin + 3
aenextframe_end := aenextframe_endpos - aenextframe_begin - 2
aenextframe_hotkey := SubStr(myscripts_string, aenextframe_begin, aenextframe_end)

IniWrite('"' aenextframe_hotkey '"', "userHotkeys.ini", "After Effects", "aenextframe")


;aepreviousframeHotkey
aepreviousframe_foundpos := InStr(myscripts_string, "aepreviousframeHotkey", 1,, 1)
aepreviousframe_findend := InStr(myscripts_string, ':',, aepreviousframe_foundpos, 2)
aepreviousframe_endpos := aepreviousframe_findend + 1
aepreviousframe_findbegin := InStr(myscripts_string, ";",, aepreviousframe_foundpos, 1)
aepreviousframe_begin := aepreviousframe_findbegin + 3
aepreviousframe_end := aepreviousframe_endpos - aepreviousframe_begin - 2
aepreviousframe_hotkey := SubStr(myscripts_string, aepreviousframe_begin, aepreviousframe_end)

IniWrite('"' aepreviousframe_hotkey '"', "userHotkeys.ini", "After Effects", "aepreviousframe")


;premzoomoutHotkey
premzoomout_foundpos := InStr(myscripts_string, "premzoomoutHotkey", 1,, 1)
premzoomout_findend := InStr(myscripts_string, ':',, premzoomout_foundpos, 2)
premzoomout_endpos := premzoomout_findend + 1
premzoomout_findbegin := InStr(myscripts_string, ";",, premzoomout_foundpos, 1)
premzoomout_begin := premzoomout_findbegin + 3
premzoomout_end := premzoomout_endpos - premzoomout_begin - 2
premzoomout_hotkey := SubStr(myscripts_string, premzoomout_begin, premzoomout_end)

IniWrite('"' premzoomout_hotkey '"', "userHotkeys.ini", "Premiere", "premzoomout")


;premselecttoolHotkey
premselecttool_foundpos := InStr(myscripts_string, "premselecttoolHotkey", 1,, 1)
premselecttool_findend := InStr(myscripts_string, ':',, premselecttool_foundpos, 2)
premselecttool_endpos := premselecttool_findend + 1
premselecttool_findbegin := InStr(myscripts_string, ";",, premselecttool_foundpos, 1)
premselecttool_begin := premselecttool_findbegin + 3
premselecttool_end := premselecttool_endpos - premselecttool_begin - 2
premselecttool_hotkey := SubStr(myscripts_string, premselecttool_begin, premselecttool_end)

IniWrite('"' premselecttool_hotkey '"', "userHotkeys.ini", "Premiere", "premselecttool")


;premprojectHotkey
premproject_foundpos := InStr(myscripts_string, "premprojectHotkey", 1,, 1)
premproject_findend := InStr(myscripts_string, ':',, premproject_foundpos, 2)
premproject_endpos := premproject_findend + 1
premproject_findbegin := InStr(myscripts_string, ";",, premproject_foundpos, 1)
premproject_begin := premproject_findbegin + 3
premproject_end := premproject_endpos - premproject_begin - 2
premproject_hotkey := SubStr(myscripts_string, premproject_begin, premproject_end)

IniWrite('"' premproject_hotkey '"', "userHotkeys.ini", "Premiere", "premproject")


;premnexteditHotkey
premnextedit_foundpos := InStr(myscripts_string, "premnexteditHotkey", 1,, 1)
premnextedit_findend := InStr(myscripts_string, ':',, premnextedit_foundpos, 2)
premnextedit_endpos := premnextedit_findend + 1
premnextedit_findbegin := InStr(myscripts_string, ";",, premnextedit_foundpos, 1)
premnextedit_begin := premnextedit_findbegin + 3
premnextedit_end := premnextedit_endpos - premnextedit_begin - 2
premnextedit_hotkey := SubStr(myscripts_string, premnextedit_begin, premnextedit_end)

IniWrite('"' premnextedit_hotkey '"', "userHotkeys.ini", "Premiere", "premnextedit")


;prempreviouseditHotkey
prempreviousedit_foundpos := InStr(myscripts_string, "prempreviouseditHotkey", 1,, 1)
prempreviousedit_findend := InStr(myscripts_string, ':',, prempreviousedit_foundpos, 2)
prempreviousedit_endpos := prempreviousedit_findend + 1
prempreviousedit_findbegin := InStr(myscripts_string, ";",, prempreviousedit_foundpos, 1)
prempreviousedit_begin := prempreviousedit_findbegin + 3
prempreviousedit_end := prempreviousedit_endpos - prempreviousedit_begin - 2
prempreviousedit_hotkey := SubStr(myscripts_string, prempreviousedit_begin, prempreviousedit_end)

IniWrite('"' prempreviousedit_hotkey '"', "userHotkeys.ini", "Premiere", "prempreviousedit")


;premnudgedownHotkey
premnudgedown_foundpos := InStr(myscripts_string, "premnudgedownHotkey", 1,, 1)
premnudgedown_findend := InStr(myscripts_string, ':',, premnudgedown_foundpos, 2)
premnudgedown_endpos := premnudgedown_findend + 1
premnudgedown_findbegin := InStr(myscripts_string, ";",, premnudgedown_foundpos, 1)
premnudgedown_begin := premnudgedown_findbegin + 3
premnudgedown_end := premnudgedown_endpos - premnudgedown_begin - 2
premnudgedown_hotkey := SubStr(myscripts_string, premnudgedown_begin, premnudgedown_end)

IniWrite('"' premnudgedown_hotkey '"', "userHotkeys.ini", "Premiere", "premnudgedown")


;premmousedrag1Hotkey
premmousedrag1_foundpos := InStr(myscripts_string, "premmousedrag1Hotkey", 1,, 1)
premmousedrag1_findend := InStr(myscripts_string, ':',, premmousedrag1_foundpos, 2)
premmousedrag1_endpos := premmousedrag1_findend + 1
premmousedrag1_findbegin := InStr(myscripts_string, ";",, premmousedrag1_foundpos, 1)
premmousedrag1_begin := premmousedrag1_findbegin + 3
premmousedrag1_end := premmousedrag1_endpos - premmousedrag1_begin - 2
premmousedrag1_hotkey := SubStr(myscripts_string, premmousedrag1_begin, premmousedrag1_end)

IniWrite('"' premmousedrag1_hotkey '"', "userHotkeys.ini", "Premiere", "premmousedrag1")


;premmousedrag2Hotkey
premmousedrag2_foundpos := InStr(myscripts_string, "premmousedrag2Hotkey", 1,, 1)
premmousedrag2_findend := InStr(myscripts_string, ':',, premmousedrag2_foundpos, 2)
premmousedrag2_endpos := premmousedrag2_findend + 1
premmousedrag2_findbegin := InStr(myscripts_string, ";",, premmousedrag2_foundpos, 1)
premmousedrag2_begin := premmousedrag2_findbegin + 3
premmousedrag2_end := premmousedrag2_endpos - premmousedrag2_begin - 2
premmousedrag2_hotkey := SubStr(myscripts_string, premmousedrag2_begin, premmousedrag2_end)

IniWrite('"' premmousedrag2_hotkey '"', "userHotkeys.ini", "Premiere", "premmousedrag2")


;premgooseHotkey
premgoose_foundpos := InStr(myscripts_string, "premgooseHotkey", 1,, 1)
premgoose_findend := InStr(myscripts_string, ':',, premgoose_foundpos, 2)
premgoose_endpos := premgoose_findend + 1
premgoose_findbegin := InStr(myscripts_string, ";",, premgoose_foundpos, 1)
premgoose_begin := premgoose_findbegin + 3
premgoose_end := premgoose_endpos - premgoose_begin - 2
premgoose_hotkey := SubStr(myscripts_string, premgoose_begin, premgoose_end)

IniWrite('"' premgoose_hotkey '"', "userHotkeys.ini", "Premiere", "premgoose")


;prembleepHotkey
prembleep_foundpos := InStr(myscripts_string, "prembleepHotkey", 1,, 1)
prembleep_findend := InStr(myscripts_string, ':',, prembleep_foundpos, 2)
prembleep_endpos := prembleep_findend + 1
prembleep_findbegin := InStr(myscripts_string, ";",, prembleep_foundpos, 1)
prembleep_begin := prembleep_findbegin + 3
prembleep_end := prembleep_endpos - prembleep_begin - 2
prembleep_hotkey := SubStr(myscripts_string, prembleep_begin, prembleep_end)

IniWrite('"' prembleep_hotkey '"', "userHotkeys.ini", "Premiere", "prembleep")


;monitor2Hotkey
monitor2_foundpos := InStr(myscripts_string, "monitor2Hotkey", 1,, 1)
monitor2_findend := InStr(myscripts_string, ':',, monitor2_foundpos, 2)
monitor2_endpos := monitor2_findend + 1
monitor2_findbegin := InStr(myscripts_string, ";",, monitor2_foundpos, 1)
monitor2_begin := monitor2_findbegin + 3
monitor2_end := monitor2_endpos - monitor2_begin - 2
monitor2_hotkey := SubStr(myscripts_string, monitor2_begin, monitor2_end)

IniWrite('"' monitor2_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "monitor2")


;monitor1Hotkey
monitor1_foundpos := InStr(myscripts_string, "monitor1Hotkey", 1,, 1)
monitor1_findend := InStr(myscripts_string, ':',, monitor1_foundpos, 2)
monitor1_endpos := monitor1_findend + 1
monitor1_findbegin := InStr(myscripts_string, ";",, monitor1_foundpos, 1)
monitor1_begin := monitor1_findbegin + 3
monitor1_end := monitor1_endpos - monitor1_begin - 2
monitor1_hotkey := SubStr(myscripts_string, monitor1_begin, monitor1_end)

IniWrite('"' monitor1_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "monitor1")


;disclocationHotkey
disclocation_foundpos := InStr(myscripts_string, "disclocationHotkey", 1,, 1)
disclocation_findend := InStr(myscripts_string, ':',, disclocation_foundpos, 2)
disclocation_endpos := disclocation_findend + 1
disclocation_findbegin := InStr(myscripts_string, ";",, disclocation_foundpos, 1)
disclocation_begin := disclocation_findbegin + 3
disclocation_end := disclocation_endpos - disclocation_begin - 2
disclocation_hotkey := SubStr(myscripts_string, disclocation_begin, disclocation_end)

IniWrite('"' disclocation_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "disclocation")


;winmaxHotkey
winmax_foundpos := InStr(myscripts_string, "winmaxHotkey", 1,, 1)
winmax_findend := InStr(myscripts_string, ':',, winmax_foundpos, 2)
winmax_endpos := winmax_findend + 1
winmax_findbegin := InStr(myscripts_string, ";",, winmax_foundpos, 1)
winmax_begin := winmax_findbegin + 3
winmax_end := winmax_endpos - winmax_begin - 2
winmax_hotkey := SubStr(myscripts_string, winmax_begin, winmax_end)

IniWrite('"' winmax_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "winmax")


;winleftHotkey
winleft_foundpos := InStr(myscripts_string, "winleftHotkey", 1,, 1)
winleft_findend := InStr(myscripts_string, ':',, winleft_foundpos, 2)
winleft_endpos := winleft_findend + 1
winleft_findbegin := InStr(myscripts_string, ";",, winleft_foundpos, 1)
winleft_begin := winleft_findbegin + 3
winleft_end := winleft_endpos - winleft_begin - 2
winleft_hotkey := SubStr(myscripts_string, winleft_begin, winleft_end)

IniWrite('"' winleft_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "winleft")


;winrightHotkey
winright_foundpos := InStr(myscripts_string, "winrightHotkey", 1,, 1)
winright_findend := InStr(myscripts_string, ':',, winright_foundpos, 2)
winright_endpos := winright_findend + 1
winright_findbegin := InStr(myscripts_string, ";",, winright_foundpos, 1)
winright_begin := winright_findbegin + 3
winright_end := winright_endpos - winright_begin - 2
winright_hotkey := SubStr(myscripts_string, winright_begin, winright_end)

IniWrite('"' winright_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "winright")


;winminHotkey
winmin_foundpos := InStr(myscripts_string, "winminHotkey", 1,, 1)
winmin_findend := InStr(myscripts_string, ':',, winmin_foundpos, 2)
winmin_endpos := winmin_findend + 1
winmin_findbegin := InStr(myscripts_string, ";",, winmin_foundpos, 1)
winmin_begin := winmin_findbegin + 3
winmin_end := winmin_endpos - winmin_begin - 2
winmin_hotkey := SubStr(myscripts_string, winmin_begin, winmin_end)

IniWrite('"' winmin_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "winmin")


;alwaysontopHotkey
alwaysontop_foundpos := InStr(myscripts_string, "alwaysontopHotkey", 1,, 1)
alwaysontop_findend := InStr(myscripts_string, ':',, alwaysontop_foundpos, 2)
alwaysontop_endpos := alwaysontop_findend + 1
alwaysontop_findbegin := InStr(myscripts_string, ";",, alwaysontop_foundpos, 1)
alwaysontop_begin := alwaysontop_findbegin + 3
alwaysontop_end := alwaysontop_endpos - alwaysontop_begin - 2
alwaysontop_hotkey := SubStr(myscripts_string, alwaysontop_begin, alwaysontop_end)

IniWrite('"' alwaysontop_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "alwaysontop")


;searchgoogleHotkey
searchgoogle_foundpos := InStr(myscripts_string, "searchgoogleHotkey", 1,, 1)
searchgoogle_findend := InStr(myscripts_string, ':',, searchgoogle_foundpos, 2)
searchgoogle_endpos := searchgoogle_findend + 1
searchgoogle_findbegin := InStr(myscripts_string, ";",, searchgoogle_foundpos, 1)
searchgoogle_begin := searchgoogle_findbegin + 3
searchgoogle_end := searchgoogle_endpos - searchgoogle_begin - 2
searchgoogle_hotkey := SubStr(myscripts_string, searchgoogle_begin, searchgoogle_end)

IniWrite('"' searchgoogle_hotkey '"', "userHotkeys.ini", "Other - Not an Editor", "searchgoogle")


;wheelupHotkey
wheelup_foundpos := InStr(myscripts_string, "wheelupHotkey", 1,, 1)
wheelup_findend := InStr(myscripts_string, ':',, wheelup_foundpos, 2)
wheelup_endpos := wheelup_findend + 1
wheelup_findbegin := InStr(myscripts_string, ";",, wheelup_foundpos, 1)
wheelup_begin := wheelup_findbegin + 3
wheelup_end := wheelup_endpos - wheelup_begin - 2
wheelup_hotkey := SubStr(myscripts_string, wheelup_begin, wheelup_end)

IniWrite('"' wheelup_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "wheelup")


;wheeldownHotkey
wheeldown_foundpos := InStr(myscripts_string, "wheeldownHotkey", 1,, 1)
wheeldown_findend := InStr(myscripts_string, ':',, wheeldown_foundpos, 2)
wheeldown_endpos := wheeldown_findend + 1
wheeldown_findbegin := InStr(myscripts_string, ";",, wheeldown_foundpos, 1)
wheeldown_begin := wheeldown_findbegin + 3
wheeldown_end := wheeldown_endpos - wheeldown_begin - 2
wheeldown_hotkey := SubStr(myscripts_string, wheeldown_begin, wheeldown_end)

IniWrite('"' wheeldown_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "wheeldown")


;virtualrightHotkey
virtualright_foundpos := InStr(myscripts_string, "virtualrightHotkey", 1,, 1)
virtualright_findend := InStr(myscripts_string, ':',, virtualright_foundpos, 2)
virtualright_endpos := virtualright_findend + 1
virtualright_findbegin := InStr(myscripts_string, ";",, virtualright_foundpos, 1)
virtualright_begin := virtualright_findbegin + 3
virtualright_end := virtualright_endpos - virtualright_begin - 2
virtualright_hotkey := SubStr(myscripts_string, virtualright_begin, virtualright_end)

IniWrite('"' virtualright_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "virtualright")


;virtualleftHotkey
virtualleft_foundpos := InStr(myscripts_string, "virtualleftHotkey", 1,, 1)
virtualleft_findend := InStr(myscripts_string, ':',, virtualleft_foundpos, 2)
virtualleft_endpos := virtualleft_findend + 1
virtualleft_findbegin := InStr(myscripts_string, ";",, virtualleft_foundpos, 1)
virtualleft_begin := virtualleft_findbegin + 3
virtualleft_end := virtualleft_endpos - virtualleft_begin - 2
virtualleft_hotkey := SubStr(myscripts_string, virtualleft_begin, virtualleft_end)

IniWrite('"' virtualleft_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "virtualleft")


;youskipforHotkey
youskipfor_foundpos := InStr(myscripts_string, "youskipforHotkey", 1,, 1)
youskipfor_findend := InStr(myscripts_string, ':',, youskipfor_foundpos, 2)
youskipfor_endpos := youskipfor_findend + 1
youskipfor_findbegin := InStr(myscripts_string, ";",, youskipfor_foundpos, 1)
youskipfor_begin := youskipfor_findbegin + 3
youskipfor_end := youskipfor_endpos - youskipfor_begin - 2
youskipfor_hotkey := SubStr(myscripts_string, youskipfor_begin, youskipfor_end)

IniWrite('"' youskipfor_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "youskipfor")


;youskipbackHotkey
youskipback_foundpos := InStr(myscripts_string, "youskipbackHotkey", 1,, 1)
youskipback_findend := InStr(myscripts_string, ':',, youskipback_foundpos, 2)
youskipback_endpos := youskipback_findend + 1
youskipback_findbegin := InStr(myscripts_string, ";",, youskipback_foundpos, 1)
youskipback_begin := youskipback_findbegin + 3
youskipback_end := youskipback_endpos - youskipback_begin - 2
youskipback_hotkey := SubStr(myscripts_string, youskipback_begin, youskipback_end)

IniWrite('"' youskipback_hotkey '"', "userHotkeys.ini", "Mouse Scripts", "youskipback")









;replacing with user stuff
reloader_hotkey_replace := IniRead(A_WorkingDir "\Support\originalHotkeys.ini", "Windows", "reloader")
reloader_hotkey_ini := IniRead("userHotkeys.ini", "Windows", "reloader")
reloader_replaced := StrReplace(replace_release, reloader_hotkey_replace, reloader_hotkey_ini)

suspender_hotkey_replace := IniRead(A_WorkingDir "\Support\originalHotkeys.ini", "Windows", "suspender")
suspender_hotkey_ini := IniRead("userHotkeys.ini", "Windows", "suspender")
suspender_replaced := StrReplace(reloader_replaced, suspender_hotkey_replace, suspender_hotkey_ini)



if FileExist(A_WorkingDir "\" Release "\My Scripts.ahk")
    FileDelete(A_WorkingDir "\" Release "\My Scripts.ahk")
FileAppend(final_replaced, A_WorkingDir "\" Release "\My Scripts.ahk")

































/*
Loop
    {
        ini := FileRead(A_WorkingDir "\userHotkeys.ini")
        
        line := InStr(ini, "=",,, A_Index)
        forchar := A_Index + 64
        if forchar > 89
            forchar := A_Index + 71
        num := Chr(forchar)
        firstlinepos := InStr(ini, "]",,, 1)
        removesquareread := StrReplace(ini, "]", '"',, &Count)
        if A_Index > 59
            num := "a" Chr(forchar)
     
        if A_Index = 1
            {
                
                firstlinestart := firstlinepos + 3
                endlinestart := line + 2
                endlineendpos := InStr(ini, '"',,, 2)
                endlineend := endlineendpos - 1
                namelength := line - firstlinestart
                name := SubStr(ini, firstlinestart, namelength)
                hotkeyused := SubStr(ini, endlinestart, endlineend)
                FileAppend(num " := SubStr(myscripts_string, 1, " name "_begin - 1)`n", "Installer.ahk")
                FileAppend("FileAppend(" num A_Space name "_hotkey" A_Space "'::', A_WorkingDir '\v2.3.1\My Scripts.ahk')`n`n", "Installer.ahk")
            }
        else
            {
                lineminus := InStr(ini, "=",,, A_Index - 1)
                namefind := InStr(removesquareread, '"',, line, -1)
                namestart := namefind + 3
                nameend := line - namestart
                nameindex := SubStr(removesquareread, namestart, nameend)
                hotkeystart := line + 2
                hotkeyendpos := InStr(removesquareread, '"',, line, 2)
                hotkeyend := hotkeyendpos - 1
                hotkeyused := SubStr(removesquareread, hotkeystart, hotkeyend)
                ;previous
                namefindprev := InStr(removesquareread, '"',, lineminus, -1)
                namestartprev := namefindprev + 3
                nameendprev := lineminus - namestartprev
                nameindexprev := SubStr(removesquareread, namestartprev, nameendprev)
                hotkeystart := lineminus + 2
                hotkeyendpos := InStr(removesquareread, '"',, lineminus, 2)
                hotkeyend := hotkeyendpos - 1
                hotkeyused := SubStr(removesquareread, hotkeystart, hotkeyend)
                ;writing
                FileAppend(num "length := " nameindex "_begin - " nameindexprev "_endpos - 1`n", "Installer.ahk")
                FileAppend(num " := SubStr(myscripts_string, " nameindexprev "_endpos, " num "length)`n", "Installer.ahk")
                FileAppend("FileAppend(" num A_Space nameindex '_hotkey "::", A_WorkingDir "\v2.3.1\My Scripts.ahk")`n`n', "Installer.ahk")
            }
    }
*/
























/*
A := SubStr(myscripts_string, 1, reloader_begin - 1)
FileAppend(A reloader_hotkey '::', A_WorkingDir "\" Release "\My Scripts.ahk")

Blength := suspender_begin - reloader_endpos - 1
B := SubStr(myscripts_string, reloader_endpos, Blength)
FileAppend(B suspender_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Clength := excel_begin - suspender_endpos - 1
C := SubStr(myscripts_string, suspender_endpos, Clength)
FileAppend(C excel_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Dlength := windowspy_begin - excel_endpos - 1
D := SubStr(myscripts_string, excel_endpos, Dlength)
FileAppend(D windowspy_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Elength := vscode_begin - windowspy_endpos - 1
E := SubStr(myscripts_string, windowspy_endpos, Elength)
FileAppend(E vscode_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Flength := streamdeck_begin - vscode_endpos - 1
F := SubStr(myscripts_string, vscode_endpos, Flength)
FileAppend(F streamdeck_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Glength := taskmanger_begin - streamdeck_endpos - 1
G := SubStr(myscripts_string, streamdeck_endpos, Glength)
FileAppend(G taskmanger_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Hlength := word_begin - taskmanger_endpos - 1
H := SubStr(myscripts_string, taskmanger_endpos, Hlength)
FileAppend(H word_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Ilength := akhdocu_begin - word_endpos - 1
I := SubStr(myscripts_string, word_endpos, Ilength)
FileAppend(I akhdocu_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Jlength := ahksearch_begin - akhdocu_endpos - 1
J := SubStr(myscripts_string, akhdocu_endpos, Jlength)
FileAppend(J ahksearch_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Klength := streamfoobar_begin - ahksearch_endpos - 1
K := SubStr(myscripts_string, ahksearch_endpos, Klength)
FileAppend(K streamfoobar_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Llength := explorerback_begin - streamfoobar_endpos - 1
L := SubStr(myscripts_string, streamfoobar_endpos, Llength)
FileAppend(L explorerback_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Mlength := showmore_begin - explorerback_endpos - 1
M := SubStr(myscripts_string, explorerback_endpos, Mlength)
FileAppend(M showmore_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Nlength := vscodems_begin - showmore_endpos - 1
N := SubStr(myscripts_string, showmore_endpos, Nlength)
FileAppend(N vscodems_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Olength := vscodefunc_begin - vscodems_endpos - 1
O := SubStr(myscripts_string, vscodems_endpos, Olength)
FileAppend(O vscodefunc_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Plength := vscodeqmk_begin - vscodefunc_endpos - 1
P := SubStr(myscripts_string, vscodefunc_endpos, Plength)
FileAppend(P vscodeqmk_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Qlength := vscodechange_begin - vscodeqmk_endpos - 1
Q := SubStr(myscripts_string, vscodeqmk_endpos, Qlength)
FileAppend(Q vscodechange_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Rlength := pauseyoutube_begin - vscodechange_endpos - 1
R := SubStr(myscripts_string, vscodechange_endpos, Rlength)
FileAppend(R pauseyoutube_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Slength := discedit_begin - pauseyoutube_endpos - 1
S := SubStr(myscripts_string, pauseyoutube_endpos, Slength)
FileAppend(S discedit_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Tlength := discreply_begin - discedit_endpos - 1
T := SubStr(myscripts_string, discedit_endpos, Tlength)
FileAppend(T discreply_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Ulength := discreact_begin - discreply_endpos - 1
U := SubStr(myscripts_string, discreply_endpos, Ulength)
FileAppend(U discreact_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Vlength := discdelete_begin - discreact_endpos - 1
V := SubStr(myscripts_string, discreact_endpos, Vlength)
FileAppend(V discdelete_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Wlength := png_begin - discdelete_endpos - 1
W := SubStr(myscripts_string, discdelete_endpos, Wlength)
FileAppend(W png_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Xlength := jpg_begin - png_endpos - 1
X := SubStr(myscripts_string, png_endpos, Xlength)
FileAppend(X jpg_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

Ylength := photopen_begin - jpg_endpos - 1
Y := SubStr(myscripts_string, jpg_endpos, Ylength)
FileAppend(Y photopen_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

alength := photoselect_begin - photopen_endpos - 1
a := SubStr(myscripts_string, photopen_endpos, alength)
FileAppend(a photoselect_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

blength := photozoom_begin - photoselect_endpos - 1
b := SubStr(myscripts_string, photoselect_endpos, blength)
FileAppend(b photozoom_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

clength := aetimeline_begin - photozoom_endpos - 1
c := SubStr(myscripts_string, photozoom_endpos, clength)
FileAppend(c aetimeline_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

dlength := aeselection_begin - aetimeline_endpos - 1
d := SubStr(myscripts_string, aetimeline_endpos, dlength)
FileAppend(d aeselection_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

elength := aenextframe_begin - aeselection_endpos - 1
e := SubStr(myscripts_string, aeselection_endpos, elength)
FileAppend(e aenextframe_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

flength := aepreviousframe_begin - aenextframe_endpos - 1
f := SubStr(myscripts_string, aenextframe_endpos, flength)
FileAppend(f aepreviousframe_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

glength := premzoomout_begin - aepreviousframe_endpos - 1
g := SubStr(myscripts_string, aepreviousframe_endpos, glength)
FileAppend(g premzoomout_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

hlength := premselecttool_begin - premzoomout_endpos - 1
h := SubStr(myscripts_string, premzoomout_endpos, hlength)
FileAppend(h premselecttool_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

ilength := premproject_begin - premselecttool_endpos - 1
i := SubStr(myscripts_string, premselecttool_endpos, ilength)
FileAppend(i premproject_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

jlength := premnextedit_begin - premproject_endpos - 1
j := SubStr(myscripts_string, premproject_endpos, jlength)
FileAppend(j premnextedit_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

klength := prempreviousedit_begin - premnextedit_endpos - 1
k := SubStr(myscripts_string, premnextedit_endpos, klength)
FileAppend(k prempreviousedit_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

llength := premnudgedown_begin - prempreviousedit_endpos - 1
l := SubStr(myscripts_string, prempreviousedit_endpos, llength)
FileAppend(l premnudgedown_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

mlength := premmousedrag1_begin - premnudgedown_endpos - 1
m := SubStr(myscripts_string, premnudgedown_endpos, mlength)
FileAppend(m premmousedrag1_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

nlength := premmousedrag2_begin - premmousedrag1_endpos - 1
n := SubStr(myscripts_string, premmousedrag1_endpos, nlength)
FileAppend(n premmousedrag2_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

olength := premgoose_begin - premmousedrag2_endpos - 1
o := SubStr(myscripts_string, premmousedrag2_endpos, olength)
FileAppend(o premgoose_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

plength := prembleep_begin - premgoose_endpos - 1
p := SubStr(myscripts_string, premgoose_endpos, plength)
FileAppend(p prembleep_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

qlength := monitor2_begin - prembleep_endpos - 1
q := SubStr(myscripts_string, prembleep_endpos, qlength)
FileAppend(q monitor2_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

rlength := monitor1_begin - monitor2_endpos - 1
r := SubStr(myscripts_string, monitor2_endpos, rlength)
FileAppend(r monitor1_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

slength := disclocation_begin - monitor1_endpos - 1
s := SubStr(myscripts_string, monitor1_endpos, slength)
FileAppend(s disclocation_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

tlength := winmax_begin - disclocation_endpos - 1
t := SubStr(myscripts_string, disclocation_endpos, tlength)
FileAppend(t winmax_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

ulength := winleft_begin - winmax_endpos - 1
u := SubStr(myscripts_string, winmax_endpos, ulength)
FileAppend(u winleft_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

vlength := winright_begin - winleft_endpos - 1
v := SubStr(myscripts_string, winleft_endpos, vlength)
FileAppend(v winright_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

wlength := winmin_begin - winright_endpos - 1
w := SubStr(myscripts_string, winright_endpos, wlength)
FileAppend(w winmin_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

xlength := alwaysontop_begin - winmin_endpos - 1
x := SubStr(myscripts_string, winmin_endpos, xlength)
FileAppend(x alwaysontop_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

ylength := searchgoogle_begin - alwaysontop_endpos - 1
y := SubStr(myscripts_string, alwaysontop_endpos, ylength)
FileAppend(y searchgoogle_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

zlength := wheelup_begin - searchgoogle_endpos - 1
z := SubStr(myscripts_string, searchgoogle_endpos, zlength)
FileAppend(z wheelup_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

aalength := wheeldown_begin - wheelup_endpos - 1
aa := SubStr(myscripts_string, wheelup_endpos, aalength)
FileAppend(aa wheeldown_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

bblength := virtualright_begin - wheeldown_endpos - 1
bb := SubStr(myscripts_string, wheeldown_endpos, bblength)
FileAppend(bb virtualright_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

cclength := virtualleft_begin - virtualright_endpos - 1
cc := SubStr(myscripts_string, virtualright_endpos, cclength)
FileAppend(cc virtualleft_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

ddlength := wheelup_begin - virtualleft_endpos - 1
dd := SubStr(myscripts_string, virtualleft_endpos, ddlength)
FileAppend(dd wheelup_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

eelength := wheeldown_begin - wheelup_endpos - 1
ee := SubStr(myscripts_string, wheelup_endpos, eelength)
FileAppend(ee wheeldown_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

fflength := virtualright_begin - wheeldown_endpos - 1
ff := SubStr(myscripts_string, wheeldown_endpos, fflength)
FileAppend(ff virtualright_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

gglength := virtualleft_begin - virtualright_endpos - 1
gg := SubStr(myscripts_string, virtualright_endpos, gglength)
FileAppend(gg virtualleft_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

hhlength := youskipfor_begin - virtualleft_endpos - 1
hh := SubStr(myscripts_string, virtualleft_endpos, hhlength)
FileAppend(hh youskipfor_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

iilength := youskipback_begin - youskipfor_endpos - 1
ii := SubStr(myscripts_string, youskipfor_endpos, iilength)
FileAppend(ii youskipback_hotkey "::", A_WorkingDir "\" Release "\My Scripts.ahk")

;will place from the youskipback_hotkey : all the way to the end of the script
final := SubStr(myscripts_string, youskipfor_endpos)
FileAppend(final, A_WorkingDir "\" Release "\My Scripts.ahk")
 */