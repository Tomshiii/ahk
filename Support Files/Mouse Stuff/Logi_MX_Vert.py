import ctypes
import ctypes.wintypes as wt
import time
import hid

VID = 0x046D
WIRED_PID, RECEIVER_PID = 0xC08A, 0xC52B
SW_ID = 0x01

DPI_LEVELS = [400, 800, 1200, 1600, 2400, 3200, 4000]
DEFAULT_DPI = 800   # applied on connect; set to None to leave it alone

# ---- edit this: CID -> action ------------------------------------------------
MAPPING = {
    0x00FD: "f18",   # DPI button
    # 0x0052: "ralt+f13",   # middle click
    # 0x0053: "ralt+f14",   # back
    # 0x0056: "ralt+f15",   # forward
}
# ------------------------------------------------------------------------------

MODS = {
    "ctrl": 0x11, "shift": 0x10, "alt": 0x12, "win": 0x5B,
    "rctrl": 0xA3, "rshift": 0xA1, "ralt": 0xA5, "rwin": 0x5C,
}
EXTENDED = {0xA3, 0xA5, 0x5B, 0x5C}


def vk(key):
    k = key.lower()
    if k in MODS:
        return MODS[k]
    if len(k) == 1 and k.isalnum():
        return ord(k.upper())
    if k.startswith("f") and k[1:].isdigit() and 1 <= int(k[1:]) <= 24:
        return 0x70 + int(k[1:]) - 1
    raise SystemExit(f"unknown key {key!r}")


def parse(action):
    if action.lower().startswith("dpi"):
        return action.lower()
    *mods, key = action.lower().split("+")
    for m in mods:
        if m not in MODS:
            raise SystemExit(f"{action!r}: {m!r} is not a modifier")
    return [MODS[m] for m in mods], vk(key)


ACTIONS = {cid: parse(a) for cid, a in MAPPING.items()}

# --- SendInput ---
INPUT_KEYBOARD = 1
KEYEVENTF_EXTENDEDKEY = 0x0001
KEYEVENTF_KEYUP = 0x0002
ULONG_PTR = ctypes.c_size_t


class KEYBDINPUT(ctypes.Structure):
    _fields_ = [("wVk", wt.WORD), ("wScan", wt.WORD), ("dwFlags", wt.DWORD),
                ("time", wt.DWORD), ("dwExtraInfo", ULONG_PTR)]


class MOUSEINPUT(ctypes.Structure):
    _fields_ = [("dx", wt.LONG), ("dy", wt.LONG), ("mouseData", wt.DWORD),
                ("dwFlags", wt.DWORD), ("time", wt.DWORD),
                ("dwExtraInfo", ULONG_PTR)]


class _I(ctypes.Union):
    _fields_ = [("ki", KEYBDINPUT), ("mi", MOUSEINPUT)]


class INPUT(ctypes.Structure):
    _fields_ = [("type", wt.DWORD), ("u", _I)]


def send_key(code, up):
    flags = KEYEVENTF_KEYUP if up else 0
    if code in EXTENDED:
        flags |= KEYEVENTF_EXTENDEDKEY
    inp = INPUT(type=INPUT_KEYBOARD)
    inp.u.ki = KEYBDINPUT(code, 0, flags, 0, 0)
    ctypes.windll.user32.SendInput(1, ctypes.byref(inp), ctypes.sizeof(INPUT))


def press(cid):
    mods, key = ACTIONS[cid]
    for m in mods:
        send_key(m, False)
    send_key(key, False)


def release(cid):
    mods, key = ACTIONS[cid]
    send_key(key, True)
    for m in reversed(mods):
        send_key(m, True)


# --- HID++ ---
def find_interface():
    """Prefer the cable, then the receiver. Returns (path, pid) or None."""
    found = {}
    for d in hid.enumerate(VID):
        if d["usage_page"] == 0xFF00 and d["usage"] == 0x0002:
            found[d["product_id"]] = d["path"]
    for pid in (WIRED_PID, RECEIVER_PID):
        if pid in found:
            return found[pid], pid
    return None


class Mouse:
    def __init__(self, path, pid):
        self.dev = hid.device()
        self.dev.open_path(path)
        self.pid = pid
        self.idx = None
        self.feat = None

    def request(self, idx, feat, func, params=b"", timeout=1.0):
        msg = bytearray(20)
        msg[0], msg[1], msg[2] = 0x11, idx, feat
        msg[3] = (func << 4) | SW_ID
        msg[4:4 + len(params)] = params
        self.dev.write(bytes(msg))
        end = time.time() + timeout
        while time.time() < end:
            r = self.dev.read(64, 100)
            if not r:
                continue
            r = bytes(r)
            if r[0] != 0x11 or r[1] != idx:
                continue
            if r[2] in (0xFF, 0x8F):      # error reply (e.g. nothing paired at idx)
                return None
            if r[2] == feat and r[3] == msg[3]:
                return r
        return None

    def get_dpi(self):
        r = self.request(self.idx, self.dpi_feat, 2, bytes([0]))
        return (r[5] << 8) | r[6] if r else None

    def set_dpi(self, dpi):
        if not self.dpi_feat:
            print("this mouse didn't report an adjustable-DPI feature")
            return
        self.request(self.idx, self.dpi_feat, 3, bytes([0, dpi >> 8, dpi & 0xFF]))
        print(f"dpi -> {dpi}")

    def dpi_action(self, act):
        if act.startswith("dpi:"):
            return self.set_dpi(int(act[4:]))
        cur = self.get_dpi() or DEFAULT_DPI or DPI_LEVELS[0]
        if act == "dpi+":
            up = [d for d in DPI_LEVELS if d > cur]
            self.set_dpi(up[0] if up else DPI_LEVELS[-1])
        else:
            down = [d for d in DPI_LEVELS if d < cur]
            self.set_dpi(down[-1] if down else DPI_LEVELS[0])

    def setup(self):
        indexes = (0xFF,) if self.pid == WIRED_PID else range(1, 7)
        for idx in indexes:
            r = self.request(idx, 0x00, 0, bytes([0x1B, 0x04]))
            if not r or not r[4]:
                continue
            feat = r[4]
            c = self.request(idx, feat, 0)
            if not c:
                continue
            cids = set()
            for i in range(c[4]):
                x = self.request(idx, feat, 1, bytes([i]))
                if x:
                    cids.add((x[4] << 8) | x[5])
            if 0x00FD in cids:            # DPI button => this is the MX Vertical
                self.idx, self.feat = idx, feat
                d = self.request(idx, 0x00, 0, bytes([0x22, 0x01]))
                self.dpi_feat = d[4] if d else 0
                return
        raise OSError("MX Vertical not found (try moving the mouse to wake it)")

    def divert(self, cid, on):
        msg = bytearray(20)
        msg[0], msg[1], msg[2] = 0x11, self.idx, self.feat
        msg[3] = (3 << 4) | SW_ID
        msg[4], msg[5] = cid >> 8, cid & 0xFF
        msg[6] = 0x03 if on else 0x02
        self.dev.write(bytes(msg))
        time.sleep(0.05)


def run_once():
    iface = find_interface()
    if not iface:
        raise OSError("no HID++ interface found")
    m = Mouse(*iface)
    m.setup()
    held = set()
    for cid in ACTIONS:
        m.divert(cid, True)
    if DEFAULT_DPI:
        m.set_dpi(DEFAULT_DPI)
    print(f"diverted {[hex(c) for c in ACTIONS]} "
          f"via {'cable' if m.pid == WIRED_PID else 'receiver'} (index {m.idx:#04x})")
    try:
        while True:
            r = m.dev.read(64, 500)
            if not r:
                continue
            r = bytes(r)
            if r[0] == 0x11 and r[1] == m.idx and r[2] == m.feat and (r[3] >> 4) == 0:
                now = {(r[i] << 8) | r[i + 1] for i in range(4, 12, 2)} & set(ACTIONS)
                for cid in now - held:
                    if isinstance(ACTIONS[cid], str):
                        m.dpi_action(ACTIONS[cid])
                    else:
                        press(cid)
                for cid in held - now:
                    if not isinstance(ACTIONS[cid], str):
                        release(cid)
                held = now
    finally:
        for cid in held:
            if not isinstance(ACTIONS[cid], str):
                release(cid)
        try:
            for cid in ACTIONS:
                m.divert(cid, False)
        except OSError:
            pass


def main():
    while True:
        try:
            run_once()
        except KeyboardInterrupt:
            break
        except OSError as e:
            print(f"{e}; retrying in 3s")
            time.sleep(3)


main()