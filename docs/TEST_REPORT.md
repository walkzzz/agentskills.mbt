# 测试报告（2026-11-24，0.2.0）

> 口径纪律：所有数字为实测并带日期；变异/覆盖率通道与环境差异如实记录。

## 测试矩阵

| 层 | 规模 | 结果 |
| --- | --- | --- |
| 单元/差分测试 | **61 test 块（native）** | native 61/61；js **62/62**（含 js-only 执行器）；wasm / wasm-gc 各 61/61（本地实测 2026-11-24） |
| 差分层（对上游） | **42 上游真实 fixtures** | 全绿（含 BUG-001 known_failure 隔离） |
| 属性测试 | 6 quickcheck（seed 2026–2032 固定；skill×4 + rag×2） | 全绿可复现 |
| **变异测试** | **30 变异点 / 7 功能域** | **30/30 KILLED（击杀率 100%）** |
| 页面门禁 | `node scripts/check_pages.mjs` | **123 项 PASS**（结构 / 钩子 / 11 导出 / 语义 / 版本） |
| 浏览器 E2E | CDP（Chrome/Edge headless） | **17 项 PASS**（本地；截图存临时目录） |
| 覆盖率 | `moon coverage analyze` + `report -f full_summary`（WSL 通道，2026-11-24） | **核心 424/433 = 97.9%**（未覆盖 9 行：jsonl 2 / frontmatter 4 / compactor 3）；cli / playground / examples / proof 不计入 |

0.2.0 新增测试（16 个 block）：

| 文件 | 覆盖 |
| --- | --- |
| `skill/skill_extra_test.mbt` | `has_license` / `compatibility_count` |
| `skill/registry_extra_test.mbt` | `is_registered` / `level_of` / `names`（shortlex）/ `promote` / `unregister` |
| `rbac/rbac_extra_test.mbt` | `Role::rank` / `Sensitivity::rank` / `label` / 3×3 矩阵 / `denied_count` / `last` |
| `compactor/compactor_extra_test.mbt` | `total_chars`（codepoint 与截断同口径） |
| `rag/rag_extra_test.mbt` | `is_empty` / `rrf_fuse_top` 前缀语义 |
| `tooling_bridge/adapter_extra_test.mbt` | `to_mcp_entry` 与 `to_descriptor` 同源 |

## 形式化验证（moon prove）

| 项 | 结果 |
| --- | --- |
| 通道 | WSL（Z3 4.8.12）——Windows 本地有 `\\?` mkdir 平台 bug |
| 目标包 | `verify/proof`（`proof_enabled = true`） |
| 结果 | **8 goals proved / 1 of 1 packages proved**（2026-11-19；0.2.0 未改动证明函数） |
| 契约核 | `gas_after` · `gas_after_never_exceeds` · `dropped` · `dropped_positive` · `allowed` · `admin_grants_confidential` · `viewer_denied_confidential` · `operator_boundary_exact` |
| 方法 | 契约式纯函数核（`proof_require`/`proof_ensure`）；真实实现（GasMeter / compact / can_access）由测试对齐核（model-based oracle） |
| 交叉 | gbz185.mbt：**20 obligations proved / 13 verified functions**（独立仓） |

## 变异矩阵（30 点）

| 编号 | 目标域 |
| --- | --- |
| M01–M04 | F01 validate 四边界（name 空/长度、desc 空/长度） |
| M05–M06 | F02 注册表（重复检查、validate 先行） |
| M07–M11 | frontmatter 解析（首行/闭合/compat 标量/metadata/body） |
| M12–M13 | 差分层（guard_known、known_failure 注册） |
| M14 | 非映射 frontmatter 被接受（0.2.0 重写） |
| M15–M16、M27 | **RBAC**（授权边界、Operator 降级、label 变异） |
| M17 | **auth 口令**（verify 恒接受） |
| M18 | **auth JWT**（claims 签发丢失） |
| M19–M20、M28 | **compactor**（占位计数、Unicode 截断 off-by-one、total_chars off-by-one） |
| M21–M22 | **storage**（put no-op、delete 恒真） |
| M23–M24、M29 | **rag**（RRF 非倒数、索引 no-op、top_n 失效） |
| M25–M26 | **skill**（has_license 反转、promote 不升格） |
| M30 | **tooling_bridge**（MCP 条目被 wire JSON 替换） |

维护纪律：`old_sub` 必须随实现演进同步——0.2.0 中 M09/M11/M14 因 `moon fmt` 重排失效（NOT-APPLIED），已改写并复验 30/30。

## 沙箱执行器覆盖（F09）

| 执行器 | 目标 | 状态 |
| --- | --- | --- |
| `StubSandbox`（契约桩） | 四目标 | ✅ 全分型（空模块/零燃料/缺入口） |
| `WasmJsSandbox`（执行器①） | js | ✅ **echo(42)=42 实测**；js 目标 62/62 |
| @process 进程隔离（②） | native | ⬜ |
| wasmoon JIT（③） | native | ⬜（GAP-7） |

诚实边界：js 执行器**不逐指令计量燃料**（WebAssembly 无 gas 钩子）——gas ≤ 0 判 OutOfGas。

## 页面与演示（0.2.0 新增）

- `agentskills/playground`：11 个非 raise 导出（解析/校验/注册/RBAC/压缩/截断/RRF/字符统计/MCP 条目），错误折叠为 `{"ok":false}` / false / -1。
- `docs/index.html`：库首页范式（Hero 实时解析、12 能力卡、9 演示卡、深浅主题、Open Graph、响应式）。
- `check_pages.mjs` 123 项：结构锚点、钩子存在、11 导出可调用、语义断言（解析字段、shortlex 名称、RBAC 矩阵、压缩占位、截断 codepoint、RRF 前缀、MCP 条目）、版本与口径一致性。
- CDP E2E 17 项：真实浏览器点击 10 个演示按钮并校验输出、Hero 初始化、主题切换。

## 运行级验证

- `examples/interconnect_demo`：双智能体互连五环节 OK
- `examples/storage_pg_demo`：PostgreSQL 18.4 真实联测（凭据经 `PG_PASSWORD`）
- `examples/storage_jsonl_demo`：JSONL 往返 OK

## 环境差异（诚实台账）

- 本地 native：moon 0.1.20261117；CI：`latest` 通道。
- `moon coverage` 在 Windows 本地有路径拼接 bug（`.\\E:\\...`）——统一经 **WSL 通道**测量；陈旧 `_build` 会影响 coverage 源文件解析（先清理后测）。
- 库代码未覆盖 3 行清单：frontmatter 1（防御分支）+ jsonl 2（编码/解码边缘分支）——边际收益递减，如实记录不再强补。
- `docs/index.md` 已删除（Jekyll 页面并入静态 `index.html`）；`_config.yml` 保留但不再依赖主题渲染。