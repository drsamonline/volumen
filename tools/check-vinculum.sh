#!/bin/sh
set -eu
CANON="${VINCULUM_CANON:-}"
[ -z "$CANON" ] && { echo "VINCULUM_CANON unset - local listing only"; ls -1 shared/vinculum/; exit 0; }
rc=0
for f in "$CANON"/*; do
  cmp -s "$f" "shared/vinculum/$(basename "$f")" || { echo "DRIFT: $(basename "$f")"; rc=1; }
done
[ "$rc" -eq 0 ] && echo "vinculum: identical"
exit "$rc"
