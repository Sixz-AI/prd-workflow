---
name: prd-executor
description: |
  Triggers when: user says "start executing PRD", "start development", "execute breakdown",
  "implement REQ", or a Dev Agent is assigned to a breakdown directory under docs/.
  Use this skill to guide the execution of a prd_decomposer breakdown from start to finish,
  enforcing hard gates on requirements confirmation, TDD workflow, and git commit/push discipline.
---

# PRD Executor Skill

## Overview

This skill guides a Dev Agent through executing a `prd_decomposer` breakdown located at
`docs/[Feature_Name]_breakdown/`. It enforces three hard gates:

1. Requirements confirmation (brainstorming all 10 closure dimensions) before any coding
2. TDD workflow during implementation
3. Git commit per completed REQ, push per completed Phase

## When to Use

- A breakdown directory exists at `docs/[Feature_Name]_breakdown/`
- User says "start executing", "start development", "implement this PRD", "execute breakdown"
- Dev Agent is handed a breakdown directory and needs to know how to proceed

## Workflow

### Step 1: Initialize

Read `docs/[Feature_Name]_breakdown/outline.md`.
Extract:
- Total Phases and REQs
- Dependency graph between REQs
- Current status of each REQ (look at the Status column)

Announce to the user: which REQs are pending, which (if any) are already in progress or done.

### Step 2: Select Next REQ

Find the first REQ with status ⬜ (not started) whose dependencies are all ✅ Done or ⚠️ Partial.

If no such REQ exists:
- If all REQs are ✅ or ⚠️: announce completion, run `git push` for any unpushed Phase, done.
- If some REQs are 🚧 In Progress: resume the in-progress REQ from Step 3.
- If some REQs are 🚫 Shelved: skip them, find next eligible REQ.

### Step 3: Requirements Confirmation [HARD GATE 1]

Open the REQ file. Locate the `🔍 详细需求确认` section.

**Check:** Does the section still contain the `⚠️ [待填充]` placeholder text?

**If YES (placeholder present — confirmation not done):**

1. Update REQ file status from ⬜ to 💬 (Discussing)
2. Update the matching row in `outline.md` Status column to 💬
3. Invoke `superpowers:brainstorming` with the REQ content as context
4. During brainstorming, ensure ALL 10 closure dimensions are addressed:
   - API closure
   - Business logic closure
   - UI/UX closure
   - Error handling closure
   - Data consistency closure
   - Permission/security closure
   - Performance boundary closure
   - Testing closure (unit test scenarios + manual UAT checkpoints)
   - Analytics/tracking closure
   - Compatibility closure
5. After brainstorming completes, replace the entire placeholder block with the analysis conclusions
6. **YOU ARE FORBIDDEN FROM WRITING ANY IMPLEMENTATION CODE UNTIL THE PLACEHOLDER IS REPLACED**

**If NO (placeholder already replaced — confirmation done):**
Skip to Step 4.

### Step 4: Begin Implementation

1. Update REQ file status from 💬 to 🚧 (In Progress)
2. Update the matching row in `outline.md` Status column to 🚧
3. Invoke `superpowers:test-driven-development` with the REQ's Acceptance Criteria as the test targets

**Do NOT commit during:**
- Debug sessions
- Mock data setup
- Adding/removing console.log or temporary logging
- WIP features that don't yet pass acceptance criteria

### Step 5: Complete REQ [HARD GATE 2]

When the REQ's main functionality is done and acceptance criteria are met:

1. Update REQ file status:
   - **✅ Done** — all Acceptance Criteria verified by manual UAT
   - **⚠️ Partial** — main feature works, some AC items shelved (write reason in 备注 field)
   - **🚫 Shelved** — blocked entirely (write reason in 备注 field, move to next REQ)

2. Update the matching row in `outline.md` Status column to match

3. Update the `最后更新` field in the REQ file's 执行状态 table to today's date

4. Commit:
   ```bash
   git add -p   # stage only implementation files, NOT debug/mock artifacts
   git commit -m "feat(REQ-X.X): [short description of what was built]"
   ```

### Step 6: Check Phase Completion

After each commit, inspect the Phase that contains the just-completed REQ.

**All REQs in Phase are ✅ or ⚠️?**

Yes → Push:
```bash
git push
```
Then return to Step 2 for the next Phase.

No → Return to Step 2 for the next REQ in this Phase.

---

## Status Reference

| Status | Emoji | Meaning |
| ------ | ----- | ------- |
| Not Started | ⬜ | Default at decomposition time |
| Discussing | 💬 | Brainstorming in progress |
| Changed | 🔄 | Requirements modified after confirmation (update 备注 with what changed and why) |
| In Progress | 🚧 | Implementation underway |
| Done | ✅ | All Acceptance Criteria verified |
| Partial | ⚠️ | Main feature done, some AC items shelved (reason in 备注) |
| Shelved | 🚫 | Blocked, see 备注 for reason |

## Handling Requirements Changes (🔄)

If requirements change mid-execution on a REQ that is 🚧 In Progress:
1. Set status to 🔄 Changed
2. In the 备注 field, record: what changed, why, and the date
3. Update the `🎯 Requirement` and `✅ Acceptance Criteria` sections of the REQ file
4. Re-run brainstorming on the changed dimensions only
5. Resume implementation with the updated requirements

## Gotchas

1. **Never skip the placeholder check** — brainstorming surfaces edge cases the PRD missed; skipping it leads to rework
2. **Status must be updated in two places** — REQ file AND `outline.md`; both must stay in sync
3. **Commit after each REQ, push after each Phase** — do not batch commits across multiple REQs
4. **⚠️ Partial ≠ done without documentation** — a Partial REQ must have a reason in 备注 before it counts toward Phase completion
5. **🔄 Changed invalidates in-progress work** — when requirements change, re-confirm before continuing implementation
