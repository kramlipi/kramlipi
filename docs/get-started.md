---
title: Get started in 1 minute
description: >-
  Fastest path to code-agent — API key, one script or one Docker command,
  browser UI or CLI. Be productive in about sixty seconds.
keywords: get started, 1 minute, docker-ui, code-agent quickstart, GEMINI_API_KEY
---

# Get started in 1 minute

You need three things: **Docker**, an **API key**, and a **project folder**.

| | |
|---|---|
| **1** | `export GEMINI_API_KEY=…` (or `OPENAI_API_KEY` / `ANTHROPIC_API_KEY`) |
| **2** | Run the one-liner below |
| **3** | Open http://127.0.0.1:8080 → pick your repo → go |

---

## Fastest path — browser UI

=== "Linux / macOS / WSL"

    ```bash
    export GEMINI_API_KEY="your-key"

    curl -fsSL -o docker-ui.sh \
      https://gist.githubusercontent.com/kramlipi/d31f4f454cd127cfb552e5ed5e854af3/raw
    chmod +x docker-ui.sh
    bash docker-ui.sh
    ```

=== "Windows PowerShell"

    ```powershell
    $env:GEMINI_API_KEY = "your-key"
    Invoke-WebRequest -Uri "https://gist.githubusercontent.com/kramlipi/387228f78eb47e437f578f625a101707/raw" -OutFile docker-ui.ps1
    .\docker-ui.ps1
    ```

Gists: [Linux](https://gist.github.com/kramlipi/d31f4f454cd127cfb552e5ed5e854af3) · [Windows](https://gist.github.com/kramlipi/387228f78eb47e437f578f625a101707)  
Or download from this site: [`docker-ui.sh`](assets/scripts/docker-ui.sh) · [`docker-ui.ps1`](assets/scripts/docker-ui.ps1)

---

## Or — one CLI command (no browser)

From **your** git repo:

```bash
export GEMINI_API_KEY="your-key"
cd /path/to/your-repo

docker pull ghcr.io/kramlipi/code-agent:latest

docker run --rm -it \
  -e GEMINI_API_KEY \
  -v "$PWD:/workspace" \
  ghcr.io/kramlipi/code-agent:latest \
  run "Fix all failing unit tests. Minimal changes only." \
  --verify-cmd "pytest -q" \
  -w /workspace
```

Go? Use `--verify-cmd "go test ./..."`.  
Need a smoke test first? Swap the last lines for `doctor --provider-test`.

---

## You are done when…

| Check | Command / action |
|-------|------------------|
| UI up | Browser opens http://127.0.0.1:8080 |
| Key works | `doctor --provider-test` prints ok |
| Fix proven | Same verify command exits `0` after the agent runs |

**Rule:** the agent only succeeds when **your** verify command exits `0` — not when the model says so.

---

## Next 2 minutes (optional)

```bash
# Rich help + examples
code-agent -h          # if installed locally
# or inside Docker: … latest -h

# Tab-complete experts and verify commands (local install)
code-agent --install-completion
```

| Want… | Go to |
|-------|--------|
| Full install / flags | [Quick Start](quick-start.md) |
| Why → command → benefit | [Use Cases](use-cases.md) |
| Pain catalog | [Pains](pains.md) |
| CLI reference + completion | [Commands](commands.md) |
| Copy-paste only | [Recipes](recipes.md) |

**Contact:** cluevion@gmail.com · **Site:** https://kramlipi.github.io/
