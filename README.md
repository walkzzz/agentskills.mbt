# agentskills.mbt

<p align="left">
  <a href="https://github.com/walkzzz/agentskills.mbt/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="MoonBit" src="https://img.shields.io/badge/MoonBit-%E6%9C%88%E5%85%94-purple">
  <img alt="Tests" src="https://img.shields.io/badge/tests-15%2F15%20passing-brightgreen">
  <img alt="Standard" src="https://img.shields.io/badge/SKILL.md-standard-teal">
  <img alt="GBZ" src="https://img.shields.io/badge/GB%2FZ%20185--2026-%E6%99%BA%E8%83%BD%E4%BD%93%E4%BA%92%E8%81%94-red">
</p>

**简体中文（默认）** · [English](#english)

---

MoonBit 全量移植的 **SKILL.md 标准技能运行时**（上游：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)，仓颉实现），`moon.work` workspace 双成员 + 已发布的国标协议栈独立仓：

| 成员 | 内容 |
| --- | --- |
| **agentskills**（主模块） | **F01** SKILL.md 解析（moonyaml frontmatter→SkillManifest+validate）→ **F02** SkillRegistry（渐进加载状态机，Kernel 式纯函数域）→ **F03** tooling_bridge（SkillTool trait→GB/Z 185.7 ToolDescriptor 单源映射）→ CLI |
| **verify** | fixture 资产 + **差分层**：known_failure 隔离机制（与上游语义分歧登记即跳过，修复后断言自动生效）+ 冻结期望差分测试 |
| **[gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)**（独立仓，已发布 mooncakes） | GB/Z 185-2026《人工智能 智能体互联》协议栈全 7 部分 + 形式化验证（moon prove 3 goals proved） |

架构采用**三层执行模型**（吸收 posoco 实战范式）：Kernel 式纯函数域（`skill/`）→ 运行时壳（`cli/`）→ 互联协议栈（gbz185 仓）——"有状态"与"纯函数"彻底分离，组合失败即 fail-fast。

## 快速开始

```bash
git clone https://github.com/walkzzz/agentskills.mbt.git
cd agentskills.mbt
moon check --deny-warn        # 四目标零警告门禁
moon test                     # 15/15（2026-11-19 实测）
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

## 能力与边界

- **定位即库+运行时骨架**：F01/F02/F03 核心链路已通；CLI 子命令面、文件系统读、MCP 适配器按 roadmap 排期落地（见 `roadmap.md`）。
- 差分层就位但样本尚少（3/40，见 [docs/known-gaps.md](docs/known-gaps.md) GAP-3）。
- **不含**：MQ 分发、国密互联安全层（gbz185 仓 0.2.0 路线）。
- 完整真话台账见 [docs/known-gaps.md](docs/known-gaps.md)；milestone 真相源见 `roadmap.md`。

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
| **[gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)** (standalone repo, published on mooncakes) | GB/Z 185-2026 agent-interconnection protocol stack, Parts 1-7, with formal verification (moon prove, 3 goals proved) |

Architecture follows the **three-layer execution model** (absorbed from posoco): kernel-style pure domain (`skill/`) → runtime shell (`cli/`) → interconnect protocol stack (gbz185) — stateful and pure separation, fail-fast composition.

### Quick start

```bash
git clone https://github.com/walkzzz/agentskills.mbt.git
cd agentskills.mbt
moon check --deny-warn        # zero warnings across four targets
moon test                     # 15/15 (measured 2026-11-19)
moon run cli                  # F01 parse → F02 register end-to-end demo
moon run examples/interconnect_demo   # two-agent interconnect demo (sans-I/O, no network)
```

As a dependency:

```bash
moon add walkzzz/agentskills.mbt
moon update
```

### Capabilities & boundaries

- **Library + runtime skeleton**: the F01/F02/F03 core chain is live; CLI subcommands, filesystem reads, and the MCP adapter land per `roadmap.md`.
- Differential layer is live with a small sample set (3/40, see [docs/known-gaps.md](docs/known-gaps.md) GAP-3).
- **Not included**: MQ fan-out, SM-suite interconnect security (gbz185 0.2.0 roadmap).
- Full honest ledger: [docs/known-gaps.md](docs/known-gaps.md); milestone source of truth: `roadmap.md`.

### License

MIT. Upstream reference: [UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime) (Cangjie implementation).
