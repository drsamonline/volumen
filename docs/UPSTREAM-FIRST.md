# Upstream first — Lynx

**Read the vendored tree before writing anything.** This repository is a fork: the
tree at the root *is* upstream at a pinned commit (see `SOURCES.md`), so every
answer to "how should this work" is already on disk. Re-deriving it from scratch
has cost whole sessions on this project family; porting it has landed first time,
with a test.

## The rule

1. **Find it upstream before designing it.** Search the vendored tree for the
   feature. If upstream has it, port the shape — the data flow, the order of
   operations, the names — not just the outcome.
2. **Read the neighbours.** Every one of these projects has more than one
   frontend or consumer. If a core API looks wrong, look at how another frontend
   already uses it before inventing a new one.
3. **When upstream has no answer, say so.** Then design it, and write down in
   `DESIGN.md` why upstream could not be followed. That note is the thing the next
   session needs.
4. **Do not patch the symptom you can see.** A state that disappears, an event
   that never arrives, a style that does not apply: find which function discards
   or drops it, and fix that one. A patch at the call site hides the fault.

## Second reference: LibWeb

For anything interaction-shaped — focus, hover, `:active`, event bubbling, style
invalidation — Ladybird's `Libraries/LibWeb` is the reference implementation this
family's Aetheris tier is derived from, and it has solved those properly:

| Problem | Read |
| --- | --- |
| focus, `:focus`, `:focus-visible`, `:focus-within` | `DOM/Document.cpp` (`set_focused_area`), `DOM/Element.cpp` (`is_focused`, `should_indicate_focus`) |
| hover and active state | `DOM/Document.cpp` (`set_hovered_node`), `DOM/Element.cpp` (`is_being_activated`) |
| style invalidation after a state change | `CSS/Invalidation` (`invalidate_style_after_pseudo_class_state_change`) |
| event bubbling to document and window | `Page/EventHandler.cpp` |
| scroll state | `DOM/Document.cpp`, `Page/EventHandler.cpp` |

    git clone --depth 1 --filter=blob:none --sparse https://github.com/LadybirdBrowser/ladybird.git
    cd ladybird && git sparse-checkout set Libraries/LibWeb

## What this rule is worth, in evidence

From the Aetheris tier of this family, one day of work:

- Three bugs — the window running no page scripts, clicks never reaching handlers,
  and `:focus` never painting — were each a case of the machinery existing and
  nothing feeding it. Each cost a session of guessing.
- The fix for the third was in a function nobody suspected (`relayout()` rebuilt
  layout without the interaction state). It was found by printing, not by reading.
- Every feature ported from `LibWeb` after reading it — `:focus-within`,
  `document.activeElement`, the focus transition order, keys bubbling from the
  focused element — landed first time, with a pixel-level test.

Read first. It is faster than being clever.

## Where things are in this tree

| You want to change | Read first |
| --- | --- |
| text rendering, wrapping, tables | `src/GridText.c` |
| HTML parsing callbacks | `src/HTML.c` |
| forms | `src/LYForms.c`, `src/HTForms.h` |
| options, startup, the main loop | `src/LYMain.c`, `userdefs.h`, `lynx.cfg` |
| cookies | `src/LYCookie.c` |
| HTTP, HTTPS, FTP, gopher | `WWW/Library/Implementation/` |
| bookmarks | `src/LYBookmark.c` |
| dump output | `src/GridText.c` (the same renderer, printed) |

`src/GridText.c` is about ten thousand lines and is where every rendering change
starts and ends. Read the existing wrapping and table code before adding a path
beside it.
