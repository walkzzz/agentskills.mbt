# agentskills.mbt 在线演示页 全面测试报告

- 目标页面：https://walkzzz.github.io/agentskills.mbt/
- 测试方式：真实浏览器（Aha Browser Use / bu 平面）逐项操作 + DOM/可访问性读取 + 控制台与网络监听 + 外部链接状态核验
- 测试时间：2026-11-24（UTC+8）
- 视口：939 × 872（页面按 924 CSS px 渲染，页面高 11827 px）
- 页面版本：标题栏 v0.2.0
- 与上一页关系：与 gbz185.mbt 同一套页面模板（topbar / nav / hero / demo-grid / quality 结构一致），模板级缺陷会同时影响两个站点

## 一、结论摘要

功能面表现扎实：9 张演示卡默认用例 9/9 通过且输出与页面文档标注的 JSON 完全一致；约 70 个测试点中，解析边界（64/1024 字符、必填项、未闭合 frontmatter、CRLF、引号、额外字段）、注册表 fail-fast、RBAC 9 组判定、Unicode 截断均按契约正确；全程 0 条控制台报错，网络仅同源 4 个文件，14 个外部链接全部 200。

发现 1 个中等级模板缺陷、1 个中等级数值缺陷、4 个低级口径问题：

| 编号 | 级别 | 问题 |
|---|---|---|
| F1 | 中 | 视口 ≤960px 时顶部导航整块消失（与 gbz185.mbt 同一模板缺陷） |
| F2 | 中 | RRF 融合对负 k 输出 `"score": "Infinity"`（字符串），且 k 经 `\|0` 转 int32 |
| F3 | 低 | 工具 MCP 条目无任何校验，空 name/description 仍生成条目并显示为成功 |
| F4 | 低 | 压缩在折叠收益为负时反而变长（默认 64 → 80 字符） |
| F5 | 低 | 截断 max_chars=0/负数/2^32 一律返回 "…"，参数无校验 |
| F6 | 低 | 字符统计把结构错误与 JSON 错误都报成 "invalid messages JSON" |

## 二、测试范围与结果

### 1. 默认用例（9 卡，逐项与页面标注输出比对）

| 卡片 | 函数 | 实测要点 | 与标注 | 结果 |
|---|---|---|---|---|
| SKILL.md 解析 | `skill_parse` | name demo-skill / license MIT / compat 2 / body_chars 27 | 一致 | 通过 |
| manifest 校验 | `skill_validate` | name_chars 10 / description_chars 28 | 一致 | 通过 |
| 注册表与渐进加载 | `registry_demo` | names `beta, zeta, alpha` / levels metadata×2 + fully-loaded / rejected [] | 一致 | 通过 |
| RBAC 授权矩阵 | `rbac_matrix` | 3×3 矩阵对角线阶梯正确，ranks 0/1/2 | 一致 | 通过 |
| 上下文压缩 | `compact_demo` | 保留 system、折叠 1 条、output_chars 80 | 一致（但见 F4） | 通过 |
| Unicode 安全截断 | `truncate_text` | "你好世界，这是一…"，codepoints 9 | 一致 | 通过 |
| RRF 融合 | `rrf_demo` | 4 条，分数 0.03279 / 0.03252 / 0.03200 / 0.01613 | 一致 | 通过 |
| 工具 MCP 条目 | `tool_mcp_entry` | name/description/inputSchema 三段齐全 | 一致（但见 F3） | 通过 |
| 字符预算统计 | `total_chars` | 中文 2 + emoji 2 = 4（按 codepoint） | 一致 | 通过 |

初始化即执行 `runHero` + 全部 10 个 action，首屏计数器（技能名 demo-skill / 兼容声明 2 / 正文字符 27）与解析卡结果一致。

### 2. SKILL.md 解析边界（12 例）

| 输入 | 输出 |
|---|---|
| 无 frontmatter | `missing frontmatter: first line must be '---'` |
| 空文本 | 同上 |
| 未闭合 frontmatter | `unterminated frontmatter: no closing '---'` |
| 缺 name | `name is required` |
| 只有 frontmatter（缺 description） | `description is required` |
| name = 65 字符 | `name exceeds 64 chars` |
| description = 1025 字符 | `description exceeds 1024 chars` |
| CRLF 换行 | 正常解析，body_chars 12 |
| `name: "demo-skill"`（带引号） | 正确去引号 |
| `description: "Use this: when needed"` | 冒号+空格未被误切 |
| 额外字段（title/allowed-tools/metadata） | 容忍，不影响 manifest |
| tab 缩进列表 | `invalid YAML frontmatter`（YAML 规范禁用 tab 缩进，属预期） |

### 3. manifest 校验边界（含预置示例）

- name=64 / desc=1024：`valid:true`（边界含等号）。
- name=65 / desc=1025：`valid:false` + 明确原因。
- license 空、compatibility 空：仍 `valid:true`（可选字段，符合契约）。
- "空 name 示例"预置：`{"ok":false,"valid":false,"error":"name is required"}`。

### 4. 注册表

| 用例 | 输出 | 评价 |
|---|---|---|
| alpha, alpha（重名） | count 1，rejected ["alpha"]，先从 Metadata 升为 fully-loaded | fail-fast 生效 |
| 单个 solo | count 1，fully-loaded | 通过 |
| 空输入 | `at least one skill name required` | 通过 |
| zeta, alpha, beta, Gamma, delta | `beta, zeta, Gamma, alpha, delta` | shortlex（长度→码位）确定序正确 |
| 连点"注册"6 次 | count 3，结果不变 | 幂等 |

### 5. RBAC 9 组交叉判定

按库内矩阵逐组执行 `判定`，viewer/operator/admin × public/internal/confidential 共 9 组全部与文档矩阵一致（仅 operator+confidential 与 viewer+internal/confidential 为拒绝），0 处不一致。

### 6. 上下文压缩边界

| 用例 | 输出 | 评价 |
|---|---|---|
| keep=8（> 消息数） | input 64 / output 64，不折叠 | 通过 |
| keep=0 | output 53，折叠 3 条为占位 | 通过 |
| keep=-1 | 与 keep=0 相同（负值静默按 0） | 无报错，口径可接受 |
| budget=10 | 每条截断为"…"，output 44 | 通过 |
| budget=0 | 所有内容变成 "…"，output 4 | 未拒绝非法预算，见 F5 同类问题 |
| 空数组 `[]` | ok true，0 条 | 通过 |
| JSON 非法 | `invalid messages JSON` | 通过 |
| content 为数字 123 | `message content must be a string` | 通过 |

### 7. Unicode 安全截断

| 用例 | 输出 | 结论 |
|---|---|---|
| n=8 中文 | `你好世界，这是一…`（9 codepoints） | 正确（n 截断 + 省略号） |
| n=0 / n=-1 | `…`（1 codepoint） | 超出上限 1 字符，见 F5 |
| n > 文本长度 | 原样返回 `abc`，不加省略号 | 正确 |
| 5 个 emoji，n=2 | `🙂🙂…`，未劈开代理对 | 正确 |
| 组合字符 `e+U+0301`，n=2 | `é…`，按 codepoint 保留组合序列 | 正确 |
| 空文本 | `""`，codepoints 0 | 正确 |
| n=4294967296 | `…`（`\|0` 后为 0） | 见 F5 |

### 8. RRF 融合

| 用例 | 输出 | 评价 |
|---|---|---|
| rankings=[] | count 0，hits [] | 通过 |
| 单路 `[["a","b"]]` | 2 条，分数按 1/(60+rank) | 通过 |
| top_n=0 | count 0（空前缀） | 通过 |
| top_n=99 | 全量 4 条（有界返回为全量前缀） | 通过 |
| 单列重复 doc `["a","a","b"]` | a 计两次排名，分数 0.03252 | 与公式一致 |
| rankings 非 JSON | `invalid rankings JSON` | 通过 |
| k=0 | 分数 2 / 1.5 / 0.833 / 0.5（1/rank） | 数学上成立，未拒绝 |
| **k=-1** | `"score": "Infinity"`（字符串！） | **异常，见 F2** |
| k=2^32 | 与 k=0 完全相同（`\|0` 回绕） | 见 F2 |

### 9. 工具 MCP 条目与字符统计

- 工具条目：空 name、空 description、全空、200 字符长名，四种都返回结构完整的条目且样式为"成功"（见 F3）。
- 字符统计：`[]`→0；坏 JSON / 缺 content / content 非字符串→统一报 `invalid messages JSON`（见 F6）；`你好`+`🙂🙂`→4，按 codepoint 计数正确。

### 10. 交互、视觉与网络

- 锚点：立即试用 → #demo（scrollY 2114，区块顶部 80px）、快速开始 → #start（7701，顶部 80px），正确避让吸顶栏。
- 主题：light → dark，图标与 aria-label 同步；刷新后仍为 dark（localStorage 生效）。
- 复制按钮 6 个（安装/工程门禁/演示产物/三段代码）：点击后文案"已复制"，1.4s 后恢复"复制"。
- 响应式：939px 下 hero 与 demo 均单列（876px），无横向溢出（scrollWidth 924 = clientWidth 924）；导航缺失见 F1。
- 网络：仅 `index.html / style.css / app.js / playground.js` 四个同源资源，主机仅 walkzzz.github.io，无第三方请求、无后端调用。
- 体积与耗时：index 30.7KB、style 16.1KB、app 7.9KB、**playground 543.9KB**；DCL 735ms、load 746ms（对比 gbz185.mbt 的 350KB / 220ms，体积是主要成本）。
- 外部链接 14 个（仓库、docs 8 篇、components/README、mooncakes、CHANGELOG、CONTRIBUTING）全部 200。
- 控制台：全流程 0 条 error/warning。

### 11. 可访问性基线

`lang="zh-CN"`、`.skip-link` 存在、唯一 H1、无重复 id、按钮均有文本、10 张卡全部输入均有 label、可聚焦元素 78 个、无图片（无 alt 问题）。

## 三、问题详情

### F1（中，模板级）窄屏导航整体缺失

- 现象：`@media (max-width:960px)` 中 `.nav { display:none; }`，实测 924px 视口下 `.nav` 尺寸 0×0，页面无折叠菜单/汉堡入口，顶部仅剩 brand、主题、GitHub（见 agentskills-hero.png、agentskills-demo.png）。
- 影响：13 寸笔电与非最大化窗口下，能力/在线演示/快速开始/API/工程质量/文档 六个入口全部不可达；与 gbz185.mbt 完全同源，建议在共享 CSS 一次性修复（原样式已具备 `overflow-x:auto`，只是被 display:none 覆盖）。
- 建议：≤960px 保留横向可滚动导航，或增加菜单按钮 + 抽屉。

### F2（中）负 k 产生 Infinity 且分数类型错误

- 复现：rankings 默认值、k = -1、top_n = 3 → `{"ok":true,"hits":[{"doc_id":"skill-parse","score":"Infinity"},{"doc_id":"skill-registry","score":"Infinity"},{"doc_id":"skill-rbac","score":1.5}]}`。
- 根因：rank 从 1 开始，`1/(k+rank)` 在 k=-1 时对 rank 1 分母为 0；非有限浮点在序列化时退化为字符串 `"Infinity"`，破坏 `score: number` 的契约。
- 附带：`Number(k) | 0` 使 k=4294967296 等同 k=0，k 超出 int32 即失真。
- 建议：k ≤ 0 时返回 `{"ok":false,"error":"k must be > 0"}`；对 `Number.isFinite` 做兜底（跳过或截断为极大值）；k 用 `Number.isSafeInteger` 校验而不是 `|0`。

### F3（低）工具条目无校验

- 现象：name="" / description="" / 二者皆空，均返回 `{name:"",description:"",inputSchema:{...}}` 且结果框为绿色成功态。
- 影响：MCP `tools/list` 条目要求非空 name，此卡却允许空 name 通过，读者可能误判桥接层具备校验能力（对比同项目 gbz185.mbt 的 `tool_descriptor_check` 会拒绝空 name/description）。
- 建议：桥接函数增加 name/description 非空与长度校验，或把卡片文案明确为"仅结构映射，不做校验"。

### F4（低）压缩可能反向膨胀

- 现象：默认参数 input_chars 64 → output_chars 80（+25%）。原因是折叠出的 `[compacted 1 earlier messages]` 比被折叠的 `first question` 更长。
- 影响：作为"上下文压缩"演示，出现"越压越大"，与直觉和成本目标相悖。
- 建议：当占位长度 ≥ 被折叠内容长度时跳过折叠（或缩短占位文案），并在输出中增加 `saved_chars` 便于判断收益。

### F5（低）截断参数无校验

- 现象：max_chars = 0、-1、4294967296 一律返回 `"…"`（1 个 codepoint），即结果长度超出给定上限；负值被静默按 0 处理。
- 建议：max_chars ≤ 0 时返回 `{"ok":false,"error":"max_chars must be > 0"}` 或返回空串；对超 int32 的输入拒绝而不是回绕。

### F6（低）字符统计错误信息粒度不足

- 现象：`[{"role":"user"}]`（缺 content）与 `[{"role":"user","content":1}]`（类型错误）都报 `invalid messages JSON`，与真正的 JSON 语法错误无法区分。
- 建议：区分 `invalid messages JSON` / `message content must be a string`，与压缩卡保持一致。

补充说明（不计缺陷）：
- 预置示例按钮（非法示例 / 空 name 示例）会把输入框改成非法值且没有复位入口，需要刷新才能回到默认态；同时首屏 hero 卡片只在初始化时运行，与 demo 区状态可能不一致。
- playground.js 单文件 544KB，首屏 load 746ms，可在发布时压缩或拆分，收益明显。

## 四、通过项清单

- 9 张演示卡默认输出与页面标注逐字段一致，初始化即全部执行。
- 解析契约精确：frontmatter 缺失/未闭合、name/description 必填、64/1024 边界、CRLF、引号、额外字段、tab 缩进（按 YAML 规范拒绝）全部符合预期。
- 注册表：重名 fail-fast + rejected 清单、空输入报错、shortlex 确定性序、升格幂等。
- RBAC：9/9 判定与矩阵一致。
- 压缩：keep>消息数不折叠、budget 截断、类型校验、空数组。
- 截断：Unicode 安全（emoji/组合字符不劈开）、超长原样返回、空文本。
- RRF：空输入、单路、top_n 边界（0 与全量前缀）、重复 doc、非法 JSON。
- 字符统计：按 codepoint 计数（中文 2 + emoji 2 = 4）。
- 主题切换与持久化、锚点避让、复制反馈、连点幂等。
- 0 第三方请求、0 控制台报错、14 个外链全部 200。
- 可访问性基线（lang / skip-link / 单 H1 / 无重复 id / label 全覆盖）。

## 五、建议优先级

1. F1 与 gbz185.mbt 一并修复（同一段 CSS，一次改动覆盖两个站点）。
2. F2 修负 k 与非有限分数（会直接输出非法 JSON 类型）。
3. F3、F5 补参数校验；F4 优化压缩收益判断；F6 细化错误文案。
4. 发布侧压缩 playground.js（544KB → 目标一半以内），可直接把 load 从 746ms 压到 400ms 级。

## 附：测试证据

- agentskills-hero.png：首屏（939px 宽下顶部导航缺失）
- agentskills-demo.png：SKILL.md 解析卡默认输出
- agentskills-rrf-infinity.png：k=-1 时 `"score": "Infinity"` 的现场
