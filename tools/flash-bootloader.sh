#!/usr/bin/env bash
# Restore the Adafruit bootloader 0.11.0 + SoftDevice S140 7.3.0 (needed to
# leave RMK for SoftDevice-based firmware; RMK overwrites the SD at 0x1000).
# Usage: double-tap reset (bootloader drive appears), then:
#   sudo chmod a+rw /dev/ttyACM0 && ./flash-bootloader.sh
set -euo pipefail
cd "$(dirname "$0")"
V=.nrfutil-venv
if [ ! -x "$V/bin/adafruit-nrfutil" ]; then
    python3 -m venv "$V"
    "$V/bin/pip" -q install adafruit-nrfutil pyserial ecdsa
fi
exec "$V/bin/adafruit-nrfutil" --verbose dfu serial --package bootloader-dfu.zip -p /dev/ttyACM0 -b 115200 --singlebank
