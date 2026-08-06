# diagrams/

Mermaid source for the flowcharts embedded in `process_maps.md` and `stakeholder_map.md`,
extracted one file per diagram so each can be exported as an image for the PDF versions.

GitHub renders Mermaid natively, so the markdown documents already show these as live
diagrams. The exported PNGs exist only so the PDF versions aren't left with raw source.

## Exporting

For each `.mmd` file below, produce a PNG **with exactly the same base name**:

| Source | Export to | Appears in |
|---|---|---|
| `process_maps-1-recall-response-as-is.mmd` | `process_maps-1-recall-response-as-is.png` | Process 1 — As-Is |
| `process_maps-2-recall-response-to-be.mmd` | `process_maps-2-recall-response-to-be.png` | Process 1 — To-Be |
| `process_maps-3-goods-in-as-is.mmd` | `process_maps-3-goods-in-as-is.png` | Process 2 — As-Is |
| `process_maps-4-goods-in-to-be.mmd` | `process_maps-4-goods-in-to-be.png` | Process 2 — To-Be |
| `process_maps-5-expiry-as-is.mmd` | `process_maps-5-expiry-as-is.png` | Process 3 — As-Is |
| `process_maps-6-expiry-to-be.mmd` | `process_maps-6-expiry-to-be.png` | Process 3 — To-Be |
| `stakeholder_map-1-influence-interest-grid.mmd` | `stakeholder_map-1-influence-interest-grid.png` | Influence and interest grid |

Two ways to do it:

- **mermaid.live** — paste the file contents in, then Actions → PNG. Set the scale to 2× or
  3× so the text stays sharp in print.
- **VS Code** — install the Markdown Preview Mermaid Support extension, open the markdown
  file, and export the rendered diagram from the preview.

The numbering matters more than the wording: the PDF build matches `<document>-<n>-*.png`
to the nth diagram in that document. Any diagram without a matching PNG is left as source
in the PDF rather than dropped silently.
