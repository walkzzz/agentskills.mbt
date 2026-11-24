# 性能与资源报告（agentskills.mbt 0.2.0）

> 本文只记录**实测**数字与可复算口径；未采集的对比不写倍数。

## 1. 基准可复现命令

```bash
moon build --target js --release agentskills/playground   # 演示产物
moon test --target native                                 # 功能面
moon run scripts/mutation_test.mbtx                       # 变异矩阵
node scripts/check_pages.mjs                              # 页面门禁
```

本仓未引入独立 bench 文件（0.2.0 未新增基准项）；性能结论以下述复杂度与实测规模为准，不宣称绝对耗时排名。

## 2. 复杂度

| 操作 | 复杂度 | 说明 |
| --- | --- | --- |
| `parse_skill_md` | O(frontmatter + body) | moonyaml 解析 + 逐行扫描 |
| `validate` | O(1) | 长度/非空检查 |
| `SkillRegistry::register` / `lookup` / `promote` | O(log n) | `Map[String, (SkillManifest, LoadLevel)]` |
| `SkillRegistry::names` | O(n log n) | 排序输出（shortlex） |
| `RagIndex::search` | 由 MoonRetrieve BM25 决定 | 外部引擎 |
| `rrf_fuse` | O(Σ\|ranking\| + n log n) | 计分 + 排序 |
| `rrf_fuse_top` | O(Σ\|ranking\| + n log n + top_n) | 精确前缀，不改变排序语义 |
| `compact` | O(m) | 单次分组 + 切片 |
| `truncate_chars` | O(min(len, max_chars) + len) | codepoint 遍历 |
| `total_chars` | O(Σlen) | 与截断同口径 |
| `can_access` | O(1) | 枚举 rank 比较 |
| `Auditor::record` | O(1) 摊销 | 追加数组 |
| `Auditor::denied_count` | O(n) | 全量扫描（诊断用） |

## 3. 演示层实测规模

`playground` 在浏览器（js 目标）中执行的典型输入：

| 场景 | 输入 | 结果 |
| --- | --- | --- |
| SKILL.md 解析 | 9 行 frontmatter + 正文 | name/description/license/compatibility/body_chars |
| 注册表演示 | 3 个技能名 | shortlex 清单 + 升格首个 |
| RBAC 矩阵 | 静态 3×3 | 9 条布尔 + 级别/标签 |
| 压缩 | 4 条消息，keep_recent=2 | system 保留 + 1 条占位 + 2 条最近 |
| RRF | 2–3 路排名，top_n=5 | 分数降序 + doc_id tie-break |
| 字符统计 | 中文 + emoji | 按 codepoint 计数（与截断一致） |

## 4. 覆盖率与质量口径

- 测试：native 61/61；js 62/62（含 js-only 执行器）；wasm / wasm-gc 各 61/61（2026-11-24）。
- 覆盖率（WSL 通道，`moon coverage analyze` + `report -f full_summary`）：**核心 424/433 = 97.9%**；未覆盖 9 行（jsonl 2 / frontmatter 4 / compactor 3）；`cli` / `playground` / `examples` / `proof` 不计入库口径。
- 变异：30 点全部 KILLED（7 功能域；详见 TEST_REPORT）。
- 形式化：`verify/proof` 8 goals proved（燃料账本 / 占位计数 / RBAC 授权）。
- 差分：42 个上游 SKILL.md 冻结期望；1 例登记 knowe_failure（BUG-001，UP-019 frontmatter 被 moonyaml 拒绝）。
- 页面门禁：`node scripts/check_pages.mjs` **142 项 PASS**；CDP E2E **29 项 PASS**（含 939px 窄屏导航）。

## 5. 资源占用

- Kernel 域无全局状态、无线程、无隐藏缓冲；
- 存储后端按需选择：内存（测试/演示）/ JSONL（本地持久）/ PostgreSQL（生产联测）；
- 沙箱执行器按目标选择：`sandbox_js`（js-only，WebAssembly 无 gas 钩子）/ 进程隔离 / wasmoon（后续）。