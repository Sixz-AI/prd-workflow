---
name: prd-decomposer
description: |
  Triggers when: user mentions "PRD", "requirements", "break down requirements", 
  "split PRD", or provides a long feature document. Use this skill to first clarify 
  ambiguous requirements, confirm business logic and boundaries, and then decompose 
  the finalized PRD into atomic frontend tasks focusing purely on BUSINESS LOGIC.
---

# PRD Decomposer Skill

## Overview

This skill transforms complex, lengthy PRDs (Product Requirement Documents) into purely structural documentation (a set of Markdown files) defining optimally sized requirement units (REQs).

**Core Focus**: A high-quality decomposition focuses on **WHAT** we are building and the underlying **Business Logic**, never on *HOW* to code it. The Agent proactively identifies ambiguous logic, confirms boundaries, and breaks the logic into atomic manageable pieces without dictating implementation methods to downstream agents.

## When to Use

- User provides a new PRD or feature requirement document
- The business logic needs to be pressure-tested and clarified before development
- Requirements need to be broken down into atomic business logic requirement units (REQs)

## Core Principles

> **1. Clarify First, Decompose Later**
> Never blindly parse a poorly defined PRD. Always interactively force the user to confirm ambiguous logic, edge cases, and boundaries first.
>
> **2. Code Exploration as INPUT, Not OUTPUT**
> When the user provides a codebase reference (e.g., project path), **thoroughly explore the code** to understand existing functionality, current behavior, and business context. This understanding is your INPUT — it helps you describe the current state accurately, identify affected features, and fill in PRD gaps. However, the OUTPUT must be expressed in **pure business language**. NEVER include file paths, line numbers, variable names, function names, or architectural patterns in the generated documents. The downstream Dev Agent will explore the code themselves.
>
> **3. Focus on Business Logic (What, Not How)**
> Requirement breakdown is strictly about decomposing **Business Logic**, not dictating implementation. Clearly explain WHAT the feature is and WHAT the business rules are. NEVER tell the downstream AI "how to code it" (e.g., do not suggest using arrays, specific hooks, or CSS frameworks unless strictly mandated by the PRD). Do NOT create REQs that are purely about code refactoring or architectural migration — if it's not a business behavior change, it doesn't belong in the breakdown.
>
> **4. Current State → Target State → Delta**
> Every REQ must clearly describe: what exists today (现状), what the product wants (需求), and the precise difference (变更: add/modify/remove). This framing helps the downstream Dev Agent understand the full business context and make informed implementation decisions.
>
> **5. File-Based Progressive Disclosure**
> Output the breakdown as a structured directory of files, starting with an outline index.

## Workflow

### Step 1: Codebase Exploration *[Silent Phase]*
When the user provides a codebase reference (project path, README, etc.), **thoroughly explore the code FIRST** before asking any questions. The goal is to build a deep understanding of:
1. **Current business behavior** — What does the existing feature do from a user's perspective?
2. **Affected features** — Which existing features will be impacted by the new requirement?
3. **Business boundaries** — Where does the current logic start and end? What are the existing conditions, edge cases, and special rules?
4. **Gaps in the PRD** — What business details does the PRD assume or omit that become obvious from reading the code?

This exploration is **silent** — do not output code details to the user. Use the understanding internally to power the next steps.

### Step 2: Multi-Role PRD Analysis & Boundary Clarification *[Interactive Phase]*
With codebase understanding in hand, simulate a multi-agent expert panel to review the business logic:
1. **QA Engineer Persona:** Identify missing unhappy paths, empty states, loading states, specific permissions, and unhandled edge cases — informed by what the current system actually handles.
2. **Senior Architect Persona:** Evaluate data flow boundaries, system interactions, and potential race conditions — informed by how the current system is structured.
3. **Product Manager Persona:** Confirm the overarching core business loop, ensure no user value is lost, and verify the relationship between new requirements and existing features.

**[HARD GATE 1: Anti-Rationalization Checklist]**
You MUST output a checklist explicitly confirming you have completed the multi-perspective review. Do not rationalise skipping this.
**Ask Questions:** Consolidate the findings from these 3 personas and present the most critical ambiguities to the user. Frame questions in business language (not code language). **You are strictly FORBIDDEN from generating any files or proceeding until the user explicitly approves.**

### Step 3: Planning Quality Review & Requirement Consolidation
Integrate the user's supplementary answers.
**[HARD GATE 2: Planning Quality Review]**
Before moving to the decomposition phase, perform a rigorous quality review of the consolidated requirements:
1. Ensure the business logic is MECE (Mutually Exclusive, Collectively Exhaustive).
2. Verify that every change (add/modify/remove) has a clear "current state" and "target state".
3. Confirm that acceptance criteria are defined in terms of observable user behaviors, not implementation details.
Garbage in, garbage out — if the business logic is still vague, loop back to Step 2.

### Step 4: Global Scan & Outline Generation

**[TARGET PROJECT SETUP]**
Before generating any files, ask the user for the target project path — the project where development will happen:

> "请提供目标项目的绝对路径（prd_executor skill 和 breakdown 文档将直接输出到该项目）。如果未提供，将输出到当前工作区的 `docs/` 目录下。"

Once confirmed, locate the installed skills and run the setup.

**macOS / Linux:**

```bash
# Skills are installed in this project's .claude/skills/
# (run install.sh from the cloned repo to set this up first)
SKILLS_DIR="$(pwd)/.claude/skills"
EXECUTOR_SRC="$SKILLS_DIR/prd_executor"
SCRIPTS_DIR="$SKILLS_DIR/prd_decomposer/scripts"

# 1. Copy prd_executor into the target project (skip if already exists)
TARGET_SKILLS="[TARGET_PROJECT]/.claude/skills"
if [ ! -d "$TARGET_SKILLS/prd_executor" ]; then
  mkdir -p "$TARGET_SKILLS"
  cp -r "$EXECUTOR_SRC" "$TARGET_SKILLS/prd_executor"
  echo "✓ prd_executor installed → $TARGET_SKILLS/prd_executor"
fi

# 2. Initialize breakdown directory and README
bash "$SCRIPTS_DIR/generate_readme.sh" \
  "[TARGET_PROJECT]/docs/[Feature_Name]_breakdown" "[Feature Name]"
```

**Windows (PowerShell):**

```powershell
# Skills are installed in this project's .claude/skills/
$SkillsDir   = Join-Path (Get-Location) ".claude\skills"
$ExecutorSrc = Join-Path $SkillsDir "prd_executor"
$ScriptsDir  = Join-Path $SkillsDir "prd_decomposer\scripts"

# 1. Copy prd_executor into the target project (skip if already exists)
$TargetSkills  = "[TARGET_PROJECT]\.claude\skills"
$executorDest  = Join-Path $TargetSkills "prd_executor"
if (-not (Test-Path $executorDest)) {
  New-Item -ItemType Directory -Force -Path $TargetSkills | Out-Null
  Copy-Item -Recurse $ExecutorSrc $executorDest
  Write-Host "✓ prd_executor installed → $executorDest"
}

# 2. Initialize breakdown directory and README
& (Join-Path $ScriptsDir "generate_readme.ps1") `
  -TargetDir "[TARGET_PROJECT]\docs\[Feature_Name]_breakdown" `
  -FeatureName "[Feature Name]"
```

All subsequent output (outline.md, reqs/) goes into `[TARGET_PROJECT]/docs/[Feature_Name]_breakdown/`.

Generate `[TARGET_PROJECT]/docs/[Feature_Name]_breakdown/outline.md` as the macro outline index.
The outline should start with a **Current State Summary** (existing business behavior, described from a user perspective) and a **Change Overview** (what is being added, modified, removed at the feature level). Then divide into 2-4 Milestones.

### Step 5: Generate Individual REQ Documents
Create a `[TARGET_PROJECT]/docs/[Feature_Name]_breakdown/reqs/` directory. For each REQ, generate a highly isolated Markdown file (e.g., `REQ-1.1.md`) following the **Current State → Requirement → Changes → Acceptance Criteria** structure.

Each REQ must describe a **business behavior change**, not a code refactoring task. If a REQ doesn't change what the user sees or experiences, it doesn't belong in the breakdown.

**[HARD GATE 3: Verification-before-completion]**
Every REQ MUST include:
1. The `📊 执行状态` section with default status ⬜ 未开始
2. The `🔍 详细需求确认` placeholder (must not be pre-filled at decomposition time — it is filled during execution)
3. Acceptance criteria written as "User does X → System shows/does Y" pairs. Include both happy paths and unhappy paths. The downstream Dev Agent must provide verifiable proofs (e.g., screenshots, test execution logs, observable behavior descriptions) before claiming a REQ is completed.

---

## Output Document Structure

After the clarification step, generate the following file structure in the target project:

```text
[TARGET_PROJECT]/docs/[Feature_Name]_breakdown/
├── README.md            # Execution guide and Git workflow rules (auto-generated)
├── outline.md           # Macro outline index with Status column
└── reqs/                # Independent, atomic requirement units
    ├── REQ-1.1.md       # Includes 执行状态 + 需求确认 placeholder
    └── REQ-X.X.md
```

### 1. Core Outline File (`[Feature_Name]_breakdown/outline.md`)

```markdown
# 📦 Business Overview & Breakdown Outline
> [A one-sentence summary of the core product and business logic]

## 📋 Current State (现状)
> [Describe the existing business behavior from a USER perspective. What does the user see and experience today? Do NOT include code details — describe it as if explaining to a product manager.]

## 🎯 Change Overview (变更总览)
| Type | Description |
| ---- | ----------- |
| ➕ Add | [What new business behavior is being introduced] |
| ✏️ Modify | [What existing behavior is changing and how] |
| ➖ Remove | [What existing behavior is being removed] |

## 🚩 Phase 1: [Module Name]

| REQ ID | Brief Description | Status | Dependencies | Detailed Context |
| ------ | ----------------- | ------ | ------------ | ---------------- |
| REQ 1.1 | [Brief] | ⬜ 未开始 | None | [REQ-1.1.md](./reqs/REQ-1.1.md) |
| REQ 1.2 | [Brief] | ⬜ 未开始 | REQ 1.1 | [REQ-1.2.md](./reqs/REQ-1.2.md) |
...
```

### 2. Individual REQ File (`docs/[Feature_Name]_breakdown/reqs/REQ-X.X.md`)

```markdown
# 📝 REQ X.X: [Specific Requirement Name]
- **💻 Module:** [Phase Name]
- **🔗 Dependencies:** [REQ X.X or "None"]

---

## 📊 执行状态

| 字段 | 内容 |
| ---- | ---- |
| **状态** | ⬜ 未开始 |
| **最后更新** | — |
| **备注** | — |

**状态说明：**
- ⬜ 未开始
- 💬 需求讨论中（正在进行头脑风暴）
- 🔄 需求变更（原需求有调整，见备注）
- 🚧 执行中
- ✅ 已完成
- ⚠️ 部分完成（主功能完成，部分搁置，见备注）
- 🚫 已搁置（见备注说明原因）

---

## 🔍 详细需求确认

> ⚠️ **[待填充]** 在开始编码前，使用 `superpowers:brainstorming` 对本 REQ
> 进行头脑风暴，覆盖以下所有维度，完成后将本占位符替换为详细分析结论。
> **占位符存在 = 需求确认未完成，禁止开始编码。**
>
> 1. **API 闭环** — 接口存在/需新增？入参出参完整？错误码覆盖？鉴权方式？
> 2. **业务逻辑闭环** — 状态机完整？所有条件分支？幂等性？并发场景？
> 3. **UI/UX 闭环** — loading/empty/error/success 全状态？所有交互路径？
> 4. **错误处理闭环** — 失败/超时/权限不足时用户看到什么？如何恢复？
> 5. **数据一致性闭环** — 操作后哪些缓存需刷新？哪些组件会联动？
> 6. **权限/安全闭环** — 不同角色可见性和可操作性？输入是否需要校验？
> 7. **性能边界闭环** — 大数据量处理？防抖/节流？分页？
> 8. **测试闭环** — 单测场景覆盖所有业务分支？验收标准能手动逐条验证？
> 9. **埋点/打点闭环** — 哪些行为需上报？事件名和参数已定义？
> 10. **兼容性闭环** — 目标系统/版本范围？向后兼容性？

---

## 📋 Current State (现状):
[Describe what the user currently sees/experiences for this specific aspect. Use business language only.]

## 🎯 Requirement (需求):
[Describe what the product wants this to become. Focus on the desired user experience and business rules.]

## 🔄 Changes (变更):
- **➕ Add:** [New business behavior to introduce. Describe WHAT, not HOW.]
- **✏️ Modify:** [Existing behavior to change. Describe the before → after from user perspective.]
- **➖ Remove:** [Existing behavior to remove. Describe what the user will no longer see/experience.]

(Only include the change types that apply to this REQ.)

## ✅ Acceptance Criteria (验收标准):
- [ ] [User action] → [Observable expected result]
- [ ] [User action under edge case] → [Observable expected result]
- [ ] [Unhappy path action] → [Observable expected result]

> **CRITICAL:** Every criterion must be written as "User does X → System shows/does Y". Include both happy paths and unhappy paths. No code-level checks — only observable business behavior.
```

---

## Gotchas

1. **Don't Dictate Code** - Never include file paths, variable names, function names, line numbers, or architectural patterns in the output documents. Speak clearly about the business rules and let the dev-agent design the code.
2. **Don't Jump the Gun!** - Never generate documents before the user clarifies ambiguous business logic.
3. **Context Isolation** - Ensure `REQ-X.X.md` **NEVER** contains business logic from other unrelated REQs to prevent the "Lost in the Middle" phenomenon.
4. **Code is INPUT, Not OUTPUT** - Codebase exploration helps you understand the current state accurately, but the generated documents must describe everything in business/product language. If you find yourself writing a variable name or file path in the output, you're doing it wrong.
5. **No Pure Refactoring REQs** - Every REQ must describe a change in user-visible business behavior. If a REQ is purely about "migrating code" or "restructuring internals" with no behavior change, it should NOT exist as a separate REQ.
6. **Current State Must Be Accurate** - The "Current State" section in each step is based on your code exploration. Describe it as observable user behavior (e.g., "when the user closes the app, a popup appears offering..."), not as code structure (e.g., "the CloseBtn onClick handler checks shouldShow...").
