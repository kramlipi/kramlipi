---
title: How to use verify commands (goal engine)
description: >-
  Practical commands to run code-agent with pytest or go test until the verify
  command exits 0. Copy-paste examples for Python and Go.
keywords: code-agent, verify-cmd, pytest, go test, how to use, failing tests
---

# How to use verify commands

Tell **code-agent** what “done” means with `--verify-cmd`. It edits your repo with tools, then re-runs that command until it exits **0** (or it fails closed).

**Contact:** cluevion@gmail.com · https://kramlipi.github.io

---

## Before you start

```bash
export GEMINI_API_KEY="your-key"
# optional model override
export CODE_AGENT_MODEL=gemini/gemini-3.1-flash-lite

# binary on PATH, or use Docker — see Quick Start
code-agent doctor
```

---

## 1) See which verify command would be used

No LLM call — discovery only:

```bash
code-agent doctor --verify-plan "fix failing unit tests" -w .
code-agent doctor --verify-plan "increase coverage to 80%" -w .
code-agent doctor --verify-plan "go test the package" -w /path/to/go-project
```

---

## 2) Fix failing tests (Python)

```bash
cd /path/to/your-python-repo

# show red first (optional)
python3 -m pytest -q

code-agent run "Fix all failing unit tests. Minimal changes only — do not change tests unless required." \
  --verify-cmd "python3 -m pytest -q" \
  -w .

# prove green with the same command
python3 -m pytest -q
```

Narrow the gate:

```bash
code-agent run "Fix the auth tests." \
  --verify-cmd "python3 -m pytest -q tests/test_auth.py" \
  -w .
```

---

## 3) Fix failing tests (Go)

```bash
cd /path/to/your-go-package

go test ./...

code-agent run "Make unit tests pass. Minimal changes only." \
  --verify-cmd "go test ./..." \
  -w .

go test ./...
```

---

## 4) Let code-agent pick the verify command

If you omit `--verify-cmd`, it tries config → CI → project manifests (`pytest`, `go test`, npm, …):

```bash
code-agent run "Fix the failing tests" -w /path/to/project
```

Prefer **explicit** `--verify-cmd` when you know the right command.

---

## 5) Dry-run (no file writes)

```bash
code-agent run "Fix failing tests" \
  --verify-cmd "python3 -m pytest -q" \
  --dry-run \
  -w .
```

---

## 6) Docker one-liner

```bash
cd /path/to/your-repo

docker run --rm -it \
  -e GEMINI_API_KEY \
  -e CODE_AGENT_MODEL \
  -v "$PWD:/workspace" \
  ghcr.io/kramlipi/code-agent:latest \
  run "Fix all failing unit tests. Minimal changes only." \
  --verify-cmd "python3 -m pytest -q" \
  -w /workspace
```

For Go, use `--verify-cmd "go test ./..."` (image must have Go, or run the binary locally).

---

## Tips

| Tip | Why |
|-----|-----|
| Same verify before and after | Proves the agent actually fixed the failure |
| Keep the prompt tight | “Minimal changes”, “do not weaken other tests” |
| If the run fails | Improve the **prompt**, re-run `code-agent` — don’t hand-edit the fix |
| CI log → fix | `code-agent experts run bug-fix --log fail.log --verify-cmd "…"` |

More: [Commands](commands.md) · [Python examples](examples/python.md) · [Go examples](examples/go.md) · [Quick Start](quick-start.md)
