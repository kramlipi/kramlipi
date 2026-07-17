---
title: "Tutorial: First-Pass PR Code Review with code-review"
description: >-
  Run the code-review expert on a pull request — dry-run locally, post inline
  comments with GH_TOKEN, or wire GitHub Actions and GitLab CI with --diff-file.
  Economy mode off by default; verify-gated quality.
keywords: >-
  code-review expert, PR review, GH_TOKEN, GitHub Actions, GitLab diff-file,
  dry-run, inline comments, Kramlipi code-agent
---

# First-Pass PR Code Review Before Humans Burn Out

**Kramlipi AI Code Agent** · [kramlipi.github.io](https://kramlipi.github.io) · [Binaries](https://github.com/kramlipi/code-agent-binaries/releases) · cluevion@gmail.com

---

## The pain

Your team opens pull requests faster than reviewers can read them. Senior engineers skim diffs at midnight. Junior authors wait two days for “LGTM” — or get a wall of nitpicks after merge.

Generic AI chat reviews have a worse problem: they **don't run your repo**. They hallucinate files that aren't in the diff. They never face a verify gate.

**Kramlipi code-review** is different: it reads the **actual PR diff**, runs scanners plus an agent loop, filters findings to lines that exist on the right side of the patch, and posts **inline review comments** on GitHub — or emits JSON for GitLab/Azure.summary workflows. It does **not** merge code. It does **not** replace human judgment. It clears the obvious floor so humans focus on design.

Full CI copy-paste templates: **[Add code-review to CI](https://kramlipi.github.io/code-review-ci/)**

---

## What you need

| Item | Why |
|------|-----|
| `code-agent` | [Releases](https://github.com/kramlipi/code-agent-binaries/releases) |
| LLM key | `GEMINI_API_KEY` (default model: `gemini/gemini-3.1-flash-lite`) |
| Open PR number | `--pr N` on GitHub |
| `GH_TOKEN` | GitHub API — `gh auth token` locally or `secrets.GITHUB_TOKEN` in Actions |
| `-w .` | Repo root (must match PR checkout) |

Install path: [Quick Start](../quick-start.md).

---

## Step 1 — Dry-run on your laptop (no posts)

Before you wire CI, prove the expert sees your PR:

```bash
export GEMINI_API_KEY=your-key
export GH_TOKEN=$(gh auth token)

cd /path/to/your-repo
git fetch origin pull/42/head:pr-42-review   # optional; gh usually handles PR refs

code-agent experts run code-review \
  --pr 42 \
  --dry-run \
  -w .
```

**`--dry-run`** prints findings and writes artifacts under `.code-agent/runs/<run_id>/review-findings.json` — **no** GitHub Review posted. Use this to tune noise before your team sees bot comments.

Inspect output:

```bash
ls -1d .code-agent/runs/*/review-findings.json | tail -1 | xargs cat | head -80
```

Invalid JSON from the critic → exit **`2`** (fail closed). No silent “empty review.”

---

## Step 2 — Live run: inline comments on GitHub

When dry-run findings look reasonable:

```bash
export GH_TOKEN=$(gh auth token)

code-agent experts run code-review \
  --pr 42 \
  -w .
```

The expert posts a **GitHub Pull Request Review** with inline comments (`side=RIGHT`). Lines outside the diff are skipped — no fantasy findings on code you didn't change.

**Economy mode is off by default** — you get full-quality review. To reduce LLM cost in high-volume repos:

```bash
export CODE_AGENT_ECONOMY_MODE=true
```

Only enable economy after you've validated default quality on your stack.

---

## Step 3 — GitHub Actions (every PR)

Minimal job — permissions and token matter:

```yaml
permissions:
  contents: read
  pull-requests: write

env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
  CODE_AGENT_MODEL: gemini/gemini-3.1-flash-lite

steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0

  - name: Install code-agent
    run: |
      TAG="$(gh release list --repo kramlipi/code-agent-binaries --limit 1 --json tagName -q '.[0].tagName')"
      VER="${TAG#code-agent-}"
      gh release download "$TAG" --repo kramlipi/code-agent-binaries \
        --pattern "code-agent-${VER}-linux" --dir /tmp
      install -m 755 "/tmp/code-agent-${VER}-linux" /usr/local/bin/code-agent

  - name: Review PR
    run: |
      code-agent experts run code-review \
        --pr ${{ github.event.pull_request.number }} \
        -w .
```

Optional **`--dry-run`** on a `workflow_dispatch` job for staging. Production PR events should omit it so comments post.

**Complete** workflows (Docker variant, Azure, secrets table): [code-review-ci](https://kramlipi.github.io/code-review-ci/)

---

## Step 4 — GitLab CI with `--diff-file`

GitLab doesn't use `--pr N` the same way. Export the MR diff, then review:

```bash
git fetch origin "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" --depth=50
git diff "origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}...HEAD" > /tmp/mr.diff

code-agent experts run code-review \
  --diff-file /tmp/mr.diff \
  -w .
```

Post a summary MR note with `glab mr note` from the generated `review-findings.json` — full snippet in [code-review-ci](https://kramlipi.github.io/code-review-ci/).

---

## How this differs from bug-fix

| Expert | Input | Success | Changes code? |
|--------|-------|---------|---------------|
| **code-review** | `--pr` or `--diff-file` | Findings JSON + posted comments | **No** — review only |
| **bug-fix** | `--log` | `--verify-cmd` exit **`0`** | **Yes** — edits until green |

Code-review never opens a merge request. Bug-fix never posts inline nits. Pick the expert for the job.

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Missing `GH_TOKEN` | Export `gh auth token` or set `secrets.GITHUB_TOKEN` in Actions |
| `pull-requests: read` only | Needs **`write`** to post reviews |
| Shallow clone | `fetch-depth: 0` for accurate diffs |
| Reviewing wrong repo with `-w` | `-w .` must be the checked-out PR branch root |
| Expecting verify-cmd green | Code-review **doesn't** run your test suite — wire **bug-fix** for that |
| Economy on day one | Leave default **off** until you've seen full-quality output |
| Pasting diff into ChatGPT | Use `--pr` / `--diff-file` so findings anchor to real lines |

---

## Fail closed on review quality

- Findings outside the PR diff → **dropped**, not invented inline.
- Critic emits bad JSON → process exits non-zero; CI should fail the job.
- Docs-only or lockfile-only PRs may **skip** with an explicit message (no fake findings).

Your humans still approve merges. The bot just stops pretending it read a diff it never fetched.

---

## Next steps

- **Wire CI tonight:** [Add code-review to CI](https://kramlipi.github.io/code-review-ci/)
- **Install & keys:** [Quick Start](../quick-start.md)
- **Expert reference:** [Experts → code-review](../experts.md#code-review-pr-inline-line-comments)
- **Pilot or enterprise:** cluevion@gmail.com

Run `--dry-run` on PR `#1`. Read the JSON. Flip one switch to live. Let your reviewers wake up to fewer obvious bugs — not fewer hours of sleep.
