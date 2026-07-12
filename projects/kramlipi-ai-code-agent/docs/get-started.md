---
title: Get started
description: >-
  KramLipi Code agent — the only ENV + one command steps that work for coverage and CI.
keywords: GEMINI_API_KEY, verify-cmd, workspace, coverage, code-agent
---

# Get started

# KramLipi Code agent

**Increase your code coverage and review automatically.**

Developers ship code faster — but unit tests and failed builds pile up.
This agent fixes that in the **CI pipeline**.

---

## These are the only steps that helped

### ENV variables (Gemini)

Key from [Google AI Studio](https://aistudio.google.com/):

```bash
export CODE_AGENT_MODEL=gemini/gemini-3.1-flash-lite
export GEMINI_API_KEY=YOUR_SECRET_KEY
```

### Use this command

```bash
code-agent run "increase unit test coverage" \
  -w /mnt/d/karm/vibe-code/kramlipi-ci-demo-golang/ \
  --verify-cmd "go test ./..."
```

| Flag | Meaning |
|------|---------|
| `-w` | Folder path of the repo to work in |
| `--verify-cmd` | Command to check if the agent did the right thing (must exit `0`) |

Details: [Quick Start](quick-start.md)

### Get the binary (download)

Download Linux / macOS / Windows builds:

**[Kramlipi-code-agent on Google Drive](https://drive.google.com/drive/folders/11iuNWM13SjrlKastaA_2FaMz4tGg9_QX?usp=sharing)**

Folders: `linux/` · `macos/` · `windows/`

```bash
# After download (Linux/macOS example)
chmod +x code-agent
export CODE_AGENT_MODEL=gemini/gemini-3.1-flash-lite
export GEMINI_API_KEY=YOUR_SECRET_KEY
./code-agent run "increase unit test coverage" \
  -w /path/to/your-repo \
  --verify-cmd "go test ./..."
```

Also: [GitHub Releases](https://github.com/kramlipi/kramlipi.github.io/releases)

### Same with Docker

```bash
docker pull ghcr.io/kramlipi/code-agent:latest

docker run --rm -it \
  -e CODE_AGENT_MODEL \
  -e GEMINI_API_KEY \
  -v "/path/to/your-repo:/workspace" \
  ghcr.io/kramlipi/code-agent:latest \
  run "increase unit test coverage" \
  --verify-cmd "go test ./..." \
  -w /workspace
```

**Rule:** success requires `--verify-cmd` to exit `0` — not model opinion.
