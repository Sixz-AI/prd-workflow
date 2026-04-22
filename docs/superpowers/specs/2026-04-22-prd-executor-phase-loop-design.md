# PRD Executor — Phase 级闭环设计文档

**日期：** 2026-04-22  
**状态：** 已确认  

---

## 背景与问题

当前 `prd-executor` 的闭环粒度是 REQ 级别：

```
REQ1 讨论 → REQ1 实现 → REQ1 验证 → 用户验收 REQ1
REQ2 讨论 → REQ2 实现 → REQ2 验证 → 用户验收 REQ2
...
```

每个 REQ 完成都需要打断用户，用户体验割裂，AI 和用户互相等待。

---

## 目标

将闭环粒度从 REQ 提升到 Phase：

- **讨论阶段**：用户专心讨论，AI 专心记录
- **实现阶段**：AI 专心实现，用户不被打断
- **验收阶段**：用户一次性验收整个 Phase

---

## 完整 Phase 闭环流程

### 阶段一：讨论阶段

1. 进入 Phase，将 Phase 状态更新为 💬 讨论中
2. 按 REQ 顺序，依次对每个 REQ 调用 `superpowers:brainstorming`
3. 每个 REQ brainstorming 完成后，将结论写入 REQ 文件，替换 `⚠️ [待填充]` 占位符
4. 所有 REQ 讨论完毕后，进入汇总确认

### 阶段二：汇总确认

1. 将 Phase 状态更新为 🔍 待确认
2. AI 将本 Phase 所有 REQ 的讨论结论汇总展示给用户，格式如：
   ```
   Phase X 讨论汇总：
   - REQ-X.1 [标题]：[关键结论 2-3 条]
   - REQ-X.2 [标题]：[关键结论 2-3 条]
   - REQ-X.3 [标题]：[关键结论 2-3 条]
   ```
3. 询问用户：**"以上讨论结论是否确认？可以开始实现了吗？"**
4. 用户可以：
   - 确认 → 进入实现阶段
   - 要求调整某个 REQ 的结论 → 对该 REQ 重新 brainstorming，再次汇总确认

### 阶段三：实现阶段

1. 将 Phase 状态更新为 🚧 实现中
2. AI 按顺序自动实现每个 REQ：
   - 将 REQ 状态更新为 🚧 In Progress
   - 调用 `superpowers:test-driven-development`
   - 通过 Acceptance Criteria → 将 REQ 状态更新为内部完成（不通知用户）
3. **全程不打断用户**，所有 REQ 实现完后进入验收通知
4. 每个 REQ 实现完成后执行 commit：
   ```bash
   git add -p
   git commit -m "feat(REQ-X.X): [description]"
   ```

### 阶段四：验收通知

1. 将 Phase 状态更新为 🧪 待验收
2. AI 生成验收清单，格式如：
   ```
   Phase X 验收清单：

   ✅ REQ-X.1 [标题]
   请验证：
   - [ ] [具体验收点1，来自 AC]
   - [ ] [具体验收点2]

   ✅ REQ-X.2 [标题]
   请验证：
   - [ ] [具体验收点1]
   - [ ] [具体验收点2]
   ```
3. 通知用户："所有 REQ 已实现完毕，请按上方清单验收，并告诉我哪些通过/不通过。"

### 阶段五：用户验收

用户按清单验收，向 AI 汇报结果，例如：
- "REQ-X.1 通过，REQ-X.2 不通过（原因：xxx）"

### 阶段六：修复循环

针对不通过的 REQ：
1. AI 根据用户反馈修复，**不重新讨论，直接修复**
2. 修复完成后，AI 重新生成该 REQ 的验收清单
3. 通知用户对该 REQ 重新验收
4. 重复直到该 REQ 通过
5. 通过的 REQ 不动

### 阶段七：Phase 完成

所有 REQ 通过验收：
1. 将所有 REQ 状态更新为 ✅ Done（或 ⚠️ Partial，需写备注）
2. 将 Phase 状态更新为 ✅ 完成
3. 执行 `git push`
4. 进入下一个 Phase

---

## Phase 状态定义

在 `outline.md` 的 Phase 行新增状态列：

| Phase 状态 | Emoji | 含义 |
|-----------|-------|------|
| 未开始 | ⬜ | 默认 |
| 讨论中 | 💬 | 正在逐个讨论 REQ |
| 待确认 | 🔍 | 所有 REQ 讨论完，等用户整体确认 |
| 实现中 | 🚧 | AI 自动实现阶段 |
| 待验收 | 🧪 | 等用户验收 |
| 完成 | ✅ | 所有 REQ 通过验收，已 push |

---

## 对现有 SKILL.md 的改动

| 原步骤 | 改动 |
|-------|------|
| Step 2: Select Next REQ | 改为 Select Next Phase |
| Step 3: Requirements Confirmation（单 REQ） | 改为遍历 Phase 内所有 REQ，依次 brainstorming |
| 新增 Step 3.5 | 汇总确认：展示所有结论，等用户整体 OK |
| Step 4: Begin Implementation | 改为自动遍历 Phase 内所有 REQ，不等用户 |
| Step 5: Complete REQ | 保留内部验证逻辑，但不通知用户 |
| 新增 Step 5.5 | 验收通知：生成验收清单，通知用户验收 |
| 新增 Step 5.6 | 修复循环：只修复不通过的 REQ |
| Step 6: Check Phase Completion | 改为所有 REQ 验收通过后才 push |

---

## 关键约束

1. **讨论阶段不写任何实现代码** — 与原 HARD GATE 1 一致
2. **实现阶段不打断用户** — AI 内部完成所有 REQ 的实现和单元测试
3. **修复循环不重新讨论** — 直接修复，避免讨论反复
4. **commit 粒度不变** — 每个 REQ 一个 commit，Phase 完成后 push
5. **状态两处同步** — REQ 文件和 outline.md 都要更新
