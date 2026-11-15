# Session format

One session document, so that a set of tabs survives a handoff between tiers.

## Location

`$XDG_STATE_HOME/vinculum/session.json`, falling back to
`~/.local/state/vinculum/session.json`. Written atomically (write to
`session.json.tmp`, `fsync`, `rename`).

## Shape

```json
{
  "schema_version": 1,
  "written_by": "sorex",
  "written_at": "2026-11-16T09:30:00Z",
  "active": 0,
  "tabs": [
    {
      "url": "https://example.org/doc",
      "title": "Doc",
      "scroll_y": 1240,
      "anchor": "section-3",
      "zoom": 1.0,
      "pinned": false
    }
  ]
}
```

## Rules

1. **Unknown fields are preserved on round-trip** if the browser rewrites the
   file, so a T0-only field survives a detour through T3. This is the one place
   where a browser must not drop what it does not understand.
2. **`anchor` is advisory.** A text-quote selector (`#:~:text=`) is preferred when
   the browser can produce one; `scroll_y` is the fallback.
3. **No credentials, no cookies, no form contents, ever.** A session file that
   contains a cookie is a bug and the check in `tools/check-session.sh` fails it.
4. **Size cap 1 MB.** Beyond that, the oldest unpinned tabs are dropped and the
   drop is logged.
5. **A browser that cannot restore a tab** (for example a text tier receiving a
   page with no text) keeps the tab with its URL and marks `"restore":"degraded"`
   rather than deleting it.
