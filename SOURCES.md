# Sources

Where this tree came from, exactly, and what may be pulled into it later.

## Upstream

| Field | Value |
|-------|-------|
| Project | Lynx |
| Repository (used here) | https://github.com/ThomasDickey/lynx-snapshots |
| Real home | https://invisible-island.net/lynx/ |
| Commit | `7f67078` (2026-10-18) |
| Version at that commit | 2.9.3f |
| Licence | GPL-2.0-only (`COPYING` is GPLv2 verbatim; per-file terms via `COPYHEADER`) |
| Size / files | 19 MB, 576 tracked files |
| Language | C |
| Code lines | ~193,000 (`.c` + `.h`) |

The whole upstream tree is present at the commit above.

## About that mirror, because it matters

`ThomasDickey/lynx-snapshots` describes itself as "snapshots of releases and interim
labels" and states plainly that it takes no pull requests. It is the maintainer's
export, not the development repository. Two consequences:

1. **Upstream syncs are snapshots, not incremental history.** Merging means comparing
   two trees, not replaying commits. Budget for that: `tools/sync-upstream.sh` shows a
   diff summary rather than a commit list.
2. **Contributing upstream means the mailing list**, `lynx-dev`, not GitHub. A fix
   worth sending upstream goes there as a patch, and comes back on the next snapshot.

This is not a reason to avoid Lynx - it is a reason to record the provenance
precisely, which is what this file is for.

## How to sync upstream

```sh
./tools/sync-upstream.sh            # fetch and summarise what changed
./tools/sync-upstream.sh --merge    # attempt the merge
```

Because the mirror is snapshot-based, a "merge" may look like a large diff even when
upstream changed little. Read it before you merge it.

## Upstream layout

| Path | What it is | Will Volumen change it? |
|------|------------|-------------------------|
| `src/` | the browser: `GridText.c` (text renderer), `HTML.c` (parser callbacks), `LYMain.c`, forms, bookmarks | yes, heavily |
| `WWW/` | libwww: HTTP, FTP, gopher, HTML parsing glue, caching | yes: HTTP/2, cache, structure capture |
| `lib/` | small utility code | no |
| `lynx_help/` | help files served as `lynx_help://` | yes: our own help |
| `po/` | translations | no |
| `samples/`, `scripts/` | config samples and helper scripts | yes: shared config |
| `docs/` | upstream documentation | yes, ours goes in `docs/` |
| `test/` | upstream tests | yes: the corpus and golden dumps |

The single most important file in the tree for this project is `src/GridText.c`:
about 10,000 lines that turn parsed HTML into the text you see. Every rendering
change starts and ends there.

## Dependencies

| Dependency | Needed for | Notes |
|------------|-----------|-------|
| ncurses or slang | the interactive UI | ncurses preferred; `--with-screen=ncurses` |
| zlib | compression | brotli is not in Lynx; see I5 |
| OpenSSL (or gnutls) | HTTPS | exactly one backend |
| libcss (optional, MIT) | structure-aware text flow | vendored from the NetSurf project, see I4 |

## Licences of things we may vendor

- **MIT, from the NetSurf project:** `libcss`, `libdom`, `libhubbub`,
  `libparserutils`, `libwapcaplet`, `libnsgif`, `libnsbmp`, `libsvgtiny`. MIT code may
  enter a GPL-2.0 tree freely. `libcss` is the interesting one here.
- **GPL-2.0-only, from Nodus:** both trees are GPL-2.0-only, so code may move in both
  directions with no relicensing. This is the family's only free code corridor and it
  is deliberate.
- **Not permitted:** anything from Sorex. Dillo is GPL-3.0-or-later, which is
  incompatible with GPL-2.0-only in both directions.

## Ideas taken from elsewhere

- Structured dump formats: the idea that a text browser is a data extractor, from a
  decade of people scraping the web with `lynx -dump`.
- Structure-aware text flow via a real CSS engine: Nodus (see `FAMILY.md`).
- The Lite Rendering Profile and its corpus: `shared/vinculum/lite-profile.md`.
- The handoff ladder and capability query: the family contract.
