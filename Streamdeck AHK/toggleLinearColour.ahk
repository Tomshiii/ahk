#Include <Classes\Editors\Premiere>

if !WinActive(prem.winTitle)
    return
if !prem.__checkPremRemoteFunc('toggleLinearColour')
    return
toggle := prem.__remoteFunc('toggleLinearColour', true)
switch toggle {
    case "failure": Notify.Show(, 'Toggling Linear Colour failed.', 'C:\Windows\System32\imageres.dll|icon237', 'Speech Misrecognition',, 'dur=5 bc=Black bdr=Red')
    default:
        state := (toggle = true) ? "Enabled" : "Disabled"
        Notify.Show(, 'Toggling Linear Colour successful.`nNew setting: ' state,,,, 'dur=5 bc=Black bdr=Aqua')
}

;// trying to open sequence settings after using this function may result in a crash. idk why, ask adobe
;// because of that, we force a save here
prem.save()
