# prd-workflow

> Claude Code skills for end-to-end PRD execution — decompose requirements into atomic REQs, track status, enforce TDD, and ship with discipline.

---

## What Is This?

**prd-workflow** is a pair of [Claude Code](https://docs.anthropic.com/claude-code) skills that turn a messy Product Requirements Document into a structured, executable development workflow — from first read to final commit.

| Skill | Role |
| ----- | ---- |
| `prd_decomposer` | Breaks a PRD into atomic REQ documents with business logic boundaries confirmed before any code is written |
| `prd_executor` | Guides a Dev Agent through each REQ with hard gates: brainstorming → TDD → commit → push |

---

## Why Use This?

Most AI coding workflows skip the hard part: **understanding what to build before building it**.

This workflow forces:
- **Requirements confirmation** before coding (10-dimension closure checklist per REQ)
- **Status tracking** directly in each REQ file (7 states from ⬜ to ✅)
- **Git discipline** — commit per REQ, push per milestone, never commit debug noise
- **Business language only** — no file paths or function names in requirement docs

---

## Install

### macOS / Linux

```bash
git clone https://github.com/myselfwly/prd-workflow.git
bash prd-workflow/install.sh /path/to/your-project
```

### Windows (PowerShell)

```powershell
git clone https://github.com/myselfwly/prd-workflow.git
.\prd-workflow\install.ps1 -Target C:\path\to\your-project
```

Restart Claude Code after install. Both `prd_decomposer` and `prd_executor` will be available as skills.

---

## Workflow Overview

```
1. You provide a PRD document
        ↓
2. prd_decomposer asks clarifying questions (QA / Architect / PM personas)
        ↓
3. Outputs to your project:
   your-project/
   ├── .claude/skills/prd_executor/    ← auto-installed
   └── docs/[feature]_breakdown/
       ├── README.md                   ← execution guide + git rules
       ├── outline.md                  ← milestone overview with Status column
       └── reqs/
           ├── REQ-1.1.md              ← status + 10-dimension confirmation placeholder
           └── REQ-X.X.md
        ↓
4. prd_executor picks up the breakdown and works REQ by REQ:
   - Brainstorm (HARD GATE — no code until confirmed)
   - TDD implementation
   - git commit per REQ, git push per milestone
```

---

## REQ Status Lifecycle

| Emoji | Status | Meaning |
| ----- | ------ | ------- |
| ⬜ | Not Started | Default at decomposition time |
| 💬 | Discussing | Brainstorming in progress |
| 🔄 | Changed | Requirements modified mid-execution |
| 🚧 | In Progress | Implementation underway |
| ✅ | Done | All acceptance criteria verified |
| ⚠️ | Partial | Main feature done, some items shelved (reason recorded) |
| 🚫 | Shelved | Blocked — reason recorded in remarks |

---

## Requirements Confirmation Checklist

Before any REQ can enter 🚧 In Progress, the Dev Agent must confirm all 10 closure dimensions:

1. API closure
2. Business logic closure
3. UI/UX closure (all states: loading / empty / error / success)
4. Error handling closure
5. Data consistency closure
6. Permission / security closure
7. Performance boundary closure
8. Testing closure (unit tests + manual UAT)
9. Analytics / tracking closure
10. Compatibility closure

---

## File Structure

```
prd-workflow/
├── install.sh                              # macOS/Linux installer
├── install.ps1                             # Windows installer
├── prd_decomposer/
│   ├── SKILL.md                            # English (used by AI)
│   ├── SKILL.zh.md                         # Chinese reference translation
│   ├── resources/
│   │   └── README_template.md              # Breakdown README template
│   └── scripts/
│       ├── generate_readme.sh              # macOS/Linux
│       └── generate_readme.ps1             # Windows
└── prd_executor/
    ├── SKILL.md                            # English (used by AI)
    └── SKILL.zh.md                         # Chinese reference translation
```

---

## Requirements

- [Claude Code](https://docs.anthropic.com/claude-code) (any platform)
- [superpowers](https://github.com/anthropics/claude-code-superpowers) plugin (for `superpowers:brainstorming` and `superpowers:test-driven-development`)

---

## License

MIT
