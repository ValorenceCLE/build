#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Allow overrides via env; fall back to lib.config defaults
./compile.sh \
  BOARD="${BOARD:-orangepizero3}" \
  BRANCH="${BRANCH:-current}" \
  RELEASE="${RELEASE:-bookworm}" \
  KERNEL_CONFIGURE="${KERNEL_CONFIGURE:-no}" \
  CLEAN_LEVEL="${CLEAN_LEVEL:-make,debs,images}"
