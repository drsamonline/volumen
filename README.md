# Volumen

**volumen, voluminis** *(n.) - a roll, a scroll, a book.* Before books had pages
they had volume: one continuous thing you unrolled and read. That is the shape of a
text browser, and it is the shape of the output this one produces.

Volumen is a fork of [Lynx](https://invisible-island.net/lynx/) at commit `7f67078`,
kept small, and rebuilt around two jobs a text browser is uniquely good at: reading
without distraction, and turning the web into data a program can use.

Part of the [Aetheris browser family](FAMILY.md) - tier 3, the text and automation
tier.

```
T0 Aetheris   full fidelity, 200 MB+
T1 Nodus      shared core, 25-70 MB
T2 Sorex      everyday GUI, 15-30 MB
T3 Volumen    THIS REPO, 5-8 MB
```

## What Volumen is

- **A reader.** Text at the speed of reading: no images, no layout, no waiting, and
  a rendering model that works over a 9600 baud link because it was designed for one.
- **A machine interface.** `--dump --format=json|markdown|reader` turns a page into
  structured output with headings, links, lists and tables intact, so a script - or a
  language model - can use the web without a browser engine.
- **An automation tool.** Forms, cookies, batches, and a deterministic output mode
  that makes a text browser a testable component rather than an interactive toy.
- **A GPL-2.0-only sibling of Nodus.** The two share a licence, which means they can
  genuinely share code: Nodus's CSS work can inform this text flow, and this text
  extraction can inform Nodus's text frontend. That corridor is the family's most
  useful one (see `FAMILY.md`).

## What Volumen is not

- Not a GUI browser. There is no window, and there never will be; that is Sorex's job.
- Not a Lynx skin. The dump format changes, the parser gets structure, and the
  automation surface becomes an API.
- Not finished. v0.1 means imported, documented, building, nothing improved yet.

## Build

```sh
./tools/build.sh                  # tuned native build
./tools/build.sh --static         # static musl, single binary
./tools/build.sh --minimal        # no TLS, no NLS, smallest possible (testing only)
```

Upstream needs a curses library (ncurses or slang), zlib, and one TLS library.
`./configure --help` in the tree is authoritative.

## Run

```sh
./src/lynx https://example.org
./src/lynx -dump https://example.org
./src/lynx -dump --format=markdown https://example.org > page.md
./src/lynx -dump --format=json https://example.org | jq '.headings'
./src/lynx --batch urls.txt --out-dir ./pages
```

## Budget

| Metric | Target | Why |
|--------|--------|-----|
| RSS, interactive, one page | <= 8 MB | it must fit beside everything else |
| RSS, single `-dump` | <= 5 MB | it must be safe in a cron job |
| Stripped static binary | <= 900 KB | it must fit on a rescue image |
| 100 URLs, batch, 8 workers | <= 30 s on a 10 Mbit link | automation has to be practical |
| Dump determinism | 100% byte-identical across runs | or nothing downstream is testable |

## Documentation

| File | Read it when |
|------|--------------|
| [FAMILY.md](FAMILY.md) | how the four browsers relate, and what may legally be shared |
| [SOURCES.md](SOURCES.md) | exactly which upstream this came from, and its odd mirror |
| [PLAN.md](PLAN.md) | scope, workstreams, success criteria |
| [DESIGN.md](DESIGN.md) | module map, the dump pipeline, the automation surface |
| [INNOVATIONS.md](INNOVATIONS.md) | the enhancement backlog with measurements |
| [ROADMAP.md](ROADMAP.md) | release sequence and exit criteria |
| [START_PROMPT.md](START_PROMPT.md) | you are an agent or a new contributor starting work |
| [AGENTS.md](AGENTS.md) | the working rules only |
| [PATCHES.md](PATCHES.md) | you are touching vendored upstream code |

## Provenance and licence

Derived from Lynx `7f67078` (2026-10-18), version 2.9.3f,
`ThomasDickey/lynx-snapshots`. Lynx is **GPL-2.0-only** - `COPYING` is GPLv2 verbatim and the per-file
terms defer to `COPYHEADER` with no blanket "or later" grant - so Volumen is
**GPL-2.0-only** too. See `COPYING`.

Note on the mirror: Lynx is developed outside GitHub, at invisible-island.net. The
GitHub repository this tree came from is the maintainer's read-only snapshot mirror
and explicitly does not accept pull requests; see `SOURCES.md` for what that means
for contributing upstream.

Shared specs in `shared/vinculum/` are CC0-1.0.

Author: Dr Sohil Momin.
