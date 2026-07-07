---
title: Kramlipi AI Code Agent
description: >-
  code-agent fixes CI failures, failing unit tests, low coverage, missing tests,
  flaky CI triage, and missing telemetry — with optional merge requests.
keywords: code-agent, ci, unit tests, coverage, telemetry, merge request
---

# Kramlipi AI Code Agent

**`code-agent`** is a headless CLI for **CI and test automation** in your git repos.

## What you use it for

| Job | Command / expert |
|-----|------------------|
| CI pipeline failed | `experts run bug-fix --log ci.log` |
| Failing unit tests (Python/Go/Java/…) | `bug-fix` or `run` + `--verify-cmd` |
| Increase code coverage | `bug-fix` on coverage log |
| Write missing unit tests | Same — agent adds `tests/` or `src/test/` |
| Slow CI — run fewer tests | `experts run test-intel` |
| Flaky / repeated failures | `bug-fix` + RCA + `experts watch --pr N` |
| Missing Prometheus / OTel metrics | `experts run monitoring-expert` |
| MR for telemetry gaps | `monitoring-expert --publish` |

## How it works

1. **Read** your repo (search, read files)  
2. **Edit** source and tests with tools  
3. **Verify** with `--verify-cmd` (must exit `0`)  
4. **Publish** optional draft MR with `--publish`  

## Start here

👉 **[Quick Start](quick-start.md)** — install binary, `GEMINI_API_KEY`, first command  

### Language guides

- [Python failing tests](examples/python.md)
- [Go failing tests](examples/go.md)
- [Java failing tests](examples/java.md)

## Experts

| Expert | Purpose |
|--------|---------|
| `bug-fix` | CI log → fix → verify → MR |
| `test-intel` | Diff → impacted tests only |
| `monitoring-expert` | Missing telemetry → optional MR |
| `deploy-guard` | Post-deploy metrics |
| `sre-expert` | Alert → reliability fix |

[Full experts reference →](experts.md)
