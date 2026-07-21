---
name: 2026-07-14-latency-budget
type: note
description: Measured p99 for fleet-api is 380ms — the planning doc's 250ms was an estimate, never re-measured.
date: 2026-07-14
tags: [signal, performance, fleet-api, measurement]
---

# Signal — fleet-api p99 is not what planning assumed

A `signals/` entry: recorded when noticed, before anyone knew whether it would matter. It
turned out to matter, so `INDEX.md` now points at it as canonical.

**Measured** 2026-07-14, 1h window, production, `p99 = 380ms`
(source: the load balancer's own histogram, not the app's self-reported timer — the two
disagreed by 90ms and the LB is the one the customer experiences).

The Q2 planning doc quotes **250ms**. That number was an estimate that was never re-measured
after the region split; it has been cited three times since as though it were measured.

**What this changes**: the canary gate in [the deploy runbook](../memory/deploy-runbook.md)
uses this figure, not the planning one. **Open**: nobody has decided whether 380ms is acceptable or a regression to
fix — this file records the measurement, not the verdict.
