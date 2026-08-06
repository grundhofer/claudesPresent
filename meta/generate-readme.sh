#!/usr/bin/env bash
# Regenerate the "What's growing" table in README.md from garden/INDEX.md.
# Run from the repo root. Idempotent.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 - "$(pwd)" <<'PYEOF'
import sys, os

root = sys.argv[1]

# 1. Extract rows from INDEX.md
with open(os.path.join(root, "garden", "INDEX.md")) as f:
    lines = f.read().splitlines()

rows = []
in_table = False
for line in lines:
    if line.startswith("| # "):
        in_table = True
        continue
    if in_table:
        if line.startswith("|") and not line.startswith("|---"):
            rows.append(line)
        elif line.strip() == "":
            break

# 2. Transform to README format
readme_rows = []
for row in rows:
    cols = [c.strip() for c in row.strip("|").split("|")]
    if len(cols) < 7:
        continue
    n, slug, status, _tags, planted, _tended, gist = cols[:7]
    title = slug.replace("-", " ").title()
    # Fix common title-case issues
    title = title.replace(" Isnt ", " Isn't ")
    path = f"garden/notes/{int(n):03d}-{slug}.md"
    readme_rows.append(f"| {n} | [{title} — {gist}]({path}) | {planted} | {status} |")

# 3. Build the new block
new_block = """## What's growing

| # | Note | Planted | Status |
|---|------|---------|--------|
""" + "\n".join(readme_rows) + """

The rendered garden lives in [`index.html`](index.html) — open it in a browser, or visit the live site above. The first note has a live flock you can disturb with your cursor. The full catalogue with German companions is [`garden/INDEX.md`](garden/INDEX.md). Run `meta/generate-readme.sh` to regenerate this table from INDEX.md."""

# 4. Replace in README.md — everything from "## What's growing" to next "##"
readme_path = os.path.join(root, "README.md")
with open(readme_path) as f:
    text = f.read()

# Find start of "## What's growing" section
marker = "## What's growing"
idx = text.find(marker)
if idx == -1:
    print("ERROR: '## What\\'s growing' not found", file=sys.stderr)
    sys.exit(1)

# Find start of next "## " heading after the marker
rest = text[idx + len(marker):]
next_heading = rest.find("\n## ")
if next_heading == -1:
    print("ERROR: no next heading found after 'What\\'s growing'", file=sys.stderr)
    sys.exit(1)

# Reconstruct
new_text = text[:idx] + new_block + rest[next_heading:]

with open(readme_path, 'w') as f:
    f.write(new_text)

print(f"README.md regenerated: {len(readme_rows)} notes")
PYEOF
