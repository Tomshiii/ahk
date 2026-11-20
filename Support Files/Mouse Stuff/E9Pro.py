import sys
import time
import hid

VID = 0x04F3
PIDS = (0x026E, 0x026F)   # wired, 2.4GHz dongle

# ---- edit this: slot name -> action ----------------------------------------
# Actions: a key like "f13" / "a" / "5", a combo like "ctrl+shift+f14",
#          "mouse:left|right|middle|back|forward|wheelup|wheeldown", "dpi+", "dpi-"
MAPPING = {
    "btn0":     "f14",
    "btn1":     "forward",
    "btn2":     "back",
    "btn3":     "f21",
    "btn4":     "ralt+f14",
    "btn5":     "ralt+f15",
    "btn6":     "f23",
    "forward":  "f20",
    "back":     "f19",
    "windesk":  "f18",
    "dpi_up":   "ralt+f23",
    "dpi_down": "ralt+f24",
    # anything not listed stays at its factory function
}
# -----------------------------------------------------------------------------

# slot order as the configurator sends it, with factory actions
SLOTS = [
    ("btn0", "0"), ("btn1", "1"), ("btn2", "2"), ("btn3", "3"),
    ("btn4", "4"), ("btn5", "5"), ("btn6", "6"),
    ("forward", "mouse:forward"), ("back", "mouse:back"),
    ("windesk", "win+d"),
    ("dpi_up", "dpi+"), ("dpi_down", "dpi-"),
    ("left", "mouse:left"), ("right", "mouse:right"), ("middle", "mouse:middle"),
    ("wheel_up", "mouse:wheelup"), ("wheel_down", "mouse:wheeldown"),
]

MODS = {
    "ctrl": 0x01, "shift": 0x02, "alt": 0x04, "win": 0x08,
    "rctrl": 0x10, "rshift": 0x20, "ralt": 0x40, "rwin": 0x80,
}
MOUSE = {"left": 0x01, "right": 0x02, "middle": 0x04, "back": 0x08,
         "forward": 0x10, "wheelup": 0x20, "wheeldown": 0x40}


def keycode(k):
    k = k.lower()
    if len(k) == 1 and k.isalpha():
        return 0x04 + ord(k) - ord("a")
    if len(k) == 1 and k.isdigit():
        return 0x27 if k == "0" else 0x1E + int(k) - 1
    if k.startswith("f") and k[1:].isdigit():
        n = int(k[1:])
        if 1 <= n <= 12:
            return 0x3A + n - 1
        if 13 <= n <= 24:
            return 0x68 + n - 13
    raise ValueError(f"unknown key {k!r}")


def encode(action):
    a = action.lower()
    if a in MOUSE:
        a = "mouse:" + a
    if a == "dpi+":
        return [0x40, 0x02, 0x00]
    if a == "dpi-":
        return [0x40, 0x03, 0x00]
    if a.startswith("mouse:"):
        return [0x10, MOUSE[a[6:]], 0x00]
    *mods, key = a.split("+")
    m = 0
    for x in mods:
        if x not in MODS:
            raise SystemExit(
                f"{action!r}: {x!r} is not a modifier. A slot can send one key "
                f"plus modifiers ({', '.join(MODS)}), not two regular keys."
            )
        m |= MODS[x]
    return [0x70, m, keycode(key)]


def build_slots(use_factory):
    out = []
    for name, factory in SLOTS:
        action = factory if use_factory else MAPPING.get(name, factory)
        out.append(encode(action))
    return out


def packets(slots, seq):
    parts = [
        (0x02, [b for s in slots[:9] for b in s]),
        (0x12, [b for s in slots[9:] for b in s] + [0xFF, 0xFF, 0xFF]),
    ]
    for b2, data in parts:
        chk = (seq + b2 + sum(data) + 7) & 0xFF
        yield bytes([6, 0x01, seq, b2, chk]) + bytes(data)
        seq = (seq + 1) & 0xFF


def main():
    use_factory = len(sys.argv) > 1 and sys.argv[1] == "factory"
    slots = build_slots(use_factory)

    cands = [
        d for d in hid.enumerate()
        if d["vendor_id"] == VID and d["product_id"] in PIDS and d["usage_page"] == 0x0A
    ]
    if not cands:
        raise SystemExit("E9PRO config interface not found")

    for d in cands:
        label = f"pid={d['product_id']:04x} iface={d['interface_number']}"
        h = hid.device()
        try:
            h.open_path(d["path"])
            ok = True
            for p in packets(slots, 0x0A):
                if h.send_feature_report(p) < 0:
                    ok = False
                    break
                time.sleep(0.1)
            h.close()
        except OSError as e:
            print(f"{label}: failed ({e})")
            continue
        if ok:
            print(f"{label}: layout written" + (" (factory)" if use_factory else ""))
            return
        print(f"{label}: write rejected")
    raise SystemExit("no interface accepted the write")


main()