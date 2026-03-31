# mAIrem Claude Integration Studio

> **Domain:** `AIAutomation\mAIrem`  
> **Project:** `mairem_claude_integration_studio`  
> **Version:** 1.0.0  
> **Created:** 2026-03-30

A governed C# / WPF application that integrates the **mAIrem** desktop
environment with the **Claude** AI model through two distinct, replaceable
runtime paths.

---

## Current phase

**Phase 1 — Project definition, documentation scaffold, and runtime architecture comparison**
Status: `in_progress`

---

## Integration paths

| Path | Runtime | Phase |
|---|---|---|
| Claude Code CLI + MCP | External subprocess (Claude Code) | Phase 1 — active |
| Messages API + app tool loop | In-process HTTPS client | Phase 2 — planned |

Both paths implement `IClaudeRuntime`. Switching paths is a DI configuration
change. Local file access is allowlisted and mediated by the application in
both paths — the model never accesses local resources directly.

---

## Documentation

Full governed documentation is rendered via MkDocs Material.

```bash
# Install dependencies (once, in active Python environment)
pip install mkdocs mkdocs-material pymdown-extensions

# Serve locally
run_mkdocs.bat
# or: mkdocs serve
```

Browse to [http://127.0.0.1:8000](http://127.0.0.1:8000)

### Key documents

| Document | Path |
|---|---|
| Project overview | `docs/index.md` |
| Runtime architecture + diagrams | `docs/architecture.md` |
| Phase roadmap | `docs/roadmap.md` |
| Session 001 log | `docs/session_logs/session_001.md` |
| Diagram sources | `docs/diagrams/source/` |

---

## Workspace layer

This project occupies **Layer D** of the governed workspace hierarchy:

```
Claude-Workspace\
  AIAutomation\               ← domain
    mAIrem\                   ← container (Layer C)
      shared\                 ← workspace-level shared (Layer C)
      projects\
        mairem_claude_integration_studio\   ← this project (Layer D)
```

Reusable assets are promoted to Layers A, B, or C only when formally justified.

---

## Governance

This project is governed by `mairem_claude_integration_studio_project_instructions.md`.
All sessions must follow the mandatory closure protocol defined there.
No phase may be marked complete without a verified closure report.
