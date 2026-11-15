# Dump formats

The contract for `--dump`. Versioned, additive, deterministic.

## `--format=text` (frozen)

Identical to `lynx -dump` at the import commit. Never changes. Golden files in
`test/corpus/expect/text/`.

## `--format=markdown` (v1)

```markdown
# Heading level from h1-h6
Paragraph text, with [link text](https://absolute.example/url) inline.

- list item
  - nested item

| col a | col b |
|-------|-------|
| 1     | 2     |

    indented code block from <pre>
```

Rules: absolute URLs only; images become `![alt](url)` unless `--no-images`; tables
only when every row has the same cell count, otherwise the cells are emitted as
paragraphs with a `[table]` marker so nothing is silently lost.

## `--format=json` (v1)

```json
{
  "schema_version": 1,
  "url": "https://example.org/",
  "final_url": "https://example.org/",
  "status": 200,
  "title": "Example",
  "lang": "en",
  "blocks": [
    {"type": "heading", "level": 1, "text": "Example"},
    {"type": "paragraph", "text": "Text with a link.",
     "links": [{"text": "a link", "href": "https://example.org/x"}]},
    {"type": "table", "header": true,
     "rows": [[{"text": "col a"}, {"text": "col b"}]]},
    {"type": "form", "action": "/search", "method": "get",
     "fields": [{"name": "q", "type": "text", "label": "Search"}]}
  ]
}
```

Rules: `schema_version` is mandatory; keys are additive only; unknown keys must be
ignored by consumers; no timestamps anywhere; arrays preserve document order.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | success |
| 64 | usage or bad URL |
| 69 | network failure after retries |
| 75 | rendered, but the page needs images or CSS - promote me |
| 76 | TLS or certificate refusal - never promote past this |
