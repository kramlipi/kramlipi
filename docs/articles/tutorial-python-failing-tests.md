---
title: Fix Failing Python Tests Until pytest Is Green
description: >-
  Hands-on tutorial — build a broken add() in /tmp/py-demo, watch pytest fail,
  then fix it with Kramlipi code-agent run and bug-fix until --verify-cmd exits 0.
keywords: >-
  python pytest tutorial, failing unit test, code-agent verify-cmd, bug-fix expert,
  GEMINI_API_KEY, Kramlipi AI Code Agent
---

# Fix Failing Python Tests Until pytest Is Green

It is 4:47 p.m. You merged a “tiny” refactor. CI is red. Slack pings. You open the log:

```text
FAILED tests/test_calc.py::test_add - assert -1 == 5
```

The test is right. The code is wrong. And somewhere between “I'll fix it after lunch” and now, the failure has become *yours*.

Most AI assistants would summarize the traceback and wish you luck. **Kramlipi AI Code Agent** does something different: it edits your repo with tools, runs your verify command, and **only stops when that command exits 0**. It does not invent success. If pytest is still red, the job is not done.

This tutorial walks through that loop on a tiny Python project you can build in five minutes.

---

## What you need

| Item | Where |
|------|-------|
| `code-agent` binary | [GitHub Releases](https://github.com/kramlipi/code-agent-binaries/releases) |
| Model + API key | See below |
| Python + pytest | Any recent Python 3 |

Download the binary, make it executable, and sanity-check your provider:

```bash
chmod +x code-agent
./code-agent doctor --provider-test
```

### Set your model and API key

Kramlipi uses LiteLLM model strings. Pick one provider:

```bash
# Gemini (recommended default)
export CODE_AGENT_MODEL=gemini/gemini-2.0-flash
export GEMINI_API_KEY=your-key-here

# Claude
export CODE_AGENT_MODEL=anthropic/claude-sonnet-4-20250514
export ANTHROPIC_API_KEY=your-key-here

# OpenAI
export CODE_AGENT_MODEL=openai/gpt-4o
export OPENAI_API_KEY=your-key-here
```

Keys: [Google AI Studio](https://aistudio.google.com/) · [Anthropic Console](https://console.anthropic.com/) · [OpenAI API keys](https://platform.openai.com/api-keys)

---

## Step 1 — Break something on purpose

We will create a minimal repo under `/tmp/py-demo` with a classic off-by-operator bug: `add()` subtracts instead of adds.

```bash
mkdir -p /tmp/py-demo && cd /tmp/py-demo
git init

mkdir -p myapp tests

cat > myapp/__init__.py <<'EOF'
# package marker
EOF

cat > myapp/calc.py <<'EOF'
def add(a: int, b: int) -> int:
    return a - b   # BUG: should be +
EOF

cat > tests/test_calc.py <<'EOF'
from myapp.calc import add

def test_add():
    assert add(2, 3) == 5
EOF

pip install pytest
pytest -q
```

You should see the same failure CI would show:

```text
FAILED tests/test_calc.py::test_add - assert -1 == 5
1 failed
```

Save the log — you will feed it to the `bug-fix` expert in a moment:

```bash
pytest -q 2>&1 | tee /tmp/pytest.log
```

---

## Step 2 — Fix with `code-agent run` (prompt mode)

Point the agent at your workspace (`-w`) and tell it how you prove success (`--verify-cmd`). Those two flags are non-negotiable.

```bash
code-agent run \
  "Fix the failing test in tests/test_calc.py. The add() function in myapp/calc.py is wrong. Run pytest -q until all tests pass. Change only what is needed." \
  --verify-cmd "pytest -q" \
  -w /tmp/py-demo
```

### What happens inside the loop

1. The agent **reads** `myapp/calc.py` and the test file.
2. It **writes** a fix through its file tools — not by pasting code in chat.
3. It runs `pytest -q` because you set `--verify-cmd`.
4. If exit code ≠ 0, it tries again.
5. When exit code = 0, status becomes **done**.

That is the core product rule: **no green verify, no victory lap.**

Expected output when it succeeds:

```text
Status: done
Files: myapp/calc.py
```

Verify yourself — trust, but verify:

```bash
cd /tmp/py-demo && pytest -q
# 1 passed
```

### Flags explained

| Flag | Value | Meaning |
|------|-------|---------|
| `"..."` | Your task | Plain English — what you want fixed |
| `--verify-cmd` | `pytest -q` | The agent must run this and get exit `0` before finishing |
| `-w` | `/tmp/py-demo` | **Workspace jail** — only this directory is edited |

Use the **exact** command your CI runs. If GitHub Actions uses `pytest -q`, do not substitute `python -m pytest` unless CI does too.

---

## Step 3 — Fix with `bug-fix` expert (CI log mode)

When CI already failed and you have a log file, skip the prose prompt. The `bug-fix` expert **parses** pytest output — file names, assertion lines, tracebacks — instead of guessing.

Re-break the demo if you fixed it in Step 2:

```bash
cd /tmp/py-demo
# revert calc.py to a - b if needed, then:
pytest -q 2>&1 | tee /tmp/pytest.log

code-agent experts run bug-fix \
  --log /tmp/pytest.log \
  --verify-cmd "pytest -q" \
  -w /tmp/py-demo
```

| Flag | Why it matters |
|------|----------------|
| `--log /tmp/pytest.log` | Structured intake from real failure output |
| `--verify-cmd "pytest -q"` | Same proof standard as `code-agent run` |
| `-w /tmp/py-demo` | Repo root the agent may edit |

Optional flags for real projects:

- `--dry-run` — see the plan without pushing
- `--publish` — commit, push branch, open a **draft PR** (requires `gh auth login`)

The agent understands pytest failures, Python tracebacks, mypy errors, and coverage gate failures — but **`--verify-cmd` always wins**. Parser hints do not override a red subprocess.

---

## Step 4 — Wire it into CI (same rule)

In GitHub Actions, GitLab, or Jenkins, the pattern is identical:

```bash
pytest -q 2>&1 | tee /tmp/ci.log

code-agent experts run bug-fix \
  --log /tmp/ci.log \
  --verify-cmd "pytest -q" \
  -w "$GITHUB_WORKSPACE"
```

Your pipeline still owns the gate. The agent owns the edit loop until the gate passes.

---

## Common mistakes

| Mistake | What goes wrong | Fix |
|---------|-----------------|-----|
| Forgot `-w` | Agent edits the wrong directory | Always pass the repo root: `-w /tmp/py-demo` |
| Wrong `--verify-cmd` | Agent “succeeds” on a different command than CI | Copy the exact CI command character-for-character |
| No API key set | `doctor --provider-test` fails | Export `GEMINI_API_KEY` (or Claude/OpenAI equivalent) |
| Trusting chat over verify | Model says “fixed!” while tests fail | Only `--verify-cmd` exit 0 counts |
| `-w` points at venv, not repo | No `tests/` found | `-w` must be where `pytest` runs from |

---

## What you learned

- A failing pytest is objective intake — not a brainstorming prompt.
- `-w` scopes edits; `--verify-cmd` scopes success.
- `code-agent run` and `bug-fix --log` share the same proof bar.
- The agent does not stop until your command exits 0.

**Next:** [Quick Start](https://kramlipi.github.io/quick-start/) · [Python examples](../examples/python.md) · [Coverage tutorial](tutorial-raise-coverage.md) · Questions: [cluevion@gmail.com](mailto:cluevion@gmail.com)
