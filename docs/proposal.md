# 立项建议书（agentskills.mbt 0.2.0）

## 1. 项目目标

在 MoonBit 生态中提供 **SKILL.md 标准技能运行时** 的完整实现，并满足：

1. Kernel 纯函数域可跨 native / js / wasm / wasm-gc 复用；
2. 与 GB/Z 185-2026 协议栈通过工具单源模型联动；
3. 技能语义有差分冻结与形式化契约核守护；
4. 以 WIT 组件对外提供跨语言接口。

## 2. 范围

### 2.1 纳入范围

- F01 解析与校验（moonyaml frontmatter、长度契约）；
- F02 渐进加载注册表（Metadata → FullyLoaded、fail-fast、升格幂等）；
- F03 工具单源桥接（SkillTool → ToolDescriptor → MCP 条目）；
- F04 BM25 + RRF 检索（含 `rrf_fuse_top` 有界返回）；
- F05 上下文压缩与 Unicode 安全截断（含 `total_chars` 预算诊断）；
- F06 RBAC 三级授权 + 单调审计（含 `denied_count` / `last`）；
- F07 认证（bcrypt + HS256 JWT）；
- F08 存储（内存 / JSONL / async 文件 / PostgreSQL）；
- F09 沙箱 API + 燃料计量 + js WebAssembly 执行器；
- F14 服务端 API（Router + SSE）；F15 CLI；
- WIT 组件导出；`playground` 12 个浏览器导出；`docs/` 静态页面。

### 2.2 非目标

- MQ 分发与国密互联安全层（属 gbz185 路线图）；
- CLI argv 子命令面（GAP-1）；
- wasmoon JIT 完整集成（GAP-7）；
- agent 规划/编排器（本项目只做技能运行时）。

## 3. 里程碑

| 里程碑 | 内容 | 状态 |
| --- | --- | --- |
| M0 F01/F02 骨架 | 解析/校验/注册表 + 差分 fixtures | ✅ 2026-11-17 |
| M1 生产级功能面 | F03–F09 + F14 + F15 + 存储/认证/沙箱 | ✅ 2026-11-19 |
| M2 形式化与变异 | 8 goals proved；24 点变异 | ✅ 2026-11-19 |
| M3 组件导出 | WIT `skill-api` + CI 自证 | ✅ 2026-11-20 |
| M4 0.2.0 立项增强 | 12 项 API、61/62/61/61 测试、30/30 变异、11 导出、123 项页检、七篇文档、工程文档同步 | ✅ 2026-11-24 |
| M5 0.3.0 候选 | wasmoon、CLI 子命令、MQ/国密联动 | ⬜ 规划中 |

## 4. 验收口径（可复算）

```bash
moon check --deny-warn --target all      # 四目标零警告
moon test  --target native               # 61/61
moon test  --target js                   # 62/62
moon test  --target wasm                 # 61/61（wasm-gc 同）
moon run scripts/mutation_test.mbtx      # 30/30 KILLED
node scripts/check_pages.mjs             # 123 项
bash scripts/local_ci.sh --quick         # 本地 CI（含 prove / coverage）
```

## 5. 交付物

- workspace 双成员源码（19 包）+ `playground`；
- 测试矩阵（黑盒/属性/差分/基准）+ 变异脚本；
- 七篇立项文档 + 测试报告 + 真话台账 + 变更日志 + 路线图；
- 浏览器演示页（`docs/index.html` + `playground.js`）与页面自检脚本；
- 工程文档 23 份（`AgentSkillsMBT-工程文档/`）与一致性检查报告。

## 6. 资源与周期

单人维护；构建依赖 MoonBit 工具链、Z3（prove 走 WSL/CI）、PostgreSQL 18.4（可选联测）。