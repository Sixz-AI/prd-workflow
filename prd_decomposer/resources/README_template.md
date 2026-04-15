# 📖 How to Use This PRD Breakdown

This directory contains the atomic business logic decomposed for **[Feature Name]**.

## Reading Order for Dev Agents
1. **Context Initialization:** Always start by reading `outline.md` to get the macro architectural view and understand the milestones.
2. **Progressive Execution:** Execute REQs sequentially within each Phase, respecting dependency order.
3. **Strict Isolation:** When working on `REQ-X.X.md`, do NOT read ahead or simultaneously process business logic from other REQs unless explicitly listed in its "Dependencies" section.

## Core Implementation Rules
- These documents describe **WHAT** to build and the exact **Business Logic** boundaries.
- As the Developer Agent, you are fully empowered to architect **HOW** to build it (e.g., choosing state management, API hooks, UI libraries).
- Before marking a REQ as complete, every item in its **Acceptance Criteria** must be manually verified.

---

## Execution Workflow

> **Before starting implementation, invoke the `prd_executor` skill.** It will guide you through the entire execution process with hard gates.

### Quick Reference: Steps for Each REQ

**Step 1 — Requirements Confirmation (required before coding)**
- Open the REQ file and locate the `🔍 Detailed Requirements Confirmation` placeholder
- Use `superpowers:brainstorming` to cover all 10 closure dimensions
- Replace the placeholder with your analysis conclusions
- Update status to 🚧 In Progress in both the REQ file and `outline.md`

**Step 2 — Implementation**
- Follow TDD workflow (`superpowers:test-driven-development`)
- No commits needed during debug / mock data / logging phases

**Step 3 — Complete REQ**
- Update status to ✅ Done or ⚠️ Partial (record shelving reason in remarks)
- Sync the Status column in `outline.md`
- Run `git commit`

### Completing a Phase
- Confirm all REQs in the Phase have a final status (✅ or ⚠️)
- Run `git push`

---

## Git Workflow

### Commit Granularity
One commit per REQ when its main feature is complete:
- Format: `feat(REQ-X.X): [short description]`
- Example: `feat(REQ-1.1): remove install-standalone popup on app close`

**Do NOT commit:**
- Temporary debug changes
- Mock data / test scaffolding
- console.log / debug logging
- Unfinished WIP code

### Push Granularity
Push after each Phase is complete:
- All REQs in the Phase must be ✅ Done or ⚠️ Partial
- Partial REQs must have a shelving reason recorded in remarks before counting as complete

### Status ↔ Git Mapping

| Action | Status Change | Git Operation |
| ------ | ------------- | ------------- |
| Start brainstorming | ⬜ → 💬 Discussing | None |
| Confirmation complete (placeholder replaced) | 💬 → 🚧 In Progress | None |
| REQ main feature done | 🚧 → ✅ / ⚠️ | `git commit` |
| All REQs in Phase done | — | `git push` |
