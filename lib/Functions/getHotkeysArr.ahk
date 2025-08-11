; { \\ #Includes
#Include <Classes\keys>
; }

/**
 * A function to determine the input hotkeys and return them as an array
 *
 * #### Warning
 * ##### *I don't know regex. As a result this is some of the only "vibe coded" functions in this repo (soz, I hate it too but editing is a busy job and learning regex is a lot) and as such I have no idea the potential limitations of this function. If you run into any issues please do let me know.*
 * @param {String} [hk=A_ThisHotkey] the hotkey string
 * @returns {Array} returns an array of `vk` values for all detected hotkeys
 * ```
 * RAlt & p::
 * {
 *    hotkeys := getHotkeysArr()
 *    hotkeys[1] ; returns "vkA5" ("RAlt")
 *    hotkeys[2] ; returns "vk50" ("p")
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

    ; Single regex pattern to match everything at once
    ; Captures: context modifiers, prefix modifiers, standard modifiers, key name
    pattern := "(?:(~|\$|\*))?(?:(<\^>!|<\+>!|<\^|>\^|<!|>!|<\+|>\+|<#|>#|<>))?([!^+#]*?)(" . keyNames . ")(?:\s*&\s*|$)"

    pos := 1
    while pos <= StrLen(hk) {
        if !RegExMatch(SubStr(hk, pos), "i)^" . pattern, &m) {
            break
        }

        ; m[1] = context modifiers (~, $, *)
        ; m[2] = prefix modifiers (<!, <^, etc.)
        ; m[3] = standard modifiers (!, ^, +, #)
        ; m[4] = key name

        ; Add context modifiers (will be filtered out later)
        if m[1] && (m[1] == "~" || m[1] == "$" || m[1] == "*")
            components.Push(m[1])

        ; Convert and add prefix modifiers using GetKeyVK
        if m[2] && keys.modMap.Has(m[2]) {
            for mod in StrSplit(keys.modMap[m[2]], "&") {
                if mod != "" {
                    vkCode := GetKeyVK(mod)
                    components.Push(vkCode ? "vk" . Format("{:X}", vkCode) : mod)
                }
            }
        }

        ; Convert and add standard modifiers using GetKeyVK
        if m[3] {
            for i, ch in StrSplit(m[3]) {
                if ch != "" && keys.modMap.Has(ch) {
                    for mod in StrSplit(keys.modMap[ch], "&") {
                        if mod != "" {
                            vkCode := GetKeyVK(mod)
                            components.Push(vkCode ? "vk" . Format("{:X}", vkCode) : mod)
                        }
                    }
                }
            }
        }

        ; Add key name - convert to VK using GetKeyVK for safety
        if m[4] {
            ; Check if it's already a VK code
            if RegExMatch(m[4], "i)^vk[0-9A-Fa-f]+$") {
                components.Push(m[4])
            } else {
                ; Use GetKeyVK for system-safe conversion
                vkCode := GetKeyVK(m[4])
                if !vkCode {
                    ;// throw
                    errorLog(ValueError("Couldn't determine Key", vkCode),,, true)
                    return
                }
                components.Push("vk" . Format("{:X}", vkCode))
            }
        }

        pos += StrLen(m[0])
    }

    ;// remove context hotkeys if they are the first entry
    if components.Length > 1 && StrLen(components[1]) = 1 {
        if components[1] == "*" || components[1] == "$" || components[1] == "~"
            components.RemoveAt(1)
    }

    return components
}