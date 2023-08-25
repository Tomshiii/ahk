/**
 * This code is originally from the `SetTimer` documentation but I have slightly modified it to make it more of a function and less like a one use command
 * @link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm#ExampleCount
 * @param {Function Object} one what you what to happen on the first input
 * @param {Function Object} two what you what to happen on the second input
 * @param {Function Object} three what you what to happen on the third and beyond input
 * @param {Integer} timerVal what number you want to feed into the settimer to determine how long to wait before a fresh keystroke is registered
 */
multiKeyPress(one, two, three, timerVal := -400)  ; This is a named function hotkey.
{
    static winc_presses := 0
    if winc_presses > 0 ; SetTimer already started, so we log the keypress instead.
    {
        winc_presses += 1
        return
    }
    ; Otherwise, this is the first press of a new series. Set count to 1 and start
    ; the timer:
    winc_presses := 1
    SetTimer(__multPress, timerVal)

    __multPress() {
        ;// The key was pressed once
        if winc_presses = 1
            one
        ;// The key was pressed twice
        else if winc_presses = 2
            two
        ;// The key was pressed three times or more
        else if winc_presses > 2
            three
        ; Regardless of which action above was triggered, reset the count to
        ; prepare for the next series of presses:
        winc_presses := 0
    }
}