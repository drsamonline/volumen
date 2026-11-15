# Vinculum

The interchange layer shared by the four browsers of the Aetheris family:
Aetheris (T0), Nodus (T1), Sorex (T2) and Volumen (T3).

This directory is a specification and a set of data files, not a library. It is
copied verbatim into every family repo and must stay byte-identical across them.
`tools/check-vinculum.sh` in each repo verifies that against the canonical copy.

## Files

| File | What it fixes |
|------|---------------|
| `config.schema.json` | JSON Schema for `~/.config/vinculum/config.json`, the one config all four browsers read |
| `capabilities.json` | what each tier can do, used to negotiate handoffs |
| `handoff-protocol.md` | how a URL moves up the ladder, and how the user is told |
| `keybindings.toml` | the shared default keymap |
| `search-engines.json` | the shared search engine list |
| `session-format.md` | session and tab interchange between tiers |
| `lite-profile.md` | the rendering subset every tier must support |

## Rules

1. **Additive only.** A new optional key is fine. Renaming or removing a key needs
   a version bump in `schema_version` and a migration note here.
2. **Unknown keys are ignored, never fatal.** A T3 browser must not crash on a
   setting that only T0 understands.
3. **Propose where it hurts, then propagate.** A change lands in the repo that
   needed it, then in the other three within the same week.
4. **No code, only contracts.** Anything executable belongs in a repo, not here.

## Licence

CC0-1.0. These files are deliberately public-domain so that the MIT-licensed
Aetheris can consume them without any licence interaction with the GPL tiers.
