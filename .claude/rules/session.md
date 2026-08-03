-->

---

### Session Backup Before Tests

<!-- [CUSTOMIZE] Adjust trigger conditions to match your test framework -->

#### Automatic Backup Trigger

At any point when tests could be run, **automatically** perform a session backup:

1. **When I recommend running tests** — **immediately before** the recommendation message
2. **When the user signals intent to start tests** — **before** running the test command

#### Why Backup
- Sessions can be forcibly terminated when tests start
- Prevents loss of conversation context, analysis results, and change history

#### How to Backup

```bash
cat > .claude/session_backup_$(date +%Y%m%d_%H%M%S).md << 'EOF'
# Session Backup - [Task Title]

## Problem
- [Issue currently being resolved]

## Changes Made
- [filename:line]
- [before/after]

## Next Steps
- [Things to verify after tests]
EOF
```

#### Important
- Perform **automatically** even without an explicit user request
- Never recommend tests without first creating a backup

---

---

### Code Writing Principles

<!-- [CUSTOMIZE] Adjust to match your project's coding conventions. Two further principles
     (locator stability, flakiness) shipped in the FH template and were deleted here: this is a
     bash/python wiki engine with no UI automation, so they had never applied. -->

Be conscious of every principle below **before** writing code — directly reduces back-and-forth where Claude rushes to create something and the user has to correct it.

#### 1. Reference Existing Code (Consistency First)

- **Reference targets**: Code with similar functionality or in the same layer within the project
- **No introducing new patterns** — follow existing patterns first; only abstract when the same pattern repeats 3+ times and needs consolidation
- **Follow framework Core/Base class patterns** — if the project has `.claude/rules/`, that hierarchy takes precedence

#### 2. Independence and Regression Prevention

- Verify that new code **does not break existing tests or functionality**
- Manage side effects (shared state, global variables, file locks)
- Use `git grep` before changes to understand the impact surface — check for unexpected callers

#### 3. Mandatory grep Before Design (Prevent Missing Own Assets)

**Before** designing a new feature or pattern:

1. grep for similar implementations in the project — reuse if already present
2. grep learnings from sibling projects in the hub (e.g., `{FH_ROOT}/`) — prevent reinventing solutions already solved elsewhere
3. Re-read the project's CLAUDE.md and rules/*.md — check for overlooked constraints

Starting design with zero cited references is a warning signal for **missing own assets**. Always present at least 1 grep result before beginning design.

---

### Rule Hierarchy and Priority

<!-- [CUSTOMIZE] Define rule sources and priority for your project -->

**Priority when conflicts arise:**
1. **Framework rules** — code patterns (non-negotiable)
2. **Test design philosophy** — "what to test" (QA Identity, etc.)
3. **Learned feedback** — rules based on user experience
4. **Operational rules** — session backup and other work processes
