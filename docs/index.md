---
title: Kramlipi Documentation
description: >-
  Official documentation hub for Kramlipi projects — AI coding agents, CI
  automation experts, and developer productivity tooling.
keywords: kramlipi, documentation, ai code agent, devops, ci automation
---

# Kramlipi Docs

Welcome to the **Kramlipi** documentation hub. This site uses a **multi-project layout**:
each product has its own section with quick-start commands, CLI reference, and guides.

## Projects

| Project | Description | Quick start |
|---------|-------------|-------------|
| [**Kramlipi AI Code Agent**](kramlipi-ai-code-agent/) | Headless coding CLI with CI, SRE, and monitoring experts | [Install & run →](kramlipi-ai-code-agent/quick-start/) |

## Search

Use the search box (`Ctrl+K` / `Cmd+K`) to find commands, experts, and flags across all projects.

## Local development

```bash
cd ~/karm/kramlip-docs
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000).

## Build for production

```bash
mkdocs build
# static site in site/
```

Deploy the `site/` directory to GitHub Pages, Netlify, Cloudflare Pages, or any static host.
