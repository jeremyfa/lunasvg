#!/bin/bash
# Builds the tests with Haxe and runs them with Node.js.
# Usage: ./run.sh [path-to-haxe] [runner options...]
# Runner options: --raw <dir> (native raw dumps, for max channel diffs),
# --lucide <dir> (Lucide icons folder), --out <dir> (write Haxe dumps).
set -eu
cd "$(dirname "$0")"
HAXE="${1:-${HAXE:-haxe}}"
shift || true
"$HAXE" build.hxml
node bin/test.js "$@"
