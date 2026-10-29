#!/usr/bin/env bash
# Optional Linux benchmark SDK; not required for standalone hardware simulation.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
name=riscv64-lp64d--glibc--stable-2021.11-1.tar.bz2
expected=70fe7d9fc74220b08b2ae0d3527641f4b938a1e4eb6bb305b2ac68fa76f2d6a4
archive="$root/third_party/toolchains/$name"
if echo "$expected  $archive" | sha256sum -c - >/dev/null 2>&1; then
  echo "Toolchain archive already verified."
  exit 0
fi
# Leave the existing LFS pointer untouched until download and checksum succeed.
partial="$archive.download"
curl --fail --location --retry 3 --connect-timeout 20 --continue-at - \
  --output "$partial" "https://media.githubusercontent.com/media/TELOS-syslab/Threadlet/main/third_party/toolchains/$name"
echo "$expected  $partial" | sha256sum -c -
mv -- "$partial" "$archive"
echo "Downloaded and verified the original Linux benchmark toolchain."
