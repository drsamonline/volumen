#!/bin/sh
# The upstream is a snapshot mirror, so this reports a diff summary rather than a
# commit list. Read the diff before merging it.
set -eu
UPSTREAM_URL="https://github.com/ThomasDickey/lynx-snapshots.git"
UPSTREAM_BRANCH="master"

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git fetch upstream

echo "== files changed upstream =="
git diff --stat HEAD upstream/$UPSTREAM_BRANCH | tail -30 || true

if [ "${1:-}" = "--merge" ]; then
  git merge "upstream/$UPSTREAM_BRANCH" || {
    echo "conflict: resolve, then update PATCHES.md"
    exit 1
  }
  echo "merged. Run tools/build.sh, tools/test-golden.sh text, and check the size budget."
else
  echo "dry run. Re-run with --merge to merge."
fi
