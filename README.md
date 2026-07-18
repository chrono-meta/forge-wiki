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

v0.1 — extracted from a year of daily operation of a private operator wiki (900+ files,
multi-machine). The concurrency simulation in `tests/` is the regression anchor for every
robustness claim; nothing here is asserted that the sim did not measure.

## Distribution surfaces

- `llms.txt` is generated on every `sync --write` (derived, like the index).
- `bin/fw_mcp.py` — zero-dependency read-only MCP server (`wiki_index` / `wiki_get` /
  `wiki_search`). Reads go through MCP; writes go through git + the gate — that asymmetry
  is the write protocol, not a missing feature.
  `claude mcp add forge-wiki -- python3 <abs>/bin/fw_mcp.py <wiki_root>`

See `SPEC.md` for the full contract.
