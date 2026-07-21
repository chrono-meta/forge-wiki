# examples/org-instance — a skeleton to copy, not a demo to read

This is a minimal, working forge-wiki instance for a fictional org. **Copy it, replace the
content, keep the shape.** Two sections, one file each, so the shape is visible at a glance.

```sh
cp -r ~/tools/forge-wiki/examples/org-instance/. your-knowledge-repo/   # copy first — it brings its own INDEX.md
cd your-knowledge-repo
fw init          # keeps the copied INDEX.md (it refuses to overwrite) and appends the AGENTS.md block
fw sync --write  # regenerate the AUTO-INDEX block + llms.txt for YOUR files
```

What each file is here to show:

- `INDEX.md` — curated **Live pointers** on top (hand-maintained: what is canonical *right now*),
  generated `AUTO-INDEX` block below. The line between them is the whole design.
- `memory/deploy-runbook.md` — a durable fact. Its own body says why it is `memory/` and not
  `signals/`: it cannot be re-derived from the repo.
- `signals/2026-07-14-latency-budget.md` — an observation recorded before anyone knew whether
  it mattered. It records the measurement and explicitly **not** the verdict.

`llms.txt` is committed here only so you can see what `sync --write` produces. In your own
repo it is a derived artifact — regenerate it, do not hand-edit it.
