---
title: Kramlipi AI Code Agent
description: >-
  Production-grade headless coding CLI — LangGraph agent loop, LiteLLM providers,
  and automation experts for CI, tests, deploy guard, SRE, and monitoring.
keywords: code-agent, ai coding agent, ci automation, bug-fix expert, langgraph, litellm
---

# Kramlipi AI Code Agent

**Kramlipi AI Code Agent** (`code-agent`) is a headless coding CLI that:

- Reads and edits your repo with real tools (`read_file`, `write_file`, `ast_edit`, `search_code`)
- Runs a **plan → execute → verify** loop (LangGraph)
- Calls LLMs via **LiteLLM** (Gemini, OpenAI, Anthropic, Ollama, …)
- Ships **automation experts** for CI failures, test selection, deploy guard, SRE alerts, and monitoring audits

!!! info "Source repository"
    Product source: [ai-code-agent](https://github.com/kramlipi/ai-code-agent) (install from that repo).

## Architecture

```mermaid
flowchart LR
    subgraph inputs [Inputs]
        Task[Task / log / alert]
        Config[config.yaml]
    end
    subgraph agent [Agent core]
        Plan[Planner]
        Exec[Executor + tools]
        Verify[Verifier + verify_cmd]
    end
    subgraph outputs [Outputs]
        Files[Changed files]
        Artifacts[.code-agent/runs/]
        MR[Draft MR optional]
    end
    Task --> Plan --> Exec --> Verify
    Config --> Plan
    Verify --> Files
    Verify --> Artifacts
    Verify --> MR
```

## What it is / is not

| | |
|---|---|
| **Is** | Terminal CLI for automated fixes, test intel, SRE/monitoring experts |
| **Is not** | Cursor IDE, a PR review bot, or a flaky-test analytics platform |
| **Verify gate** | `verify_cmd` must exit `0` — subprocess beats LLM claims |
| **Safety** | Will **not** edit `.github/workflows/**` to mask failures |

## Experts at a glance

| Expert | One-line purpose |
|--------|------------------|
| `bug-fix` | CI log → RCA → fix → optional draft MR |
| `test-intel` | Git diff → impacted tests + shard plan |
| `deploy-guard` | Metrics vs baseline → pass / block / rollback |
| `sre-expert` | Alert JSON → reliability fix |
| `monitoring-expert` | Repo scan → missing metrics / bad rules |

## Next steps

- [Quick Start](quick-start.md) — install, doctor, first command
- [Commands](commands.md) — full CLI reference
- [Recipes](recipes.md) — copy-paste workflows for Python, Go, CI logs
