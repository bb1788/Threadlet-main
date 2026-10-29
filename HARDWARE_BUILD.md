# WSL 硬件编译使用说明

在 WSL Ubuntu-22.04 中运行：

```bash
cd ~/work/Threadlet-main
bash script/build-hardware.sh build
bash script/build-hardware.sh smoke
```

第一条编译 Threadlet CPU 的独立 Verilator 仿真器；第二条编译并运行最小程序。
看到 `PASS` 表示基本运行测试通过。以后改了硬件代码，重新执行这两条即可。
本次已实际完成这两步。首次构建需要较长时间，后续支持增量编译。

这条路径不需要缺失的 LFS 工具链压缩包。它使用 Nix 提供的裸机工具链。
若以后要编译 Linux benchmark，可另运行 `bash script/fetch-toolchain.sh`，
从原仓库下载并校验真正的压缩包；本次没有完成这个大文件的下载。

当前验证范围是独立 CPU 仿真，不包含完整 Threadlet 调度功能验证、
Chipyard 集成、LoomOS 或 FPGA 比特流。详细技术说明如下。

---
# WSL: Threadlet CPU standalone Verilator build

This builds the Threadlet-modified Rocket CPU in this repository. It does not use
or change `~/work/rocket-chip` or `~/work/threadlet-rocket`.

## Prerequisite

Nix with `nix-command` and `flakes` support is required. It is already installed in
the current Ubuntu-22.04 WSL environment. For a fresh machine, follow the official
Nix installation instructions: https://nixos.org/download/ . First-time dependency
downloads require network access and may take a while.

## Commands (run from WSL)

```bash
cd ~/work/Threadlet-main
# Optional: check Scala compilation only.
bash script/build-hardware.sh compile
# Build the DefaultConfig standalone Verilator simulator.
bash script/build-hardware.sh build
# Compile and execute the bare-metal arithmetic smoke test.
bash script/build-hardware.sh smoke
```

The helper enters the development shell pinned by Rocket Chip's `flake.lock`.
It uses Nix-provided Mill, Chisel dependencies, CIRCT, Verilator, Clang, Spike/FESVR,
and the bare-metal RISC-V compiler. Java and native compilation use two threads;
Java defaults to a 3 GiB heap. Override `JAVA_TOOL_OPTIONS` if necessary.

Simulator output:

```text
chipyard/generators/rocket-chip/out/emulator/freechips.rocketchip.system.TestHarness/freechips.rocketchip.system.DefaultConfig/verilator/elf.dest/emulator
```

Build outputs are local and ignored by Git. Re-run `build` after editing hardware.
A smoke PASS verifies basic CPU execution and `tohost` exit, not full Threadlet
scheduling behavior or FPGA correctness.

## Changes supporting standalone compilation

* Restored the four missing dependency source directories; see their README for
  upstream URLs, recovered revisions, and licenses. They are vendored ordinary
  files so `git clone` also gets them without submodule setup.
* The standalone Mill module includes a small `SynthesizePrintf` adapter. It keeps
  ordinary Chisel `printf` calls but does not add FireSim FPGA instrumentation.
  It lives outside `src/main/scala`, so the Chipyard/FireSim build does not include
  the adapter and must use the real FireSim implementation.
* Ninja parallelism is limited to two jobs to fit this WSL machine.
* Optional RISCOF Python installation is disabled by default in the Nix shell.
  Set `THREADLET_INSTALL_RISCOF=1` if you need that separate test framework.

## LFS archive and other build paths

The 134-byte `.tar.bz2` under `third_party/toolchains` is an upstream Git LFS pointer,
not the archive. It is NOT needed for the standalone hardware build above.
The Linux userspace benchmarks use a different compiler (glibc, rv64gc/lp64d),
which cannot be replaced with the bare-metal compiler used for the smoke test.

To obtain the actual archive from the original public repository:

```bash
bash script/fetch-toolchain.sh
```

The helper resumes interrupted downloads, verifies the original SHA-256, and only
then replaces the pointer. This fork does not currently host that large LFS object;
installing Git LFS and running `git lfs pull` against this fork alone will not fix it.
Do not commit the expanded 124 MB archive as a normal Git file.

Full Chipyard integration, FireSim, FPGA bitstreams, LoomOS, and Linux benchmarks
are separate build targets and are not validated by this standalone smoke test.
The original FPGA scripts also contain author-specific absolute paths and require
additional environment setup described in `EVALUATION_GUIDE.md`.
