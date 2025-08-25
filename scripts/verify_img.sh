#!/usr/bin/env bash
set -euo pipefail

IMG=${1:-$(ls -t output/images/*.img | head -n1)}
[ -f "$IMG" ] || { echo "No image found"; exit 1; }

LOOP=$(sudo losetup -Pf --show "$IMG")
trap 'sudo losetup -d "$LOOP" >/dev/null 2>&1 || true' EXIT

sudo mkdir -p /mnt/armbian
sudo mount ${LOOP}p1 /mnt/armbian
trap 'sudo umount /mnt/armbian >/dev/null 2>&1 || true; sudo losetup -d "$LOOP" >/dev/null 2>&1 || true' EXIT

echo "[verify] DTBOs present:"
ls -l /mnt/armbian/boot/dtb/allwinner/overlay/sun50i-h616-ph-i2c{3,4}.dtbo

echo "[verify] Symlink:"
ls -l /mnt/armbian/boot/dtb/overlay | grep 'allwinner/overlay'

echo "[verify] armbianEnv:"
grep -E '^(overlay_prefix|overlays)=' /mnt/armbian/boot/armbianEnv.txt | tee /dev/stderr | grep -q 'overlays=ph-i2c3 ph-i2c4'

echo "[verify] OK"
