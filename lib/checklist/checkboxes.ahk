;// defining checkboxes

class checkboxes {
    /**
     * This function goes through the [Checkboxes] section of the ini file and counts how many checkboxes there are. It then returns an object for us to use while generating checkboxes
     * @returns {object} returns an object of the amount of boxes and the entire [checkboxes] list
     */
    __getCheckboxNum()
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
     * @param {Integer} count is the loop index we pass into the function
     * @returns {object} returns an object containing the checkbox name and it's current state
     */
    __getCheckboxKeys(count)
    {
        var := this.__getCheckboxNum()
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
    __controlCreate(passedName)
    {
        totLength := StrLen(passedName)
        startPos := InStr(passedName, " ")
        FirstWord := SubStr(passedName, 1, startPos - 1)
        length := StrLen(FirstWord)
        SecondWord := SubStr(passedName, startPos + 1, (totLength - (length + 1)))
        control := FirstWord SecondWord
        return control
    }

    /**
     * This function will go through the [Checkboxes] section of the checklist.ini file and generate the same amount of checkboxes as there are values
     */
    static gatherCheckboxes(&morethannine, &morethan11)
    {
        morethannine := false, morethan11 := false
        boxes := this().__getCheckboxNum()
        listedNames := Array()
        controlNames := Array()
        state := Array()
        dupeCheck := ""
        dupeCount := 0
        loop boxes.count {
            getname := this().__getCheckboxKeys(A_Index)
            if !InStr(dupeCheck, getname.name "`n")
                {
                    listedNames.Push(getname.name)
                    dupeCheck .= getname.name "`n"
                }
            else
                {
                    orig := getname.name
                    loop {
                        start:
                        if !InStr(dupeCheck, getname.name dupeCount)
                            {
                                getname.name := getname.name dupeCount
                                dupeCheck .= getname.name "`n"
                                dupeCount := 0
                                break
                            }
                        else
                            {
                                dupeCount := ++dupeCount
                                getname.name := orig
                                goto start
                            }
                    }
                    listedNames.Push(getname.name)
                }
            state.Push(getname.currentState)
            controlname := listedNames.Get(A_Index)
            if InStr(controlname, " ")
                controlname := this().__controlCreate(controlname)
            controlNames.Push(controlname)
        }
        ;array is full now
        loop listedNames.Length {
            x := Mod(A_Index, 9)
            y := Mod(A_Index, 8)
            getnamm := listednames.Get(A_Index)
            getcont := controlNames.Get(A_Index)
            stateget := state.Get(A_Index)
            if A_Index = 1
                {
                    checklistGUI.Add("Checkbox", "Section v" getcont " Y+4 Checked" stateget, getnamm)
                    checklistGUI[getcont].OnEvent("Click", logCheckbox)
                }
            if A_Index >= 11
                morethan11 := true
            if y = 0 && A_Index > 10 ;create the third column and beyond
                {
                    checklistGUI.Add("Checkbox", "Section v" getcont " X+85 Ys Checked" stateget, getnamm)
                    checklistGUI[getcont].OnEvent("Click", logCheckbox)
                    continue
                }
            if x != 0 && A_Index != 1
                {
                    checklistGUI.Add("Checkbox", "v" getcont " Y+4 Checked" stateget, getnamm)
                    checklistGUI[getcont].OnEvent("Click", logCheckbox)
                    continue
                }
            if x = 0 && A_Index < 10 ;create the second column. The && -- part is necessary so the column down't overlap the timer
                {
                    checklistGUI.Add("Checkbox", "Section v" getcont " X+85 Ys Checked" stateget, getnamm)
                    checklistGUI[getcont].OnEvent("Click", logCheckbox)
                    morethannine := true
                    continue
                }
        }
    }
}