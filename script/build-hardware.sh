#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
hw="$root/chipyard/generators/rocket-chip"
mode=${1:-build}
if [[ ${THREADLET_NIX_READY:-0} != 1 ]]; then
  command -v nix >/dev/null || { echo "Install Nix with flakes support first (see HARDWARE_BUILD.md)." >&2; exit 1; }
  cd "$hw"
  exec nix --extra-experimental-features 'nix-command flakes' develop "path:$hw" --command env THREADLET_NIX_READY=1 bash "$root/script/build-hardware.sh" "$mode"
fi
cd "$hw"
export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:--XX:ActiveProcessorCount=2 -Xmx3g}"
case "$mode" in
  compile) mill -i 'rocketchip[6.7.0].compile' ;;
  build) mill -i 'emulator[freechips.rocketchip.system.TestHarness,freechips.rocketchip.system.DefaultConfig].elf' ;;
  smoke)
    sim="$hw/out/emulator/freechips.rocketchip.system.TestHarness/freechips.rocketchip.system.DefaultConfig/verilator/elf.dest/emulator"
    [[ -x "$sim" ]] || { echo "Run build first." >&2; exit 1; }
    mkdir -p "$root/.hardware-build"
    riscv64-none-elf-gcc -march=rv64imac -mabi=lp64 -nostdlib -nostartfiles -Wl,-Ttext=0x80000000 -Wl,--no-relax -o "$root/.hardware-build/smoke.elf" "$root/script/hardware-smoke.S"
    timeout 120 "$sim" +max-cycles=1000000 "$root/.hardware-build/smoke.elf"
    echo 'PASS: standalone CPU executed the smoke program and reported tohost=1.' ;;
  *) echo "Usage: bash script/build-hardware.sh [compile|build|smoke]" >&2; exit 2 ;;
esac
