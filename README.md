# Kramlipi Docs

Multi-project  documentation hub built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

## Projects

| Project | Path |
|---------|------|
| **Kramlipi AI Code Agent** | `projects/kramlipi-ai-code-agent/` |

## Features

- **Multi-project layout** via `mkdocs-monorepo-plugin`
- **Full-text search** (Material built-in + suggest/highlight)
- **SEO** — meta descriptions, sitemap, social cards, `robots.txt`, canonical URLs
- **Dark / light mode**

## Quick start (local)

```bash
cd ~/karm/kramlip-docs
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000).

## Build

```bash
mkdocs build
# output: site/
```

## Deploy to GitHub Pages

This repo deploys automatically on every push to `main`.

### One-time GitHub setup

1. Open **https://github.com/kramlipi/kramlipi/settings/pages**
2. Under **Build and deployment** → **Source**, choose **GitHub Actions**
3. Push to `main` (or run the **Deploy documentation to GitHub Pages** workflow manually under Actions)

### Live URL

After the first successful deploy:

**https://kramlipi.github.io/kramlipi/**

### Custom domain (optional)

1. Add a `CNAME` file in `docs/` with your domain (e.g. `docs.kramlipi.dev`)
2. Update `site_url` in `mkdocs.yml` to match
3. Configure DNS at your registrar (CNAME → `kramlipi.github.io`)
4. Enable **Enforce HTTPS** in GitHub Pages settings

## Add a new project

1. Create `projects/<project-slug>/mkdocs.yml` and `projects/<project-slug>/docs/`
2. Add to root `mkdocs.yml` nav:

   ```yaml
   nav:
     - Projects:
         - My New Project: "!include ./projects/my-new-project/mkdocs.yml"
   ```

3. Run `mkdocs serve` to verify.

## Deploy

Deploy the `site/` directory to:

- **GitHub Pages** — set `site_url` in `mkdocs.yml`, push `gh-pages` branch
- **Netlify / Cloudflare Pages** — build command `mkdocs build`, publish `site/`

Update `site_url` in `mkdocs.yml` to your production domain for correct canonical URLs and sitemap.

## Source docs

Kramlipi AI Code Agent content is derived from the product repo user docs:

- `ai-code-agent/docs/USER-MANUAL.md`
- `ai-code-agent/docs/USER-GUIDE.md`
- `ai-code-agent/docs/UNIT-TEST-COVERAGE.md`
