# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/) 与 [语义化版本](https://semver.org/)。
数字口径：测试与功能状态以仓库实测为准（native，日期标注）。

## [0.1.0] - 2026-11-19

### Added

- **workspace 双成员结构**：`agentskills`（主模块）+ `verify`（fixture 资产与差分验证），对齐官方 async 单模块多包模式。
- **F01 SKILL.md 解析**：`parse_skill_md`——frontmatter 提取（moonyaml 解析）→ `SkillManifest`（name/description 必填校验、license/compatibility/metadata 可选）。
- **F02 SkillRegistry**：Kernel 式纯函数域（无 IO）——`register`（同名冲突 fail-fast）/`lookup`/`count` + `LoadLevel`（Metadata/FullyLoaded）渐进加载状态机。
- **F03 tooling_bridge**：`SkillTool` 契约 → GB/Z 185.7 `ToolDescriptor` 单源映射 + `register_skill_tool` 桥入 gbz185 `ToolRegistry`（统一调用与审计日志）。
- **F15 CLI 最小闭环演示**：`moon run cli` 输出 F01 解析 → F02 注册全链路。
- **双智能体互联演示**：`examples/interconnect_demo`（一条命令，sans-I/O 零网络依赖）——ATR 注册（GB/Z 185.3）→ ADP 发现（185.5）→ 单播直连（`send_direct`）→ 群组 dispatch/fanout（185.6）→ 变异信封拒收（防重放）→ 状态机不变量，五环节实测全绿。
- **差分层（D2）**：`known_failure` 隔离机制（编号登记即跳过断言，修复移除自动生效）+ **42 个上游真实 SKILL.md 冻结期望 fixture**（FIXTURE_TARGET=40 达成；实测期望独立于 F01 生成）。
- **F04 RAG 混合检索**：`rag` 包（Kernel 式编排）——MoonRetrieve BM25 引擎（含中文分词）+ `rrf_fuse` 倒数排名融合（k=60）+ `RankedHit`；测试覆盖中英检索与手工期望融合。
- **F07 认证（口令面）**：`auth` 包——bcrypt 口令哈希/校验封装（委托官方 `moonbitlang/x`，salt 由运行时壳提供，**不自研密码学**）。
- **F07 认证（JWT 面）**：`auth` 包——HS256 签发/校验（mooncred 0.8.1 + mooncrypt HMAC-SHA256；`Clock::At(unix_seconds)` 纯值注入，不读系统时钟）；错误密钥与篡改 token 拒收测试。
- **F06 RBAC 三级敏感 + 审计**：`rbac` 包（Kernel 式纯函数域）——`Sensitivity`（Public/Internal/Confidential）× `Role`（Viewer/Operator/Admin）授权矩阵 `can_access` + `Auditor` 单调审计日志（seq 自增，无 IO）。
- **F05 compactor 上下文压缩**：`compactor` 包——确定性裁剪（system 全保留 + 最近 N 条 + 计数占位）+ `fit_budget` 单消息预算 + **Unicode 安全截断（E7：按 codepoint，绝不劈开多字节字符）**。
- **F08 存储抽象（核心）**：`storage` 包——`Storage` pub(open) trait（get/put/delete/all_keys/count）+ `MemoryStorage` 内存实现（四目标）+ `extend` 方法提升；JSONL/PostgreSQL 后端随 native 集成。
- **F08 存储后端（JSONL 编解码核）**：`jsonl.mbt`——`encode_line`/`parse_line`（引号/反斜杠/换行/制表/回车转义对称，中文/emoji 往返）+ `encode_all`/`parse_all`（空行/坏行容错）；文件 IO wrapper 随 native @fs 集成。
- **F08 存储 IO wrapper**：`jsonl_io.mbt`——async `save_jsonl`/`load_jsonl`（薄 IO 层复用已测编解码核，@fs 整文件读写）；`examples/storage_jsonl_demo` 运行级验证往返 OK；async 依赖接入后 native 37/37 保持全绿。
- **F09 沙箱 API 面**：`sandbox` 包——`Sandbox` pub(open) trait（模块字节+入口+参数+燃料 → 分型结果）+ `GasMeter` 燃料计量（限额/消耗/耗尽/负额拒绝，纯逻辑）+ `StubSandbox` 确定性桩（空模块/零燃料/缺入口全分型）；wasmoon 运行时注入随 W10。
- **F14 服务端 API 面**：`server` 包——HTTP 契约（HttpRequest/HttpResponse + ok/404/405）+ `Router` 分发核（精确/前缀匹配，路径命中方法不符 → 405）+ **SSE 事件编码核**（多行 data 逐行前缀）；HTTPS 传输（@async socket+TLS）与 WebMCP 描述面随 native 集成。
- `docs/known-gaps.md` 真话台账（6 条 GAP 如实登记）。
- CI 模板（ci.yml，复用 gbz185 三轮修复成果：retry@v3 语法/Windows 显式 zip/版本锁定）。

### Changed

- **4 基建库自研计划撤销**（2026-11-18）：bcrypt/bm25/pg/wasm3 全部撞车现有生态（mooncakes 实测 bcrypt 5 实现 / bm25 ≥5 / pg 3 / wasm 2）→ 改用 `moonbitlang/x`（bcrypt）/ `MoonRetrieve`（BM25+RRF）/ `moonbit-community/postgres` / `wasmoon`，主工程提前。详见《依赖选型冒烟报告》（工程文档目录）。
- `SkillManifest.metadata` 类型 `Map[String, String]` → `Map[String, Json]`：兼容上游真实文件的 inline 数组等非标量形态（如 `tags: ["a", "b"]`）。
- `compatibility` 字段兼容字符串标量形态（`compatibility: >` 块标量 → 单元素数组）。

### Fixed

- （登记中）**BUG-001**：UP-019（investment-research-assistant/SKILL.md）frontmatter 被 moonyaml 拒绝、上游仓颉解析器接受——已入 `known_failures` 隔离，待裁决（moonyaml flavor 放宽 or F01 预处理）。

### Verified

- `moon check --deny-warn` 干净；`moon test` 45/45（native，2026-11-19，含 6 个 quickcheck 属性、RAG、bcrypt、RBAC、HS256、compactor Unicode 截断、存储契约、JSONL 编解码往返、沙箱燃料、HTTP 路由/SSE 编码、frontmatter 错误分支）；差分层 42 fixtures 全绿（含 1 登记分歧）；**变异测试 24/24 KILLED（击杀率 100%，7 功能域，scripts/mutation_test.mbtx）**；覆盖率库代码仅 3 行未覆盖（`moon coverage analyze` 经 WSL；详见 docs/TEST_REPORT.md）。
- 依赖：`walkzzz/gbz185.mbt@0.1.0`（mooncakes 已发布，国标协议栈 13 verified functions / 20 obligations machine-proved）。