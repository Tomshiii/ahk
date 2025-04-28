
;// turns out menu items don't update until the user opens the menu so...
;// defeats the purpose unfortunately
isMenuItemEnabled(hwnd, menuPath*) {
    MF_DISABLED := 0x2, MF_GRAYED := 0x1, MF_BYPOSITION := 0x400

    hMenu := DllCall("GetMenu", "Ptr", hwnd, "Ptr")
    if !hMenu
        return false

    currentMenu := hMenu
    menuTextObj := {}
    for i, v in menuPath {
        menuTextObj.%i% := {}
    }

    for index, item in menuPath {
        count := DllCall("GetMenuItemCount", "Ptr", currentMenu, "Int")
        found := false

        Loop count {
            i := A_Index - 1
            bufferInt := Buffer(256)
            DllCall("GetMenuString", "Ptr", currentMenu, "UInt", i, "Ptr", bufferInt, "Int", 256, "UInt", MF_BYPOSITION)
            menuText := RegExReplace(StrGet(bufferInt), "&")

            if (menuText = item) {
                for ind, v in menuPath {
                    if ind = 1
                        continue
                    loop {
                        newi := A_Index - 1
                        newInd := ind
                        subMenu := DllCall("GetSubMenu", "Ptr", currentMenu, "Int", i, "Ptr")
                        DllCall("GetMenuString", "Ptr", subMenu, "UInt", newi, "Ptr", bufferInt, "Int", 256, "UInt", MF_BYPOSITION)
                        menuTextObj.%newInd% := RegExReplace(StrGet(bufferInt), "&")
                        if InStr(menuTextObj.%newInd%, v, true) {
                            if newInd = menuPath.Length {
                                state := DllCall("GetMenuState", "Ptr", subMenu, "UInt", newi, "UInt", MF_BYPOSITION, "UInt")
                                return !(state & (MF_DISABLED | MF_GRAYED))
                            }
                            currentMenu := subMenu
                            i := newi
                            break
                        }
                        newInd += 1
                        continue
                    }
                }
            }
        }
        return false
    }
}