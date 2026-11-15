#!/bin/sh
# Volumen build driver.
set -eu

MODE=native
JOBS=$( (getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2) )

for arg in "$@"; do
  case "$arg" in
    --static)  MODE=static ;;
    --minimal) MODE=minimal ;;
    --debug)   MODE=debug ;;
    -h|--help)
      cat <<'EOF'
usage: tools/build.sh [--static] [--minimal] [--debug]

  --static    static musl build (needs musl-gcc)
  --minimal   no TLS, no NLS, smallest possible; for rescue images only
  --debug     -O0 -g3, for gdb
EOF
      exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 64 ;;
  esac
done

TLS_FLAG=--with-ssl
case "$MODE" in
  native)
    CFLAGS="-O2 -flto -fomit-frame-pointer -DNDEBUG -fstack-protector-strong -D_FORTIFY_SOURCE=2"
    LDFLAGS="-Wl,-O1 -Wl,--as-needed -s" ;;
  static)
    CFLAGS="-O2 -flto -fomit-frame-pointer -DNDEBUG -fstack-protector-strong -D_FORTIFY_SOURCE=2 -static"
    LDFLAGS="-static -s"
    CC=musl-gcc; export CC ;;
  minimal)
    CFLAGS="-Os -DNDEBUG"
    LDFLAGS="-s"
    TLS_FLAG=--without-ssl ;;
  debug)
    CFLAGS="-O0 -g3 -fno-omit-frame-pointer"
    LDFLAGS="" ;;
esac
export CFLAGS LDFLAGS

[ -x ./configure ] || { echo "no ./configure - this tree ships one; check the import" >&2; exit 1; }

echo "== configure ($MODE) =="
# --help is authoritative for this tree. These are the flags that matter for
# size and speed and are stable across Lynx 2.9.x.
./configure \
  "$TLS_FLAG" \
  --disable-nls \
  --with-screen=ncurses \
  --enable-htmlized-cfg \
  --disable-full-paths \
  || { echo "configure failed. Usually: ncurses, zlib or an SSL dev package." >&2; exit 1; }

echo "== make -j$JOBS =="
make -j"$JOBS"

echo "== done =="
ls -l src/lynx 2>/dev/null || true
if command -v size >/dev/null 2>&1; then size src/lynx 2>/dev/null || true; fi
echo "budget: 900 KB stripped static. See PLAN.md."
