/************************************************************************
 * @description parse premiere xml, excalibur xml, photoshop xml, and after effects ini keyboard shortcut files
 * @author tomshi
 * @date 2026/05/28
 * @version 1.3.0
 ***********************************************************************/

; { \\ #Includes
#Include '%A_Appdata%\tomshi\lib'
#Include Classes\Mip.ahk
#Include GUIs\tomshiBasic.ahk
#Include Functions\loadXML.ahk
; }

/**
 * @param file a filepath to the xml file you wish to parse
 * @returns {Object} returns an xml comobj to allow the user
 * Examples:
```
xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]/virtualkey').text
xml.selectSingleNode('/PremiereData/shortcuts/context.global/*[commandname="cmd.transport.shuttle.stop"]').nodename
```
 */
class adobeXML {
    __New(file) {
        this.xml := loadXML(this.readFile := FileRead(file))
        if !this.xml
            return
    }
    readFile := ""
    xml := ""
    buttonSelect := 1

    /**
     * adobe uses the `<virtualkey></virtualkey>` tag to either denote a full key, or they will sometimes use a 1-2 digit number to denote a special key. This is a map of known special keys
     */
    knownVirtualKeys := Map(
        "1",              "{Space}",
        "2",              "{BackSpace}",
        "3",              "{Tab}",
        "4",              "{Enter}",

        "7", "{F1}", "8", "{F2}", "9", "{F3}", "10", "{F4}", "11", "{F5}", "12", "{F6}", "13", "{F7}", "14", "{F8}", "15", "{F9}", "16", "{F10}", "17", "{F11}", "18", "{F12}", "19", "{F13}", "20", "{F14}", "21", "{F15}", "22", "{F16}", "23", "{F17}", "24", "{F18}", "25", "{F19}", "26", "{F20}", "27", "{F21}", "28", "{F22}", "29", "{F23}", "30", "{F24}",

        "32",             "{ScrollLock}", "33", "{Pause}", "34", "{Ins}",
        "35",             "{Delete}",
        "36",             "{Home}", "37", "{End}", "38", "{PgUp}", "39", "{PgDown}",
        "40",             "{Help}",
        ; "41",             "{Sleep}", ;// I assume this is sleep? but doesn't work on my pc so idk
        "42",             "{Left}", "43", "{Right}", "44", "{Up}", "45", "{Down}",
    )

    /**
     * A map of known ae replacements
     */
    AEKeyMap := Mip(
        "PadInsert",   "{Insert}",
        "Comma",       ",",             "SingleQuote", "'",           "Backslash", "\",
        "LeftArrow",   "{Left}",        "RightArrow",  "{Right}",     "UpArrow",   "{Up}",        "DownArrow",  "{Down}",
        "PadSlash",    "{NumpadDiv}",   "PadPlus",     "{NumpadAdd}", "PadMinus",  "{NumpadSub}", "PadDecimal", "{NumpadDot}", "PadMultiply", "{NumpadMulti}",
        "PadHome",     "{NumpadHome}",  "PadEnd",      "{NumpadEnd}",
        "PadPageUp",   "{NumpadPgUp}",  "PadPageDown", "{NumpadPgDn}",
        "FwdDel",      "{BackSpace}",   "PadDelete",   "{NumpadDel}", "PadClear",    "{NumpadClear}",
    )

    knownKeys := Mip(
        "Space",      1,
        "Enter",      1,
        "BackSpace",  1, "Del",    1, "Delete", 1,
        "Up",         1, "Down",   1, "Left",   1, "Right", 1,
        "Tab",        1,
        "Esc",        1, "Escape", 1,
        "Home",       1, "End",    1, "Insert", 1, "Ins",   1,
        "PgUp",       1, "PgDown", 1,
        "ScrollLock", 1, "Pause",  1,
    )

    /**
     * takes premiere's virtual key value and returns the formatted key
     * @param {Integer} virtualKey the virtual key value retrieved from the xml file
     * @returns {String|Object} returns an object containing `{isSet: false}` on failure or a string containing the name of the key. The object is to avoid stings like; `+0` being interpreted as `false`
     */
    __convVirtToKey(virtualKey) {
        if this.knownVirtualKeys.Has(virtualKey)
            return this.knownVirtualKeys.Get(virtualKey)
        if StrLen(virtualKey) < 8
            return {isSet: false}
        val := SubStr((Format("{:x}", virtualKey)), -2)
        return StrLower(Chr(Integer("0x" . val)))
    }

    /**
     * retrieves the modifiers for the given hotkey
     * @param {String} path the xml path for the desired hotkey
     * @returns {String} returns a string containing the modifiers for the given hotkey or a blank string if none
     */
    __retriveModifiers(path) {

        try ctrl  := (this.xml.selectSingleNode(path "/modifier.ctrl").text  = "true") ? "^" : ""
        try alt   := (this.xml.selectSingleNode(path "/modifier.alt").text   = "true") ? "!" : ""
        try shift := (this.xml.selectSingleNode(path "/modifier.shift").text = "true") ? "+" : ""
        return (ctrl ?? "") . (alt ?? "") . (shift ?? "")
    }

    /**
     * Wraps any required keys in "{}" so ahk interprets them correctly
     * @param {String} key the hotkey string
     * @returns {String} the final hotkey
     */
    __wrapKey(key) {
        if checkF := this.__isFKey(key)
            return checkF
        if (
            (pad := InStr(key, "Pad") || numpad := InStr(key, "Numpad")) &&
            (IsNumber(SubStr(key, -1, 1)) || IsNumber(SubStr(key, -1, 2)))
        ) {
            if numpad
                return "{" key "}"
            if pad {
                if this.AEKeyMap.Has(key) {
                    return this.AEKeyMap.Get(key)
                }
            }
        }
        if this.knownKeys.Has(key)
            return "{" key "}"
        return key
    }

    __isFKey(key) {
        if StrLen(key) <= 3 && SubStr(key, 1, 1) == "F"
            return "{" key "}"
        return key
    }

    /**
     * Clears any modifiers from the AE shortcut string
     * @param {String} key the hotkey string to be stripped
     */
    __clearHotkey(key) {
        key := StrReplace(key, "Shift+", "")
        key := StrReplace(key, "Ctrl+", "")
        key := StrReplace(key, "Alt+", "")
        return key
    }

    /**
     * Builds the AE hotkey from an ini value
     * @param {String} hotkey turns the ini value of the desired hotkey into an AHK readable hotkey
     * @returns {String} returns a string of the desired hotkey
     */
    __aeBuildHotkey(hotkey) {
        baseHotkey := SubStr(hotkey
                        , startpos := InStr(hotkey, "(",, 1, 1) + 1
                        , InStr(hotkey, ")",, 1, 1) - startpos
                    )
        builtHotkey := InStr(baseHotkey, "Ctrl",, 1, 1) ? "^" : ""
        builtHotkey := InStr(baseHotkey, "Alt",, 1, 1) ? builtHotkey "!" : builtHotkey
        builtHotkey := InStr(baseHotkey, "Shift",, 1, 1) ? builtHotkey "+" : builtHotkey

        baseHotkey := this.__clearHotkey(baseHotkey)
        return this.__generateAHKkeys(baseHotkey, builtHotkey)
    }

    __generateAHKkeys(baseHotkey, builtHotkey) {
        loop {
            nextKey := (plus := InStr(baseHotkey, "+",, 1, 1)) ? SubStr(baseHotkey, 1, InStr(baseHotkey, "+",, 1, 1))
                                                     : SubStr(baseHotkey, 1)
            nextKey := (this.AEKeyMap.Has(nextKey)) ? this.AEKeyMap.Get(nextKey) : nextKey
            nextKey := this.__wrapKey(nextKey)
            if StrLen(nextKey) = 1
                nextKey := StrLower(nextKey)
            builtHotkey := builtHotkey nextKey
            if !plus
                break
        }
        return builtHotkey
    }

    __excaliburBuildHotkey(keyMap) {
        buildKey := ""
        buildKey .= (keyMap["ctrl"] = true)   ? "^" : ""
        buildKey .= (keyMap["alt"] = true)    ? "!" : ""
        buildKey .= (keyMap["shift"] = true)  ? "+" : ""
        checkKey := (this.AEKeyMap.Has(keyMap["key"])) ? this.AEKeyMap.Get(keyMap["key"]) : keyMap["key"]
        checkKey := this.__wrapKey(checkKey)
        return buildKey checkKey
    }

    /**
     * Builds the hotkey for the desired xml path
     * @param {String} start the xml path of the desired hotkey. eg. `'/PremiereData/shortcuts/context.global'` in pre v27.0
     * or `'/PremiereData/shortcuts/mode.Edit/context.global'`/`'/PremiereData/shortcuts/mode.Color/context.global'` post v27
     * @param {String} codename the xml `codename` for the desired hotkey. eg. `"cmd.clip.scaletoframesize"`
     * @param {Integer} [selectWhichHotkey=1] in the event the user has multiple shortcuts defined, pick which one you wish to use. If this parameter is set to `false` the user will be prompted with a GUI to pick which to use
     * @returns {String|Object} returns a string of the desired hotkey. Else returns an object containing `{isSet: false}` on failure this is to avoid stings like; `+0` being interpreted as `false`
     *
     * example
     * ```
     * premXML := adobeXML("path\to\shortcutfile")
     * hotkeyVal := premXML.__premBuildHotkey("/PremiereData/shortcuts/context.global", "cmd.clip.aeify", 1) ;// pre v27.0
     * hotkeyVal := premXML.__premBuildHotkey("/PremiereData/shortcuts/mode.Edit/context.global", "cmd.clip.aeify", 1) ;// v27.0+
     * ```
     */
    __premBuildHotkey(start, codename, selectWhichHotkey := 1) {
        if codename = "" {
            errorLog(ValueError("Codename for KSA is empty", -1))
            return {isSet: false}
        }
        if !InStr(this.xml.text, codename) {
            errorLog(ValueError("Incorrect command for KSA", -1, codename))
            return {isSet: false}
        }

        try {
            firstPrompt  := Format('{}/*[commandname="{}"]', start, codename)
            getItemNodes := this.xml.selectNodes(firstPrompt)
            if selectWhichHotkey = false && getItemNodes.Length > 1 {
                selectGui := tomshiBasic(,, "AlwaysOnTop +MinSize200x200", "Select Hotkey to Define")
                xmarg := 7
                selectGui.AddText("Section", "Multiple hotkeys are set for the following shortcut.`nPlease select which Hotkey you wish to use for the following command;")
                selectGui.AddText("Section vcommandText x" xmarg " w420", codename)
                selectGui["commandText"].SetFont("Bold")
                for i, v in getItemNodes {
                    selectGui.AddText("x" xmarg ((A_Index=1) ? " y+22" : ""), buildSelection(getItemNodes, A_Index))
                    selectGui.AddButton("v" A_Index " x" xmarg+100 " y+-20", "Use").OnEvent("Click", (butt, *) => (this.buttonSelect := butt.name, WinClose(selectGui.Hwnd)))
                }
                selectGui.Show()
                WinWaitClose(selectGui.Hwnd)
            } else {
                this.buttonSelect := ((selectWhichHotkey > 0) ? selectWhichHotkey : 1)
            }

            return buildSelection(getItemNodes, this.buttonSelect)

            buildSelection(nodes, which) {
                getItemNum   := nodes[which-1].nodename
                secondPrompt := Format('{}[commandname="{}"]', start "/" getItemNum, codename)
                getModifiers := this.__retriveModifiers(secondPrompt)
                virtkey := this.__convVirtToKey(this.xml.selectSingleNode(secondPrompt "/virtualkey").text)
                getKey  := (virtkey != -1) ? virtkey : "false"
                if getKey == "false" {
                    return {isSet: false}
                }
                getKey := this.__wrapKey(getKey)
                return (getModifiers getKey)
            }
        } catch as e {
            errorLog(e)
            return {isSet: false}
        }

    }

    /**
     * Builds the hotkey for the desired xml path. Does not currently have support for checking nested xml values (ie. `<taskspace name="Select and Mask">
		<taskspace-tool name="Quick Selection Tool" type="1" key="1902867308">W</taskspace-tool>`)
     * @param {String} [hotkeyType] the type of hotkey you're searching for. Will appear in the xml as `<tool ` or `<command `
     * @param {String} [name] the `@name=` value for the desired hotkey. eg. `"Hand Tool"`
     * @returns {String|Object} returns a string of the desired hotkey. Else returns an object containing `{isSet: false}` on failure this is to avoid stings like; `+0` being interpreted as `false`
     * example
     * ```
     * psXML := adobeXML("path\to\shortcutfile")
     * hotkeyVal := psXML.__psBuildHotkey("command", "Free Transform")
     * ```
     */
    __psBuildHotkey(hotkeyType, name) {
        if hotkeyType = "" {
            errorLog(ValueError("hotkeyType for KSA is empty", -1))
            return {isSet: false}
        }
        if !InStr(this.readFile, name) {
            A_Clipboard := this.xml.text
            errorLog(ValueError("Incorrect name for Photoshop command in KSA", -1, name))
            return {isSet: false}
        }

        firstPrompt := Format("//{}[@name='{}']", hotkeyType, name)
        getItemNodes := this.xml.selectNodes(firstPrompt)
        firstHotkey := getItemNodes.item(0).text
        if StrLen(firstHotkey) < 1
            return {isSet: false}
        if StrLen(firstHotkey) = 1
            return StrLower(firstHotkey)
        buildHotkey := InStr(firstHotkey, "Ctrl+",, 1, 1) ? "^" : firstHotkey
        buildHotkey := InStr(buildHotkey, "Alt+",, 1, 1) ? "!" : buildHotkey
        buildHotkey := InStr(buildHotkey, "Shift+",, 1, 1) ? "+" : buildHotkey
        baseHotkey := this.__clearHotkey(firstHotkey)
        return this.__generateAHKkeys(baseHotkey, buildHotkey)
    }
}