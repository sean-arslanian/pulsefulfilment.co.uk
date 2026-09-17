#!/usr/bin/env python3
"""Pre-deploy checks for site/.

Fails (exit 1) if any of these are wrong:
  - an internal href/src points at a file or page that does not exist
  - sitemap.xml lists a page that does not exist, or misses one that does
  - a .htaccess 301 target points at a page that does not exist
  - any page references the .com host instead of .co.uk
Run from anywhere: python3 scripts/check-site.py
"""
import os
import re
import sys
import urllib.parse

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "site")
ROOT = os.path.normpath(ROOT)
CANONICAL = "https://pulsefulfilment.co.uk"
problems = []


def page_exists(path):
    """True if /path resolves to a file or a folder with index.html."""
    target = os.path.join(ROOT, path.lstrip("/"))
    return os.path.isfile(target) or os.path.isfile(os.path.join(target, "index.html"))


html_files = []
for dirpath, _, files in os.walk(ROOT):
    for name in files:
        if name.endswith(".html"):
            html_files.append(os.path.join(dirpath, name))

# 1. Internal links and assets
seen = set()
for path in html_files:
    html = open(path, encoding="utf-8").read()
    rel = os.path.relpath(path, ROOT)
    if "pulsefulfilment.com" in html:
        problems.append(f"{rel}: references pulsefulfilment.com (should be .co.uk)")
    for m in re.finditer(r"""(?:href|src)=["']([^"']+)["']""", html):
        url = m.group(1)
        if url.startswith(("http", "mailto:", "tel:", "#", "data:", "//")):
            continue
        url = urllib.parse.unquote(url.split("#")[0].split("?")[0])
        if not url:
            continue
        if url.startswith("/"):
            ok = page_exists(url)
        else:
            ok = os.path.exists(os.path.normpath(os.path.join(os.path.dirname(path), url)))
        if not ok and (rel, url) not in seen:
            seen.add((rel, url))
            problems.append(f"{rel}: broken link {url}")

# 2. Sitemap vs pages on disk
sitemap = open(os.path.join(ROOT, "sitemap.xml"), encoding="utf-8").read()
listed = set()
for loc in re.findall(r"<loc>([^<]+)</loc>", sitemap):
    if not loc.startswith(CANONICAL):
        problems.append(f"sitemap.xml: {loc} is not on {CANONICAL}")
        continue
    path = loc[len(CANONICAL):] or "/"
    listed.add(path.rstrip("/") or "/")
    if not page_exists(path):
        problems.append(f"sitemap.xml: {loc} has no page on disk")

on_disk = set()
for path in html_files:
    rel = "/" + os.path.relpath(path, ROOT).replace(os.sep, "/")
    if rel == "/404.html":
        continue
    if rel.endswith("/index.html"):
        rel = rel[: -len("/index.html")] or "/"
    on_disk.add(rel)
for missing in sorted(on_disk - listed):
    problems.append(f"sitemap.xml: page {missing} is not listed")

# 3. .htaccess redirect targets
htaccess = open(os.path.join(ROOT, ".htaccess"), encoding="utf-8").read()
for m in re.finditer(r"^RewriteRule\s+\S+\s+(/[^\s$]*)\s+\[R=301", htaccess, re.M):
    target = m.group(1)
    if not page_exists(target):
        problems.append(f".htaccess: 301 target {target} has no page on disk")

if problems:
    for p in problems:
        print("FAIL", p)
    print(f"{len(problems)} problem(s) found")
    sys.exit(1)

print(f"OK: {len(html_files)} pages, {len(listed)} sitemap entries, no broken links or redirect targets")
