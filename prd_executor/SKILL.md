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

### Step 2: Select Next Phase

Find the first Phase in `outline.md` whose status is ⬜ (not started) and whose REQ dependencies (if any cross-Phase) are all ✅ or ⚠️.

If no such Phase exists:
- If all Phases are ✅: announce completion, done.
- If a Phase is 🚧 or 🔍 or 🧪: resume that Phase from the appropriate stage below.

---

### Stage A: Discussion — Discuss All REQs in the Phase [HARD GATE 1]

1. Update Phase status in `outline.md` to 💬 (Discussing)
2. For each REQ in this Phase, in order:
   a. Open the REQ file. Check whether `🔍 详细需求确认` still contains `⚠️ [待填充]`.
   b. If YES (placeholder present):
      - Update REQ status in REQ file and `outline.md` to 💬
      - Invoke `superpowers:brainstorming` with the REQ content as context
      - Ensure ALL 10 closure dimensions are addressed:
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
      - Replace the entire `⚠️ [待填充]` placeholder block with the brainstorming conclusions
   c. If NO (placeholder already replaced): skip brainstorming for this REQ.
3. **YOU ARE FORBIDDEN FROM WRITING ANY IMPLEMENTATION CODE DURING STAGE A**

---

### Stage B: Summary Confirmation

1. Update Phase status in `outline.md` to 🔍 (Pending Confirmation)
2. Present a summary of all REQ discussion conclusions to the user:

   ```
   Phase X Discussion Summary:
   - REQ-X.1 [Title]: [2-3 key conclusions]
   - REQ-X.2 [Title]: [2-3 key conclusions]
   - REQ-X.3 [Title]: [2-3 key conclusions]
   ```

3. Ask the user: **"Does the above look correct? Ready to start implementation?"**
4. Wait for the user's response:
   - **Confirmed** → proceed to Stage C
   - **Revision requested for a specific REQ** → re-run brainstorming for that REQ only, update its conclusions in the REQ file, then re-present the full summary

---

### Stage C: Implementation — Implement All REQs Autonomously

1. Update Phase status in `outline.md` to 🚧 (Implementing)
2. For each REQ in this Phase, in order:
   a. Update REQ status in REQ file and `outline.md` to 🚧 (In Progress)
   b. Invoke `superpowers:test-driven-development` with the REQ's Acceptance Criteria as test targets
   c. When Acceptance Criteria pass internally: keep REQ status as 🚧 (updated to ✅ after user UAT)
   d. Commit immediately after each REQ:
      ```bash
      git add -p   # stage only implementation files, NOT debug/mock artifacts
      git commit -m "feat(REQ-X.X): [short description of what was built]"
      ```
3. **DO NOT interrupt the user at any point during Stage C**
4. **Do NOT commit during:** debug sessions, mock data setup, adding/removing console.log, WIP that doesn't pass AC

---

### Stage D: UAT Notification

1. Update Phase status in `outline.md` to 🧪 (Pending UAT)
2. Generate a UAT checklist from each REQ's Acceptance Criteria:

   ```
   Phase X UAT Checklist:

   REQ-X.1 [Title]
   Please verify:
   - [ ] [AC item 1]
   - [ ] [AC item 2]

   REQ-X.2 [Title]
   Please verify:
   - [ ] [AC item 1]
   - [ ] [AC item 2]
   ```

3. Notify the user: "All REQs in Phase X are implemented. Please verify each item in the checklist above and report which REQs pass or fail (with reason for failures)."

---

### Stage E: User UAT

Wait for the user to report results. Expected format (user can use any natural language):
- "REQ-X.1 pass, REQ-X.2 fail — [reason]"

---

### Stage F: Fix Loop (failing REQs only)

For each REQ the user reports as failing:
1. **Do NOT re-run brainstorming** — go straight to fixing based on user feedback
2. Fix the implementation
3. Re-generate the UAT checklist for that REQ only:

   ```
   REQ-X.2 [Title] — Fixed. Please re-verify:
   - [ ] [AC item 1]
   - [ ] [AC item 2]
   ```

4. Ask the user to re-verify only this REQ
5. Repeat until this REQ passes
6. REQs that already passed are not touched

---

### Stage G: Phase Completion

When all REQs in the Phase have passed UAT:
1. Update each REQ file status:
   - **✅ Done** — all Acceptance Criteria verified by user UAT
   - **⚠️ Partial** — main feature works, some AC items shelved (write reason in 备注 field)
2. Update the matching rows in `outline.md`
3. Update the `最后更新` field in each REQ file to today's date
4. Update Phase status in `outline.md` to ✅ (Complete)
5. Push:
   ```bash
   git push
   ```
6. Return to Step 2 for the next Phase

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

## Phase Status Reference

| Status | Emoji | Meaning |
| ------ | ----- | ------- |
| Not Started | ⬜ | Default |
| Discussing | 💬 | Brainstorming REQs in progress |
| Pending Confirmation | 🔍 | All REQs discussed, waiting for user sign-off |
| Implementing | 🚧 | AI implementing all REQs autonomously |
| Pending UAT | 🧪 | Waiting for user verification |
| Complete | ✅ | All REQs passed UAT, pushed |

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
