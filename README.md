# RMK TOTEM

## Layout (this fork)

Colemak-DH port of the zilpzalp/corne-ish-zen layout (see
[totem-zmk](../totem-zmk) for the full design history). Layers:
CLDH / SYM (hold middle thumbs) / NUM (hold outer thumbs) / FN (hold the
`*` thumbs on SYM or NUM). Ctrl held on Z and `/`, Super on the extra
pinky keys, Alt on inner thumbs.

Chords (20 ms): Esc F+P · Tab X⋯D · `-` W⋯P · `_` H⋯. · `'` N+H ·
`"` T+D · copy W+R · paste Y+I · Ctrl+A P+T, L+N · PgUp F+S · PgDn U+E ·
lang J+M · caps-word A+O · CapsLock Q+; · Bspc L+U · Del U+Y ·
del-word L⋯Y · Shift Z+X, .+/ · Ctrl+Shift (held) A+Z, O+/

FN layer: T/S/R/A = BLE profile 0-3, Q = clear profile bond,
G = USB/BLE output toggle, B = bootloader.

Build: `nix develop`, then `./build-uf2.sh`; flash with
`dd if=<uf2> of=/run/media/$USER/XIAO-SENSE/fw.uf2 bs=512 oflag=direct`
after double-tap reset (central → left, peripheral → right).


RMK configuration for [the Totem keyboard](https://github.com/GEIGEIGEIST/TOTEM/).

## uf2 support

If you’re using the Adafruit_nRF52_Bootloader (pre-installed on the nice!nano), you’re in luck! This bootloader supports the .uf2 firmware format, which eliminates the need for a debugging probe to flash your firmware. RMK uses the `cargo-make` tool to generate .uf2 firmware, with the generation process defined in the `Makefile.toml`.

Follow these steps to generate and flash the .uf2 firmware with RMK:

1. Get `cargo-make` tool:
   ```shell
   cargo install --force cargo-make
   ```
2. Compile RMK and generates .uf2 firmware:
   ```shell
   cargo make uf2 --release
   ```
3. Flash

   - Put your board into bootloader mode. A USB drive will appear on your computer.
   - Drag and drop the generated .uf2 firmware file onto the USB drive. The RMK firmware will be automatically flashed onto your microcontroller.

   For additional details on entering bootloader mode and flashing firmware, refer to the [nice!nano documentation](https://nicekeyboards.com/docs/nice-nano/getting-started#flashing-firmware-and-bootloaders)

## Edit layout
RMK supports Vial, so you can edit layout at https://vial.rocks 

### Tips for nRF52840

Most nice!nano compatible boards have bootloader with SoftDevice pre-flashed. Since v0.7.x, RMK will remove old SoftDevice Bluetooth stack and replace it with its own. So if you want to rollback to v0.6.x, or switch to firmwares that use SoftDevice stack(for example, zmk), you will need to [re-flash the bootloader](https://nicekeyboards.com/docs/nice-nano/troubleshooting#my-nicenano-seems-to-be-acting-up-and-i-want-to-re-flash-the-bootloader).

### Additional notes

RMK defaults to USB-priority mode if a USB cable is connected. After flashing, remember to disconnect the USB cable, or [switch to BLE-priority mode](https://rmk.rs/docs/features/wireless.html#multiple-profile-support) by pressing User11(Switch Output) key.
