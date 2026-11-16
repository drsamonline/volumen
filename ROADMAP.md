# Roadmap

Dates are targets, not promises. Each phase has an exit criterion that is a command,
not a feeling: if the command does not pass, the phase is not done and the next one
does not start.

Phases are deliberately short. A phase that cannot be finished in six to ten weeks of
evenings is a phase that will be abandoned, so scope is cut before dates move.

## P0 - Scaffold (November 2026)

Upstream imported at `7f67078`, documentation written, build script and golden-test
harness in place, shared Vinculum contract in place.

**Exit:** `./tools/build.sh` produces a working `src/lynx`; `./tools/build.sh --static`
produces a static binary; the size baseline is in `PERFORMANCE.md`.

## P1 - Freeze the contract (December 2026)

Capture today's `-dump` output for ten self-written fixtures as golden files, and write
`tools/test-golden.sh`. This freezes the behaviour the project promises not to break,
before anything is changed.

**Exit:** `tools/test-golden.sh text` passes; the golden files are committed; the RSS
baseline is in `PERFORMANCE.md`.

**This phase cannot be cut.** Everything else depends on it.

## P2 - Structured dump (January - February 2027)

The structure tree, plus the markdown and JSON serialisers, documented in
`docs/DUMP-FORMATS.md`.

**Exit:** criteria 1 and 2 in `PLAN.md`; three formats green against goldens;
determinism test passes under two timezones and two locales.

## P3 - Structure-aware text flow (March - April 2027)

`libcss` in the text path (I3), optional at configure time, with the `--format=text`
freeze intact.

**Exit:** criterion 8: table fixtures keep their columns, sidebars move out of the main
flow, and no fixture gets worse. If the text format would have to change to show the
improvement, the improvement goes into `--reader` instead.

## P4 - Automation (May - June 2027)

Scriptable forms (I5), batch mode with a manifest (I6), the JSON cookie jar, and the
readability reducer (I7).

**Exit:** criteria 6 and 7: 100 URLs in under 30 s at 8 workers with exact ordering, and
a three-command authenticated fetch in `tools/test-forms.sh`.

## P5 - Network, hardening, v1.0 (July - September 2027)

HTTP/2 and connection reuse (I4), the arena and hot-path work (I8), protocol plugins
(I9) if there is room, fuzzing, and the static release artifacts.

**Exit:** all eight success criteria in `PLAN.md` pass; static musl binary under 900 KB;
deterministic under every configuration tested.

## What is explicitly not on this roadmap

- Images, CSS rendering, JavaScript, a GUI.
- A DOM. A structure tree is a serialisation target.
- Floats or positioning in the text renderer.
- Any change to `--format=text` bytes.

## How this roadmap changes

The freeze comes first and never moves. After that, formats before rendering, rendering
before automation, automation before network. If time runs out, the tool is still worth
having at P3: a deterministic structured dumper is the most useful thing here.

## Deferred by decision (2026-11-16)

**The family landing page.** Once all four browsers are finished, one page listing the
ladder, the licences and the honest state of each project goes in the hub repo
(`drsamonline.github.io`) - not in a fifth repository, and not before. A landing page
that advertises four unfinished browsers is worse than no landing page.

The trigger is concrete, not a date: Aetheris, Nodus, Sorex and Volumen all at v1.0, or
the point where one of them is good enough that a stranger would actually try it. Until
then, `FAMILY.md` in each repo is the family's front door and it is enough.

**No fifth repo.** The family is four browsers and a shared contract. Anything that
wants to be a fifth repository has to justify itself against that.
