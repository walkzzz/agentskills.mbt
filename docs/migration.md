# 迁移指南（迁入 agentskills.mbt 0.2.0）

> 适用：从「手写技能加载器 / 其他语言运行时 / 上游仓颉实现」迁到本库。

## 1. 依赖与包选择

```bash
moon add walkzzz/agentskills.mbt@0.2.0
moon update
```

Kernel 包（可独立使用，无 IO）：

| 需求 | 包 |
| --- | --- |
| SKILL.md 解析与校验 | `skill` |
| 检索与融合 | `rag` |
| 授权与审计 | `rbac` |
| 上下文压缩 | `compactor` |
| 工具单源桥接 | `tooling_bridge`（需 gbz185） |

运行时包（按需）：`auth` / `storage` / `storage_io` / `storage_pg` / `sandbox` / `sandbox_js` / `server` / `cli`。

## 2. 迁移步骤

1. **把技能文件映射到 manifest**：用 `parse_skill_md` 取代自有 YAML 解析；保留正文用于运行时壳消费。
2. **替换注册逻辑**：用 `SkillRegistry::register`（validate 先行、重名 fail-fast）取代 last-wins 表；需要覆盖时显式 `unregister`。
3. **接入渐进加载**：初始注册用 `Metadata`；需要正文/资源时 `promote(name)` 升格，`level_of` 观测。
4. **替换检索**：`RagIndex::add/search` + `rrf_fuse`（多路排名融合）；只需前 N 条时用 `rrf_fuse_top`（精确前缀）。
5. **替换上下文压缩**：`compact(keep_recent)` + `fit_budget(max_chars)`；用 `total_chars` 做预算诊断。
6. **替换授权**：`can_access(role, sensitivity)`；审计用 `Auditor::record`，观测 `denied_count` / `last`。
7. **工具面**：实现 `SkillTool`，经 `to_descriptor` 注册进 gbz185 `ToolRegistry`，用 `to_mcp_entry` 暴露 MCP 条目。
8. **传输/存储**：按需选择 `Storage` 实现（内存/JSONL/PG）；同步 trait 与 PG async API 的差异见 GAP-8。

## 3. 行为对齐检查表

| 检查项 | 期望 |
| --- | --- |
| 校验边界 | name ≤64、description ≤1024；空值拒绝 |
| 重名 | 第二次注册返回 Err（不覆盖） |
| 升格 | `promote` 幂等；未注册返回 Err |
| 名称清单 | `names()` 为 shortlex（先长度后逐字符） |
| 截断 | 按 codepoint，多字节不劈开；截断追加 `…` |
| 压缩 | system 全保留；旧对话折叠为计数占位 |
| RRF | 分数降序；同分 doc_id 升序；`top_n` 为全量前缀 |
| 授权 | `max_sensitivity(role).rank() >= sensitivity.rank()` |
| MCP 条目 | 含 name / description / inputSchema（单源） |

## 4. 常见坑

1. **YAML 类型错误**：frontmatter 字段类型不符会返回 Err（不是静默忽略）；请先校验上游样本。
2. **`String::length()` 与 codepoint**：预算统计请用 `total_chars` / `truncate_chars`，不要用字节数。
3. **shortlex**：`names()` 不是严格字典序；需要严格顺序时自行 `sort_by`。
4. **js 执行器无 gas 钩子**：`sandbox_js` 对 `gas<=0` 判 OutOfGas，不做逐指令计量（GAP-7）。
5. **PG 只提供 async API**：不要硬套同步 `Storage` trait（GAP-8）。
6. **known_failure**：差分测试中登记的分歧会在修复后自动复活；删除登记前先确认上游行为。

## 5. 从 0.1.1 升级（0.1.1 → 0.2.0）

- 新增 API（无破坏）：`SkillManifest::has_license/compatibility_count`、
  `SkillRegistry::is_registered/level_of/names/promote/unregister`、
  `Role::rank/Sensitivity::rank/label`、`Auditor::denied_count/last`、
  `RagIndex::is_empty`、`rrf_fuse_top`、`compactor::total_chars`、`tooling_bridge::to_mcp_entry`。
- 无删除或改名；`can_access` 语义不变（内部改为枚举 rank 方法）。

## 6. 回滚

将依赖钉回 `0.1.1` 即可；`playground` 与 `docs/` 不参与库契约，不影响下游编译。