<!-- FORGE-WIKI:START -->
## Wiki protocol (forge-wiki)
- Read `INDEX.md` first; open only files the index makes relevant (progressive disclosure).
- Every knowledge file: YAML frontmatter with `type` + `description` (OKF v0.1-compatible).
- Write into your OWN scoped files (e.g. `signals/<topic>_<date>_<author>.md`); never rewrite
  another author's file wholesale — propose changes via PR/handoff instead (HITL gate).
- Write content-first: push your files WITHOUT regenerating the index per write (under
  concurrent writers, per-write index commits make everyone conflict — measured). The index
  is repaired by any later `python3 bin/fw.py sync --write` (CI / session close / next reader).
  Index conflicts: `fw heal --write` — the AUTO block is a derivation, regeneration IS the merge
  resolution. Rejected push: back off with jitter and retry (a give-up stays local, republish later).
- Before research/measurement: grep the relevant section for a prior result; extend, don't fork.
<!-- FORGE-WIKI:END -->
