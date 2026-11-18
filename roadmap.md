# agentskills.mbt Roadmap

> MoonBit 实现的 AgentSkills 标准智能体技能运行时——SKILL.md 开放标准 + MCP/WebMCP + **GB/Z 185-2026《人工智能 智能体互联》国标**（含 185.6 智能体交互协议 AIP）。
>
> 移植对标：[UCToo/agentskills-runtime](https://atomgit.com/UCToo/agentskills-runtime)（仓颉 v0.0.30，MIT，35 核心模块）· 全量、无折扣移植 + MoonBit 优势增强（E1-E10）。
>
> 负责人：walkzzz · 工程文档：`../AgentSkillsMBT-工程文档/`（23 份，里程碑真相源 Charter §4）· 本文件更新日期：2026-11-17
>
> **架构演进（2026-11-17，2026-11-18 修订）**：仓库形态 = **moon.work workspace + 2 分仓**（本仓 agentskills.mbt = 主 workspace：agentskills 单模块多包 + verify 成员；**GB/Z 185.1-185.7 协议栈独立仓 gbz185.mbt 先行开发**，10 包：wire/arch根包/identity/registry/capability/discovery/aip/tooling/transport_async/verify；**原 4 基建库 bcrypt/bm25/pg/wasm3 全部撞车生态，撤销自研改依赖**——mooncakes 实测 bcrypt 5 实现/bm25≥5/pg 3/wasm 2，详见《依赖选型冒烟报告》）——详见工程文档 ARCH §2.1/§2.5（重叠钉扎 7 项决策）。

---

## 一、当前进度快照（2026-11-17，正式开工日 2026-11-23 之前）

| 状态 | 图例 |
| --- | --- |
| ✅ 已完成 | 🔵 提前完成（超出排期） |
| 🔶 部分完成 | ⬜ 未开始（按 DEV 65 日排期推进） |

### 已完成

| 项 | 说明 | 证据 |
| --- | --- | --- |
| ✅ 上游调研 | 35 模块全貌 + 双模式架构 + GB/Z 185.1~185.7 国标结构提取（AIP=185.6 交互协议；AIC/CAI 身份、ATR 注册、ACS 能力、ADP 发现） | 会话调研记录 + 上游 README_cn |
| ✅ 生态对照 | mooncakes 3641 模块扫描：MCP/agent 框架已拥挤、AgentSkills 运行时为空白；锁定依赖清单（async 0.22.9 / mooncry 0.95 / mooncred 0.7.1 / moonyaml / cmark / mcp 家族 / workflow / maria 评估） | ecosystem-index 快照 |
| ✅ 工程文档 | 23 份全生命周期文档（立项→运维），一致性检查 D1-D9 零阻断（V2） | `../AgentSkillsMBT-工程文档/` |
| ✅ 工具链实测 | moon 0.1.20261104 下语法事实确认（`#derive`/`pub(all) suberror`/`pub extend` 声明/Int64 ToJson 字符串形态等），已回写 COD 规范 | aip 包编译迭代记录 |
| 🔵 **F17 AIP 协议核心** | **提前实现**（原排期 W12）：GB/Z 185.2/185.4/185.5/185.6 数据模型与 sans-I/O 状态机 + wire JSON codec + AGENTS.md frontmatter 映射 | `aip/` 包 9 文件，见下 |

### AIP 协议核心（🔵 已迁移至独立仓 **walkzzz/gbz185.mbt** 并推送）

> 2026-11-17：原 `aip/` 包已按 ARCH §2.1 拆分迁移至独立仓 **https://github.com/walkzzz/gbz185.mbt**（10 包：wire/arch根包/identity/registry/capability/discovery/aip/tooling/transport-async/verify），**47/47 测试全绿**、四目标零警告、.mbti 契约生成、verify 形式化（proof_enabled）。主仓本目录的 aip 包已移除（单一事实源 = gbz185 仓）。

| 门禁（gbz185 仓） | 结果 |
| --- | --- |
| `moon check --deny-warn --target all` | 四目标**零警告** |
| `moon test` | **47/47 全绿**（黑盒 / 白盒 / Fake Transport / quickcheck 属性 / wire / registry / discovery / capability / identity / tooling） |
| 覆盖率 | 93.1%（迁移前基线；gbz185 仓含新增 AIC 校验/registry 生命周期后更高） |
| 变异测试 | **10/10 KILLED，击杀率 100%**（方法与报告见 `docs/TEST_REPORT.md`） |
| `moon info` | 各包 `pkg.generated.mbti` 契约生成（E4） |
| `moon fmt` | 已格式化 |
| 形式化 | 可执行不变量 + **moon prove 形式化证明完成：2 goals proved**（clamp_i64 + next_seq 严格递增，WSL Ubuntu + Z3 4.8.12；next_seq 已接入 dispatch 真实调用） |
| LLM 夹具 | ModelScope Qwen2.5-0.5B GGUF 登记（`test-fixtures/llm-local.md`） |

### 未开始（按排期推进）

⬜ W1 依赖选型实测 → ⬜ W2 行为 fixture 锚定（≥40 例）→ ⬜ W3-W6 四个基建库 → ⬜ W7-W9 主工程纯核心/域包/桥接 → ⬜ W10-W11 沙箱与 PG → ⬜ W12 互联集成 → ⬜ W13 终验发布

---

## 二、里程碑路线（真相源：Charter §4）

```text
2026-11-23 开工 ──► M0 ──────► M1 ──────► M2 ──────► M3
                    12-04      2027-01-01  01-22      02-19
                    选型+fixture  三大能力面  v0.1.0     v1.0.0
                    骨架          集成验证     可演示版本   全量+大赛材料
                    [⬜]         [⬜]       [⬜]       [⬜]
                        ▲ F17 核心已提前就位（aip 包）
```

| 阶段 | 周 | 日期 | 内容 | 状态 |
| --- | --- | --- | --- | --- |
| P0a 依赖选型 | W1 | 11-23 ~ 11-27 | moonyaml/mcp 家族/maria/workflow/mizchi-llm/moonhnsw 冒烟 + 版本锁定（**bcrypt/bm25/pg/wasm 替代依赖已提前冒烟锁定，2026-11-18**） | 🔶 |
| P0b 行为锚定 | W2 | 11-30 ~ 12-04 | 上游 fixture ≥40 例 + 主工程骨架 + CI | ⬜ **M0** |
| P1-1 认证集成 | W3 | 12-07 ~ 12-11 | moonbitlang/x bcrypt + mooncred 认证面集成验证 | ⬜ |
| P1-2 检索集成 | W4 | 12-14 ~ 12-18 | MoonRetrieve（BM25/RRF）+ moonhnsw 检索面集成验证 | ⬜ |
| P1-3 存储集成 | W5-6 | 12-21 ~ 01-01 | moonbit-community/postgres 存储面集成验证（真实 PG 联测） | ⬜ **M1** |
| P2 纯核心 | W7 | 01-04 ~ 01-08 | skills 契约（declare）→ F01-F03 实现（四目标含 wasm-gc） | ⬜ |
| P2 域包 | W8 | 01-11 ~ 01-15 | rag / security / storage(trait+内存+文件)（GB/Z 185 栈已拆分至独立仓 gbz185.mbt 先行开发） | ⬜ |
| P2 桥接 | W9 | 01-18 ~ 01-22 | MCP 适配器 + 18 内置工具 + server + CLI → **v0.1.0** | ⬜ **M2** |
| P3 沙箱 | W10 | 01-25 ~ 01-29 | wasmoon 沙箱执行器集成验证（JIT+解释器+WASI） | ⬜ |
| P3 集成 | W11 | 02-01 ~ 02-05 | 三执行器 + wasm-gc 组件通道(E2) + PG 接入 | ⬜ |
| P4 互联 | W12 | 02-08 ~ 02-12 | **AIP 集成**（transport/MQ/mTLS/双协议互通）+ 国密(E8) + PQ(E9) + 结构化并发(E6) | 🔶 核心⬜→已就绪 |
| P5 终验 | W13 | 02-15 ~ 02-19 | 对照矩阵 100% + 门禁终跑 → **v1.0.0** + 浏览器 demo(E1) + 大赛材料 | ⬜ **M3** |

---

## 三、功能面路线（PRD F01-F17）

| 功能 | 描述 | 版本 | 状态 |
| --- | --- | --- | --- |
| F17 | AIP 智能体互联协议适配层（GB/Z 185.6） | 1.0.0 | 🔶 sans-I/O 核心与模型已就绪；transport/MQ/mTLS/互通 ⬜ |
| F01 | SKILL.md 解析与校验 | 0.1.0 | 🔶 parse_skill_md 落地（frontmatter 提取+moonyaml+validate，4 测试含差分层起步）；YAML 全语法面与文件系统读随 async 接入 ⬜ |
| F02 | 技能注册表与渐进加载 | 0.1.0 | 🔶 SkillRegistry Kernel 式纯函数域落地（register/lookup/count + LoadLevel 状态机，同名冲突 fail-fast）；文件加载 ⬜ |
| F03 | 技能→工具适配器（MCP 面） | 0.1.0 | ⬜ |
| F04 | RAG 混合检索（BM25+RRF+HNSW） | 0.1.0 核心 | ⬜ |
| F05 | compactor 上下文压缩 | 1.0.0 | ⬜ |
| F06 | RBAC 三级敏感 + 审计 | 0.1.0 | ⬜ |
| F07 | 认证（JWT+口令） | 0.1.0 | ⬜ |
| F08 | 存储抽象（内存/文件/PG） | 0.1.0/1.0.0 | ⬜ |
| F09 | WASM 沙箱三执行器 | 1.0.0 | ⬜ |
| F10 | MoonBit 技能 wasm-gc 组件通道 [E2] | 1.0.0 | ⬜ |
| F11 | GB/Z 185 本地模式 | 0.1.0 | ⬜ |
| F12 | GB/Z 185 互联模式 | 1.0.0 | ⬜ |
| F13 | 18 内置工具 | 0.1.0 | ⬜ |
| F14 | HTTPS 服务与 WebMCP | 0.1.0 | ⬜ |
| F15 | CLI 单二进制 [E10] | 0.1.0 | ⬜ |
| F16 | 四目标 + 浏览器运行时 [E1] | 0.1.0/1.0.0 | ⬜（aip 包已验证四目标编译路径） |

---

## 四、依赖路线（原新建库计划撤销——全部撞车生态，2026-11-18 决策）

| 能力域 | 依赖（锁定版本） | 备选 | 冒烟状态 |
| --- | --- | --- | --- |
| 口令哈希 | moonbitlang/x@0.5.7（bcrypt 包） | moonbitstack/mooncrypt@0.5.2（交叉验证一致） | ✅ 编译+运行级互验 1/1（2026-11-18） |
| 检索 | niuniu513-ask/MoonRetrieve@0.6.0 | NaIWaniubi/moonseek@0.17.5（平台级） | ✅ 编译通过 |
| 数据库 | moonbit-community/postgres@0.1.3 | — | ✅ 编译通过（native-only） |
| WASM 沙箱 | Milky2018/wasmoon@0.19.0 | moonbitlang/typst/wasmi | ✅ 编译通过（10 子模块） |
| ~~walkzzz/bcrypt.mbt~~ | ~~自研撤销~~ | — | ❌ 生态 5 实现（含官方 x） |
| ~~walkzzz/bm25.mbt~~ | ~~自研撤销~~ | — | ❌ 生态 ≥5 实现 |
| ~~walkzzz/pg.mbt~~ | ~~自研撤销~~ | — | ❌ moonbit-community/postgres 2389 下载 |
| ~~walkzzz/wasm3.mbt~~ | ~~自研撤销~~ | — | ❌ wasmoon 1851 下载全功能 |
| walkzzz/agentskills.mbt | W9 / W13 | 主工程 v0.1.0 / v1.0.0 | 🔶 工程骨架与 aip 包已建 |

集成纪律：主工程依赖每个生态包前跑冒烟项目回归（.tmp-smoke 保留）；MoonSearch@0.9.0 因自身编译错误出局（记录于冒烟报告）。

---

## 五、MoonBit 优势增强路线（E1-E10，上游无）

| # | 增强 | 状态 |
| --- | --- | --- |
| E3 | 类型化错误全栈（suberror 分型） | 🔶 aip 包已落实（AipError 五型 + Show/ToJson） |
| E4 | .mbti 契约门禁 | 🔶 aip 包已生成（pkg.generated.mbti）；全包推广随排期 |
| E1 | 浏览器/边缘 wasm-gc 运行时 | 🔶 四目标编译路径已验证（aip 包）；demo W13 |
| E2 | MoonBit 技能即 wasm-gc 组件（双通道沙箱） | ⬜ W11 |
| E5 | README doctest | ⬜ 随各库（W3 起） |
| E6 | @async 结构化并发编排 | ⬜ W12 |
| E7 | Unicode 正确 token 截断 | ⬜ W8 |
| E8 | 国密套件通道（SM2/SM3/SM4） | ⬜ W12 |
| E9 | 后量子证书实验（ML-DSA） | ⬜ W12 |
| E10 | skill CLI 单二进制 | ⬜ W9 |

---

## 六、发布与质量路线

| 发布物 | 日期 | 门禁 |
| --- | --- | --- |
| agentskills.mbt 0.1.0 | 2027-01-22 | W10 门禁首跑（M2） |
| agentskills.mbt 1.0.0 | 2027-02-19 | 门禁终跑 + 对照矩阵 100%（M3） |

（原 bcrypt/bm25/pg/wasm3 四条库发布行随自研计划撤销删除，2026-11-18。）

发布纪律：依赖集成前冒烟回归 + 步间 `moon update`；dry-run 202/409 判版本占用；CHANGELOG ≠ 已发布（mooncakes docs 为事实源）；发布类命令由 walkzzz 亲自执行。

---

## 七、风险与缓冲

| 风险 | 缓冲策略 |
| --- | --- |
| wasm3 三平台编译阻塞 | Windows+Linux 优先，macOS 延 W11；沙箱功能不缺席 |
| 依赖包不达标 | W1 实测 + fork 兜底 |
| 上游/标准演进 | 锚定 SKILL.md 标准与 GB/Z 185 国标文本（已提取规范细节） |
| 65 日体量 | M2 保底 + 周缓冲日；压缩顺序 W12 外部联测 → W11 增强 |

已知外部依赖：GB/Z 185 互联模式完整联测需真实 ACPs/CA/MQ 服务环境（当前本地桩先行，v1.1.0 真实联测）。

---

## 八、文档索引

- 工程文档体系（23 份）：`../AgentSkillsMBT-工程文档/00-文档体系总览.md`（术语/角色/里程碑/技术四大真相源）
- 一致性检查报告：`../AgentSkillsMBT-工程文档/一致性检查与修复报告.md`（V2，0 阻断）
- 移植对照矩阵：W13 产出 `docs/PORTING_MATRIX.md`（上游 35 模块逐项勾验）
- 测试计划/用例：`../AgentSkillsMBT-工程文档/05-测试阶段/`（TC-F01-F17 编号体系）

> 本 roadmap 与 Charter §4（里程碑）、ARCH §10（技术选型）、DEV §3（65 日排期）保持同步；任何日期/范围变更以 Charter 为准并回改本文。
