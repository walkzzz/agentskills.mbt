# 方案对比（agentskills.mbt 0.2.0）

> 对比对象：在 MoonBit 中实现「SKILL.md 技能运行时」的常见替代路线，以及上游仓颉实现。
> 只陈述设计差异与已知边界，不对未实测的性能/生态作断言。

## 1. 对比矩阵

| 维度 | agentskills.mbt | 手写 Python/TS 运行时 | 直接调用上游仓颉运行时 | 通用 agent 框架（自带技能层） |
| --- | --- | --- | --- | --- |
| SKILL.md 标准解析 | moonyaml + 契约校验 + 42 fixtures 差分 | 依赖第三方 YAML | 有 | 视框架 |
| 渐进加载状态机 | `Metadata → FullyLoaded`，fail-fast | 常见 last-wins | 有 | 视框架 |
| 检索 | BM25（MoonRetrieve）+ RRF | 依赖外部向量库 | 视上游 | 常见向量检索 |
| 压缩/截断 | 确定性裁剪 + codepoint 安全 | 需自建 | 视上游 | 视框架 |
| RBAC | 三级静态策略 + 单调审计 + 契约证明 | 需自建 | 视上游 | 视框架 |
| 工具桥接 | SkillTool → GB/Z 185.7 ToolDescriptor → MCP 视图 | 各自为政 | 与国标无桥 | 框架自有 |
| 跨目标 | native / js / wasm / wasm-gc 同源 | 单生态 | 仓颉生态 | 视框架 |
| 组件导出 | WIT Component Model（`skill-api`） | 无 | 无 | 无 |
| 依赖面 | Kernel 零 mooncakes 依赖；IO/DB/密码学按需 | 中-高 | 视上游 | 高 |

## 2. 何时选本项目

- 需要在 MoonBit 项目中使用 **SKILL.md 标准**，并希望技能域与 IO 严格分离（可在 js/wasm 复用）；
- 需要与 **GB/Z 185-2026** 国标协议栈联动（工具单源、MCP 视图）；
- 需要机器可查的契约核（燃料账本、占位计数、RBAC 授权）与变异守护。

## 3. 何时不选

- 需要成熟向量检索/agent 编排全家桶——本项目只做技能运行时，不含 agent 规划器；
- 需要开箱即用的 MQ 分发或国密安全层——属 gbz185 路线图；
- 目标运行时是仓颉/其他语言生态——可直接使用上游实现。

## 4. 与上游的关系

协议与技能语义来自上游 agentskills-runtime；本项目做的是 **MoonBit 全量移植 + 工程化**：

- 差分层以「冻结期望 + known_failure 隔离」记录与上游的分歧（当前 1 例 BUG-001）；
- 上游修复后，隔离断言自动复活，避免「悄悄偏离」；
- 重叠通过单一模型钉扎（SkillManifest / ToolDescriptor / Storage trait），不复制语义。