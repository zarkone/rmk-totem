# rmk-totem

[RMK](https://github.com/HaoboGu/rmk) firmware for the
[TOTEM](https://github.com/GEIGEIGEIST/TOTEM) (38 keys, split), on a pair of
Seeed XIAO nRF52840. Forked from
[andriidemus/rmk-totem](https://github.com/andriidemus/rmk-totem); the layout
is the shared one from [zilpzalp-zmk](../zilpzalp-zmk) and the corne-ish zen:
colemak-DH, chord-heavy, zen-style layers.

## Why RMK and not ZMK

The XIAO modules on this particular totem are (most likely) clone nRF52840
silicon: **any Zephyr-based firmware hangs before USB init** — ZMK v0.2, ZMK
main and CircuitPython all flash byte-perfectly (verified by `CURRENT.UF2`
readback) but never boot, with or without the SoftDevice installed. The
Adafruit bootloader (2021-era nrfx) and Embassy-based RMK run fine; the
likely difference is modern nrfx SoC init poking undocumented errata/trim
registers that clones don't implement. The full investigation and a
mothballed, buildable ZMK config live in [totem-zmk](../totem-zmk).

Two RMK-specific facts inherited from that story:

- **RMK is pinned to git main**, not crates.io: released 0.8.2 (2025-12) has
  broken permissive-hold ([#743](https://github.com/HaoboGu/rmk/issues/743),
  fixed 2026-02) — tap-holds resolved by timeout only, so cross-half
  `ctrl+key` needed an unnatural pause.
- RMK links at `0x1000`, **replacing the SoftDevice**. To ever go back to
  SoftDevice-based firmware, restore it via
  `../totem-zmk/tools/flash-bootloader.sh`.

## Base layer (CLDH)

```
                LEFT                                      RIGHT
  ┌─────┬─────┬─────┬─────┬─────┐          ┌─────┬─────┬─────┬─────┬─────┐
  │  Q  │  W  │  F  │  P  │  B  │          │  J  │  L  │  U  │  Y  │  ;  │
  ├─────┼─────┼─────┼─────┼─────┤          ├─────┼─────┼─────┼─────┼─────┤
  │  A  │  R  │  S  │  T  │  G  │          │  M  │  N  │  E  │  I  │  O  │
┌─┼─────┼─────┼─────┼─────┼─────┤          ├─────┼─────┼─────┼─────┼─────┼─┐
│⊞│  Z  │  X  │  C  │  D  │  V  │          │  K  │  H  │  ,  │  .  │  /  │⊞│
└─┤ ctl │     │     │     │     │          │     │     │     │     │ ctl ├─┘
  └─────┴─────┴─┬───┴─┬───┴─┬───┴─┐      ┌─┴───┬─┴───┬─┴───┬─┴─────┴─────┘
                │ TAB │ SPC │ SPC │      │ RET │ BSPC│ ESC │
                │ NUM │ SYM │ alt │      │ alt │ SYM │ NUM │
                └─────┴─────┴─────┘      └─────┴─────┴─────┘
```

- `⊞` = Super (LGui/RGui) on the extra outer pinky keys.
- Ctrl is held on Z and `/`; all tap-holds use the `bal` morse profile
  (permissive hold = ZMK's "balanced" flavor: another key pressed *and
  released* during the hold resolves it as hold instantly).
- Thumbs: outer taps Tab/Esc + holds NUM, middle taps Space/Bspc + holds
  SYM, inner taps Space/Enter + holds Alt.

## Chords (combos)

All chords have a 20 ms timeout. Shift lives only on chords (plus
caps-word):

| Chord | Keys | Output | Mnemonic |
|-------|------|--------|----------|
| Esc | F+P | `Esc` | top-left horizontal |
| Bspc | L+U | `Bspc` | top-right horizontal, mirrors Esc |
| Tab | X⋯D | `Tab` | bottom-left skip |
| dash | W⋯P | `-` | top-left skip |
| under | H⋯. | `_` | bottom-right skip, mirrors dash |
| `'` | N+H | `'` | inner vertical, right |
| `"` | T+D | `"` | inner vertical, left |
| copy | W+R | `Ctrl+Shift+C` | terminal copy, left ring vertical |
| paste | Y+I | `Ctrl+Shift+V` | terminal paste, right ring vertical |
| Ctrl+A | P+T, L+N | `Ctrl+A` | select all, both index verticals |
| PgUp | F+S | `PgUp` | left middle vertical |
| PgDn | U+E | `PgDn` | right middle vertical |
| lang | J+M | `Alt+"` | OS layout switch, right inner vertical |
| Del | U+Y | `Del` | |
| del word | L⋯Y | `Ctrl+Bspc` | |
| caps word | A+O | caps-word | both home pinkies |
| CAPS | Q+; | `CapsLock` | both top corners |
| Shift | Z+X / .+/ | `LShift` / `RShift` | bottom corners, hold & type |
| Ctrl+Shift | A+Z / O+/ | held `Ctrl+Shift` | pinky verticals — Ctrl held lives below |

The Ctrl+Shift chords are held modifiers, implemented as `LM()` onto a
fully-transparent layer — RMK's `WM()` drops its modifiers on the next
keypress by design, so it can't act as a held modifier pair.

## Layers

```
SYM (hold middle thumb: Space / Bspc)
  _  :  =  -  +     mute vol- ⏯  vol+  `
  <  >  (  )  pgu    "   ←   ↑   →    '
  {  }  [  ]  pgd    ~  home ↓  end   \
    TAB* ESC ALT     ALT DEL  =*        (* = hold for FN)

NUM (hold outer thumb: Tab / Esc)
  _  _  _  &  *     capsW 7  8  9  ~
  !  @  #  $  ^     CAPS  4  5  6  `
  _  _  _  %  |     PrtSc 1  2  3  .
    _  SPC* SPC      0  .*  _           (* = hold for FN)

FN (hold a * thumb on SYM or NUM)
  btclr _   _   _   BOOT    _  F7 F8 F9 F10
  bt3  bt2  bt1 bt0 out     _  F4 F5 F6 F11
  _    _    _   _   _       _  F1 F2 F3 F12
```

FN legend: T/S/R/A select BLE profile 0–3, Q (`btclr`) clears the current
profile's bond, G (`out`) toggles USB/BLE output priority, B enters the UF2
bootloader.

## Build

Requires [nix](https://nixos.org) with flakes; the dev shell provides latest
stable rust (rust-overlay) with the thumbv7em target, and libclang for the
nrf-sdc bindgen.

```sh
nix develop
./build-uf2.sh   # -> rmk-totem-central.uf2 (left), rmk-totem-peripheral.uf2 (right)
```

## Flash

Double-tap the reset button — the `XIAO-SENSE` drive appears — then copy
with **dd, not cp**: the bootloader reboots the instant it receives the
final UF2 block, while `cp`'s page cache may still hold middle blocks
(silent partial flash).

```sh
dd if=rmk-totem-central.uf2    of=/run/media/$USER/XIAO-SENSE/fw.uf2 bs=512 oflag=direct  # left
dd if=rmk-totem-peripheral.uf2 of=/run/media/$USER/XIAO-SENSE/fw.uf2 bs=512 oflag=direct  # right
```

Only the left half (central) talks to hosts; the right half only talks to
the left. After changing the *stored* keymap format, set
`clear_storage = true` in `keyboard.toml` for one flash cycle, then back to
`false` (while true, bonds are wiped on every boot).

## Pairing

- **Halves**: automatic on the first boot of both.
- **Host**: the totem only advertises when the active profile has no bond —
  unplug USB, pick a free profile (FN+S/R/A) or clear the current one
  (FN+Q), then pair from the OS bluetooth settings. After firmware version
  jumps, stored bonds break: remove the device host-side, FN+Q, re-pair.
- Vial works at [vial.rocks](https://vial.rocks) over USB for live layout
  edits.
