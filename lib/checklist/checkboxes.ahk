;defining checkboxes
checkbox := getCheckboxNum()
;this function will go through the [Checkboxes] section of the checklist.ini file and generate the same amount of checkboxes as there are values
loop checkbox.count {
    checkboxState := getCheckboxKeys(A_Index)
    x := Mod(A_Index, 9)
    y := Mod(A_Index, 8)
    if A_Index = 1
    {
        control := checkboxState.name
        if InStr(checkboxState.name, " ")
            control := controlCreate()
        checkEvent := MyGui.Add("Checkbox", "Section v" control " Y+4 Checked" checkboxState.currentState, checkboxState.name)
        checkEvent.OnEvent("Click", logCheckbox)
    }
    if x != 0 && A_Index != 1
    {
        control := checkboxState.name
        if InStr(checkboxState.name, " ")
            control := controlCreate()
        checkEvent := MyGui.Add("Checkbox", "v" control " Y+4 Checked" checkboxState.currentState, checkboxState.name)
        checkEvent.OnEvent("Click", logCheckbox)
    }
    if x = 0 && A_Index < 10 ;create the second column. The && -- part is necessary so the column down't overlap the timer
    {
        control := checkboxState.name
        if InStr(checkboxState.name, " ")
            control := controlCreate()
        checkEvent := MyGui.Add("Checkbox",  "Section v" control " X+85 Ys Checked" checkboxState.currentState, checkboxState.name)
        checkEvent.OnEvent("Click", logCheckbox)
    }
    if y = 0 && A_Index > 10 ;create the third column and beyond
    {
        control := checkboxState.name
        if InStr(checkboxState.name, " ")
            control := controlCreate()
        checkEvent := MyGui.Add("Checkbox",  "Section v" control " X+85 Ys Checked" checkboxState.currentState, checkboxState.name)
        checkEvent.OnEvent("Click", logCheckbox)
    }
}


/**
 * This function goes through the [Checkboxes] section of the ini file and counts how many checkboxes there are. It then returns an object for us to use while generating checkboxes
 * @returns {object} returns an object of the amount of boxes and the entire [checkboxes] list
 */
getCheckboxNum()
{
    var := IniRead(checklist, "Checkboxes")
    count := 0
    pos := 1
    loop {
        if !InStr(var, "=",,, A_Index)
            break
        pos := InStr(var, "=",,, A_Index)
        count += 1
    }
    return {count: count, list: var}
}


/**
 * This function allows us to figure out the name of each key in the [Checkboxes] section of the checklist.ini file
 * @param {any} count is the loop index we pass into the function
 * @returns {object} returns an object containing the checkbox name and it's current state
 */
getCheckboxKeys(count)
{
    var := getCheckboxNum()
    pos := InStr(var.list, "=",,, count)
    if count = 1
        startpos := 1
    else
        startpos := InStr(var.list, "`n",, pos, -1) + 1
    name := SubStr(var.list, startpos, pos - startpos) 
    currentState := SubStr(var.list, pos + 1, 1)
    return {name: name, currentState: currentState}
}


/**
 * Takes the checkbox name and checks to see if it's two words, if it is it will remove the whitespace and create one word so we can input that as the checkboxes control value
 * @returns {string}
 */
controlCreate()
{
    totLength := StrLen(checkboxState.name)
    startPos := InStr(checkboxState.name, " ")
    FirstWord := SubStr(checkboxState.name, 1, startPos - 1)
    length := StrLen(FirstWord)
    SecondWord := SubStr(checkboxState.name, startPos + 1, (totLength - (length + 1)))
    control := FirstWord SecondWord
    return control
}