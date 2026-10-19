#Requires AutoHotkey v2
#Include "%A_Appdata%\tomshi\lib"
#Include Functions\delaySI.ahk
#Include Classes\block.ahk
#Include Other\UIA\UIA.ahk

titles := Map(
    "Channel dashboard - YouTube Studio - Google Chrome", true,
    "Video monetization - YouTube Studio - Google Chrome", true,
    "Channel content - YouTube Studio - Google Chrome", true,
    "Ways to earn - YouTube Studio - Google Chrome", true
)

docCond := UIA.CreateCondition({Type: "Document"})
allCond := UIA.CreateCondition([
    {AutomationId: "skip-forward-10"},
    {AutomationId: "play-button"},
    {Name: "Insert ad slot"}
])
btnCache := UIA.CreateCacheRequest(["AutomationId", "Name"], ["Invoke"], UIA.TreeScope.Element)

; hwnd -> {doc, els: Map(key -> cached element)}. Lives for the whole script run.
cache := Map()

IsStudioPage() => WinActive("ahk_exe chrome.exe") && titles.Has(WinGetTitle("A"))

KeyOf(el) {
    switch el.CachedAutomationId {
        case "skip-forward-10": return "skip"
        case "play-button":     return "play"
    }
    return el.CachedName = "Insert ad slot" ? "ad" : ""
}

FindDoc(hwnd) {
    win := UIA.ElementFromHandle(hwnd)
    try return win.FindElement(docCond)
    return win
}

; Created once per window, never discarded.
GetContext(hwnd) {
    if !cache.Has(hwnd)
        cache[hwnd] := {doc: FindDoc(hwnd), els: Map()}
    return cache[hwnd]
}

; Adds any targets not already cached. Existing entries are left alone.
Scan(ctx) {
    for el in ctx.doc.FindElements(allCond, 4,,, btnCache) {
        key := KeyOf(el)
        if key && !ctx.els.Has(key)
            ctx.els[key] := el
    }
}

; refresh=true drops just this one key so it gets re-found.
GetEl(hwnd, key, refresh := false) {
    ctx := GetContext(hwnd)
    if refresh
        ctx.els.Delete(key)
    if !ctx.els.Has(key) {
        try Scan(ctx)
        catch {   ; the document node itself died (e.g. tab switch): replace it, and its children with it
            ctx.doc := FindDoc(hwnd)
            ctx.els.Clear()
            try Scan(ctx)
        }
    }
    return ctx.els.Get(key, 0)
}

; Uses the cached element as-is. Only if Invoke throws does it re-find that one element and
; continue from where it left off.
Press(hwnd, key, times := 1) {
    done := 0
    loop 2 {
        if !(el := GetEl(hwnd, key, A_Index = 2))
            return false
        try {
            pat := el.CachedInvokePattern
            while done < times {
                pat.Invoke()
                done++
            }
            return true
        }
    }
    return false
}

Skip(count) {
    hwnd := WinExist("A")
    Press(hwnd, "skip", count)
    Sleep 50
    Press(hwnd, "play")
}

#HotIf IsStudioPage()
F1::Skip(3)
F2::Skip(9)
F3::Skip(15)

`:: {
    hwnd := WinExist("A")
    Press(hwnd, "ad")
    if el := GetEl(hwnd, "play")
        try el.SetFocus()
}