# AGENTS.md

Working rules for coding agents in this repository. Humans should read
`START_PROMPT.md`, the long form of this file.

## Read order

`FAMILY.md` -> `SOURCES.md` -> `PLAN.md` -> `DESIGN.md` -> `INNOVATIONS.md` ->
`ROADMAP.md` -> `PATCHES.md`.

## Non-negotiables

1. `--format=text` output is frozen and byte-compatible.
2. Dumps are deterministic: no timestamps, no locale formatting, no hash order.
3. No images, no CSS rendering, no JavaScript, no GUI.
4. RSS ceilings: 8 MB interactive, 5 MB per dump.
5. GPL-2.0-only: Nodus code may merge; Sorex code may never.
6. Vendored-file edits are logged in `PATCHES.md` in the same commit.
7. Exit codes: 0, 64, 69, 75, 76.
8. Structure, not styling. No floats, no positioning.

## Commit style

`feat(dump):`, `feat(forms):`, `feat(batch):`, `fix(text):`, `perf(arena):`,
`docs(schema):`.

## Before you claim success

Run the command, paste the output. A claim without a command is folklore.

## Where things live

| Need | Path |
|------|------|
| Text renderer (`GridText.c`) and the browser | `src/` |
| Parser callbacks, structure capture | `src/HTML.c`, `src/structure.c` |
| libwww: HTTP, protocols, cache | `WWW/` |
| Small utilities | `lib/` |
| Help pages | `lynx_help/` |
| Tests, fixtures, golden dumps | `test/` |
| Our documentation | `docs/` |
| Shared family specs (do not diverge) | `shared/vinculum/` |
