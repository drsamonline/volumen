# Innovations

Ten enhancements, each with the reason, the module, and the measurement. Ordered by
what makes the tool useful to more people.

---

## I1 - Structured dump: markdown and JSON

**Why.** `lynx -dump` is the most-used scraping tool nobody documents. Its output is
for humans, so every pipeline re-parses it with regexes and breaks on whitespace.
Returning structure instead is the single highest-value change available.

**What.** A structure tree built from the existing parser callbacks, plus two
serialisers. JSON carries headings, paragraphs, lists, tables (with header
association), links with absolute URLs, images with alt text, and forms with fields.
Markdown carries the same, flattened for prose.

**Where.** `src/HTML.c` (capture), new `src/structure.c`, new `src/dump_{text,md,json}.c`.

**Measured by.** Golden dumps for every fixture; schema documented in
`docs/DUMP-FORMATS.md`; criterion 1.

**Risk.** Low. The hard part is deciding the schema, and it is decided here.

---

## I2 - Determinism as a guarantee

**Why.** Automation is only possible if the same input gives the same bytes. Every
scraping pipeline has a story about the day the output changed because of a timezone.

**What.** Remove the seven sources of variance listed in `DESIGN.md`; run every dump
test twice under different `TZ` and `LC_ALL`; sort everything that comes from a hash.

**Where.** `src/`, `WWW/`, the serialisers.

**Measured by.** `tools/test-determinism.sh`, criterion 2.

**Risk.** Low, tedious, and it pays for itself immediately.

---

## I3 - Structure-aware text flow with `libcss`

**Why.** A table that loses its columns and a sidebar that interrupts a paragraph are
the two most common complaints about text browsers. Both are missing-information
problems, not algorithm problems.

**What.** Run the cascade with `libcss` for the elements the renderer cares about, and
give `GridText.c` three extra facts per block: display role, width hint, order key.
Drop `display:none` content. Align simple tables. Move sidebars after the main flow.

**Where.** New `src/css.c`, hooks in `src/GridText.c`, optional at configure time.

**Measured by.** `tools/bench-readability.sh` on the corpus: column alignment on table
fixtures, and a human-labelled "is the main content intact" score, target 80% of pages
improved and none made worse.

**Risk.** Medium. It touches the renderer, so golden dumps are the safety net and the
`--format=text` freeze is the constraint.

---

## I4 - HTTP/2 and connection reuse

**Why.** A page with 60 subresources on a 200 ms link is mostly latency, and text
browsers are used precisely on bad links.

**What.** A minimal HTTP/2 client (HPACK plus framing, no push), a keep-alive pool,
and brotli.

**Where.** `WWW/Library/Implementation/`.

**Measured by.** Time-to-first-byte and total bytes on the corpus over a simulated
slow link; connection count per page.

**Risk.** Medium-high, and it is the least "text browser" work on this list, so it is
late.

---

## I5 - Scriptable forms

**Why.** Half the useful web is behind a form: a search box, a login, a query. Lynx can
do forms interactively and cannot do them from a script, which is the case that
matters.

**What.** `--form name=value` repeated, `--submit`, `--method`, plus a JSON cookie jar
so a session survives across invocations.

**Where.** `src/` form handling, new `src/form_cli.c`.

**Measured by.** `tools/test-forms.sh`: log in, keep the cookie, fetch a protected page,
in three commands.

**Risk.** Medium. Authentication flows are diverse; scope to simple POST forms and say
so.

---

## I6 - Batch mode with a manifest

**Why.** The pipeline builder does not run one URL, they run a thousand. Doing that
with a shell loop means no concurrency, no retries, no ordering and no summary.

**What.** `--batch urls.txt --out-dir DIR --workers N --retries N --manifest out.json`.
Output in input order regardless of completion order; per-URL status, bytes, timing,
and content hash in the manifest.

**Where.** New `src/batch.c`.

**Measured by.** 100 URLs, 8 workers, under 30 s on a 10 Mbit link; ordering is exact;
manifest validates against its schema.

**Risk.** Low. Mostly bookkeeping, and it makes the tool genuinely useful.

---

## I7 - A readability reducer

**Why.** Most of a page is not the page: navigation, footers, cookie banners,
related-article lists. A reader wants the article; a pipeline wants the same thing.

**What.** A scoring pass over the structure tree (text density, link density, class and
id hints, position) that marks the main content region, with `--reader` to output only
that.

**Where.** New `src/readability.c`.

**Measured by.** A hand-labelled 50-page set; 90% correct main-content identification
is the target, and the labelled set is committed so the number is reproducible.

**Risk.** Medium. Heuristics rot; the labelled set is what keeps it honest.

---

## I8 - An arena allocator and a smaller hot path

**Why.** The text renderer allocates a character cell at a time in places. On a
Raspberry Pi that is visible.

**What.** Arena allocation per document, integer cell arithmetic instead of float text
metrics, and removal of the per-character allocations in the wrapping path.

**Where.** `src/GridText.c`, `lib/`.

**Measured by.** RSS and time to render the largest fixtures; target 20% faster and no
RSS growth.

**Risk.** Low-medium. ASan in CI.

---

## I9 - Protocol plugins for the small web

**Why.** Gemini, gopher, finger and spartan are text protocols for text clients. Lynx
already speaks gopher; the rest are a natural extension and a reason to choose this
browser over `curl`.

**What.** A small plugin ABI in `WWW/`, plus reference plugins for gemini and spartan,
each under 500 lines. Off unless compiled in.

**Where.** `WWW/Library/Implementation/`, new `WWW/Library/Implementation/protocols/`.

**Measured by.** A plugin builds against installed headers and fetches a page; size
cost per plugin under 20 KB.

**Risk.** Low, and it is the kind of thing that makes a text browser feel alive.

---

## I10 - A hardened, tiny, static build

**Why.** The rescue-image use case is real: a 900 KB binary that runs where nothing
else does, with no shared library surprises.

**What.** `--static` musl builds, `--minimal` profile (no TLS, no NLS, no colour), a
size budget in CI, and a reproducible artifact.

**Where.** `tools/build.sh`, CI.

**Measured by.** Binary size, `ldd` output, and a run inside an empty Alpine container.

**Risk.** Low. Unglamorous, and it is the reason a text browser is worth keeping.

## Prior art in this tree

Every item below already has a home upstream. Read it before designing the
replacement — the text renderer is ten thousand lines of solved problems.

| Innovation | Where upstream already does part of this |
| --- | --- |
| I1 structured dump | `src/GridText.c` (the renderer), `src/HTML.c` (the callbacks that already see every element) |
| I2 determinism | `src/GridText.c`, `src/LYMain.c` (where locale and time leak in) |
| I3 structure-aware text flow | `src/GridText.c` (the wrapping and table code to feed) |
| I4 HTTP/2 and reuse | `WWW/Library/Implementation/` (`HTAccess.c`, `HTTCP.c`) |
| I5 scriptable forms | `src/LYForms.c`, `src/HTForms.h` |
| I6 batch mode | `src/LYMain.c` (the option and startup path) |
| I7 readability reducer | `src/HTML.c` (the structure the scoring needs) |
| I8 arena allocator | `src/GridText.c` (per-cell allocation) |
| I9 protocol plugins | `WWW/Library/Implementation/HTAccess.c` (the protocol dispatch) |
| I10 static builds | `configure.in`, `makefile.in` |

`src/GridText.c` is where every rendering change starts and ends. Read its existing
wrapping and table code before adding a path beside it.
