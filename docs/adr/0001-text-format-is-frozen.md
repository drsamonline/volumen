# ADR 0001 - The text dump format is frozen

- Status: accepted
- Date: 2026-11-16

## Context

`lynx -dump` output is consumed by more software than anyone has counted: scrapers,
archivers, documentation generators, mail filters. Those consumers parse whitespace,
and whitespace is exactly what a well-meaning rendering fix changes.

The tempting move is to improve the text output: fix the table alignment, stop
wrapping long URLs mid-link, tidy the indentation. Every one of those changes breaks
somebody's parser, silently, in a place we will never see the bug report.

## Decision

`--format=text` reproduces today's bytes exactly. Rendering improvements that change
the text output are not allowed. Everything better is opt-in:

- `--format=markdown` - structured, for prose pipelines.
- `--format=json` - the structure tree, for programs.
- `--reader` - main content only.

These are additive, versioned, and documented in `docs/DUMP-FORMATS.md`.

## Consequences

- Users get a stable contract, which is worth more than tidy output.
- Improvements have somewhere to go, so the freeze does not block progress.
- We own a compatibility promise in perpetuity. Golden tests enforce it, and the
  golden files are committed, so the promise is auditable.
- Some fixtures will look wrong forever in `text` mode. That is the cost, and the
  workaround is one flag away.
