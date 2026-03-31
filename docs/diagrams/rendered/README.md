# Rendered Diagrams — mAIrem Claude Integration Studio

This directory contains optional exported renders (PNG / SVG) of the governed
Mermaid diagrams for the project.

## Governance rules

- **Source files are authoritative.** All diagrams are defined as `.mmd` files
  in `docs/diagrams/source/`. This directory holds derived outputs only.
- Rendered outputs are excluded from MkDocs navigation via `exclude_docs` in
  `mkdocs.yml`. They are never treated as governed artifacts.
- Do not edit rendered files directly. Always update the `.mmd` source file and
  regenerate.

## Diagram index

| Source file | Description |
|---|---|
| `source/claude_code_integration_flow.mmd` | Claude Code CLI + MCP integration flow |
| `source/messages_api_integration_flow.mmd` | Messages API + app-owned tool loop flow |

## How to export (optional)

Use the Mermaid CLI (`mmdc`) or the MkDocs Material live preview to generate
PNG/SVG renders if needed:

```bash
mmdc -i docs/diagrams/source/claude_code_integration_flow.mmd \
     -o docs/diagrams/rendered/claude_code_integration_flow.png

mmdc -i docs/diagrams/source/messages_api_integration_flow.mmd \
     -o docs/diagrams/rendered/messages_api_integration_flow.png
```

Rendered outputs committed here are informational only.
