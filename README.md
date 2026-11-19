# agentskills.mbt

<p align="left">
  <a href="https://github.com/walkzzz/agentskills.mbt/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/walkzzz/agentskills.mbt/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/walkzzz/agentskills.mbt/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <a href="https://mooncakes.io/docs/walkzzz/agentskills.mbt"><img alt="mooncakes" src="https://img.shields.io/badge/mooncakes-0.1.0-blueviolet"></a>
  <img alt="MoonBit" src="https://img.shields.io/badge/MoonBit-%E6%9C%88%E5%85%94-purple">
  <img alt="Tests" src="https://img.shields.io/badge/tests-45%2F45%20passing-brightgreen">
  <img alt="Mutation" src="https://img.shields.io/badge/mutation-24%2F24%20KILLED-success">
  <img alt="Prove" src="https://img.shields.io/badge/moon%20prove-8%20goals%20proved-blue">
  <img alt="Standard" src="https://img.shields.io/badge/SKILL.md-standard-teal">
  <img alt="GBZ" src="https://img.shields.io/badge/GB%2FZ%20185--2026-%E6%99%BA%E8%83%BD%E4%BD%93%E4%BA%92%E8%81%94-red">
</p>

**简体中文（默认）** · [English](#english)

**目录**：[特性一览](#特性一览) · [快速开始](#快速开始) · [双智能体互联演示](#双智能体互联演示国标全流程) · [质量与验证](#质量与验证) · [能力与边界](#能力与边界) · [文档](#文档) · [许可证](#许可证)

---

MoonBit 全量移植的 **SKILL.md 标准技能运行时**（上游：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)，仓颉实现），`moon.work` workspace 双成员 + 已发布的国标协议栈独立仓：

| 成员 | 内容 |
| --- | --- |
| **agentskills**（主模块） | **F01** SKILL.md 解析（moonyaml→SkillManifest+validate）· **F02** SkillRegistry（渐进加载状态机，Kernel 式纯函数域）· **F03** tooling_bridge（GB/Z 185.7 单源映射）· **F04** RAG（BM25+RRF）· **F05** compactor（Unicode 安全截断）· **F06** RBAC（三级敏感+审计）· **F07** 认证（bcrypt+HS256 JWT）· **F08** 存储（内存+JSONL+async IO）· **F09** 沙箱 API（GasMeter）· **F14** 服务端 API（Router+SSE）· **F15** CLI |
| **verify** | fixture 资产 + **差分层**：known_failure 隔离机制（与上游语义分歧登记即跳过，修复后断言自动生效）+ 冻结期望差分测试 |
| **[gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)**（独立仓，已发布 mooncakes） | GB/Z 185-2026《人工智能 智能体互联》协议栈全 7 部分 + 形式化验证（moon prove 20 obligations proved / 13 verified functions） |

架构采用**三层执行模型**（吸收 posoco 实战范式）：Kernel 式纯函数域（`skill/`）→ 运行时壳（`cli/`）→ 互联协议栈（gbz185 仓）——"有状态"与"纯函数"彻底分离，组合失败即 fail-fast。

```
      应用面（CLI / Server / Examples）
                 │
      运行时壳（cli/ · server/ · examples/）—— IO、时钟、密钥由调用方注入
                 │
      Kernel 纯函数域（skill/ rag/ auth/ rbac/ compactor/ storage/ sandbox/ tooling_bridge）
                 │
      GB/Z 185 协议栈（gbz185.mbt 独立仓 · 20 obligations proved）
```

## 特性一览

| 能力 | 状态 |
| --- | --- |
| SKILL.md 标准解析（moonyaml frontmatter + validate） | ✅ |
| 技能注册表渐进加载（同名冲突 fail-fast） | ✅ |
| 工具单源桥接（GB/Z 185.7 ToolDescriptor → gbz185 ToolRegistry） | ✅ |
| 混合检索（BM25 + RRF 倒数排名融合） | ✅ |
| 上下文压缩（确定性裁剪 + Unicode 安全截断） | ✅ |
| RBAC 三级敏感授权 + 单调审计日志 | ✅ |
| 认证（bcrypt 口令 + HS256 JWT，不自研密码学） | ✅ |
| 存储抽象（内存 / JSONL 编解码 / async 文件 IO） | ✅ |
| 沙箱 API + 燃料计量（形式化契约核）+ **js WebAssembly 执行器**（echo(42)=42 实测） | ✅ |
| 服务端 API（HTTP 契约 + Router + SSE 编码） | ✅ |
| 双智能体互联演示（GB/Z 185.3/185.5/185.6 全流程） | ✅ |
| 形式化验证（moon prove 8 goals proved） | ✅ |
| 变异测试（24/24 KILLED，7 功能域） | ✅ |

## 快速开始

```bash
git clone https://github.com/walkzzz/agentskills.mbt.git
cd agentskills.mbt
moon check --deny-warn        # 四目标零警告门禁
moon test                     # 45/45（2026-11-19 实测）
moon run cli                  # F01 解析 → F02 注册 端到端演示
moon run examples/interconnect_demo   # 双智能体互联演示（sans-I/O 零网络依赖）
```

作为依赖使用：

```bash
moon add walkzzz/agentskills.mbt
moon update
```

## 双智能体互联演示（国标全流程）

```
== GB/Z 185-2026 AIP 双智能体互联演示 ==
[0]   ATR 注册: alpha/beta 身份激活 (AIC 1.2.156.185.2.1/2)
[0.5] ADP 发现: alpha 识别 1 个新 peer, beta 识别 1 个
[1]   单播直连: beta received AipMessage OK
[2]   群组分发: fanout=1 delivered
[3]   重放攻击: REJECTED (anti-replay holds)
[4]   invariant(alpha)=true invariant(beta)=true peer_count(beta)=1
```

注册（GB/Z 185.3）→ 发现（185.5）→ 单播直连 → 群组扇出（185.6）→ **变异信封现场拒收（防重放）** → 状态机不变量——全部经 gbz185 协议栈的形式化证明背书。

## 质量与验证

- 测试 **45/45**（四目标；CI 全绿——check/contract/**prove**/native×3/portable×3/**coverage**）
- 变异 **24/24 KILLED**（7 功能域）；覆盖率库代码仅 3 行未覆盖（[docs/TEST_REPORT.md](docs/TEST_REPORT.md)）
- **形式化验证：`verify/proof` `proof_enabled`——moon prove 8 goals proved**（Why3 + Z3：燃料账本 `gas_after`/占位计数 `dropped`/RBAC 授权 `allowed` 等契约核）
- 本地 CI 与 `.github/workflows/ci.yml` 对齐：`bash scripts/local_ci.sh`（prove 走 WSL 通道；`--quick` 跳过变异/覆盖率慢项）

## 能力与边界

- **功能面**：F01–F09 + F14 全部 🔶 就绪（解析/注册表/工具桥接/RAG/压缩/RBAC/认证/存储/沙箱 API/服务端 API）+ F15 CLI + F17 互联演示；CLI 子命令面与 MCP 适配器按 roadmap 排期。
- 差分层 **42/40 达成**（上游全量 SKILL.md 冻结，含 1 登记分歧 BUG-001——见 [docs/known-gaps.md](docs/known-gaps.md)）。
- **不含**：MQ 分发、国密互联安全层（gbz185 仓 0.2.0 路线）。
- 完整真话台账见 [docs/known-gaps.md](docs/known-gaps.md)；milestone 真相源见 `roadmap.md`。

## 文档

| 文档 | 内容 |
| --- | --- |
| [docs/TEST_REPORT.md](docs/TEST_REPORT.md) | 测试矩阵 · 变异清单 · 覆盖率基线 · 形式化验证 |
| [docs/known-gaps.md](docs/known-gaps.md) | 真话台账：已知边界与缺口（诚实记录） |
| [roadmap.md](roadmap.md) | 里程碑路线与功能面进度（真相源） |
| [CHANGELOG.md](CHANGELOG.md) | 版本变更（Keep a Changelog） |
| [CONTRIBUTING.md](CONTRIBUTING.md) | 贡献指南：门禁命令 · 差分层三铁律 · 架构纪律 |
| [SECURITY.md](SECURITY.md) | 安全政策：漏洞报告渠道 · 防重放证明背书 |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | 行为准则（Contributor Covenant 2.1） |

## 许可证

MIT。上游参考：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)（仓颉实现）。

---

<a id="english"></a>

## English

MoonBit full port of the **SKILL.md standard skill runtime** (upstream: UCToo/agentskills-runtime, Cangjie implementation), as a `moon.work` workspace with two members plus the published national-standard protocol stack repo:

| Member | Content |
| --- | --- |
| **agentskills** (main module) | **F01** SKILL.md parsing (moonyaml frontmatter → SkillManifest + validate) → **F02** SkillRegistry (progressive-loading state machine, kernel-style pure functional domain) → **F03** tooling_bridge (SkillTool trait → GB/Z 185.7 ToolDescriptor single-source mapping) → CLI |
| **verify** | fixture assets + **differential layer**: known_failure quarantine (upstream semantic divergences registered by id, assertions auto-revive on fix) + frozen-expectation differential tests |
| **[gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)** (standalone repo, published on mooncakes) | GB/Z 185-2026 agent-interconnection protocol stack, Parts 1-7, with formal verification (moon prove, 20 obligations proved / 13 verified functions) |

Architecture follows the **three-layer execution model** (absorbed from posoco): kernel-style pure domain (`skill/`) → runtime shell (`cli/`) → interconnect protocol stack (gbz185) — stateful and pure separation, fail-fast composition.

### Quick start

```bash
git clone https://github.com/walkzzz/agentskills.mbt.git
cd agentskills.mbt
moon check --deny-warn        # zero warnings across four targets
moon test                     # 45/45 (measured 2026-11-19)
moon run cli                  # F01 parse → F02 register end-to-end demo
moon run examples/interconnect_demo   # two-agent interconnect demo (sans-I/O, no network)
```

As a dependency:

```bash
moon add walkzzz/agentskills.mbt
moon update
```

### Quality & verification

- Tests **45/45** (four targets; CI green — check/contract/**prove**/native×3/portable×3/**coverage**)
- Mutation **24/24 KILLED** (7 domains); coverage: only 3 library lines uncovered ([docs/TEST_REPORT.md](docs/TEST_REPORT.md))
- **Formal verification: `verify/proof` `proof_enabled` — moon prove 8 goals proved** (Why3 + Z3: gas ledger `gas_after`, compaction `dropped`, RBAC `allowed` cores)
- Local CI mirrors `.github/workflows/ci.yml`: `bash scripts/local_ci.sh` (prove via WSL; `--quick` skips slow items)

### Capabilities & boundaries

- **Function surface**: F01–F09 + F14 all 🔶 (parse/registry/tooling bridge/RAG/compaction/RBAC/auth/storage/sandbox API/server API) + F15 CLI + F17 interconnect demo; CLI subcommands and MCP adapter land per `roadmap.md`.
- Differential layer **42/40 achieved** (full upstream SKILL.md frozen, 1 registered divergence BUG-001 — see [docs/known-gaps.md](docs/known-gaps.md)).
- **Not included**: MQ fan-out, SM-suite interconnect security (gbz185 0.2.0 roadmap).
- Full honest ledger: [docs/known-gaps.md](docs/known-gaps.md); milestone source of truth: `roadmap.md`.

### License

MIT. Upstream reference: [UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime) (Cangjie implementation).
