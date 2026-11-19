# 测试报告（2026-11-19）

> 口径纪律：所有数字为实测并带日期；变异/覆盖率通道与环境差异如实记录。

## 测试矩阵

| 层 | 规模 | 结果 |
| --- | --- | --- |
| 单元/差分测试 | **45 test 块** | 45/45 绿（native 本地实测；js / wasm / wasm-gc / native×3 OS 经 CI 实测绿——8/8 job） |
| 差分层（对上游） | **42 上游真实 fixtures** | 全绿（含 BUG-001 known_failure 隔离） |
| 属性测试 | 6 quickcheck（seed 2026–2032 固定；skill×4 + rag×2） | 全绿可复现 |
| **变异测试** | **24 变异点 / 7 功能域** | **24/24 KILLED（击杀率 100%）** |
| 覆盖率 | `moon coverage analyze`（WSL 通道） | **29 uncovered / 4 files**——库代码仅 3 行未覆盖（frontmatter 1 + jsonl 2）；cli 4 + interconnect_demo 22 属演示代码 |

## 变异矩阵（24 点）

| 编号 | 目标域 |
| --- | --- |
| M01–M04 | F01 validate 四边界（name 空/长度、desc 空/长度） |
| M05–M06 | F02 注册表（重复检查、validate 先行） |
| M07–M11 | frontmatter 解析（首行/闭合/compat String/metadata/body） |
| M12–M13 | 差分层（guard_known、known_failure 注册） |
| M14 | 未知字段拒绝 |
| M15–M16 | **RBAC**（授权边界兼具、Operator 降级） |
| M17 | **auth 口令**（verify 恒接受） |
| M18 | **auth JWT**（claims 签发丢失） |
| M19–M20 | **compactor**（占位计数、Unicode 截断 off-by-one） |
| M21–M22 | **storage**（put no-op、delete 恒真） |
| M23–M24 | **rag**（RRF 非倒数、索引 no-op） |

## 运行级验证

- `examples/interconnect_demo`：双智能体互连五环节（ATR 注册→ADP 发现→单播→群组扇出→变异信封拒收→不变量）OK
- `examples/storage_jsonl_demo`：JSONL 往返 OK（中文/多行/制表）

## 环境差异（诚实台账）

- 本地 native：moon 0.1.20261117；CI：`latest` 通道（CDN 版本化对象 403 期，详见根 README 与 commit 记录）
- `moon coverage` 在 Windows 本地有路径拼接 bug（`.\\E:\\...`）——统一经 **WSL 通道**测量；陈旧 `_build` 会影响 coverage 源文件解析（先清理后测）
- 库代码未覆盖 3 行清单：frontmatter 1（防御分支）+ jsonl 2（编码/解码边缘分支）——边际收益递减，如实记录不再强补