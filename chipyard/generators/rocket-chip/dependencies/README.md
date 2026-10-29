# Vendored standalone hardware dependencies

These source snapshots make the ZIP import buildable without missing submodules.
Original licenses are retained. Revisions below were recovered from the existing
working Rocket Chip environment and verified with the standalone Threadlet build.

| Directory | Upstream | Revision |
|---|---|---|
| cde | https://github.com/chipsalliance/cde.git | `52768c97a27b254c0cc0ac9401feb55b29e18c28` |
| chisel | https://github.com/chipsalliance/chisel.git | `e3bcc90db37f1aec9f8048813f4f0666098d9bee` |
| diplomacy | https://github.com/chipsalliance/diplomacy.git | `fe5e131d4fc8adec14a3ce4a4935bb5c0a269871` |
| hardfloat | https://github.com/ucb-bar/berkeley-hardfloat.git | `d93aa570806013dea479a92ba9bb33d1f2d4f69f` |

The nested HardFloat softfloat/testfloat working trees are included as well.
These directories are ordinary tracked files, not registered Git submodules.
