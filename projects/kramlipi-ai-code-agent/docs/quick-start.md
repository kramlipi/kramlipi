---
title: Quick Start
description: >-
  Install Kramlipi AI Code Agent, run doctor, sync API keys, and execute your
  first code-agent command in under five minutes.
keywords: code-agent install, quick start, doctor, gemini api key, pip install
---

# Quick Start

Get **code-agent** running in five minutes.

## Prerequisites

| Requirement | Why |
|-------------|-----|
| **Python 3.11+** | Runtime |
| **ripgrep (`rg`)** | Code search tool; `doctor` fails without it |
| **LLM access** | `GEMINI_API_KEY`, OpenAI key, or local Ollama |
| **Git** (optional) | For `--publish` draft MRs via `gh` / `glab` |

## 1. Install

=== "Linux / macOS / WSL"

    ```bash
    git clone https://github.com/kramlipi/ai-code-agent.git
    cd ai-code-agent
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e ".[dev]"
    cp config.example.yaml config.yaml
  ```

=== "Windows (PowerShell)"

    ```powershell
    git clone https://github.com/kramlipi/ai-code-agent.git
    cd ai-code-agent
    python -m venv .venv
    .venv\Scripts\Activate.ps1
    pip install -e ".[dev]"
    copy config.example.yaml config.yaml
    ```

Or use the helper script (Linux/WSL):

```bash
bash install.sh
source .venv/bin/activate
```

## 2. API key

=== "Environment variable"

    ```bash
    export GEMINI_API_KEY="your-key-here"
    ```

=== "WSL + Windows env sync"

    Set Windows user variable `geminikey`, then:

    ```bash
    code-agent env sync
    code-agent env show    # values redacted
    ```

## 3. Preflight

```bash
code-agent doctor
code-agent doctor --provider-test   # optional: live LLM ping
```

**Expected (healthy):**

```text
✓ Python 3.11+
✓ ripgrep available
✓ config.yaml found
✓ LLM provider reachable (with --provider-test)
```

**Exit code:** `0` on success, `1` on failure.

## 4. See what's available

```bash
code-agent experts list
code-agent config show
```

**Expected:**

```text
Experts:
  bug-fix          CI/build log → fix → MR
  test-intel       Diff → impacted tests
  deploy-guard     Metrics → pass/block/rollback
  sre-expert       Alert → reliability fix
  monitoring-expert  Repo observability audit
```

## 5. First commands

### Run a one-shot task

```bash
code-agent run "Add type hints to src/utils.py" --workspace .
```

With verification:

```bash
code-agent run "Fix failing login test" \
  --verify-cmd "pytest -q tests/test_auth.py" \
  -w .
```

### Fix CI from a log (bug-fix expert)

```bash
pytest -q 2>&1 | tee /tmp/ci.log
code-agent experts run bug-fix \
  --log /tmp/ci.log \
  --verify-cmd "pytest -q"
```

### Open a draft MR after fix

```bash
code-agent experts run bug-fix \
  --log /tmp/ci.log \
  --verify-cmd "pytest -q" \
  --publish
```

Requires authenticated `gh` (GitHub) or `glab` (GitLab).

### Point at any repo

Workspace does **not** have to be the code-agent repo:

```bash
code-agent run "Add GET /health endpoint with a test" \
  --verify-cmd "go test -v ./..." \
  -w /path/to/your-project
```

Priority: CLI `-w` → `config.yaml` `workspace:` → env `CODE_AGENT_WORKSPACE`.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success (done, skipped, or test plan produced) |
| `1` | Startup / config / doctor failure |
| `2` | Ran but failed (verify fail, max iterations, expert failed) |

## What's next?

- [Commands](commands.md) — full CLI reference
- [Experts](experts.md) — each expert's inputs and outputs
- [Recipes](recipes.md) — Python tests, Go tests, CI babysit, coverage
