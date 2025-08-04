; { \\ #Includes
#Include <Classes\keys>
; }

/**
 * A function to determine the input hotkeys and return them as an array
 * @param {String} [hk=A_ThisHotkey] the hotkey string
 * @returns {Array}
 * ```
 * RAlt & p::
 * {
 *    hotkeys := getHotkeysArr()
 *    hotkeys[1] ; returns "RAlt" (actually returns "vkA5")
 *    hotkeys[2] ; returns "p"
 * }
 * ```
 */
getHotkeysArr(hk := A_ThisHotkey) {
    components := []

    ; Build comprehensive key name pattern
    keyNames := "(?:"
        ; Function keys F1-F24
        . "F(?:[1-9]|1\d|2[0-4])|"
        ; Modifier keys as regular keys (LShift, RShift, etc.)
        . "(?:L|R)?(?:Shift|Control|Ctrl|Alt|Win)|"
        ; Letter keys (single letter only)
        . "[a-zA-Z](?![a-zA-Z])|"
        ; Number keys (single digit only)
        . "[0-9](?![0-9])|"
        ; Numpad keys - INCLUDING NumpadEnter
        . "Numpad(?:[0-9]|Add|Sub|Mult|Div|Dot|Del|Ins|Clear|Up|Down|Left|Right|Home|End|PgUp|PgDn|Enter)|"
        ; Mouse buttons and wheel
        . "(?:L|R|M|X)Button|XButton[12]|Wheel(?:Up|Down|Left|Right)|"
        ; Special keys
        . "Space|Tab|Enter|Escape|Esc|Backspace|Delete|Del|Insert|Ins|"
        . "Home|End|PgUp|PgDn|Up|Down|Left|Right|"
        . "PrintScreen|ScrollLock|CapsLock|NumLock|"
        . "Pause|Break|AppsKey|Sleep|"
        ; Media keys
        . "Browser_(?:Back|Forward|Refresh|Stop|Search|Favorites|Home)|"
        . "Volume_(?:Mute|Down|Up)|"
        . "Media_(?:Next|Prev|Stop|Play_Pause)|"
        . "Launch_(?:Mail|Media|App1|App2)|"
        ; Symbol keys - Must be at the end to prevent greedy matching
        . "[``~!@#$%^&*()_+=\-{}[\]|\\:;\`"'<,>.?/]"
    . ")"

    ; Complete pattern
    ; First group: optional prefix modifiers (non-capturing outer group)
    ; Second group: optional standard modifiers
    ; Third group: the key name
    pattern := "(?:(<\^>!|<\+|\+|>!|>\^|>#|<|>|~|\$|\*))?([!^+#]*?)(" . keyNames . ")(?:\s*&\s*|$)"

    pos := 1

    while pos <= StrLen(hk) {
        if !RegExMatch(SubStr(hk, pos), "^" . pattern, &m) {
            ; No match found
            break
        }

        ; m[1] = prefix modifiers (like <+)
        ; m[2] = standard modifiers (like !^+)
        ; m[3] = key name

        ; Push prefix modifiers if present
        if m[1]
            components.Push(m[1])

        ; Push each standard modifier individually
        if m[2] {
            for i, ch in StrSplit(m[2]) {
                if ch != ""
                    components.Push(ch)
            }
        }

        ; Push key name
        if m[3]
            components.Push(m[3])

        ; Move position forward
        matchLen := StrLen(m[0])
        pos += matchLen

        /* ; Skip over & if present
        if SubStr(hk, pos - 2, 2) ~= "\s*&$" {
            ; Already handled by the pattern
        } */
    }

    /** This loop scrubs any context hotkeys and converts them to a vk value so ahk functions can actually use them */
    for i, v in components {
        checkKey := keys.vk(v)
        if !checkKey
            continue
        components.InsertAt(i, checkKey)
        components.RemoveAt(i+1)
    }

    ;// remove context hotkeys if they are the first entry
    if components.Length > 1 && StrLen(components[1] = 1) {
        if components[1] == "*" || components[1] == "$" || components[1] == "~"
            components.RemoveAt(1)
    }

    return components
}