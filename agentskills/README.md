# agentskills.mbt

MoonBit 全量移植的 **SKILL.md 标准技能运行时**（上游：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentsskills-runtime)，仓颉实现）。

本模块（`walkzzz/agentskills.mbt`）是 workspace 主成员；配套 `verify` 成员（fixture 资产 + 差分层验证）与已发布的国标协议栈 [gbz185.mbt](https://github.com/walkzzz/gbz185.mbt)（GB/Z 185-2026，13 verified functions / 20 obligations machine-proved）。

## 安装

```bash
moon add walkzzz/agentskills.mbt
moon update
```

## 包面

| 包 | 能力 |
| --- | --- |
| `skill` | **F01** SKILL.md 解析（moonyaml frontmatter → SkillManifest + validate）+ **F02** SkillRegistry（LoadLevel 渐进加载状态机，Kernel 式纯函数域） |
| `rag` | **F04** 混合检索——MoonRetrieve BM25（中英分词）+ `rrf_fuse` 倒数排名融合（k=60）+ RankedHit |
| `auth` | **F07** 认证——bcrypt 口令哈希/校验（委托官方 moonbitlang/x）+ HS256 JWT 签发/校验（mooncred，Clock 纯值注入） |
| `rbac` | **F06** 三级敏感 × 三角色授权矩阵（`can_access` 纯函数）+ `Auditor` 单调审计日志 |
| `compactor` | **F05** 上下文压缩——确定性裁剪 + 单消息预算 + **Unicode 安全截断（按 codepoint）** |
| `tooling_bridge` | **F03** 技能工具桥接——`SkillTool` 契约 → GB/Z 185.7 `ToolDescriptor` 单源映射 → gbz185 `ToolRegistry` |
| `storage` | **F08** 存储抽象——`Storage` trait + `MemoryStorage`（四目标）+ JSONL 编解码核 + async 文件 IO wrapper |
| `sandbox` | **F09** 沙箱 API 面——`Sandbox` trait + `GasMeter` 燃料计量（限额/耗尽/负额拒绝） |
| `server` | **F14** 服务端 API 面——HTTP 契约 + `Router` 分发核（精确/前缀，方法不符 405）+ SSE 事件编码 |

## 质量

`moon check --deny-warn` 零警告；`moon test` 27/27；变异测试 14/14 KILLED（击杀率 100%）；数字一致性门禁 `scripts/repo_stats.sh`。

架构遵循**三层执行模型**（Kernel 式纯函数域 → 运行时壳 → 互联协议栈）；密码学原语不自研。详见 [仓库 README 与真话台账](https://github.com/walkzzz/agentskills.mbt)。

## 许可证

MIT。