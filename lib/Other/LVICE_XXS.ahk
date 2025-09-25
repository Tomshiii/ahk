; ======================================================================================================================
;  Class LVICE_XXS      - ListView in-cell editing for AHK v2 - minimal version
; ======================================================================================================================
Class LVICE_XXS {
   ; -------------------------------------------------------------------------------------------------------------------
   __New(LV) {
      If (Type(LV) != "Gui.ListView")
         Throw Error("Class LVICE requires a GuiControl object of type Gui.ListView!")
      This.DoubleClickFunc := ObjBindMethod(This, "DoubleClick")
      This.BeginLabelEditFunc := ObjBindMethod(This, "BeginLabelEdit")
      This.EndLabelEditFunc := ObjBindMethod(This, "EndLabelEdit")
      This.CommandFunc := ObjBindMethod(This, "Command")
      LV.OnNotify(-3, This.DoubleClickFunc)
      This.LV := LV
      This.HWND := LV.Hwnd
      This.Changes := []
   }
   ; -------------------------------------------------------------------------------------------------------------------
   __Delete() {
      If DllCall("IsWindow", "Ptr", This.HWND, "UInt")
         This.LV.OnNotify(-3, This.DoubleClickFunc, 0)
      This.DoubleClickFunc := ""
      This.BeginLabelEditFunc := ""
      This.EndLabelEditFunc := ""
      This.CommandFunc := ""
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; NM_DBLCLK (list view) notification
   ; -------------------------------------------------------------------------------------------------------------------
   DoubleClick(LV, L) {
      Critical -1
      Item := NumGet(L + (A_PtrSize * 3), 0, "Int")
      Subitem := NumGet(L + (A_PtrSize * 3), 4, "Int")
      CellText := LV.GetText(Item + 1, SubItem + 1)
      RC := Buffer(16, 0)
      NumPut("Int", 0, "Int", SubItem, RC)
      DllCall("SendMessage", "Ptr", LV.Hwnd, "UInt", 0x1038, "Ptr", Item, "Ptr", RC) ; LVM_GETSUBITEMRECT
      This.CX := NumGet(RC, 0, "Int")
      If (Subitem = 0)
         This.CW := DllCall("SendMessage", "Ptr", LV.Hwnd, "UInt", 0x101D, "Ptr", 0, "Ptr", 0, "Int") ; LVM_GETCOLUMNWIDTH
      Else
         This.CW := NumGet(RC, 8, "Int") - This.CX
      This.CY := NumGet(RC, 4, "Int")
      This.CH := NumGet(RC, 12, "Int") - This.CY
      This.Item := Item
      This.Subitem := Subitem
      This.LV.OnNotify(-175, This.BeginLabelEditFunc)
      DllCall("PostMessage", "Ptr", LV.Hwnd, "UInt", 0x1076, "Ptr", Item, "Ptr", 0) ; LVM_EDITLABEL
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; LVN_BEGINLABELEDIT notification
   ; -------------------------------------------------------------------------------------------------------------------
   BeginLabelEdit(LV, L) {
      Critical -1
      This.HEDT := DllCall("SendMessage", "Ptr", LV.Hwnd, "UInt", 0x1018, "Ptr", 0, "Ptr", 0, "UPtr")
      This.ItemText := LV.GetText(This.Item + 1, This.Subitem + 1)
      DllCall("SendMessage", "Ptr", This.HEDT, "UInt", 0x00D3, "Ptr", 0x01, "Ptr", 4) ; EM_SETMARGINS, EC_LEFTMARGIN
      DllCall("SendMessage", "Ptr", This.HEDT, "UInt", 0x000C, "Ptr", 0, "Ptr", StrPtr(This.ItemText)) ; WM_SETTEXT
      DllCall("SetWindowPos", "Ptr", This.HEDT, "Ptr", 0, "Int", This.CX, "Int", This.CY,
                              "Int", This.CW, "Int", This.CH, "UInt", 0x04)
      OnMessage(0x0111, This.CommandFunc, -1)
      This.LV.OnNotify(-175, This.BeginLabelEditFunc, 0)
      This.LV.OnNotify(-176, This.EndLabelEditFunc)
      Return False

   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; LVN_ENDLABELEDIT notification
   ; -------------------------------------------------------------------------------------------------------------------
   EndLabelEdit(LV, L) {
      Static OffText := 16 + (A_PtrSize * 4)
      Critical -1
      This.LV.OnNotify(-176, This.EndLabelEditFunc, 0)
      OnMessage(0x0111, This.CommandFunc, 0)
      If (TxtPtr := NumGet(L, OffText, "UPtr")) {
         ItemText := StrGet(TxtPtr)
         If (ItemText != This.ItemText) {
            LV.Modify(This.Item + 1, "Col" . (This.Subitem + 1), ItemText)
            This.Changes.Push({Row: This.Item + 1, Col: This.Subitem + 1})
         }
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; WM_COMMAND notification
   ; -------------------------------------------------------------------------------------------------------------------
   Command(W, L, M, H) {
      Critical -1
      If (L = This.HEDT) {
         N := (W >> 16) & 0xFFFF
         If (N = 0x0400) || (N = 0x0300) || (N = 0x0100) { ; EN_UPDATE | EN_CHANGE | EN_SETFOCUS
            DllCall("SetWindowPos", "Ptr", L, "Ptr", 0, "Int", This.CX, "Int", This.CY,
                                    "Int", This.CW, "Int", This.CH, "UInt", 0x04)
         }
      }
   }
}
