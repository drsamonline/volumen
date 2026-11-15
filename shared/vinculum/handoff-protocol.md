# Handoff protocol

How one tier passes work to another instead of pretending to be it.

## The problem

A T3 text browser that silently renders a broken page is worse than one that says
"this page needs images, Sorex can show it". Handoff is the family's answer to
scope creep: capability gaps are routed, not implemented four times.

## Vocabulary

- **Tier** - 0 Aetheris, 1 Nodus, 2 Sorex, 3 Volumen. Lower number, higher fidelity.
- **Promote** - hand a URL *up* the ladder, toward more capability.
- **Demote** - hand a URL *down*, toward less cost. Usually a user action, rarely automatic.
- **Capability query** - asking a browser what it can do.

## Capability query

Every family binary supports `--vinculum-caps`, which prints exactly one JSON
object to stdout and exits 0:

```json
{"name":"volumen","tier":3,"version":"0.1.0+lynx.2.9.3f","javascript":false,
 "images":[],"css":false,"http2":false,"headless":true,
 "dump_formats":["text","markdown","json"],"rss_idle_mb":6}
```

This is the only IPC contract that must never break. The expected answers for all
four browsers live in `capabilities.json`.

## The wrapper

Each repo ships `tools/vinculum-open`, a small POSIX shell script that implements
the ladder. Behaviour:

1. Read `~/.config/vinculum/config.json` for `handoff.ladder` and `auto_promote`.
2. Ask each binary in ladder order for its capabilities, caching the answers for
   60 seconds in `$XDG_RUNTIME_DIR/vinculum/caps.<name>.json`.
3. Pick the cheapest tier that satisfies the request. "Satisfies" is decided by
   the request's own requirements, expressed as flags:
   `--needs images`, `--needs js`, `--needs forms`, `--needs text-only`.
4. `exec` the chosen browser.
5. If the chosen browser exits with code 75 (`EX_TEMPFAIL` semantics: "I cannot
   render this, try higher"), promote and try the next tier.

## Exit codes

| Code | Meaning | Wrapper action |
|------|---------|----------------|
| 0 | success | none |
| 64 | bad URL or usage | none, print usage |
| 69 | upstream network failure | retry once, then stop |
| 75 | rendered but capability-limited | promote to next tier if `auto_promote` |
| 76 | TLS or certificate refusal | stop, never promote past a security refusal |

Code 76 exists because promoting past a certificate failure would turn a security
decision into an availability decision. It never promotes.

## Announcing the handoff

If `handoff.announce` is true, the promoting browser prints one line to stderr
before exec'ing:

```
volumen: no images on this page, handing to sorex (tier 3 -> 2)
```

The receiving browser may render it in its status bar. Silent handoffs are a bug:
the user must always know which program is now on screen and why.

## What travels with the handoff

A handoff passes a URL, plus optionally a session file (`session-format.md`) and a
scroll anchor (`#fragment` or a text-quote selector). It never passes cookies,
history or form state between tiers: those are per-browser and per-session by
policy, and copying them would make the family a single shared attack surface.

## Testing

`tools/test-handoff.sh` in each repo runs the ladder against a local fixture set
and asserts the exit codes above. A handoff that cannot be tested on fixtures is
not implemented.
