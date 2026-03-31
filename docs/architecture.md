# Architecture — mAIrem Claude Integration Studio

**Project:** `mairem_claude_integration_studio`
**Version:** 1.0.0
**Framework:** C# / .NET · WPF · MkDocs Material
**Date:** 2026-03-30

---

## Overview

This document describes the runtime architecture for integrating the mAIrem
WPF application with the Claude model through two approved paths.

Before reading the diagrams, it is essential to understand three distinct
concepts that this architecture treats as separate layers:

---

## Conceptual model — three layers that must never be conflated

### 1. The model

The **Claude model** is a remote inference engine hosted by Anthropic.
It receives a sequence of messages and returns a response. The model has
no inherent access to the local machine. Any information about the local
environment that the model "sees" was explicitly included in the prompt
by the application layer.

### 2. The client / runtime

The **client or runtime** is the component responsible for sending requests
to the model and receiving responses. In Phase 1 this is the **Claude Code
CLI**, invoked as a subprocess by the C# application. In Phase 2 this is
the **MessagesApiRuntime**, an in-process component that calls the Anthropic
Messages API directly over HTTPS.

The client/runtime is the only component that communicates with the model.
It acts as a controlled gateway — not a transparent pipe.

### 3. MCP / tools

**MCP (Model Context Protocol)** is a protocol that allows the model to
request the execution of named tools during a conversation. The tools
themselves run locally, managed by MCP servers registered in a
project-visible configuration file. In Phase 2, equivalent functionality
is provided by **app-owned tool connectors** managed by the
`ToolLoopOrchestrator`.

In both paths, tool execution is triggered by the model's response but
**controlled and executed entirely by the application**. The model does
not execute code or access files. It requests an action; the application
decides whether and how to fulfill it.

---

## Access control principle

Local file and directory access is **never unrestricted**. All access is:

- defined by a `PermissionProfileResolver` that maintains an allowlist
  of approved directories and operations
- enforced before any tool call or CLI invocation is initiated
- logged to an audit trail regardless of outcome

The model only receives the result of an allowed, executed operation —
it never holds a filesystem handle or session.

---

## Integration path comparison

| Dimension | Path 1 — Claude Code CLI | Path 2 — Messages API |
|---|---|---|
| Runtime process | External subprocess (Claude Code CLI) | In-process HTTP client |
| Model access | Via Claude Code (proxied) | Direct HTTPS to `/v1/messages` |
| MCP / tool execution | Delegated to Claude Code + MCP servers | App-owned `ToolLoopOrchestrator` |
| Local file access | Allowlisted via MCP server config | Allowlisted via app tool connectors |
| Structured output | `--output-format json` flag | `content[]` block parsing |
| Replaceability | CLI layer is intentionally isolated | Runtime implements `IClaudeRuntime` |
| Phase | Phase 1 — approved | Phase 2 — planned |

---

## Runtime abstraction boundary

Both paths are hidden behind a common interface:

```csharp
public interface IClaudeRuntime
{
    Task<ClaudeResult> InvokeAsync(ClaudeRequest request, CancellationToken ct);
}
```

This ensures that the ViewModel, IntegrationService, and PromptBuilder are
**independent of the underlying runtime path**. Switching from Claude Code
to Messages API is a dependency injection configuration change, not an
architectural rewrite.

---

## Path 1 — Claude Code CLI + MCP integration flow

> **Source file:** `docs/diagrams/source/claude_code_integration_flow.mmd`

```mermaid
flowchart TD
    USER(["👤 User"])
    WPF["WPF Application\n(mAIrem UI)"]

    subgraph APP_LAYER ["Application Layer — C# / .NET"]
        VM["ViewModel\n(ReactiveUI + Autofac)"]
        SVC["IntegrationService"]
        RT["ClaudeCodeRuntime\nimplements IClaudeRuntime"]
        PERM["PermissionProfileResolver\n(allowlist: dirs, ops)"]
        PROMPT["PromptBuilder\n(context assembly)"]
        PARSER["ResultParser\n(structured output)"]
    end

    subgraph CLI_BRIDGE ["CLI Bridge — Local Process"]
        PROC["Process Wrapper\n(System.Diagnostics.Process)"]
        CLAUDECODE["Claude Code CLI\n(claude --print --output-format json)"]
    end

    subgraph MCP_LAYER ["MCP Layer — Mediated Local Access"]
        MCPCFG["MCP Config\n(project-visible JSON)"]
        MCPSRV["MCP Server(s)\n(filesystem, custom tools)"]
        FS["Local Filesystem\n(allowlisted paths only)"]
    end

    MODEL(["☁️ Claude Model\n(Anthropic API — via Claude Code)"])
    AUDIT[("Audit / Trace Log")]

    USER -->|"prompt / command"| WPF
    WPF --> VM
    VM --> SVC
    SVC --> PERM
    PERM -->|"validate allowed\ndirs + operations"| SVC
    SVC --> PROMPT
    PROMPT -->|"assembled context"| RT
    RT --> PROC
    PROC -->|"shell invocation\nwith flags + stdin"| CLAUDECODE
    CLAUDECODE <-->|"token exchange\n(HTTPS)"| MODEL
    CLAUDECODE <-->|"tool calls\n(MCP protocol)"| MCPSRV
    MCPSRV --> MCPCFG
    MCPSRV -->|"read / write\n(controlled scope)"| FS
    CLAUDECODE -->|"structured JSON\nresponse"| PROC
    PROC --> PARSER
    PARSER -->|"parsed result"| SVC
    SVC --> VM
    VM -->|"result display"| WPF
    WPF -->|"feedback"| USER
    RT -.->|"log invocation\n+ permissions used"| AUDIT
    PERM -.->|"log access decisions"| AUDIT

    style APP_LAYER fill:#e8f0fe,stroke:#3c6bc9
    style CLI_BRIDGE fill:#fef3e2,stroke:#e6920a
    style MCP_LAYER fill:#e6f4ea,stroke:#34a853
    style MODEL fill:#fce8e6,stroke:#d93025
    style AUDIT fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray:4 4
```

---

## Path 2 — Messages API + app-owned tool loop flow

> **Source file:** `docs/diagrams/source/messages_api_integration_flow.mmd`

```mermaid
flowchart TD
    USER(["👤 User"])
    WPF["WPF Application\n(mAIrem UI)"]

    subgraph APP_LAYER ["Application Layer — C# / .NET"]
        VM["ViewModel\n(ReactiveUI + Autofac)"]
        SVC["IntegrationService"]
        RT["MessagesApiRuntime\nimplements IClaudeRuntime"]
        PERM["PermissionProfileResolver\n(allowlist: dirs, ops)"]
        PROMPT["PromptBuilder\n(context + tool definitions)"]
        ORCH["ToolLoopOrchestrator\n(agentic loop controller)"]
        PARSER["ResultParser\n(content blocks → domain model)"]
    end

    subgraph TOOL_LAYER ["Tool Layer — App-Owned Connectors"]
        TOOL_FS["FileSystemTool\n(read/write — allowlisted)"]
        TOOL_CUSTOM["Custom Tools\n(project-specific connectors)"]
        FS["Local Filesystem\n(allowlisted paths only)"]
    end

    subgraph API_LAYER ["Anthropic API"]
        APIEP["POST /v1/messages\n(HTTPS — API key auth)"]
        MODEL(["☁️ Claude Model"])
    end

    AUDIT[("Audit / Trace Log")]

    USER -->|"prompt / command"| WPF
    WPF --> VM
    VM --> SVC
    SVC --> PERM
    PERM -->|"validate allowed\ndirs + operations"| SVC
    SVC --> PROMPT
    PROMPT -->|"messages[] +\ntool definitions"| RT
    RT --> ORCH
    ORCH -->|"POST request\n(messages + tools)"| APIEP
    APIEP <--> MODEL
    MODEL -->|"response\n(text or tool_use)"| APIEP
    APIEP -->|"response body"| ORCH
    ORCH -->|"stop_reason = tool_use\nexecute locally"| TOOL_FS
    ORCH -->|"stop_reason = tool_use\nexecute locally"| TOOL_CUSTOM
    TOOL_FS -->|"controlled access\n(scope-checked)"| FS
    TOOL_CUSTOM -.->|"extensible connectors"| FS
    ORCH -->|"tool_result → next turn\n(loop continues)"| ORCH
    ORCH -->|"stop_reason = end_turn\nfinal result"| PARSER
    PARSER -->|"parsed result"| SVC
    SVC --> VM
    VM -->|"result display"| WPF
    WPF -->|"feedback"| USER
    RT -.->|"log API calls\n+ token usage"| AUDIT
    PERM -.->|"log access decisions"| AUDIT
    ORCH -.->|"log tool calls\n+ results"| AUDIT

    style APP_LAYER fill:#e8f0fe,stroke:#3c6bc9
    style TOOL_LAYER fill:#e6f4ea,stroke:#34a853
    style API_LAYER fill:#fce8e6,stroke:#d93025
    style AUDIT fill:#f1f3f4,stroke:#9aa0a6,stroke-dasharray:4 4
```

---

## Service responsibilities

| Component | Layer | Responsibility |
|---|---|---|
| `IClaudeRuntime` | Application | Abstract boundary isolating runtime path from business logic |
| `ClaudeCodeRuntime` | Application | Wraps Claude Code CLI subprocess invocation |
| `MessagesApiRuntime` | Application | Calls Anthropic `/v1/messages` directly over HTTPS |
| `PromptBuilder` | Application | Assembles context, system prompt, and tool definitions |
| `PermissionProfileResolver` | Application | Enforces directory/operation allowlist before any invocation |
| `ToolLoopOrchestrator` | Application | Manages the agentic tool-use loop for Messages API path |
| `ResultParser` | Application | Converts raw CLI output or API response blocks to domain model |
| MCP Config JSON | Config | Declares MCP server registrations for Claude Code path |
| MCP Server(s) | CLI Bridge | Execute tool calls on behalf of Claude Code (allowlisted scope) |
| App Tool Connectors | Tool Layer | Execute tool calls on behalf of Messages API path |

---

## External dependencies (Phase 1)

| Dependency | Type | Justification |
|---|---|---|
| Claude Code CLI | Local binary | Required runtime bridge for Phase 1 MCP-capable integration |
| Anthropic API | HTTPS endpoint | Remote model inference — accessed via Claude Code in Phase 1 |
| MCP Server(s) | Local process | Controlled tool execution layer registered in project config |

## External dependencies (Phase 2, planned)

| Dependency | Type | Justification |
|---|---|---|
| Anthropic Messages API | HTTPS endpoint | Direct model access, replacing Claude Code subprocess |
| `Anthropic.SDK` or `HttpClient` | NuGet / stdlib | HTTP client for API calls |

---

## Known constraints

- Claude Code CLI must be installed and available on the local `PATH` for Phase 1.
- MCP server registration must use a project-visible JSON config file —
  hidden or undocumented machine state is not acceptable.
- The `IClaudeRuntime` boundary must be preserved when Phase 2 is implemented.
  Do not bypass it with direct API calls from UI or ViewModel code.
- Messages API does not provide native MCP client behavior. Local tool
  access in Phase 2 is fully owned and mediated by the application.
