# Patches

Every change to a file that came from upstream Lynx is recorded here, in the same
commit that makes the change.

## Format

```
### <path> - <one-line summary>
- Commit: <sha>
- Why: <the reason, in one sentence>
- Upstream: <lynx-dev mailing list thread, or "not filed">
- Revert risk: <what breaks if upstream changes this area>
```

## Log

Nothing yet. This tree is a clean import of Lynx `7f67078`.

## Policy

1. **Prefer new files.** `src/structure.c`, `src/dump_*.c` and `src/batch.c` are new
   files by design, so upstream merges stay cheap.
2. **Touch `GridText.c` reluctantly.** It is the heart of the project and the most
   likely place for an upstream conflict. Every hunk there needs a `PATCHES.md` entry.
3. **Send real fixes to `lynx-dev`.** There is no GitHub pull request path upstream.
