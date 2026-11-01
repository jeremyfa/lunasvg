#!/bin/bash
# Builds the native reference generator against an upstream lunasvg 3.5.0
# checkout (with its bundled plutovg 1.3.3) and regenerates the hash files of
# test/reference/ for every case list given.
#
# Usage: ./build.sh <path-to-lunasvg-checkout> <build-dir> [--raw] [list...]
#
# With no list, test/cases-resvg.txt and test/cases-lucide.txt are used.
# Raw dumps (--raw) are written to <build-dir>/out/raw/ and hash files to
# test/reference/. Floating point contraction is disabled
# (-ffp-contract=off) so that the native results do not depend on whether
# the compiler emits fused multiply-add instructions, which the Haxe port
# cannot reproduce. System fonts are not loaded, so text is not rendered,
# like the Haxe port without a font provider.
set -eu

LUNASVG_DIR="${1:?usage: build.sh <lunasvg-dir> <build-dir> [--raw] [list...]}"
BUILD_DIR="${2:?usage: build.sh <lunasvg-dir> <build-dir> [--raw] [list...]}"
shift 2
RAW=""
if [ "${1:-}" = "--raw" ]; then
    RAW="--raw"
    shift
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$HERE/.."
OUT_DIR="$BUILD_DIR/out"
mkdir -p "$BUILD_DIR/obj" "$OUT_DIR/raw"

FLAGS="-O2 -ffp-contract=off -DPLUTOVG_BUILD -DPLUTOVG_BUILD_STATIC -DLUNASVG_BUILD -DLUNASVG_BUILD_STATIC -DLUNASVG_DISABLE_LOAD_SYSTEM_FONTS"
INCLUDES="-I$LUNASVG_DIR/include -I$LUNASVG_DIR/source -I$LUNASVG_DIR/plutovg/include -I$LUNASVG_DIR/plutovg/source"

if [ ! -f "$BUILD_DIR/refgen" ]; then
    for src in "$LUNASVG_DIR"/plutovg/source/*.c; do
        cc -std=c11 $FLAGS $INCLUDES -c "$src" -o "$BUILD_DIR/obj/$(basename "$src" .c).o"
    done
    for src in "$LUNASVG_DIR"/source/*.cpp; do
        c++ -std=c++17 $FLAGS $INCLUDES -c "$src" -o "$BUILD_DIR/obj/$(basename "$src" .cpp).o"
    done
    c++ -std=c++17 $FLAGS $INCLUDES "$HERE/refgen.cpp" "$BUILD_DIR"/obj/*.o -lm -o "$BUILD_DIR/refgen"
fi

if [ $# -eq 0 ]; then
    set -- "$TEST_DIR/cases-resvg.txt" "$TEST_DIR/cases-lucide.txt"
fi

for list in "$@"; do
    "$BUILD_DIR/refgen" "$list" "$OUT_DIR" $RAW
    cp "$OUT_DIR/$(basename "$list" .txt).hashes" "$TEST_DIR/reference/"
done

echo "Hashes written to $TEST_DIR/reference"
