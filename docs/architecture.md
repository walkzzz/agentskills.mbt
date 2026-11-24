# 架构设计（agentskills.mbt 0.2.0）

> 范围：`walkzzz/agentskills.mbt` —— SKILL.md 标准技能运行时的 MoonBit 全量移植（上游 UCToo/agentskills-runtime，仓颉）。
> 本文描述 workspace 结构、三层执行模型、包边界与关键决策；数字口径见 [TEST_REPORT.md](TEST_REPORT.md)。

## 1. workspace 结构

`moon.work` 双成员：

| 成员 | 内容 |
| --- | --- |
| `agentskills`（主模块） | F01–F09 + F14 + F15：`skill` / `rag` / `auth` / `rbac` / `compactor` / `storage` / `storage_io` / `storage_pg` / `sandbox` / `sandbox_js` / `server` / `cli` / `tooling_bridge` / `playground` + 3 个 examples |
| `verify` | fixture 资产 + 差分层：`verify`（known_failure 隔离、冻结期望）+ `proof`（moon prove 契约核） |

`playground` 为浏览器演示导出层（`pkgtype(kind: "foreign_library")`，12 个 `#export_name` 非 raise 函数）。

## 2. 三层执行模型

```
      应用面（CLI / Server / Examples）
                 │
      运行时壳（cli/ · server/ · examples/）—— IO、时钟、密钥由调用方注入
                 │
      Kernel 纯函数域（skill/ rag/ auth/ rbac/ compactor/ storage/ sandbox/ tooling_bridge）
                 │
      GB/Z 185 协议栈（独立仓 gbz185.mbt；tooling_bridge 经 ToolDescriptor 单源桥接）
```

规则：

- **Kernel 域无 IO、无时钟、无全局状态**——因此可在 js / wasm / wasm-gc 直接运行（本仓 `playground` 即证明）；
- 运行时壳承担副作用；「有状态」与「纯函数」彻底分离，组合失败即 fail-fast；
- 与国标协议栈的交叉仅在 `tooling_bridge`（ToolDescriptor 单源模型），不复制协议语义。

## 3. 包职责与依赖方向

| 包 | 职责 | 关键依赖 |
| --- | --- | --- |
| `skill` | SKILL.md 解析（moonyaml）、manifest 校验、注册表状态机 | moonyaml |
| `rag` | BM25 检索（MoonRetrieve）+ RRF 融合 | MoonRetrieve |
| `rbac` | 三级敏感授权 + 单调审计 | 无 |
| `compactor` | 确定性压缩 + Unicode 安全截断 | 无 |
| `auth` | bcrypt 口令 + HS256 JWT | mooncred / mooncrypt |
| `storage` / `storage_io` / `storage_pg` | 内存 / JSONL / async 文件 / PostgreSQL | async / postgres |
| `sandbox` / `sandbox_js` | 燃料计量契约核 / js WebAssembly 执行器 | 无 / js 目标 |
| `server` | HTTP 契约 + Router + SSE 编码 | 无（sans-I/O） |
| `tooling_bridge` | SkillTool → GB/Z 185.7 ToolDescriptor / MCP 条目 | gbz185 `tooling` |
| `playground` | 浏览器演示导出（12 个非 raise 函数） | 上述 Kernel 包 |

依赖单向：`playground → skill/rag/rbac/compactor/tooling_bridge`；`tooling_bridge → gbz185/tooling`；Kernel 包之间无环。

## 4. 关键设计决策

| 决策 | 说明 | 代价 / 边界 |
| --- | --- | --- |
| **Kernel 纯函数域** | 无 IO 依赖，便于跨目标与属性测试 | 副作用须由壳层注入 |
| **注册表 fail-fast** | 同名注册直接 Err（无 last-wins） | 覆盖需显式 unregister |
| **渐进加载状态机** | `LoadLevel::Metadata → FullyLoaded`；`promote` 幂等 | 正文消费属运行时壳 |
| **工具单源** | `SkillTool` → `ToolDescriptor` → `to_mcp_entry`（MCP 视图） | 新增工具面须经该映射 |
| **Unicode 安全截断** | 按 codepoint 计数与截断（`total_chars` 同口径） | 不做字节级截断 |
| **有界返回** | `rrf_fuse_top` 为 `rrf_fuse` 的精确前缀 | 不改变排序语义，非渐近优化 |
| **差分冻结** | `verify` 以 42 个上游 SKILL.md 冻结期望；1 例登记为 known_failure（BUG-001） | 分歧修复后断言自动复活 |

## 5. 排序语义（重要）

MoonBit 的 `Compare for String` 是 **shortlex（先长度、后逐字符）**：

- `SkillRegistry::names()` 返回 shortlex 确定性顺序；
- 同长度名称按字典序（如 `beta` < `zeta`）；
- 需要严格字典序时请自定义比较，不要假设 `sort()` 是字典序。

## 6. 数据流（演示与生产同源）

1. **解析**：`parse_skill_md` → `(SkillManifest, body)`；`validate` 校验契约；
2. **注册**：`SkillRegistry::register(manifest, Metadata)` → `promote` 升格；
3. **检索**：`RagIndex::add/search`（BM25）→ 多路排名 → `rrf_fuse` / `rrf_fuse_top`；
4. **压缩**：`compact(keep_recent)` → `fit_budget(max_chars)` → `total_chars` 诊断；
5. **授权**：`can_access(role, sensitivity)` → `Auditor::record`（单调 seq）；
6. **工具**：`SkillTool` → `to_descriptor` → 注册进 gbz185 `ToolRegistry` → `to_mcp_entry` 暴露 MCP 视图。

## 7. 不做的部分

- MQ 分发、国密互联安全层（属 gbz185 路线图）；
- CLI 子命令 argv（工具链限制，GAP-1）；
- wasmoon JIT 完整集成（GAP-7，当前为 js WebAssembly 执行器）。