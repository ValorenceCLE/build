#!/bin/bash
set -euo pipefail

echo "[customize] start"

# Ensure dtc exists inside target rootfs
if ! command -v dtc >/dev/null 2>&1; then
  echo "[customize] installing device-tree-compiler"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends device-tree-compiler
fi

# 1) Compile source overlays shipped via userpatches/overlay -> /tmp/overlay
mkdir -p /boot/dtb/allwinner/overlay
compiled=0
for dts in /tmp/overlay/usr/local/share/dts/sun50i-h616-ph-i2c*.dts; do
  [ -f "$dts" ] || continue
  base="$(basename "$dts" .dts)"
  echo "[customize] compiling $base.dts -> /boot/dtb/allwinner/overlay/$base.dtbo"
  dtc -q -@ -I dts -O dtb -o "/boot/dtb/allwinner/overlay/${base}.dtbo" "$dts"
  compiled=$((compiled+1))
done
echo "[customize] compiled $compiled overlay(s)"

# 2) U-Boot compatibility symlink (some scripts expect /boot/dtb/overlay)
if [ ! -e /boot/dtb/overlay ]; then
  ln -s /boot/dtb/allwinner/overlay /boot/dtb/overlay
  echo "[customize] created symlink /boot/dtb/overlay -> /boot/dtb/allwinner/overlay"
fi

# 3) Configure overlays like armbian-config
sed -i '/^user_overlays=/d' /boot/armbianEnv.txt

if grep -q '^overlay_prefix=' /boot/armbianEnv.txt; then
  sed -i 's/^overlay_prefix=.*/overlay_prefix=sun50i-h616/' /boot/armbianEnv.txt
else
  echo 'overlay_prefix=sun50i-h616' >> /boot/armbianEnv.txt
fi

if grep -q '^overlays=' /boot/armbianEnv.txt; then
  sed -i 's/^overlays=.*/overlays=ph-i2c3 ph-i2c4/' /boot/armbianEnv.txt
else
  echo 'overlays=ph-i2c3 ph-i2c4' >> /boot/armbianEnv.txt
fi

# 4) Optional helpers
mkdir -p /etc/modules-load.d
echo i2c-dev > /etc/modules-load.d/i2c.conf
if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends i2c-tools
fi

echo "[customize] done"
