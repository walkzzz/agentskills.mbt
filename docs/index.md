---
title: agentskills.mbt — MoonBit 技能运行时
---

<h1 align="center">agentskills.mbt</h1>

<p align="center">
  <a href="https://github.com/walkzzz/agentskills.mbt/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/walkzzz/agentskills.mbt/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://mooncakes.io/docs/walkzzz/agentskills.mbt"><img alt="mooncakes" src="https://img.shields.io/badge/mooncakes-0.1.1-blueviolet"></a>
  <img alt="MoonBit" src="https://img.shields.io/badge/MoonBit-%E6%9C%88%E5%85%94-purple">
  <img alt="Tests" src="https://img.shields.io/badge/tests-45%2F45%20passing-brightgreen">
  <img alt="Mutation" src="https://img.shields.io/badge/mutation-24%2F24%20KILLED-success">
  <img alt="Prove" src="https://img.shields.io/badge/moon%20prove-8%20goals%20proved-blue">
  <img alt="Standard" src="https://img.shields.io/badge/GB%2FZ%20185--2026-%E6%99%BA%E8%83%BD%E4%BD%93%E4%BA%92%E8%81%94-red">
</p>

> **MoonBit 全量移植的 SKILL.md 标准技能运行时** —— [UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)（仓颉）的 MoonBit 重写，配套 **GB/Z 185-2026《人工智能 智能体互联》国标协议栈**，并以 **WebAssembly Component Model（WIT）** 标准接口对外提供能力。

```bash
moon add walkzzz/agentskills.mbt
moon update
```

---

## 架构：三层执行模型

```
       应用面（CLI / Web Server / Examples）
                  │
       运行时壳（cli/ · server/ · examples/）—— IO、时钟、密钥由调用方注入
                  │
       Kernel 纯函数域（skill/ rag/ auth/ rbac/ compactor/ storage/ sandbox/ tooling_bridge）
                  │
       GB/Z 185 协议栈（gbz185.mbt 独立仓 · 20 obligations proved）
                  │
       WebAssembly 组件（WIT skill-api · 跨语言零胶水调用）
```

## 能力全景

| 能力 | 状态 | 证据 |
| --- | --- | --- |
| SKILL.md 标准解析（moonyaml frontmatter + validate） | ✅ | 45/45 测试 · 42 上游 fixtures 差分 |
| 技能注册表渐进加载（同名冲突 fail-fast） | ✅ | Kernel 式纯函数域 |
| 工具单源桥接（GB/Z 185.7 ToolDescriptor → gbz185 ToolRegistry） | ✅ | F03 集成测试 |
| 混合检索（BM25 + RRF 倒数排名融合） | ✅ | 手工期望融合 + 属性测试 |
| 上下文压缩（确定性裁剪 + Unicode 安全截断） | ✅ | Emoji/中文截断实测 |
| RBAC 三级敏感授权 + 单调审计 | ✅ | **moon prove 契约核** |
| 认证（bcrypt 口令 + HS256 JWT） | ✅ | 篡改 token 拒收实测 |
| 存储（内存 / JSONL / async IO / **PostgreSQL**） | ✅ | **真实 PG 18.4 全链路联测** |
| 沙箱 API + 燃料计量 + **js WebAssembly 执行器** | ✅ | echo(42)=42 实测 |
| WebAssembly 组件导出（Component Model · WIT） | ✅ | CI 构建 + `.component.wasm` artifact |
| 双智能体互联演示（GB/Z 185.3/185.5/185.6） | ✅ | 五环节 live 输出 |
| 形式化验证 | ✅ | **moon prove 8 goals proved（W3+Z3）** |
| 变异测试 / 覆盖率 | ✅ | 24/24 KILLED · 库代码仅 3 行未覆盖 |

## 运行演示（实录输出）

**双智能体互联（GB/Z 185-2026 全流程）**

```text
== GB/Z 185-2026 AIP 双智能体互联演示 ==
[0]   ATR 注册: alpha/beta 身份激活 (AIC 1.2.156.185.2.1/2)
[0.5] ADP 发现: alpha 识别 1 个新 peer, beta 识别 1 个
[1]   单播直连: beta received AipMessage OK
[2]   群组分发: fanout=1 delivered
[3]   重放攻击: REJECTED (anti-replay holds)
[4]   invariant(alpha)=true invariant(beta)=true peer_count(beta)=1
```

**PostgreSQL 后端（真实 PG 18.4）**

```text
put/get: {"name":"demo"}   count after 2 puts: 2
overwrite: {"name":"demo2"}   cjk roundtrip: 多行/值/制表 OK
delete exists: true   delete again: false   get after delete: (none)
PG DEMO OK
```

## 🧩 WebAssembly Component Model（跨语言集成）

MoonBit 一流支持 WebAssembly。本项目核心能力以 **WIT 标准组件**导出——`walkzzz:agentskills@0.1.0` / `skill-api` 可被任意宿主（JS / Python / Rust / wasmtime）零胶水调用：

```wit
package walkzzz:agentskills@0.1.0;

interface skill-api {
    parse-name: func(skill-md: string) -> string;
    parse-description: func(skill-md: string) -> string;
    validate: func(skill-md: string) -> string;
    can-access: func(role-rank: u32, sens-rank: u32) -> bool;
    rrf-score: func(rank: u32, k: u32) -> f64;
}

world agentskills { export skill-api; }
```

一条命令构建：

```bash
bash scripts/component_build.sh
# → components/agentskills.component.wasm
# → wasm-tools component wit 接口自证
```

CI `components` job 自动构建并上传 artifact，可用 [wasmtime](https://wasmtime.dev/) 直接调用：

```bash
wasmtime run --invoke 'can-access(2, 2)' agentskills.component.wasm   # true（Admin 可达机密）
wasmtime run --invoke 'rrf-score(0, 60)' agentskills.component.wasm   # 0.0166...
```

## 质量（全部实测，2026-11-19）

| 维度 | 结果 |
| --- | --- |
| 测试 | **45/45**（native）；js 46/46（含 js 执行器）；wasm / wasm-gc 全绿 |
| 变异 | **24/24 KILLED（100%）** · 7 功能域 |
| 属性测试 | 6 quickcheck（seed 固定可复现） |
| 形式化 | **8 goals proved**（verify/proof，WSL Z3 4.8.12） |
| 覆盖率 | `moon coverage analyze`——库代码仅 3 行未覆盖 |
| CI | **11/11 jobs 全绿**（check / contract / prove / native×3 / portable×3 / coverage / components） |
| 门禁 | `moon check --deny-warn --target all` 四目标零警告 · 本地 `scripts/local_ci.sh` 与 CI 对齐 |

## 相关链接

- GitHub：[walkzzz/agentskills.mbt](https://github.com/walkzzz/agentskills.mbt)
- mooncakes：[walkzzz/agentskills.mbt 0.1.1](https://mooncakes.io/docs/walkzzz/agentskills.mbt)
- 国标协议栈：[walkzzz/gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)（GB/Z 185-2026 全 7 部分 · 20 obligations proved）
- 热心文档：[测试报告](TEST_REPORT.md) · [真话台账](known-gaps.md) · [README](https://github.com/walkzzz/agentskills.mbt)
- 上游参考：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)（仓颉实现）

<p align="center"><i>GitHub Pages · Jekyll 渲染 · MIT License</i></p>