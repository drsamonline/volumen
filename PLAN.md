# Plan

## Mission

Make the text browser the best tool for two things: reading a page without
distraction, and turning a page into data without a browser engine. Keep it under
8 MB, keep its output deterministic, and make it the thing a script reaches for
before it reaches for a headless Chrome.

## Position in the family

Tier 3, the bottom of the ladder: the cheapest thing that can still fetch and read.
It is also the family's automation entry point, and - because it shares
GPL-2.0-only with Nodus - the only tier that can exchange source code with another.

## Users, in priority order

1. **The reader.** Terminal user, ssh session, e-ink device, slow link, or someone who
   simply wants the article.
2. **The scripter.** Wants `curl` with structure: headings, links, tables, forms, and
   a stable output format that does not break between versions.
3. **The pipeline builder.** Wants a hundred pages as Markdown or JSON, fast, without
   a browser engine in the dependency tree.
4. **The rescue user.** Wants a browser on a 900 KB binary on a broken system.

## Non-goals

- No images, no CSS rendering, no JavaScript. Ever.
- No GUI, no X11, no framebuffer. Sorex and Nodus own those surfaces.
- No WebExtensions, no ad blocking via engine hooks (a text browser blocks ads by not
  loading them).
- No rendering fidelity work that belongs in Nodus. If a page needs layout, hand it
  up the ladder.

## Success criteria for v1.0

| # | Criterion | Measured by |
|---|-----------|-------------|
| 1 | `--format=json` and `--format=markdown` are documented, versioned and stable | `docs/DUMP-FORMATS.md` plus golden tests |
| 2 | 100% byte-identical dumps across runs, locales and machines | `tools/test-determinism.sh` |
| 3 | Lite Profile v0 conformance for all fixtures | `tools/check-corpus.sh` |
| 4 | RSS under 8 MB interactive, 5 MB for a dump | `tools/measure.sh` |
| 5 | Static musl binary under 900 KB | release artifact |
| 6 | 100 URLs in under 30 s with 8 workers | `tools/bench-batch.sh` |
| 7 | Forms: fill, submit, follow redirects, keep a cookie jar - scriptable end to end | `tools/test-forms.sh` |
| 8 | Structure-aware text flow via `libcss` beats today's text on 80% of the corpus | `tools/bench-readability.sh` |

## Workstreams

**W1 - Build and shrink.** One build script, static musl, no NLS by default, a
`--minimal` profile, and a size budget enforced in CI. Exit: criterion 5.

**W2 - The dump pipeline.** Refactor the existing `-dump` path into a pipeline:
fetch, parse, extract structure, serialise. Three serialisers: text (compatible with
today), markdown, json. Exit: criterion 1.

**W3 - Determinism.** Remove every source of run-to-run variance: timestamps,
locale-dependent formatting, hash iteration order, floating-point text metrics. Exit:
criterion 2.

**W4 - Structure-aware text flow.** Capture the element tree and the cascade (using
`libcss`) and let the text renderer see it, so a table keeps its columns and a sidebar
stops sitting above the text. Exit: criterion 8.

**W5 - Network modernisation.** HTTP/2, connection reuse, brotli, TLS session
resumption, and a strict TLS policy. Exit: measurable time-to-first-byte win on a slow
link.

**W6 - Automation surface.** Scriptable forms, a JSON cookie jar, batch mode with
concurrency, retries and a manifest output. Exit: criteria 6 and 7.

**W7 - Extraction quality.** A readability pass that finds the main content, strips
navigation and boilerplate, and keeps tables and code blocks intact. Exit: a
hand-labelled 50-page set where the main content is correctly identified 90% of the
time.

**W8 - Hardening.** Fuzz the HTML parser path and the text renderer; harden the build;
write the threat model. Exit: fuzz hours with no crash.

## Milestones

| Milestone | Contains | Gate |
|-----------|----------|------|
| v0.1 scaffold | upstream imported, docs, tools, shared specs | `tools/build.sh` green |
| v0.2 formats | markdown and json dumps, documented | criterion 1 |
| v0.3 deterministic | golden dumps in CI | criterion 2 |
| v0.4 structured | `libcss` in the text path | criterion 8 |
| v0.5 fast | HTTP/2, reuse, brotli | measurable TTFB win |
| v0.6 scriptable | forms, cookies, batch | criteria 6, 7 |
| v1.0 release | static build, packaging, soak | all |

## Risks

| Risk | Likelihood | Response |
|------|-----------|----------|
| Upstream is a snapshot mirror with no PR path | certain | we own the tree; upstream fixes go to `lynx-dev` as patches |
| Adding `libcss` blows the size budget | medium | it is ~300 KB stripped; measure, and make it optional at configure time |
| Determinism fights ncurses | low | dumps are non-interactive by definition; the interactive path may differ |
| Users expect `lynx`-compatible output | medium | the `text` format stays compatible; new formats are additive |
| JSON output invites a schema-compatibility promise | medium | version the schema from day one, and say so in `docs/DUMP-FORMATS.md` |
