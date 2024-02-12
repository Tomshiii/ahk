#Requires AutoHotkey v2
#SingleInstance Force

#Include <Classes\coord>
#Include <Classes\obj>

;// hover over item you want to bulk craft in the guide book, then hold button
;// mousemove position will need to change depending on whether you're using a crafting bench/inventory/depending on GUI scale/screen resolution
f6::
{
    coord.s()
    ogMouse := obj.MousePos()
    SendInput("+{Click}")
    MouseMove(2105, 600, 2)
    SendInput("+{Click}")
    MouseMove(ogMouse.x, ogMouse.y, 2)
}

;// spam sword
;// designed for enderman farm - will cull all entities every once in a while
;// to help with lag
XButton2::
{
    sleep 250
    loop {
        if Mod(A_Index, 500) = 0 {
            SendInput("{Enter}")
            sleep 50
            SendInput("`/kill @e[type=item]")
            sleep 50
            SendInput("{Enter}")
        }
        if GetKeyState("XButton2", "P")
            break
        SendInput("{LButton}")
        sleep(500)
    }
}