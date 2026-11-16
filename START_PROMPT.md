# Start prompt

Paste this whole file into a coding agent at the start of a work session in this
repository. It is self-contained: the agent needs nothing else except the files it
names.

---

You are working in **Volumen**, a fork of the Lynx text browser, at
`https://github.com/drsamonline/volumen`. You are one of four browsers in the Aetheris
family; Volumen is tier 3, the cheapest tier and the automation entry point.

## Read before you type

In this order, and the first one is not optional:

0. `docs/UPSTREAM-FIRST.md` - this tree is a fork; read the vendored source for the
   feature before designing it, and read Ladybird's `Libraries/LibWeb` for anything
   interaction-shaped (focus, events, style invalidation).


1. `FAMILY.md` - the four tiers, the Vinculum contract, and the licence firewall.
2. `SOURCES.md` - the pinned upstream commit, and why the upstream mirror is odd.
3. `PLAN.md` - mission, non-goals, workstreams, success criteria.
4. `DESIGN.md` - the dump pipeline, the determinism rules, decisions D1-D6.
5. `INNOVATIONS.md` - the ten-item backlog with measurements.
6. `ROADMAP.md` - which item belongs to the release you are in.
7. `PATCHES.md` - every local change to vendored upstream code.

If a file contradicts this prompt, the file wins and this prompt gets fixed.

## What this project is

A ~8 MB text browser in C, built on Lynx, that reads pages well and turns them into
markdown or JSON deterministically. GPL-2.0-only. ~193,000 lines of C, most of it
inherited. The job is not to rewrite Lynx: it is to give the text renderer more
information and to give programs a real output format.

## Hard constraints

1. **`--format=text` output is frozen.** It must stay byte-compatible with today's
   `-dump`. Everything new is additive and opt-in.
2. **Dumps are deterministic.** A dump is a function of (URL, response bytes,
   options). No timestamps, no locale formatting, no hash iteration order, no
   floating-point text metrics.
3. **No images, no CSS rendering, no JavaScript, no GUI.** Ever. Pages that need those
   exit 75 and get promoted up the ladder.
4. **RSS ceilings:** 8 MB interactive, 5 MB for a dump. If a feature breaks them, the
   feature loses.
5. **Licence hygiene.** GPL-2.0-only. Code from Nodus (also GPL-2.0) may merge in both
   directions. Code from Sorex (GPL-3.0-or-later) may not, at all. MIT libraries from
   the NetSurf project are always fine.
6. **Upstream edits are logged** in `PATCHES.md` in the same commit.
7. **Upstream is a snapshot mirror with no PR path.** Patches worth sending go to the
   `lynx-dev` mailing list. Do not expect a GitHub pull request to be seen.
8. **Exit codes follow the family contract:** 0, 64, 69, 75, 76.

## How to work

- **Small commits, conventional messages:** `feat(dump): add markdown serialiser`,
  `fix(text): keep table columns`, `perf(arena): drop per-cell malloc`.
- **One workstream per branch.** W1 build/size, W2 dump pipeline, W3 determinism,
  W4 text flow, W5 network, W6 automation, W7 extraction, W8 hardening.
- **Golden dumps first.** Every output change starts with the expected file committed
  in `test/corpus/expect/` and a test that currently fails.
- **Structure, not styling.** `libcss` is used for display role and order, never for
  positioning. The line is in `DESIGN.md` and it does not move.
- **Measure, do not assert.** `tools/measure.sh` output goes in the pull request.

## Your first three tasks

**Task 1 - Build and baseline.** Run `./tools/build.sh`, fix what breaks, then
`./tools/build.sh --static`. Record binary size and RSS in `PERFORMANCE.md` with the
date. Try `--minimal` too and record the size. Do not optimise anything yet.

**Task 2 - Capture today's output as the contract.** Take the fixture set (start with
ten pages you write yourself, in `test/corpus/fixtures/`), run `-dump` on each, and
commit the output as the golden files under `test/corpus/expect/text/`. Then write
`tools/test-golden.sh` to diff against them. This freezes the behaviour you are
promising not to break, before you start changing it.

**Task 3 - Start the structure tree.** Read `src/HTML.c` and identify the callbacks
that already see every element and every text run. Add `src/structure.c` with the node
types from `DESIGN.md`, populate it from those callbacks, and add a debug dump behind
`--debug-structure`. Do not wire it into any serialiser yet. The deliverable is: for
one fixture, the structure tree printed correctly.

## Definition of done

- `./tools/build.sh` passes from clean, and `--static` produces a working binary.
- Golden tests pass; new behaviour has a golden file that fails without the change.
- `tools/test-determinism.sh` passes for anything that touches output.
- `tools/measure.sh` output is in the pull request for any performance claim.
- `PATCHES.md` updated if a vendored file changed.
- Docs updated in the same commit.
- The commit message says why.

## Anti-goals, restated because they keep coming back

- Do not change `--format=text` output.
- Do not add images, CSS rendering or JavaScript.
- Do not build a DOM. A structure tree is a serialisation target, not a document model.
- Do not implement floats or positioning in the text renderer.
- Do not emit a timestamp, ever, in any output format.
- Do not make the JSON schema clever. Flat, versioned, additive.

## When you are unsure

Write the question in `docs/questions.md` with your best guess and the reason. Prefer
the guess that preserves determinism and the frozen text format. Those two are never
the wrong answer.
