# 已知边界与缺口（真话台账）

> 维护者人工维护的诚实台账：记录已知缺口与平台边界，避免「宣传面与事实面漂移」。
> README 只描述能力；本文件描述边界。评审/集成前请先读此页。

## 功能边界

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-1 | CLI 无 argv（moon run 不传命令行参数——moon-cross 实测工具链限制） | F15 CLI 子命令面（skill load/run/build） | 子命令经环境变量/内嵌演示剧本过渡；argv 方案随 @process 集成裁决 |
| GAP-2 | ~~文件系统读未接入~~ **已闭环（2026-11-19）** | F02 文件加载、CLI 读 SKILL.md | ✅ F08 JSONL IO wrapper 落地（async save/load + demo 往返 OK） |
| GAP-3 | 差分样本 **42/40 达成**（FIXTURE_TARGET=40，上游全量 42 个 SKILL.md 冻结） | D2 差分层覆盖度 | ✅ 已闭环；**BUG-001 登记**：UP-019（investment-research-assistant）frontmatter 被 moonyaml 拒绝、上游接受——known_failure 隔离待裁决 |
| GAP-4 | ~~Metadata→FullyLoaded 升格路径未接文件消费~~ **部分闭环（0.2.0）**：新增 `promote` / `level_of` 显式 API 与测试；正文消费仍属运行时壳 | F02 完整面 | 状态机与升格 API 就位；CLI skill load 子命令落地后接文件消费 |
| GAP-5 | F03 MCP 面（server 侧暴露）未实现 | F03 完整面 | 0.2.0 已补 `to_mcp_entry`（MCP tools/list 单源条目）；**server 侧注册/路由**随 W9 mcp 家族落地 |
| GAP-7 | F09 执行器覆盖：wasmoon 完整集成 = 编译器级依赖链 | F09 三执行器 | ①js WebAssembly ✅；②@process 进程隔离 ⬜；③wasmoon JIT 随 W10 |
| GAP-8 | F08 PG 后端与同步 `Storage` trait 的接口差 | 存储后端统一性 | `storage_pg` 提供 async 独立 API（`with_pg_storage` + kv_*）；**SQL 值当前单引号转义拼接（联测用途）**，参数化准备语句留后续 |
| GAP-9 | 排序语义：MoonBit `Compare for String` 为 **shortlex（长度优先）** | `SkillRegistry::names` 等确定性清单 | 文档明示；同长度按字典序；需要严格字典序请自定义比较（0.2.0 已在测试中锁定该语义） |

## 平台与工具链

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-6 | gbz185.mbt Windows 本地 `moon prove` 触发 moon 工具链 `\\?` mkdir bug（EACCES/EINVAL） | 国标形式化验证的本地运行 | WSL 通道 **20 obligations proved / 13 verified functions**；CI 走 ubuntu runner |

## 演示与页面

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-10 | 演示层（`playground` / `cli` / `examples`）不计入覆盖率与核心质量口径 | 覆盖率数字解读 | 文档与 TEST_REPORT 明示；核心 Kernel 包单独计 |
| GAP-11 | `docs/index.md` 已删除（Jekyll 页面并入静态 `index.html`）；`_config.yml` 保留但不依赖主题 | Pages 渲染方式 | 静态页为事实源；本地预览 `node scripts/serve_pages.mjs` |
| GAP-12 | 演示层参数校验：RRF `k > 0`、截断 `max_chars ≥ 1`、工具 name/description 非空；压缩在无收益时跳过折叠 | 浏览器演示数值与口径 | 0.2.1 修复（F1–F6）；库核心 API 不变 |

## 测试口径（2026-11-24 实测）

- 测试：**native 61/61**；**js 62/62**（含 js-only 执行器）；**wasm / wasm-gc 各 61/61**。
- 变异：**30/30 KILLED**（7 功能域，`scripts/mutation_test.mbtx`）。
- 覆盖率：`moon coverage analyze` + `report -f full_summary`（WSL 通道，2026-11-24）——**核心 424/433 = 97.9%**，未覆盖 9 行（jsonl 2 / frontmatter 4 / compactor 3）；`cli`/`playground`/`examples`/`proof` 不计入（GAP-10）。
- 形式化：`verify/proof` **8 goals proved**（moon prove / WSL Z3 4.8.12）。
- 页面：`node scripts/check_pages.mjs` **142 项 PASS**；CDP E2E **29 项 PASS**（含 939px 窄屏导航、边界输入与预置复位）。
- 数字一致性门禁：`scripts/repo_stats.sh`；本地 CI `scripts/local_ci.sh` 与 `.github/workflows/ci.yml` 对齐。