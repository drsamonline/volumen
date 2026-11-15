# The Lite Rendering Profile (v0)

What every tier in the family must render, and how we measure it. The point of
this document is to stop four browsers from each having a private idea of "the
web" and to make "it looks wrong" a testable statement.

## Why a profile instead of a spec

No tier here aims at full HTML or CSS conformance. Each aims at *usefulness on the
pages people actually read*. So the profile is written from a corpus, not from a
specification: every requirement below was chosen because a page in the corpus
needed it.

## The corpus

`test/corpus/` in each repo, identical files, git submodule-free (plain copies,
checked by `tools/check-corpus.sh` against a manifest of SHA-256 sums).

Three parts:

1. **`fixtures/`** - hand-written pages, one feature each, ~120 files. Tiny, fast,
   every one has an expected result.
2. **`saved/`** - real pages captured as single-file HTML with their images
   inlined or beside them, ~40 pages, chosen for being text-heavy and
   layout-light. Captured once, committed, never re-fetched in CI.
3. **`expect/`** - expected output per fixture: a text dump (for every tier), a
   PNG render (for T1 and T0), and a structural outline (element tree, no styling).

## Required behaviour, v0

A tier conforms at v0 when, for every fixture in `fixtures/`:

| ID | Requirement | T0 | T1 | T2 | T3 |
|----|-------------|----|----|----|----|
| R1 | Headings produce a document outline in the correct nesting order | must | must | must | must |
| R2 | Paragraph, `br`, `hr` and `pre` whitespace is preserved as written | must | must | must | must |
| R3 | Lists nest and number correctly (`ol` with `start`, `reversed`, `type`) | must | must | must | must |
| R4 | Tables linearise without losing cell-to-header association | must | must | must | must |
| R5 | Links expose their target; relative URLs resolve against `base` | must | must | must | must |
| R6 | Forms expose label, name, type and current value, in document order | must | must | must | must |
| R7 | Images degrade to alt text when images are off or unavailable | must | must | must | must |
| R8 | `lang` is honoured for hyphenation and quotation marks | should | should | should | must |
| R9 | Block layout respects `display:none` and `visibility:hidden` | must | must | must | must |
| R10 | The page's own `<title>` is available to the UI | must | must | must | must |

"must" is a merge blocker; "should" is a bug with a milestone attached.

## The text dump is the canonical output

Every tier can produce `--dump` text. That is the family's lingua franca and the
reason the profile is testable at all: a T3 browser's dump and a T0 browser's dump
of the same fixture should agree on R1-R7, because those requirements are about
*document structure*, not about pixels. Diffing two dumps is a one-line test;
diffing two renders is not.

## Adding a requirement

Bring a real page that fails. Write the fixture. Add the row. Then implement it in
at least two tiers before it becomes "must" for all four, so the requirement is
known to be achievable at the cheap end of the family.
