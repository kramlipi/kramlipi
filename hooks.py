"""MkDocs hooks — keep GitHub Pages SEO files correct after build."""

from pathlib import Path


def on_post_build(sender=None, *, config, **kwargs):
    """Ensure .nojekyll is in the published site root.

    GitHub Actions upload-pages-artifact only ships the site/ directory.
    Without .nojekyll, Pages may run Jekyll and Google Search Console
    reports "Couldn't fetch" for sitemap.xml (browsers can still get 200).
    """
    site_dir = Path(config.site_dir)
    (site_dir / ".nojekyll").touch()
    sitemap = site_dir / "sitemap.xml"
    robots = site_dir / "robots.txt"
    if not sitemap.is_file():
        raise RuntimeError(f"missing sitemap after build: {sitemap}")
    if not robots.is_file():
        raise RuntimeError(f"missing robots.txt after build: {robots}")
