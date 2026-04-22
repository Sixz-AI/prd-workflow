# PRD Executor Phase-Level Closed Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `prd-executor` so the closed-loop granularity is Phase-level instead of REQ-level — discuss all REQs first, then implement all autonomously, then notify the user once for UAT.

**Architecture:** The existing 6-step REQ loop in `SKILL.md` is restructured into a 7-stage Phase loop: (1) discuss all REQs, (2) show summary & wait for user confirmation, (3) implement all REQs autonomously, (4) generate UAT checklist & notify user, (5) user reports pass/fail, (6) fix-only loop for failing REQs, (7) push & move to next Phase. The Chinese reference file `SKILL.zh.md` is kept in sync as a translation.

**Tech Stack:** Markdown skill files only — no code. Changes are purely textual rewrites of `prd_executor/SKILL.md` and `prd_executor/SKILL.zh.md`.

---

## File Map

| File | Action | What changes |
|------|--------|--------------|
| `prd_executor/SKILL.md` | Modify | Full rewrite of Steps 2-6 into the new 7-stage Phase loop |
| `prd_executor/SKILL.zh.md` | Modify | Chinese translation kept in sync with new SKILL.md |

---

### Task 1: Rewrite `SKILL.md` — Steps 2 through 6

Replace the current REQ-level loop (Steps 2–6) with the new Phase-level loop. Step 1 (Initialize) and the Status Reference / Handling Requirements Changes sections stay, with additions for Phase-level statuses.

**Files:**
- Modify: `prd_executor/SKILL.md`

- [ ] **Step 1: Open the file and locate the section to replace**

The block to replace starts at `### Step 2: Select Next REQ` and ends at the last line of `### Step 6: Check Phase Completion` (before the `---` separator that precedes the Status Reference table).

- [ ] **Step 2: Replace Steps 2–6 with the new Phase loop**

Replace that entire block with:

```markdown
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
   c. When Acceptance Criteria pass internally: update REQ status to an internal marker (keep 🚧 until user UAT)
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
```

- [ ] **Step 3: Update the Status Reference table**

The existing REQ-level status table stays. Add a new Phase Status table immediately after it:

```markdown
## Phase Status Reference

| Status | Emoji | Meaning |
| ------ | ----- | ------- |
| Not Started | ⬜ | Default |
| Discussing | 💬 | Brainstorming REQs in progress |
| Pending Confirmation | 🔍 | All REQs discussed, waiting for user sign-off |
| Implementing | 🚧 | AI implementing all REQs autonomously |
| Pending UAT | 🧪 | Waiting for user verification |
| Complete | ✅ | All REQs passed UAT, pushed |
```

- [ ] **Step 4: Commit**

```bash
git add prd_executor/SKILL.md
git commit -m "feat(prd-executor): refactor to Phase-level closed loop"
```

---

### Task 2: Update `SKILL.zh.md` — Chinese Translation Sync

Rewrite `SKILL.zh.md` to match the new English `SKILL.md` exactly, in Chinese.

**Files:**
- Modify: `prd_executor/SKILL.zh.md`

- [ ] **Step 1: Replace Steps 2–6 in the Chinese file**

Locate the block from `### 第二步：选择下一个 REQ` through the end of `### 第六步：检查 Phase 完成情况`, and replace with:

```markdown
### 第二步：选择下一个 Phase

在 `outline.md` 中找到第一个状态为 ⬜（未开始）且跨 Phase 依赖项（如有）全为 ✅ 或 ⚠️ 的 Phase。

如果不存在这样的 Phase：
- 所有 Phase 均为 ✅：宣布完成，结束。
- 某个 Phase 处于 🚧、🔍 或 🧪：从对应阶段恢复。

---

### 阶段 A：讨论——依次讨论 Phase 内所有 REQ【硬性关卡 1】

1. 将 `outline.md` 中的 Phase 状态更新为 💬（讨论中）
2. 按顺序对本 Phase 内每个 REQ 执行：
   a. 打开 REQ 文件，检查 `🔍 详细需求确认` 是否仍包含 `⚠️ [待填充]`。
   b. 如果是（占位符存在）：
      - 将 REQ 文件和 `outline.md` 中的 REQ 状态更新为 💬
      - 以 REQ 内容为上下文调用 `superpowers:brainstorming`
      - 确保覆盖所有 10 个闭环维度：
        - API 闭环
        - 业务逻辑闭环
        - UI/UX 闭环
        - 错误处理闭环
        - 数据一致性闭环
        - 权限/安全闭环
        - 性能边界闭环
        - 测试闭环（单测场景 + 手动 UAT 验收点）
        - 埋点/打点闭环
        - 兼容性闭环
      - 用头脑风暴结论替换整个 `⚠️ [待填充]` 占位符块
   c. 如果否（占位符已替换）：跳过该 REQ 的头脑风暴。
3. **阶段 A 期间严禁编写任何实现代码**

---

### 阶段 B：汇总确认

1. 将 Phase 状态更新为 🔍（待确认）
2. 向用户展示所有 REQ 讨论结论汇总：

   ```
   Phase X 讨论汇总：
   - REQ-X.1 [标题]：[关键结论 2-3 条]
   - REQ-X.2 [标题]：[关键结论 2-3 条]
   - REQ-X.3 [标题]：[关键结论 2-3 条]
   ```

3. 询问用户：**"以上讨论结论是否确认？可以开始实现了吗？"**
4. 等待用户回应：
   - **确认** → 进入阶段 C
   - **要求调整某个 REQ** → 仅对该 REQ 重新执行头脑风暴，更新 REQ 文件结论，再次展示完整汇总

---

### 阶段 C：实现——自动实现所有 REQ

1. 将 Phase 状态更新为 🚧（实现中）
2. 按顺序对本 Phase 内每个 REQ 执行：
   a. 将 REQ 文件和 `outline.md` 中的 REQ 状态更新为 🚧（执行中）
   b. 以 REQ 的验收标准为测试目标调用 `superpowers:test-driven-development`
   c. 内部验收标准通过后：保持状态 🚧（等待用户 UAT）
   d. 每个 REQ 实现完成后立即 commit：
      ```bash
      git add -p   # 仅暂存实现文件，不包含调试/Mock 产物
      git commit -m "feat(REQ-X.X): [简短描述构建了什么]"
      ```
3. **阶段 C 全程不打断用户**
4. **以下情况不 commit：** 调试过程、Mock 数据、临时日志、未通过 AC 的功能

---

### 阶段 D：验收通知

1. 将 Phase 状态更新为 🧪（待验收）
2. 根据每个 REQ 的验收标准生成验收清单：

   ```
   Phase X 验收清单：

   REQ-X.1 [标题]
   请验证：
   - [ ] [AC 条目 1]
   - [ ] [AC 条目 2]

   REQ-X.2 [标题]
   请验证：
   - [ ] [AC 条目 1]
   - [ ] [AC 条目 2]
   ```

3. 通知用户："Phase X 所有 REQ 已实现完毕，请按上方清单验收，并告知哪些通过/不通过（不通过请注明原因）。"

---

### 阶段 E：用户验收

等待用户汇报结果，例如：
- "REQ-X.1 通过，REQ-X.2 不通过——[原因]"

---

### 阶段 F：修复循环（仅针对不通过的 REQ）

针对用户报告不通过的每个 REQ：
1. **不重新执行头脑风暴**——根据用户反馈直接修复
2. 修复实现
3. 仅为该 REQ 重新生成验收清单：

   ```
   REQ-X.2 [标题]——已修复，请重新验收：
   - [ ] [AC 条目 1]
   - [ ] [AC 条目 2]
   ```

4. 请用户仅对该 REQ 重新验收
5. 重复直到该 REQ 通过
6. 已通过的 REQ 不动

---

### 阶段 G：Phase 完成

当 Phase 内所有 REQ 通过用户验收后：
1. 更新每个 REQ 文件状态：
   - **✅ 已完成** — 所有验收标准经用户 UAT 验证通过
   - **⚠️ 部分完成** — 主功能可用，部分 AC 条目搁置（在备注字段写明原因）
2. 同步更新 `outline.md` 中对应行
3. 将每个 REQ 文件执行状态表中的 `最后更新` 字段更新为今日日期
4. 将 Phase 状态更新为 ✅（已完成）
5. 推送：
   ```bash
   git push
   ```
6. 返回第二步处理下一个 Phase
```

- [ ] **Step 2: Add the Chinese Phase Status table**

After the existing REQ status table, add:

```markdown
## Phase 状态说明

| 状态 | Emoji | 含义 |
| ---- | ----- | ---- |
| 未开始 | ⬜ | 默认状态 |
| 讨论中 | 💬 | 正在逐个讨论 REQ |
| 待确认 | 🔍 | 所有 REQ 讨论完，等用户整体确认 |
| 实现中 | 🚧 | AI 自动实现阶段 |
| 待验收 | 🧪 | 等待用户 UAT |
| 已完成 | ✅ | 所有 REQ 通过验收，已推送 |
```

- [ ] **Step 3: Commit**

```bash
git add prd_executor/SKILL.zh.md
git commit -m "feat(prd-executor): sync Chinese translation to Phase-level loop"
```

---

## Self-Review

**Spec coverage check:**
- ✅ 阶段一（讨论）→ Stage A
- ✅ 阶段二（汇总确认）→ Stage B
- ✅ 阶段三（实现，不打断用户）→ Stage C
- ✅ 阶段四（验收清单通知）→ Stage D + E
- ✅ 阶段六（修复循环，只修不通过的）→ Stage F
- ✅ 阶段七（Phase 完成，push）→ Stage G
- ✅ Phase 状态定义 → Phase Status Reference table
- ✅ 中文同步 → Task 2

**Placeholder scan:** No TBD, no TODO, no "similar to above".

**Consistency check:** Status emojis (💬 🔍 🚧 🧪 ✅) are used consistently across SKILL.md and SKILL.zh.md tasks.
