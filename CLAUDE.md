# CLAUDE.md

> `{FH_ROOT}` = wherever the hub clone lives on the reader's machine. Written as a variable, not an
> absolute path: this repo is used both personally and inside organizations, and one person's
> directory layout does not belong in an org-visible checkout. Substitute it, or ignore the hub
> rows entirely if you do not run a hub.

## Session Start

If you run the forge-harness hub, read this project's track first —
`{FH_ROOT}/tracks/forge-wiki/`, most recent by mtime — for the last work on this domain. If you do
not run a hub, skip it; nothing else here depends on one.

**Simplification guard**: When an explicit task utterance is made (e.g., "debug X code"), enter task immediately (skip onboarding). Activates once per session.

### Field Depth-Escalation Notice (advisory — once per session)

The Sonnet default covers routine field work because FH dispatches floored skills/agents at higher
tiers itself. But when **main-thread development visibly strains the session tier**, surface a
one-line escalation proposal — do not leave it to recall:

**Triggers** (any one): the same problem survives 2–3 correction loops · the work enters
architecture/design reasoning that cannot be decomposed into a dispatchable unit · the user
signals being stuck ("keeps failing", "why is this still wrong").

**Two-step ladder** (propose the cheaper rung first):
1. **Opus dispatch (sidecar)** — if the heavy reasoning packages into a unit (a design review, a
   root-cause hunt, an adversarial pass), propose dispatching it to an Opus agent: the session
   stays on Sonnet, cost stays local to the unit.
2. **Session pin** — if the work is inherently main-thread (iterative dialogue design, repeated
   whole-context reasoning), propose: *"This work demands session-level design depth — pinning
   `/model opus` is recommended. Proceeding as-is also works: dispatches still cover floored units."*
3. **No higher tier available** — common in metered API routing (a Bedrock-style Sonnet-only
   deployment) or alternative runtimes (Hermes / OpenCode-class) that don't offer higher Claude
   tiers: skip the proposal, proceed at the available tier, and **flag depth-sensitive
   deliverables with an explicit below-floor limitation note** (F2 semantics — tier-floor
   resolution, `multi_model_sidecar_strategy.md §Tier-floor`). Silent proceeding is the failure
   mode this rung exists to prevent; the note makes the deliverable a re-review candidate when a
   floor tier becomes reachable.

**Guards** (mirrors the hub's Mode D Model Notice): once per session · advisory only — **never
switch the session model autonomously** (human override is inviolable) · sessions where nothing
strains never see it — the Sonnet default stays friction-free.

**Basis**: Meta-harness mission *"easy and convenient + no setup burden + token savings"* direct implementation mechanism. Natural hub/action-leader division (single trigger in meta-harness cwd → handover to action-leader cwd).

## Asset Synergy Branching Decision (meta vs. action-leader)

When persisting new assets (memory · feedback · patterns · rules) during a session, asset location determination is required:

| Location | Nature | Examples |
|---|---|---|
| **Meta-harness side seed** | Useful as-is when installed in other projects (cross-project synergy) | User baseline propositions, environment common conventions, common action rules for all personas, session operation patterns |
| **Action-leader project side persistence** | Meaningful only in this project's domain/session context | Domain knowledge, session records, domain-specific validation loop outputs, per-project identity |

When the judgment is ambiguous, the AI **states synergy potential first** then delegates the location decision to the user.

## Knowledge Hub (forge-harness)

Persistent knowledge for this project is stored at `{FH_ROOT}/`.

- **Past work search**: First read `{FH_ROOT}/CATALOG.md`, identify related files by tags
- **Learnings/feedback originals**: `{FH_ROOT}/tracks/forge-wiki/`
- **At session end**: follow the Sync Protocol in `{FH_ROOT}/CLAUDE.md` to sync
- **When new patterns are found**: follow the Push Protocol in `{FH_ROOT}/CLAUDE.md` to feed back

<!-- [CUSTOMIZE] Replace forge-wiki with the actual project name -->
<!-- [CUSTOMIZE] If there is a domain knowledge path, add:
- **Domain knowledge**: `{FH_ROOT}/knowledge/domain/{domain}/`
-->
