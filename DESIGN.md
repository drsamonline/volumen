# Design

## The shape of the thing

Lynx is a text renderer with a network stack attached. The text renderer is
`src/GridText.c`; the network stack is libwww in `WWW/`. Everything else is glue,
options and character encoding.

```
   URL
    |
    v
  WWW/            libwww: HTTP(S), FTP, gopher, redirects, cookies, cache
    |
    v
  src/HTML.c      parser callbacks: start_element, end_element, character data
    |
    v
  src/GridText.c  the text renderer: builds styled character cells, wraps, paginates
    |
    +--> interactive: curses screen, links numbered, forms as fields
    |
    +--> -dump: plain text to stdout
         (Nodus: --format=markdown|json, and a structure capture beside the text)
```

The whole project is a bet that this pipeline is still the right one, and that the
text renderer should be given *more* information (structure, some cascade) rather than
a different architecture.

## The dump pipeline (new)

Today `-dump` walks the same renderer and prints cells. That is fine for humans and
useless for programs, because a table becomes spaces. The new path splits the work:

```
  fetch -> parse -> STRUCTURE TREE -> +--> text serialiser     (today's behaviour)
                                     +--> markdown serialiser
                                     +--> json serialiser
                                     +--> readability reducer -> any serialiser
```

**The structure tree** is the new middle: a small, explicit tree of blocks
(heading, paragraph, list, list-item, table, row, cell, pre, blockquote, link,
image-alt, form, field) with the text and the link targets attached. It is built from
the same parser callbacks that already exist, and it is deliberately *not* a DOM: no
CSS, no mutation, no generality. Roughly 1,500 lines and a big win.

Every serialiser is a pure function of the structure tree, which is what makes the
output deterministic and testable.

## Determinism, concretely

Byte-identical output across runs, locales and machines requires removing:

| Source of variance | Fix |
|--------------------|-----|
| Timestamps in output | never emitted; if needed, `--now` takes an explicit value |
| Locale-dependent number/date formatting | format explicitly, never via `printf` with locale |
| Hash table iteration order | sort before serialising; never iterate a hash |
| Floating-point text metrics | integer cell arithmetic in the text path |
| Environment-dependent defaults | all defaults from one file, resolved once |
| Response header ordering | sort header names in JSON output |
| Concurrent batch completion order | emit in input order, always |

The rule: **a dump is a function of (URL, response bytes, options).** If the same
inputs can produce two outputs, that is a bug with a test attached.

## Structure-aware text flow

The interesting enhancement, and the one that needs `libcss` (MIT, from NetSurf, so
legally free here).

**Problem.** Lynx's text renderer does not know what a `div` is. A two-column page
becomes a single column of interleaved text; a sidebar lands in the middle of the
paragraph; a table loses its alignment. This is not a bug in the code, it is a missing
input: the renderer has never been told about layout intent.

**Approach.** Parse the page's stylesheets with `libcss`, run the cascade for the
elements the renderer cares about, and hand `GridText.c` three extra facts per block:
its display role (block, inline, table-cell, none), a coarse width hint, and an
order key. That is enough to:

- drop `display:none` content entirely (which also drops a lot of tracking pixels and
  hidden boilerplate),
- lay out simple tables as aligned columns instead of space-separated runs,
- keep a sidebar after the main text rather than through it,
- honour `white-space: pre` and basic text alignment.

**Why not more.** Because a text browser that starts implementing floats has become a
bad GUI browser. The line is: structure yes, positioning no. If a page needs
positioning, the user should hand it to Sorex - and the browser should say so (see the
handoff protocol).

## The automation surface

Text browsers are used by scripts more than by people, and Lynx's interface for that is
a set of flags that grew organically. Volumen makes it deliberate:

| Surface | Shape | Stability promise |
|---------|-------|-------------------|
| `--dump --format=text` | today's output | frozen, byte-compatible |
| `--dump --format=markdown` | headings, lists, links, tables, code | versioned, additive |
| `--dump --format=json` | structure tree as JSON | versioned schema, additive |
| `--batch FILE` | one URL per line, ordered output | stable |
| `--cookies-jar FILE` | JSON, not Netscape format | versioned |
| `--form` / `--submit` | fill and post from the command line | stable |
| exit codes | documented, aligned with the family | stable |

Exit codes follow `shared/vinculum/handoff-protocol.md` so that `vinculum-open` can
route work: 0 success, 64 usage, 69 network, 75 capability-limited (this page needs
images or CSS - promote me), 76 TLS refusal.

Code 75 is the interesting one: a text browser that knows when it has lost is more
useful than one that renders garbage silently.

## Decisions

### D1 - The text format is frozen; new formats are additive

Existing users have parsers built on `-dump` output. Changing it breaks them. So
`--format=text` reproduces today's bytes exactly, and everything new is opt-in. This
costs us the freedom to "fix" the text output, which is the correct price.

### D2 - A structure tree, not a DOM

A DOM would drag in `libdom`, mutation, events and the whole model of a scripting
browser. A structure tree is a serialisation target. The distinction keeps this
project at 193,000 lines instead of 400,000.

### D3 - Determinism is a hard requirement, not a nice-to-have

Without it there is no golden test, and without golden tests a text renderer rots. The
variance table above is the specification.

### D4 - `libcss` is optional at configure time

It costs about 300 KB stripped and buys structure-aware flow. On a rescue image that
300 KB may not exist. So it is a configure flag with a documented fallback to today's
behaviour, and the build reports which mode it chose.

### D5 - GPL-2.0-only, which makes Nodus a partner

Same licence, so code can move both ways. Volumen should take Nodus's CSS integration
experience and give back its text extraction. This is the family's only free corridor
and the roadmap uses it.

### D6 - Upstream is a snapshot, so we are the maintainer

No pull requests, no commit replay. The tree is ours; upstream is a reference. Patches
worth sending go to `lynx-dev`.

## Testing strategy

- **Golden dumps.** Every fixture has an expected text, markdown and json output,
  committed. CI diffs. This is the whole test strategy and it is enough.
- **Determinism runs.** Every dump test runs twice, with a different `TZ` and `LC_ALL`,
  and diffs the two.
- **Corpus conformance.** The Lite Profile fixtures, shared with the family.
- **Batch benches.** Wall time and RSS for 100 URLs at 8 workers.
- **Fuzzing.** The parser callback path and the text renderer, with libFuzzer.
