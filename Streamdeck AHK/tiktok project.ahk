#SingleInstance Force
; { \\ #Includes
#Include <Classes\ptf>
#Include <Classes\tool>
#Include <Classes\coord>
#Include <Classes\Mip>
#Include <GUIs\tomshiBasic>
#Include <Functions\delaySI>
#Include <Classes\switchTo>
; }

if !WinActive(editors.Premiere.winTitle)
    Exit()

;// setting up
finalChoice := ""
guiTitle := "Select desired resolution"

;// start GUI
resGUI := tomshiBasic(,, "+Resize +MinSize300x", guiTitle)
resGUI.AddText(, "Desired Resolution")

;// radio controls
seven    := resGUI.Add("Radio", "vseven", "720x1280")
ten      := resGUI.Add("Radio", "vten Checked", "1080x1920")
four     := resGUI.Add("Radio", "vfour", "2160x3840")
numbers := ["seven", "ten", "four"]
for v in numbers {
    %v%.OnEvent("Click", __numChange)
}

;// custom input
custText := resGUI.AddText("Section", "Custom: ")

cust1    := resGUI.Add("Edit", "xs+55 ys-5 r1 w100 Limit4 Number Section vcust1")
xText    := resGUI.AddText("xs+105 ys+3 Section", "x")
cust2    := resGUI.Add("Edit", "xs+13 ys-3 r1 w100 Limit4 Number vcust2")
cust := ["cust1", "cust2"]
for v in cust {
    %v%.OnEvent("Change", __custEdit.Bind(v))
    %v%.OnEvent("Focus", __custEdit.Bind(v))
}
allCtrls := Mip("seven", 0, "ten", 1, "four", 0, "cust1", 0, "cust2", 0)
numVals  := Mip("seven", "720x1280", "ten", "1080x1920", "four", "2160x3840")

;// button logic
select   := resGUI.Add("Button", "Default ys-40 xs+54", "Select")
select.OnEvent("Click", __selectres.Bind(&finalChoice))

;// show the GUI
resGUI.Show()
resGUI.OnEvent("Close", __close)
resGUI.OnEvent("Escape", __close)
resGUI.Opt("-Resize")


WinWaitClose(guiTitle)
switchTo.Premiere()
if !WinWaitActive(Editors.Premiere.winTitle)
coord.w()
;// input resolution options
;// maybe input selector && text input boxes for custom
SendInput("!s" "q")
WinWait("Sequence Settings")
sleep 500
MouseMove(0, 0)
delaySI(50, "{Tab 4}", finalChoice.first, "{Tab}", finalChoice.second, "{Enter}")
if WinWait("Delete All Previews For This Sequence",, 1)
    SendInput("{Enter}")

__close(*) => ExitApp()

__numChange(ctrl, *) {
    for v in numbers {
        %v%.Value := 0
        allCtrls[ctrl] := 1
        ctrl.Value := 1
    }
}

__selectres(&finalChoice, *) {
    contents := resGUI.Submit()
    for k, v in allCtrls {
        if v = 0
            continue
        if Type(k) != "String"
            continue
        if !InStr(k, "cust",, 1)
            {
                first  := SubStr(numVals[k], 1, InStr(numVals[k], "x")-1)
                second := SubStr(numVals[k], InStr(numVals[k], "x")+1)
                finalChoice := {first: first, second: second}
                return
            }
        else
            {
                cust1Num := ""
                cust2Num := ""
                for v in cust {
                    %v%Num := %v%.Text != "" ? %v%.Text : 0
                }
                finalChoice := {first: cust1Num, second: cust2Num}
                return
            }
    }
}

__custEdit(which, ctrl, *) {
    if ctrl.Value != ""
        {
            for v in numbers {
                %v%.Value := 0
            }
            allCtrls[which] := 1
            return
        }
    ten.Value := 1
}