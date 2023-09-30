;// jiggle the mouse every x minutes

SetDefaultMouseSpeed(0)

interval := 5
timeperiod := interval * (1000*60)

SetTimer(__wiggle, timeperiod)

__wiggle() {
    MouseGetPos(&x, &y)
    loop 25 {
        MouseMove(Random(25, 25), Random(25,25),, "R")
        MouseMove(x, y)
    }
}