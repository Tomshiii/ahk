/************************************************************************
 * @description parse premiere xml keyboard shortcut files
 * @author tomshi
 * @date 2025/12/08
 * @version 1.1.0
 ***********************************************************************/

#Include <Classes\Mip>
#Include <Functions\loadXML>

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
        this.xml := loadXML(FileRead(file))
        if !this.xml
            return
    }
    xml := ""

    /**
     * adobe uses the `<virtualkey></virtualkey>` tag to either denote a full key, or they will sometimes use a 1-2 digit number to denote a special key. This is a map of known special keys
     */
    knownVirtualKeys := Map(
        "1",              "{Space}",
        "2",              "{BackSpace}",
        "3",              "{Tab}",
        "4",              "{Enter}",

        "7", "{F1}", "8", "{F2}", "9", "{F3}", "10", "{F4}", "11", "{F5}", "12", "{F6}", "13", "{F7}", "14", "{F8}", "15", "{F9}", "16", "{F10}", "17", "{F11}", "18", "{F12}", "19", "{F13}", "20", "{F14}", "21", "{F15}", "22", "{F16}", "23", "{F17}", "24", "{F18}", "25", "{F19}", "26", "{F20}", "27", "{F21}", "28", "{F22}", "29", "{F23}", "30", "{F24}",

        "32",             "{ScrollLock}",
        "33",             "{Pause}",
        "34",             "{Ins}",
        "35",             "{Delete}",
        "36",             "{Home}",
        "37",             "{End}",
        "38",             "{PgUp}",
        "39",             "{PgDown}",
        "40",             "{Help}",
        ; "41",             "{Sleep}", ;// I assume this is sleep? but doesn't work on my pc so idk
        "42",             "{Left}",
        "43",             "{Right}",
        "44",             "{Up}",
        "45",             "{Down}",
    )

    /**
     * A map of known ae replacements
     */
    AEKeyMap := Mip(
        "Comma",       ",",
        "LeftArrow",   "{Left}",
        "RightArrow",  "{Right}",
        "UpArrow",     "{Up}",
        "DownArrow",   "{Down}",
        "FwdDel",      "{BackSpace}",
        "SingleQuote", "'",
        "Backslash",   "\",
        "PadClear",    "{NumpadClear}",
        "PadSlash",    "{NumpadDiv}",
        "PadMinus",    "{NumpadSub}",
        "PadPlus",     "{NumpadAdd}",
        "PadInsert",   "{Insert}",
        "PadDecimal",  "{NumpadDot}",
        "PadMultiply", "{NumpadMulti}",
        "PadHome",     "{NumpadHome}",
        "PadEnd",      "{NumpadEnd}",
        "PadPageUp",   "{NumpadPgUp}",
        "PadPageDown", "{NumpadPgDn}",
        "PadDelete",   "{NumpadDel}",
    )

    knownKeys := Mip(
        "Space",      1,
        "Enter",      1,
        "BackSpace",  1,
        "Del",        1, "Delete", 1,
        "Up",         1, "Down",   1, "Left",   1, "Right", 1,
        "Tab",        1,
        "Esc",        1, "Escape", 1,
        "Home",       1, "End",    1, "Insert", 1,
        "PgUp",       1, "PgDown", 1,
        "ScrollLock", 1,
        "Pause",      1, "Ins",    1
    )

    /**
     * takes premiere's virtual key value and returns the formatted key
     * @param {Integer} virtualKey the virtual key value retrieved from the xml file
     * @returns {Boolean/String} returns `false` on failure or a string containing the name of the key
     */
    __convVirtToKey(virtualKey) {
        if this.knownVirtualKeys.Has(virtualKey)
            return this.knownVirtualKeys.Get(virtualKey)
        if StrLen(virtualKey) < 8
            return false
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
     * Builds the AE hotkey
     * @param {String} hotkey turns the shortcut file hotkey into an AHK readable hotkey
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

    /**
     * Builds the hotkey for the desired xml path
     * @param {String} start the xml path of the desired hotkey. eg. `'/PremiereData/shortcuts/context.global'`
     * @param {String} codename the xml `codename` for the desired hotkey. eg. `"cmd.clip.scaletoframesize"`
     * @returns {String} returns complete hotkey
     */
    __premBuildHotkey(start, codename, selectWhichHotkey := 1) {
        if codename = ""
            return false
        if !InStr(this.xml.text, codename)
            return false
        if selectWhichHotkey = false && InStr(this.xml.text, codename,,, 2) {
            ;// need to prompt the user to select which hotkey seems correct
            ;// would need to do a loop finding ALL occurrences of the desired codename (could be more than 2)
            ;// then have the user select which
            ;// "cmd.clip.aeify" is an example of a command that I have 2 hotkeys set for rn

            ; selectWhichHotkey := selection
        }

        return __doBuild(selectWhichHotkey)
        __doBuild(whichIndex) {
            try {
                firstPrompt := Format('{}/*[commandname="{}"]', start, codename)
                getItemNodes := this.xml.selectNodes(firstPrompt)
                getItemNum := getItemNodes[whichIndex-1].nodename
                secondPrompt := Format('{}[commandname="{}"]', start "/" getItemNum, codename)
                getModifiers := this.__retriveModifiers(secondPrompt)
                virtkey := this.__convVirtToKey(this.xml.selectSingleNode(secondPrompt "/virtualkey").text)
                getKey := (virtkey != false) ? virtkey : "false"
                if getKey == "false"
                    return false
                getKey := this.__wrapKey(getKey)
                return (getModifiers getKey)
            } catch {
                return false
            }
        }
    }
}