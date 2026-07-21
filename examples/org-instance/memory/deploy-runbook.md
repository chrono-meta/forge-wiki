---
name: deploy-runbook
type: note
description: Production deploy sequence for the fleet-api service, including the one step that cannot be automated.
date: 2026-07-02
tags: [ops, deploy, fleet-api]
---

# Deploy runbook — fleet-api

A `memory/` entry, not a `signals/` one: this is a durable fact the team needs on every deploy,
and it is not derivable from the repo (step 3 lives in a vendor console).

1. `make release` — builds and tags. Fails closed if the changelog is unedited.
2. Canary to 5% for 20 minutes. Roll forward only if p99 stays under the budget in
   [[2026-07-14-latency-budget]].
3. **Manual**: flip the vendor feature flag in the partner console. No API exists for this —
   this is the step that keeps the runbook a document instead of a script.
4. Full rollout, then post the release note.

**Rollback**: `make rollback` is safe at any point after step 1 and before step 3. After
step 3 the vendor flag must be flipped back *first* — reversing the order double-serves
traffic for the flag TTL.
