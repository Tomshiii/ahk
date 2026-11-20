import random
import sys
import time
import hid

VID = 0x04F3
PIDS = (0x026E, 0x026F)   # cable, 2.4GHz dongle

# ---- edit these ----------------------------------------------------------------
DPI_PRESETS = [800, 1000, 1600, 2400, 3200, 6400]   # exactly 6, multiples of 50
CUSTOM_SLOT = 1   # which preset slot holds your custom DPI (0-5)

SLEEP_MINUTES = 20            # 1-20
KEEP_MOTION_WAKE = 1          # 1 on, 0 off
LIGHTS_OFF_WHILE_MOVING = 1   # 1 on, 0 off

ANGLE_SNAP = 0                # 1 on, 0 off
MOTION_SYNC = 1
RIPPLE_CONTROL = 0
# --------------------------------------------------------------------------------

RATE_CODES = {125: 8, 250: 4, 500: 2, 1000: 1, 2000: 0x11, 4000: 0x12, 8000: 0x14}
LIGHT_MODES = {
    "off": 0, "spectral": 1, "respiratory": 2, "streaming": 3, "breathing": 4,
    "wave": 5, "meteor": 6, "coverage": 7, "stars": 8, "explosion": 9,
}

# DPI indicator colours, copied from the page's packet
COLOURS = [0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0x00,
           0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0x6B, 0x6B, 0x4E, 0xCD, 0xC4]


_seq = random.randint(0x20, 0xE0)


def build(ptype, b2, data, pad=0xFF):
    global _seq
    data = list(data) + [pad] * (27 - len(data))
    chk = (ptype + _seq + b2 + sum(data) + 6) & 0xFF
    pkt = bytes([6, ptype, _seq, b2, chk] + data)
    _seq = (_seq + 1) & 0xFF
    return pkt


def dpi_packets(active, presets):
    d = [active, 0x3F]
    for v in presets:
        r = v // 50 - 1
        d += [r & 0xFF, r >> 8]
    return [build(2, 0x02, d), build(2, 0x12, d), build(3, 0x01, COLOURS)]


def candidates():
    return [d for d in hid.enumerate(VID)
            if d["product_id"] in PIDS and d["usage_page"] == 0x0A]


def write(pkts):
    for d in candidates():
        h = hid.device()
        try:
            h.open_path(d["path"])
        except OSError:
            continue
        ok = True
        try:
            for p in pkts:
                if h.send_feature_report(p) < 0:
                    ok = False
                    break
                time.sleep(0.05)
                try:
                    h.get_feature_report(6, 32)   # the page reads back after each send
                except OSError:
                    pass
                time.sleep(0.05)
        finally:
            h.close()
        if ok:
            return True
    return False


def read_status(seconds=7):
    for d in candidates():
        h = hid.device()
        try:
            h.open_path(d["path"])
            h.read(64, 1)
        except OSError:
            continue
        end = time.time() + seconds
        while time.time() < end:
            r = h.read(64, 500)
            if r and r[0] == 0x04:
                h.close()
                return bytes(r)
        h.close()
        return None
    return None


def fields(s):
    if not s:
        return "no status"
    return (f"byte2={s[2]} rate_code={s[3]} battery={s[4]} light_mode={s[6]}"
            f"  raw={s[:10].hex(' ')}")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    arg = sys.argv[2] if len(sys.argv) > 2 else None

    if cmd == "status":
        print(fields(read_status(10)))
        return
    if cmd == "battery":
        s = read_status(10)
        if not s:
            raise SystemExit("no status report received")
        print(f"{s[4]}%")
        return
    if cmd == "dpi":
        n = int(arg) if arg is not None else 0
        presets = list(DPI_PRESETS)
        if len(presets) != 6:
            raise SystemExit("DPI_PRESETS needs exactly 6 values")
        if n <= 5:
            idx = n                        # select a preset
        else:
            if not 200 <= n <= 36000:
                raise SystemExit("dpi <0-5> to pick a preset, or 200-36000")
            idx = CUSTOM_SLOT
            presets[idx] = round(n / 50) * 50
        pkts = dpi_packets(idx, presets)
    elif cmd == "rate":
        hz = int(arg) if arg is not None else 1000
        if hz not in RATE_CODES:
            raise SystemExit(f"rate {sorted(RATE_CODES)}")
        pkts = [build(4, 0x01, [RATE_CODES[hz]], pad=0x00)]
    elif cmd == "lights":
        name = (arg or "off").lower()
        mode = int(name) if name.isdigit() else LIGHT_MODES.get(name)
        if mode is None or not 0 <= mode <= 9:
            raise SystemExit(f"lights {list(LIGHT_MODES)} or 0-9")
        pkts = [build(6, 0x01, [0xFF, mode, 0x00, 0x00])]
    elif cmd == "power":
        if not 1 <= SLEEP_MINUTES <= 20:
            raise SystemExit("SLEEP_MINUTES must be 1-20")
        pkts = [build(7, 0x01, [SLEEP_MINUTES, KEEP_MOTION_WAKE, LIGHTS_OFF_WHILE_MOVING])]
    elif cmd == "sensor":
        pkts = [build(8, 0x01, [ANGLE_SNAP, MOTION_SYNC, RIPPLE_CONTROL])]
    else:
        raise SystemExit("usage: dpi <value> | rate <hz> | lights <name> | power | sensor | battery | status")

    print("done" if write(pkts) else "write FAILED on every interface")


main()