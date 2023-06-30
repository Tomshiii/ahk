; { \\ #Includes
#Include <Functions\getHotkeys>
#Include <Classes\errorLog>
; }

/**
 * This function is to allow the user to simply jump 10 characters in either direction. Useful when ^Left/^Right isn't getting you to where you want the cursor to be
 *
 * @param {Integer} amount is the amount of characters you want this function to jump, by default it is set to 10 and isn't required if you do not wish to override this value
 */
jumpChar(amount := 10)
{
    if !IsInteger(amount) {
        ;// throw
        errorLog(TypeError("Function requires an Integer but recieved a " Type(amount), -1, amount),,, 1)
    }
    getHotkeys(&first, &second)
    side := "{" second " " amount "}"
    if GetKeyState("Shift", "P")
        {
            SendInput("{Shift Down}" side "{Shift Up}")
            return
        }
    SendInput(side)
}