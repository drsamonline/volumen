#!/bin/sh
# Diff every fixture dump against its committed golden file.
set -eu
BIN=${VOLUMEN_BIN:-./src/lynx}
FMT=${1:-text}
DIR="test/corpus/expect/$FMT"
[ -d "$DIR" ] || { echo "no goldens in $DIR - see START_PROMPT.md task 2" >&2; exit 1; }

rc=0; pass=0; fail=0
for golden in "$DIR"/*; do
  name=$(basename "$golden")
  fixture="test/corpus/fixtures/$name"
  [ -f "$fixture" ] || fixture="test/corpus/fixtures/$(basename "$name" .txt).html"
  [ -f "$fixture" ] || { echo "SKIP $name (no fixture)"; continue; }
  if [ "$FMT" = "text" ]; then
    "$BIN" -dump "$fixture" > /tmp/g.$$ 2>/dev/null
  else
    "$BIN" -dump "--format=$FMT" "$fixture" > /tmp/g.$$ 2>/dev/null
  fi
  if diff -q "$golden" /tmp/g.$$ >/dev/null; then
    pass=$((pass+1))
  else
    echo "FAIL $name"; diff -u "$golden" /tmp/g.$$ | head -20; fail=$((fail+1)); rc=1
  fi
  rm -f /tmp/g.$$
done
echo "golden[$FMT]: $pass passed, $fail failed"
exit "$rc"
