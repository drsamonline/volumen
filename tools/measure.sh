#!/bin/sh
# Measure the numbers PLAN.md is judged on.
set -eu
BIN=${VOLUMEN_BIN:-./src/lynx}
[ -x "$BIN" ] || { echo "no binary at $BIN - build first" >&2; exit 1; }

echo "== binary =="
ls -l "$BIN" | awk '{print "size_bytes: "$5}'
if command -v ldd >/dev/null 2>&1; then echo -n "dynamic: "; ldd "$BIN" 2>&1 | head -1; fi

echo "== single dump: rss and time =="
FIX=test/corpus/fixtures/index.html
[ -f "$FIX" ] || FIX=about:blank
/usr/bin/time -f "rss_kb: %M  wall_s: %e" "$BIN" -dump "$FIX" >/dev/null

echo "== determinism spot check =="
if [ -f "$FIX" ]; then
  a=$(TZ=UTC LC_ALL=C "$BIN" -dump "$FIX" | sha256sum | cut -d' ' -f1)
  b=$(TZ=Asia/Kolkata LC_ALL=en_US.UTF-8 "$BIN" -dump "$FIX" | sha256sum | cut -d' ' -f1)
  [ "$a" = "$b" ] && echo "deterministic: yes" || echo "deterministic: NO ($a vs $b)"
fi

echo
echo "Paste this into the pull request. Compare against PLAN.md, not a feeling."
