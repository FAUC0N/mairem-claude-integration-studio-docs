# Roadmap — mAIrem Claude Integration Studio

**Project:** `mairem_claude_integration_studio`
**Version:** 1.0.0
**Last updated:** 2026-03-30

---

## Phase status legend

| Symbol | Status |
|---|---|
| ✅ | `complete` |
| ⏳ | `in_progress` |
| 🔵 | `approved` |
| 🔲 | `pending` |
| ⏸ | `deferred` |

---

## Phase 1 — Project definition, documentation scaffold, and runtime architecture comparison

**Status:** ⏳ `in_progress`
**Objective:** Define the project scope, establish the MkDocs documentation scaffold,
produce the two governed runtime architecture diagrams, and document the comparison
between the Claude Code CLI path and the Messages API path before any implementation begins.

### Deliverables

| Deliverable | Status |
|---|---|
| Approved project name and scope | ✅ |
| Governed project instructions | ✅ |
| MkDocs scaffold (`mkdocs.yml`, `run_mkdocs.bat`, `docs/` structure) | ✅ |
| `docs/index.md` — project overview and phase table | ✅ |
| `docs/architecture.md` — conceptual model + both runtime diagrams | ✅ |
| `docs/diagrams/source/claude_code_integration_flow.mmd` | ✅ |
| `docs/diagrams/source/messages_api_integration_flow.mmd` | ✅ |
| `docs/diagrams/rendered/README.md` | ✅ |
| `docs/roadmap.md` (this file) | ✅ |
| `docs/session_logs/session_001.md` | ⏳ |
| `README.md` (project root) | ⏳ |

### Success criteria

- Both `.mmd` diagrams exist, are syntactically valid, and are referenced in `architecture.md`.
- `mkdocs.yml` nav matches the real `docs/` file set.
- No governed document describes superseded or future-phase architecture as current.
- The conceptual separation between model, client/runtime, and MCP/tools is clearly documented.
- Local file access is described as mediated and controlled — never unrestricted.
- Session log documents all decisions and the scaffold state.

### Phase 1 notes

The `AIAutomation\mAIrem` container did not exist at the start of this phase.
The full directory hierarchy was created from scratch in session 001, following
workspace governance rules (Layers A–D). No pre-existing artifacts were found.

---

## Phase 2 — Claude Code CLI integration — C# implementation

**Status:** 🔲 `pending`
**Prerequisite:** Phase 1 complete and closed.
**Objective:** Implement the `ClaudeCodeRuntime`, `PermissionProfileResolver`,
`PromptBuilder`, and `ResultParser` components in C#. Validate end-to-end
invocation of Claude Code CLI from the WPF application.

### Planned deliverables (not yet approved in detail)

- C# solution scaffold under `src/`
- `IClaudeRuntime` interface definition
- `ClaudeCodeRuntime` implementation
- `PromptBuilder` and `ResultParser`
- `PermissionProfileResolver` with allowlist enforcement
- MCP config sample (project-visible JSON)
- Integration smoke test
- Updated session log and architecture docs

---

## Phase 3 — Messages API integration — C# implementation

**Status:** 🔲 `pending`
**Prerequisite:** Phase 2 complete and closed.
**Objective:** Implement `MessagesApiRuntime` and `ToolLoopOrchestrator`.
Validate that switching from Claude Code to Messages API requires only a
DI configuration change, not an architectural rewrite.

---

## Phase 4 — Hardening, audit, and production readiness

**Status:** 🔲 `pending`
**Prerequisite:** Phase 3 complete and closed.
**Objective:** Harden error handling, validate audit trail, review permission
profile coverage, and prepare the integration for production use within mAIrem.

---

## Deferred items

None currently designated.
