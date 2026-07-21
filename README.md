# forge-wiki

English · **[한국어](README.ko.md)** · **[日本語](README.ja.md)** · **[中文](README.zh.md)**

A governed markdown wiki for LLM agents — and the humans they work with.

Most agent-knowledge tools are either fully automatic memory (mem0, Zep, Letta — no
approval concept) or human curation services. forge-wiki holds the middle: **agents
write, humans gate, the index maintains itself.**

## Three design commitments

1. **Content is curated; recency is derived.** The `AUTO-INDEX` block in `INDEX.md` is
   regenerated from frontmatter + filename dates — a merge conflict there is resolved by
   regeneration, not by hand. Verified under concurrent multi-writer simulation
   (see `tests/` — N writers up to 50, corruption injection included).
2. **OKF v0.1-compatible.** Files are markdown + YAML frontmatter (`type`, `description`),
   reserved `index.md`, links as edges — readable by any OKF consumer, no lock-in.
3. **Scoped writes, gated merges.** Each writer owns its files; cross-author changes are
   proposals (PR/handoff), not silent edits. HITL is the write protocol, not a feature flag.
   The human gate exists to add **taste** — personal and organizational judgment — not to
   catch defects: functional integrity is the machine layer's job, verified by simulation
   before anything reaches a reviewer.

## Quick start

```sh
cd your-knowledge-repo
python3 bin/fw.py init          # Phase-0 audit + non-overwriting scaffold
# drop markdown files into section dirs (signals/, notes/, ...)
python3 bin/fw.py sync --write  # regenerate the recency index
python3 bin/fw.py doctor        # freshness + broken-pointer report
```

On a merge conflict in `INDEX.md`: take either side, run `fw.py heal --write`. Done.

## Your org's instance

`fw init` gives you a working index. It does not tell you *what to put in it* — that decision
is what makes the wiki yours, and no tool can make it for you.

The pairing this is built for: **a harness carries method and gates; the wiki carries your
org's context.** Neither substitutes for the other. A harness with no context landing site
re-derives the same organizational facts every session; a wiki with no harness has no gate on
what enters it.

A section axis that survived ~2 months of daily operation (981 files — the four largest
sections hold 73% of them):

| Section | Holds | Enters when |
|---|---|---|
| `memory/` | durable facts that outlive the session that found them | a fact will be needed again and is not derivable from the code |
| `tracks/<project>/` | per-project working records, accumulated | work on that project produced something worth re-reading |
| `signals/` | an observation or measurement that *may* matter later | you notice it — recorded before you know whether it pays off |
| `handoff/` | state passed between machines, sessions, or people | the next reader is not the current writer |
| `audit/` | periodic reviews on a cadence | the cadence fires, not when you feel like it |
| `digests/` | recurring external scans | an automated job lands its output |

Start with two — `memory/` and `signals/` — and let a section appear the first time a file
genuinely does not fit the existing ones. Adding a directory is cheap; **a section nobody
writes to is the signal to delete it, not to fill it.**

`examples/org-instance/` is a minimal filled-in skeleton: copy it, replace the content, keep
the shape.

## Subcommands

| cmd | does | fail direction |
|---|---|---|
| `init` | state-audit + scaffold (never overwrites) | refuses on existing files |
| `sync [--write]` | regenerate AUTO-INDEX block | dry-run by default |
| `heal [--write]` | collapse conflict markers / duplicate blocks, then sync | curated-region conflicts stay human |
| `lint` | frontmatter report | report-only, never rewrites |
| `doctor` | freshness + stale-pointer report | advisory |
| `check` | index-drift gate | exit 1 on drift (CI-blocking) |

## Status

v0.1 — extracted from ~2 months of daily operation of a private operator wiki: **981 markdown
files, commits on 50 of 57 days, multi-machine** (measured 2026-07-21 —
`git ls-files '*.md' | wc -l`; the store itself stays private). The concurrency simulation in
`tests/` is the regression anchor for every robustness claim; nothing here is asserted that
the sim did not measure.

## Distribution surfaces

- `llms.txt` is generated on every `sync --write` (derived, like the index).
- `bin/fw_mcp.py` — zero-dependency read-only MCP server (`wiki_index` / `wiki_get` /
  `wiki_search`). Reads go through MCP; writes go through git + the gate — that asymmetry
  is the write protocol, not a missing feature.
  `claude mcp add forge-wiki -- python3 <abs>/bin/fw_mcp.py <wiki_root>`

See `SPEC.md` for the full contract.
