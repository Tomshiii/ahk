/**
 * A function to send a string of sendinput commands that are staggered out with sleeps.
 * This function helps write out multiple inputs that need to be slightly delayed
 * @param {Integer} delay The delay you wish to be between each input in `ms`
 * @param {String} inputs* All inputs you wish to be sent
 */
delaySI(delay := 50, inputs*) {
    for i in inputs {
        SendInput(i)
        sleep delay
    }
}