#!/usr/bin/env bash
# Build both halves and produce uf2 files (run inside `nix develop`).
set -euo pipefail
cd "$(dirname "$0")"

# force re-read of keyboard.toml (cargo doesn't track it reliably)
touch build.rs
cargo build --release
cargo objcopy --release --bin central -- -O binary rmk-central.bin
cargo objcopy --release --bin peripheral -- -O binary rmk-peripheral.bin

python3 - <<'EOF'
import struct
def bin_to_uf2(src, dst, base=0x1000):  # RMK links at 0x1000 (replaces SoftDevice)
    data = open(src,'rb').read()
    chunks = [data[i:i+256] for i in range(0,len(data),256)]
    n = len(chunks); out = bytearray()
    for i,c in enumerate(chunks):
        block = struct.pack('<8I', 0x0A324655, 0x9E5D5157, 0x2000, base+i*256, 256, i, n, 0xADA52840)
        block += c.ljust(476, b'\x00') + struct.pack('<I', 0x0AB16F30)
        out += block
    open(dst,'wb').write(out)
    print(f"{dst}: {len(data)} bytes")
bin_to_uf2('rmk-central.bin','rmk-totem-central.uf2')
bin_to_uf2('rmk-peripheral.bin','rmk-totem-peripheral.uf2')
EOF

echo "Flash: double-tap reset, then:"
echo "  dd if=rmk-totem-central.uf2 of=/run/media/\$USER/XIAO-SENSE/fw.uf2 bs=512 oflag=direct   # left"
echo "  dd if=rmk-totem-peripheral.uf2 of=/run/media/\$USER/XIAO-SENSE/fw.uf2 bs=512 oflag=direct # right"
