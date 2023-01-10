; { \\ #Includes
#Include <GUIs\tomshiBasic>
#Include <Classes\dark>
; }

new := tomshiBasic()
new.AddButton(, "hello")
new.AddText(, "hello")
new.AddCheckbox(, "hello")
new.AddRadio(, "hello")
new.AddGroupBox(, "hi")

new.Show()

for hwnd, ctrl in new
    {
        try {
            name := ctrl.Name
            text := ctrl.Text
            value := ctrl.value
        }
        if Type(ctrl) = "Gui.Button"
            {
                try {
                    Dark.button(ctrl.Hwnd)
                }
            }
        /* MsgBox(ctrl.ClassNN)
        MsgBox(name ?? 0)
        MsgBox(text ?? 0)
        MsgBox(value ?? 0) */
    }