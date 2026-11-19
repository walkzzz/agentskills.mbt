///|
///verify 模块：fixture 资产 + 差分验证 + mockgen（原 testkit 并入，ARCH §2.5 钉扎 2）。
///FIXTURE_TARGET = 40 是 M0 验收门（Charter §4）；实际冻结 42 例（2026-11-19，
///全部来自上游 UCToo/agentsskills-runtime skills/ 的真实 SKILL.md，实测期望独立于
///F01 实现生成——差分层语义：解析输出与冻结字面量逐字段对比）。
pub const FIXTURE_TARGET : Int32 = 40

///|
///Fixture — 冻结的差分样本：SKILL.md 输入 + 期望的 frontmatter 解析结果。
pub(all) struct Fixture {
  id : String
  skill_md : String
  expect_name : String
  expect_description : String
  expect_license : String?
}

///|
///fixtures — 冻结样本清单（42 例：UP-001..UP-042，覆盖上游全量技能）。
pub let fixtures : Array[Fixture] = [
  {
    id: "UP-001",
    skill_md: "---\nname: cangjie-build-diagnose\ndescription: \"提供仓颉项目构建与运行故障诊断文档，包括cjc/cjpm编译报错诊断与修复/运行时异常定位与修复/CFFI与链接故障/编译器崩溃/SDK版本回归/问题复现与验证等\"\n---\n\n# fixture body\n",
    expect_name: "cangjie-build-diagnose",
    expect_description: "提供仓颉项目构建与运行故障诊断文档，包括cjc/cjpm编译报错诊断与修复/运行时异常定位与修复/CFFI与链接故障/编译器崩溃/SDK版本回归/问题复现与验证等",
    expect_license: None,
  },
  {
    id: "UP-002",
    skill_md: "---\nname: cangjie-code-review\ndescription: \"提供仓颉代码审查与优化文档，包括高性能编码与性能优化/OOM与RSS增长取证/堆增长与内存泄漏分析/资源释放与内存优化/基准测试/CPU热点/延迟与吞吐/问题修复与验证等\"\n---\n\n# fixture body\n",
    expect_name: "cangjie-code-review",
    expect_description: "提供仓颉代码审查与优化文档，包括高性能编码与性能优化/OOM与RSS增长取证/堆增长与内存泄漏分析/资源释放与内存优化/基准测试/CPU热点/延迟与吞吐/问题修复与验证等",
    expect_license: None,
  },
  {
    id: "UP-003",
    skill_md: "---\nname: cangjie-coding\ndescription: \"提供仓颉编程语言的完备知识库及辅助工具，覆盖仓颉语言特性、标准库、扩展标准库、工具链与典型应用案例，渐进披露、按需查询，助你高效学习仓颉知识、完成仓颉项目开发。\"\n---\n\n# fixture body\n",
    expect_name: "cangjie-coding",
    expect_description: "提供仓颉编程语言的完备知识库及辅助工具，覆盖仓颉语言特性、标准库、扩展标准库、工具链与典型应用案例，渐进披露、按需查询，助你高效学习仓颉知识、完成仓颉项目开发。",
    expect_license: None,
  },
  {
    id: "UP-004",
    skill_md: "---\nname: rsi\ndescription: >\n  ASR 自进化系统（Recursive Self-Improvement，RSI）技能——把《人工智能软件工程方法论》落地为可执行的闭环：\n  以确定性代码生成工具（loaddbinfo/crudgen/crudweb/plugingen）保障框架级结构正确性，LLM 仅在胶水逻辑等非标准处生成代码，\n  驱动\"代码+技能+数据库\"三大基础设施闭环自进化；综合编排 SDD 流水线、多技能并行、LRT 长程任务与一切皆技能插件机制。\n  触发词：\"自进化\"、\"RSI\"、\"递归自改进\"、\"框架自我演进\"、\"让框架自己进化\"、\"代码+技能+数据库闭环\"、\n  \"AI 驱动开发框架自主进化\"、\"按方法论做一次演进\"。\nlicense: MIT\nversion: \"0.1.0\"  # 2026-10-17 初版，与 specs/RSI SDD 同源\ncompatibility: >\n  需要宿主侧能力：L3 进程隔离轨插件宿主（CordisHostManager + host.db 服务代理）、\n  SDD 编排（skills/sdd）、多技能并行（src/skill/parallel）、LRT 长程任务（src/app/services/lrt/）、\n  确定性代码生成工具链（src/app/tools + src/plugin/tools）、UMI 数据架构（docs/uctoo-v4）。\n  自身建议以 L3 process 轨插件形态落地（对齐 plugingen 默认轨）。\nmetadata:\n  author: UCToo Team\n  category: recursive-self-improvement\n  tags: [\"rsi\", \"self-improvement\", \"spec-driven\", \"deterministic-codegen\", \"ai-driven-dev-framework\", \"闭环自进化\"]\nallowed-tools: filesystem, cli, skill\n---\n\n# fixture body\n",
    expect_name: "rsi",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-005",
    skill_md: "---\nname: ai-dev-demo\ndescription: AI-driven development demo that showcases the complete SDD workflow with AgentTeams collaboration. Orchestrates spec→design→task→code→verify with team-based execution. Trigger on \"AI dev demo\", \"run demo\", \"AI驱动开发Demo\", \"演示\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: demo-orchestrator\ninputs:\n  - name: requirement\n    type: string\n    required: true\n    description: 需求描述（如：为employee表生成全栈CRUD模块）\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\n  - name: team_config\n    type: string\n    required: false\n    description: AgentTeams配置名称\noutputs:\n  - name: spec_path\n    type: string\n    description: 生成的spec.md路径\n  - name: design_path\n    type: string\n    description: 生成的design.md路径\n  - name: tasks_path\n    type: string\n    description: 生成的tasks.md路径\n  - name: code_files\n    type: string[]\n    description: 生成的代码文件列表\n  - name: verification_passed\n    type: boolean\n    description: 验证是否通过\n  - name: evidence_chain_valid\n    type: boolean\n    description: 证据链完整性校验\n  - name: total_duration_ms\n    type: integer\n    description: 总耗时（毫秒）\ndependencies:\n  - sdd-flow\n  - fullstack-codegen\n---\n\n# fixture body\n",
    expect_name: "ai-dev-demo",
    expect_description: "AI-driven development demo that showcases the complete SDD workflow with AgentTeams collaboration. Orchestrates spec→design→task→code→verify with team-based execution. Trigger on \"AI dev demo\", \"run demo\", \"AI驱动开发Demo\", \"演示\".",
    expect_license: None,
  },
  {
    id: "UP-006",
    skill_md: "---\nname: app-coder\ndescription: 原生应用 / 小程序代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化微信小程序、移动端原生应用代码时使用。遵循确定性优先：先在目标工程查到确定依据（既有实现 + 官方文档）再写代码，禁止凭跨栈经验臆造 API。\nversion: 1.0.0\nauthor: UCToo\n# 纯技能形态：本技能**不建 agents/ 目录、不派生编码子 agent**（SDD tasks.md v3 决策）。\ndependencies:\n  - frontend-dev            # 过渡期路由：app-coder 未挂载时的降级技能\n---\n\n# fixture body\n",
    expect_name: "app-coder",
    expect_description: "原生应用 / 小程序代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化微信小程序、移动端原生应用代码时使用。遵循确定性优先：先在目标工程查到确定依据（既有实现 + 官方文档）再写代码，禁止凭跨栈经验臆造 API。",
    expect_license: None,
  },
  {
    id: "UP-007",
    skill_md: "---\nname: beichen-finance-matching\ndescription: 金融匹配智能体（北辰金融匹配智能体）—— 实现北辰命题\"金融服务体系化\"课题的产业金融服务 SOP 全流程线上化，解决企业\"融资难、对接繁、流程慢\"痛点。采集企业融资需求并初步审核，基于金融工具数据库（90+ 金融伙伴与产品）智能匹配优势金融机构，生成定制融资方案与对接材料包，按北辰金融 SOP 六阶段时效（1d/1d/2d/3-5d/约定时限/长期）跟踪进度与超期提醒，结果写入 company 表与 tasks 表并通过 aibuilder 呈现。触发词：\"融资匹配\"、\"金融服务\"、\"融资需求\"、\"贷款对接\"、\"金融方案\"、\"机构匹配\"、\"融资智能体\"。\nlicense: MIT\nversion: \"1.0.0\"\ncompatibility: 需要 runtime 内置工具支持（cli_execute/file_read/file_write/http_request/web_fetch/web_search）。脚本优先使用 TypeScript 版本（Node.js v23.10+，原生支持 --experimental-strip-types）；TS 版本运行有错误时降级使用 Python 版本（Python 3.8+ + requests 库，落库模式需 psycopg2-binary）\nmetadata:\n  author: UCToo Team (beichen-hackathon)\n  version: \"1.0.0\"\n  category: fintech\n  tags: [\"beichen\", \"fintech\", \"financing\", \"matching\", \"SOP\", \"融资\", \"金融\"]\nallowed-tools: network, filesystem, cli\n---\n\n# fixture body\n",
    expect_name: "beichen-finance-matching",
    expect_description: "金融匹配智能体（北辰金融匹配智能体）—— 实现北辰命题\"金融服务体系化\"课题的产业金融服务 SOP 全流程线上化，解决企业\"融资难、对接繁、流程慢\"痛点。采集企业融资需求并初步审核，基于金融工具数据库（90+ 金融伙伴与产品）智能匹配优势金融机构，生成定制融资方案与对接材料包，按北辰金融 SOP 六阶段时效（1d/1d/2d/3-5d/约定时限/长期）跟踪进度与超期提醒，结果写入 company 表与 tasks 表并通过 aibuilder 呈现。触发词：\"融资匹配\"、\"金融服务\"、\"融资需求\"、\"贷款对接\"、\"金融方案\"、\"机构匹配\"、\"融资智能体\"。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-008",
    skill_md: "---\nname: beichen-policy-assistant\ndescription: 产业政策智能体（北辰产业政策智能体）—— 实现北辰命题\"政策赋能精准化\"课题的政策库—匹配库—申报库全流程 SOP。支持两类入口：① 主题/产业方向检索（不给企业名，直接检索近期可申报的产业政策，带可信度四因子与原文库交叉验证）；② 给定企业名称做全景画像→政策匹配→研判报告→申报任务→落库。触发词：\"政策匹配\"、\"政策申报\"、\"企业画像\"、\"政策智能体\"、\"能申报什么政策\"、\"产业政策\"、\"专项政策\"、\"政策查询\"、\"申报条件\"、\"检索产业政策\"、\"近期可申报\"。关联检索内核 yuanbao-search（skills/yuanbao-search/）。\nlicense: MIT\nversion: \"1.0.0\"\ncompatibility: 需要 runtime 内置工具 cli_execute（在 runtime 根目录执行子进程）。脚本优先使用 TypeScript 版本（需 Node.js v23.10.0+，原生支持 TypeScript：`node --experimental-strip-types`）；TS 版本运行有错误时降级使用 Python 版本（需 Python 3.8+ + requests 库）。\nmetadata:\n  author: UCToo Team (beichen-hackathon)\n  version: \"1.0.0\"\n  category: policy\n  tags: [\"beichen\", \"policy\", \"enterprise-profile\", \"policy-matching\", \"政策\", \"申报\"]\nallowed-tools: network, filesystem, cli\n---\n\n# fixture body\n",
    expect_name: "beichen-policy-assistant",
    expect_description: "产业政策智能体（北辰产业政策智能体）—— 实现北辰命题\"政策赋能精准化\"课题的政策库—匹配库—申报库全流程 SOP。支持两类入口：① 主题/产业方向检索（不给企业名，直接检索近期可申报的产业政策，带可信度四因子与原文库交叉验证）；② 给定企业名称做全景画像→政策匹配→研判报告→申报任务→落库。触发词：\"政策匹配\"、\"政策申报\"、\"企业画像\"、\"政策智能体\"、\"能申报什么政策\"、\"产业政策\"、\"专项政策\"、\"政策查询\"、\"申报条件\"、\"检索产业政策\"、\"近期可申报\"。关联检索内核 yuanbao-search（skills/yuanbao-search/）。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-009",
    skill_md: "---\nname: cangjie-coder\ndescription: 仓颉代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化任何 .cj 仓颉代码文件时,必须使用此技能。主 agent 加载后按四步工作流自行执行：查阅文档 → 检索代码片段 → 编辑适配 → 写入文件，再按验证结果修复闭环（最多 3 次）。此技能确保所有仓颉代码完全符合语言规范,并提供最佳实践指导。\nversion: 4.0.0\nauthor: OpenCangjie Team\n# 知识库依赖：与本项目同目录的 ../CangjieSkills（渐进披露知识库，经 scripts/search_docs.py 查询），\n# 不再依赖旧版 cangjie-language-guide / cangjie-full-docs 静态文档布局。\ndependencies: []\n# 说明：原 `agents:` 声明键与 skills/cangjie-coder/agents/ 目录已按 SDD tasks.md v3/T-18\n# **下线**——\"换脑子的才派生，换说明书的用技能\"：编码不需要换脑子，需要的是确定的\n# API 依据与工程内既有范式。四角色职责已并入下方「四步工作流」，由主 agent 直接执行。\nscripts:\n  - cangjie_syntax_check.ts  # TypeScript 版本（推荐）\n  - cangjie_compile.ts       # TypeScript 版本（推荐）\n  - cangjie_test_runner.ts   # TypeScript 版本（推荐）\n  - cangjie_fix_suggest.ts   # TypeScript 版本（推荐）\n  - cangjie_syntax_check.py  # Python 降级备选\n  - cangjie_compile.py       # Python 降级备选\n  - cangjie_test_runner.py   # Python 降级备选\n  - cangjie_fix_suggest.py   # Python 降级备选\n  - pkggraph.ts             # 包级循环依赖检测（TypeScript，推荐）\n  - pkggraph.py             # 包级循环依赖检测（Python 降级备选）\n---\n\n# fixture body\n",
    expect_name: "cangjie-coder",
    expect_description: "仓颉代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化任何 .cj 仓颉代码文件时,必须使用此技能。主 agent 加载后按四步工作流自行执行：查阅文档 → 检索代码片段 → 编辑适配 → 写入文件，再按验证结果修复闭环（最多 3 次）。此技能确保所有仓颉代码完全符合语言规范,并提供最佳实践指导。",
    expect_license: None,
  },
  {
    id: "UP-010",
    skill_md: "---\nname: code-gen-verifier\ndescription: 代码生成验证技能。验证crud-generator生成的代码是否可编译、是否符合仓颉语言规范、是否遵循uctoo-v4模块开发规范。当代码生成后需要自动验证时使用。触发词：\"验证生成代码\"、\"code-gen-verifier\"、\"verify generated code\"。\nversion: 1.1.0\nauthor: OpenCangjie Team\ninputs:\n  - name: files\n    type: string[]\n    required: true\n    description: 需要验证的生成文件路径列表\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\n  - name: verify_level\n    type: string\n    default: \"compile\"\n    description: 验证级别（syntax/compile/test）\noutputs:\n  - name: passed\n    type: boolean\n    description: 验证是否通过\n  - name: errors\n    type: object[]\n    description: 错误列表\n  - name: warnings\n    type: object[]\n    description: 警告列表\n  - name: fix_suggestions\n    type: object[]\n    description: 修复建议列表\ndependencies:\n  - cangjie-coder\n---\n\n# fixture body\n",
    expect_name: "code-gen-verifier",
    expect_description: "代码生成验证技能。验证crud-generator生成的代码是否可编译、是否符合仓颉语言规范、是否遵循uctoo-v4模块开发规范。当代码生成后需要自动验证时使用。触发词：\"验证生成代码\"、\"code-gen-verifier\"、\"verify generated code\"。",
    expect_license: None,
  },
  {
    id: "UP-011",
    skill_md: "---\nname: codelabs\ndescription: >\n  CRUD capability for the {{tableName}} table ({{dbName}} database)\n  provided by the codelabs plugin. Supports create, update, soft-delete,\n  restore, paged list with Prisma-style filter/sort. Triggers on:\n  {{tableName}} data management requests, codelabs plugin capability discovery.\nlicense: MIT\nplugin: codelabs\nservice: skill_codelabs.CodelabsService\nroute: /api/v1/{{dbName}}/{{tableName}}\n---\n\n# fixture body\n",
    expect_name: "codelabs",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-012",
    skill_md: "---\nname: crud-generator\ndescription: Generate standard CRUD modules for UCToo V4 with DAO layer. Use this skill when the user wants to create a new database module, scaffold CRUD operations, or generate boilerplate code for a database table. The skill uses the crudgen command-line tool to read database structure from db_info table and generate Model, DAO, Service, Controller, Route files in Cangjie language. It also generates permission nodes automatically. Trigger when user mentions \"generate CRUD\", \"create module\", \"scaffold\", \"new table\", \"add entity\", \"为xxx表生成CRUD\" or \"创建xxx模块\".\nversion: 2.0.0\nauthor: OpenCangjie Team\ninputs:\n  - name: table_name\n    type: string\n    required: true\n    description: 要生成CRUD代码的数据库表名\n  - name: database\n    type: string\n    required: true\n    description: 数据库名称（对应db_info表中的table_catalog）\n  - name: generate_backend\n    type: boolean\n    default: true\n    description: 是否生成后端CRUD代码\n  - name: generate_frontend\n    type: boolean\n    default: true\n    description: 是否生成前端CRUD页面\n  - name: output_dir\n    type: string\n    default: \"./src/app\"\n    description: 输出目录\noutputs:\n  - name: files\n    type: string[]\n    description: 生成的文件路径列表\n  - name: api_endpoints\n   \n---\n\n# fixture body\n",
    expect_name: "crud-generator",
    expect_description: "Generate standard CRUD modules for UCToo V4 with DAO layer. Use this skill when the user wants to create a new database module, scaffold CRUD operations, or generate boilerplate code for a database table. The skill uses the crudgen command-line tool to read database structure from db_info table and generate Model, DAO, Service, Controller, Route files in Cangjie language. It also generates permission nodes automatically. Trigger when user mentions \"generate CRUD\", \"create module\", \"scaffold\", \"new table\", \"add entity\", \"为xxx表生成CRUD\" or \"创建xxx模块\".",
    expect_license: None,
  },
  {
    id: "UP-013",
    skill_md: "---\nname: due-diligence-agent\ndescription: 企业信用与风控尽调智能体 —— 自动采集天眼查企业数据、股权穿透、风险分级、生成结构化尽调报告并入库。触发词：\"尽调\"、\"企业尽调\"、\"信用尽调\"、\"风控尽调\"、\"供应商尽调\"、\"客户授信\"、\"投资尽调\"、\"竞对分析\"、\"合规排查\"、\"Due Diligence\"、\"KYB\"。\nlicense: MIT\nversion: \"1.0.0\"\ncompatibility: 需要 runtime 内置工具支持（cli_execute/file_read/file_write/http_request），脚本执行需 Node.js v23.10.0（原生 TypeScript 支持，优先）或 Python 3.8+ + requests 库（降级备份），天眼查 MCP 凭证（TIANYANCHA_MCP_TOKEN）\nmetadata:\n  author: UCToo Team\n  version: \"1.0.0\"\n  category: risk-management\n  tags: [\"due-diligence\", \"credit-risk\", \"kyb\", \"tianyancha\", \"enterprise-screening\", \"尽调\", \"风控\"]\nallowed-tools: network, filesystem, cli\n---\n\n# fixture body\n",
    expect_name: "due-diligence-agent",
    expect_description: "企业信用与风控尽调智能体 —— 自动采集天眼查企业数据、股权穿透、风险分级、生成结构化尽调报告并入库。触发词：\"尽调\"、\"企业尽调\"、\"信用尽调\"、\"风控尽调\"、\"供应商尽调\"、\"客户授信\"、\"投资尽调\"、\"竞对分析\"、\"合规排查\"、\"Due Diligence\"、\"KYB\"。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-014",
    skill_md: "---\nname: entity\ndescription: >\n  CRUD capability for the entity table (uctoo database)\n  provided by the entity plugin. Supports create, update, soft-delete,\n  restore, paged list with Prisma-style filter/sort. Triggers on:\n  entity data management requests, entity plugin capability discovery.\nlicense: MIT\nplugin: entity\nservice: magic.plugins.entity.EntityService\nroute: /api/v1/uctoo/entity\n---\n\n# fixture body\n",
    expect_name: "entity",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-015",
    skill_md: "---\nname: feedback\ndescription: >\n  CRUD capability for the feedback table (uctoo database)\n  provided by the feedback plugin. Supports create, update, soft-delete,\n  restore, paged list with Prisma-style filter/sort. Triggers on:\n  feedback data management requests, feedback plugin capability discovery.\nlicense: MIT\nplugin: feedback\nservice: magic.plugins.feedback.FeedbackService\nroute: /api/v1/uctoo/feedback\n---\n\n# fixture body\n",
    expect_name: "feedback",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-016",
    skill_md: "---\nname: find-skills\ndescription: Helps users discover and install agent skills when they ask questions like \"how do I do X\", \"find a skill for X\", \"is there a skill that can...\", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.\n---\n\n# fixture body\n",
    expect_name: "find-skills",
    expect_description: "Helps users discover and install agent skills when they ask questions like \"how do I do X\", \"find a skill for X\", \"is there a skill that can...\", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.",
    expect_license: None,
  },
  {
    id: "UP-017",
    skill_md: "---\nname: firecrawl-scraper\ndescription: Scrape web content using Firecrawl\nauthor: UCToo\nversion: 1.0.0\nlicense: MIT\n---\n\n# fixture body\n",
    expect_name: "firecrawl-scraper",
    expect_description: "Scrape web content using Firecrawl",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-018",
    skill_md: "---\nname: fullstack-codegen\ndescription: Full-stack code generation workflow that orchestrates database schema loading, CRUD generation, web UI generation, and code verification. Combines loaddbinfo, crudgen, crudweb, cangjie-coder, and code-gen-verifier skills. Trigger on \"full stack code gen\", \"generate full stack\", \"全栈代码生成\", \"完整CRUD生成\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: codegen-orchestrator\ninputs:\n  - name: table_name\n    type: string\n    required: true\n    description: 要生成代码的数据库表名\n  - name: database\n    type: string\n    required: true\n    description: 数据库名称\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\n  - name: generate_frontend\n    type: boolean\n    default: true\n    description: 是否生成前端页面\n  - name: optimize_code\n    type: boolean\n    default: true\n    description: 是否使用cangjie-coder优化代码\noutputs:\n  - name: backend_files\n    type: string[]\n    description: 生成的后端文件列表\n  - name: frontend_files\n    type: string[]\n    description: 生成的前端文件列表\n  - name: verification_passed\n    type: boolean\n    description: 代码验证是否通过\n  - name: api_endpoints\n    type: string[]\n    description: 生成的API端点列表\ndependencies:\n  - loaddbinfo\n  - crud-generator\n \n---\n\n# fixture body\n",
    expect_name: "fullstack-codegen",
    expect_description: "Full-stack code generation workflow that orchestrates database schema loading, CRUD generation, web UI generation, and code verification. Combines loaddbinfo, crudgen, crudweb, cangjie-coder, and code-gen-verifier skills. Trigger on \"full stack code gen\", \"generate full stack\", \"全栈代码生成\", \"完整CRUD生成\".",
    expect_license: None,
  },
  {
    id: "UP-019",
    skill_md: "---\nname: investment-research-assistant\ndescription: 智能投研助理（Investment Research Assistant）—— 实现金融行业\"自动抓取、清洗、提取，输出每日投资简报\"全流程最佳实践 SOP。自动抓取行情/公告/新闻等多源数据，清洗去重，提取关键投资要素（估值、财务、事件、情绪），生成结构化每日投资简报并按公司写入 company 表、研报内容写入关联 tasks 表，通过 aibuilder 模块呈现。触发词：\"投研\"、\"投资简报\"、\"研报\"、\"每日投资简报\"、\"股票分析\"、\"Investment Research\"、\"热点公司\"、\"行情\"、\"A股\"、\"复盘\"、\"盘后分析\"、\"市场资讯\"、\"估值分析\"、\"公司基本面\"、\"财报\"、\"盘前盘后\"。\nlicense: MIT\nversion: \"1.1.0\"\ncompatibility: 需要 runtime 内置工具支持（cli_execute/file_read/file_write/http_request/web_fetch），脚本执行需 Node.js ≥22.6（推荐 v23.10+）（推荐 TypeScript 版本）或 Python 3.8+ + requests 库（降级备选，落库模式需 psycopg2-binary）\nmetadata:\n  author: UCToo Team\n  version: \"1.1.0\"\n  category: fintech\n  tags: [\"fintech\", \"investment\", \"research\", \"daily-briefing\", \"投研\", \"投资简报\"]\nallowed-tools: network, filesystem, cli\ndecision-points:\n  - id: data_source\n    when: 抓取行情数据时选择数据源\n    question: 使用哪个数据源抓取行情数据？\n    options:\n      - id: tushare\n        label: Tushare\n        description: 免费 Tushare 接口，覆盖 A 股日线/分钟线\n        tradeoff: 免费但有限频限制，高频调用需加 sleep\n      - id: wind\n        label: Wind\n        description: Wind 商业接口，数据质量更高\n        tradeoff: 需付费授权，适合机构级场景\n      - id: eastmoney\n        label: 东方财富\n        description: 东方财富公开接口，无需注册\n        trad\n---\n\n# fixture body\n",
    expect_name: "investment-research-assistant",
    expect_description: "智能投研助理（Investment Research Assistant）—— 实现金融行业\"自动抓取、清洗、提取，输出每日投资简报\"全流程最佳实践 SOP。自动抓取行情/公告/新闻等多源数据，清洗去重，提取关键投资要素（估值、财务、事件、情绪），生成结构化每日投资简报并按公司写入 company 表、研报内容写入关联 tasks 表，通过 aibuilder 模块呈现。触发词：\"投研\"、\"投资简报\"、\"研报\"、\"每日投资简报\"、\"股票分析\"、\"Investment Research\"、\"热点公司\"、\"行情\"、\"A股\"、\"复盘\"、\"盘后分析\"、\"市场资讯\"、\"估值分析\"、\"公司基本面\"、\"财报\"、\"盘前盘后\"。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-020",
    skill_md: "---\nname: llm-channel-tokendance\ndescription: >\n  L3 通道适配器插件（模式B）。为 protocol=plugin:llm_channel_tokendance 的\n  llm_channel 通道提供 adapter.describe / chat / chatStream / probe 四个契约方法，\n  经 stdio JSON-RPC 被宿主调用。密钥经 host.secret 按引用名代取，进程内不落明文。\n  Triggers on: llm_channel 通道 protocol=plugin: 模式的探测/对话/能力发现，\n  Tokendance 专用网关接入。\nlicense: MIT\nplugin: llm_channel_tokendance\n---\n\n# fixture body\n",
    expect_name: "llm-channel-tokendance",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-021",
    skill_md: "---\nname: loaddbinfo\ndescription: 数据库信息加载技能。将数据库表结构信息加载到db_info表中，供crud-generator等代码生成工具读取。当用户需要同步数据库结构、更新db_info表、或在使用crudgen前准备数据时使用。触发词：\"加载数据库信息\"、\"同步表结构\"、\"loaddbinfo\"、\"load db info\"。\nversion: 1.0.0\nauthor: OpenCangjie Team\ninputs:\n  - name: database\n    type: string\n    required: true\n    description: 要加载数据库信息的数据库名称\n  - name: tables\n    type: string[]\n    required: false\n    description: 指定要加载的表名列表（为空则加载全部表）\noutputs:\n  - name: loaded_tables\n    type: string[]\n    description: 成功加载的表名列表\n  - name: table_count\n    type: integer\n    description: 加载的表数量\n  - name: column_count\n    type: integer\n    description: 加载的列数量\ndependencies: []\n---\n\n# fixture body\n",
    expect_name: "loaddbinfo",
    expect_description: "数据库信息加载技能。将数据库表结构信息加载到db_info表中，供crud-generator等代码生成工具读取。当用户需要同步数据库结构、更新db_info表、或在使用crudgen前准备数据时使用。触发词：\"加载数据库信息\"、\"同步表结构\"、\"loaddbinfo\"、\"load db info\"。",
    expect_license: None,
  },
  {
    id: "UP-022",
    skill_md: "---\nname: long-running-task\ndescription: AI 自主驱动长程任务系统 —— 接收高层目标，AI 自主规划并驱动分钟级到天级长程任务，实现\"人设目标、AI 自主规划与执行、人评审交付\"闭环。触发词：\"长程任务\"、\"自主任务\"、\"跑一个长期任务\"、\"AI 自主执行\"、\"定时自主任务\"、\"Long Running Task\"、\"Autonomous Task\"。\nlicense: MIT\nversion: \"1.1.0\"\ncompatibility: 需要 runtime 内置工具支持（cli_execute/file_read/file_write/http_request/skill），脚本执行需 Node.js ≥22.6（推荐 v23.10+）（推荐 TypeScript 版本）或 Python 3.8+（降级备选），宿主 PostgreSQL + crontab 调度引擎。L3 进程隔离轨插件（mode=process）。\nmetadata:\n  author: UCToo Team\n  version: \"1.1.0\"\n  category: autonomous-agent\n  tags: [\"long-running-task\", \"autonomous\", \"planning\", \"self-evolution\", \"长程任务\", \"自主规划\"]\nallowed-tools: network, filesystem, cli\ndecision-points:\n  - id: pause\n    when: 用户请求暂停任务\n    question: 是否暂停当前长程任务？\n    options:\n      - id: \"yes\"\n        label: 暂停\n        description: 等待当前回合完成后暂停，crontab.status=2，agent_tasks.status=5\n        tradeoff: 任务暂停但不丢失上下文，可从检查点恢复\n      - id: \"no\"\n        label: 继续\n        description: 不暂停，继续执行\n        tradeoff: 任务继续运行\n    default: \"yes\"\n    recommended: \"yes\"\n    timeout_seconds: 30\n  - id: resume\n    when: 用户请求恢复已暂停任务\n    question: 是否从检查点恢复执行？\n    options:\n      - id: \"yes\"\n        label: 恢复\n        description: 从检查点继续执行，crontab.status=1\n      \n---\n\n# fixture body\n",
    expect_name: "long-running-task",
    expect_description: "AI 自主驱动长程任务系统 —— 接收高层目标，AI 自主规划并驱动分钟级到天级长程任务，实现\"人设目标、AI 自主规划与执行、人评审交付\"闭环。触发词：\"长程任务\"、\"自主任务\"、\"跑一个长期任务\"、\"AI 自主执行\"、\"定时自主任务\"、\"Long Running Task\"、\"Autonomous Task\"。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-023",
    skill_md: "---\nname: multi-search-engine\ndescription: Multi search engine integration with 16 engines (7 CN + 9 Global). Supports advanced search operators, time filters, site search, privacy engines, and WolframAlpha knowledge queries. No API keys required.\ndescription_zh: \"集成 17 个搜索引擎（8 国内 + 9 国际），无需 API\"\ndescription_en: \"Multi search engine integration with 16 engines (7 CN + 9 Global). Supports adva...\"\nversion: 2.1.3\ndisplay_name: \"multi-search-engine\"\ndisplay_name_en: \"multi-search-engine\"\nvisibility: \"public\"\n---\n\n# fixture body\n",
    expect_name: "multi-search-engine",
    expect_description: "Multi search engine integration with 16 engines (7 CN + 9 Global). Supports advanced search operators, time filters, site search, privacy engines, and WolframAlpha knowledge queries. No API keys required.",
    expect_license: None,
  },
  {
    id: "UP-024",
    skill_md: "---\nname: opentiny-next-app-integration\ndescription: Use when an existing Vue 3 + Vite app needs OpenTiny TinyRobot Chat, GenUI, business WebMCP, business Skill, or PageTool integration and the installed APIs, ownership boundaries, or validation scope must be established from the project.\nlicense: MIT\nmetadata:\n  author: opentiny\n  version: '1.0.0'\n---\n\n# fixture body\n",
    expect_name: "opentiny-next-app-integration",
    expect_description: "Use when an existing Vue 3 + Vite app needs OpenTiny TinyRobot Chat, GenUI, business WebMCP, business Skill, or PageTool integration and the installed APIs, ownership boundaries, or validation scope must be established from the project.",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-025",
    skill_md: "---\nskill_type: profile\nname: personalization\ndescription: >-\n  Agent personalization layer. Combines SOUL (core purpose / values),\n  IDENTITY (role / persona), USER (who the user is), and MEMORY (persistent\n  context) into a single always-on profile skill. Injected into the\n  <profile_context> block at agent initialization, in parallel with the\n  capability skills, instead of being registered as a tool. Replaces the\n  legacy workspace-file mechanism: the OS environment where the agent is\n  installed is itself the default workspace, so no separate workspace file\n  tree is required. The persona impersonates ancient Chinese scientific\n  worthies such as Zhang Heng (张衡) and Guo Shoujing (郭守敬), and replies\n  in classical Chinese (文言文) for easy observation of the effect.\nprofile_kind: identity\nload_policy: always_on\npriority: high\nsync_scope: agent_owned\nauthoritative: true\nconflict_policy: last_write_wins\nversion: 2\n---\n\n# fixture body\n",
    expect_name: "personalization",
    expect_description: "",
    expect_license: None,
  },
  {
    id: "UP-026",
    skill_md: "---\nname: sdd-design\ndescription: Generate technical design document (design.md) based on spec.md requirements. Defines HOW to implement the requirements. Trigger on \"create design\", \"write design\", \"技术设计\", \"设计文档\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: design-agent\ninputs:\n  - name: spec_path\n    type: string\n    required: true\n    description: spec.md文件路径\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\noutputs:\n  - name: design_path\n    type: string\n    description: 生成的design.md文件路径\n  - name: interfaces_count\n    type: integer\n    description: 接口设计数量\n  - name: components_count\n    type: integer\n    description: 组件设计数量\ndependencies:\n  - sdd-spec\n---\n\n# fixture body\n",
    expect_name: "sdd-design",
    expect_description: "Generate technical design document (design.md) based on spec.md requirements. Defines HOW to implement the requirements. Trigger on \"create design\", \"write design\", \"技术设计\", \"设计文档\".",
    expect_license: None,
  },
  {
    id: "UP-027",
    skill_md: "---\nname: sdd-flow\ndescription: Orchestrate the complete SDD (Specification-Driven Development) workflow from requirements to verified code. Combines sdd-spec, sdd-design, sdd-task, cangjie-coder, and sdd-test skills. Trigger on \"SDD flow\", \"full development\", \"规范驱动开发\", \"完整开发流程\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: sdd-orchestrator\ninputs:\n  - name: requirement\n    type: string\n    required: true\n    description: 用户需求描述\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\noutputs:\n  - name: spec_path\n    type: string\n    description: 生成的spec.md路径\n  - name: design_path\n    type: string\n    description: 生成的design.md路径\n  - name: tasks_path\n    type: string\n    description: 生成的tasks.md路径\n  - name: code_files\n    type: string[]\n    description: 生成的代码文件列表\n  - name: verification_passed\n    type: boolean\n    description: 验证是否通过\ndependencies:\n  - sdd-spec\n  - sdd-design\n  - sdd-task\n  - cangjie-coder\n  - sdd-test\n---\n\n# fixture body\n",
    expect_name: "sdd-flow",
    expect_description: "Orchestrate the complete SDD (Specification-Driven Development) workflow from requirements to verified code. Combines sdd-spec, sdd-design, sdd-task, cangjie-coder, and sdd-test skills. Trigger on \"SDD flow\", \"full development\", \"规范驱动开发\", \"完整开发流程\".",
    expect_license: None,
  },
  {
    id: "UP-028",
    skill_md: "---\nname: sdd-spec\ndescription: Generate EARS-format requirements specification (spec.md) based on project description and steering context. Use when user first chats with spec-agent or needs to create/update a spec.md document. Trigger on \"create spec\", \"write spec\", \"generate requirements\", \"需求规格\", \"规格文档\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: spec-agent\ninputs:\n  - name: requirement\n    type: string\n    required: true\n    description: 用户需求描述文本\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\n  - name: steering_context\n    type: string\n    required: false\n    description: 项目约束和指导上下文（如AGENTS.md内容）\noutputs:\n  - name: spec_path\n    type: string\n    description: 生成的spec.md文件路径\n  - name: sections_count\n    type: integer\n    description: 规格文档章节数量\n  - name: requirements_count\n    type: integer\n    description: 需求条目数量\ndependencies: []\n---\n\n# fixture body\n",
    expect_name: "sdd-spec",
    expect_description: "Generate EARS-format requirements specification (spec.md) based on project description and steering context. Use when user first chats with spec-agent or needs to create/update a spec.md document. Trigger on \"create spec\", \"write spec\", \"generate requirements\", \"需求规格\", \"规格文档\".",
    expect_license: None,
  },
  {
    id: "UP-029",
    skill_md: "---\nname: sdd-task\ndescription: Generate implementation tasks (tasks.md) from design.md. Breaks design into executable coding tasks with priorities and dependencies. Trigger on \"create tasks\", \"plan tasks\", \"任务规划\", \"编码任务\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: task-agent\ninputs:\n  - name: design_path\n    type: string\n    required: true\n    description: design.md文件路径\n  - name: project_path\n    type: string\n    required: true\n    description: 项目根目录路径\noutputs:\n  - name: tasks_path\n    type: string\n    description: 生成的tasks.md文件路径\n  - name: task_count\n    type: integer\n    description: 任务总数\n  - name: total_effort_days\n    type: number\n    description: 预估总工时（天）\ndependencies:\n  - sdd-design\n---\n\n# fixture body\n",
    expect_name: "sdd-task",
    expect_description: "Generate implementation tasks (tasks.md) from design.md. Breaks design into executable coding tasks with priorities and dependencies. Trigger on \"create tasks\", \"plan tasks\", \"任务规划\", \"编码任务\".",
    expect_license: None,
  },
  {
    id: "UP-030",
    skill_md: "---\nname: sdd-test\ndescription: Execute verification and testing for SDD workflow. Runs build, lint, and tests to validate code quality. Passive design, records but does not block. Trigger on \"run tests\", \"verify code\", \"验证代码\", \"运行测试\".\nversion: 1.0.0\nauthor: OpenCangjie Team\nagent_type: qa-worker\ninputs:\n  - name: code_path\n    type: string\n    required: true\n    description: 要验证的代码路径\n  - name: verification_types\n    type: string[]\n    default: [\"build\", \"lint\", \"test\"]\n    description: 验证类型列表\noutputs:\n  - name: report_path\n    type: string\n    description: 验证报告路径\n  - name: passed\n    type: boolean\n    description: 验证是否通过\n  - name: error_count\n    type: integer\n    description: 错误数量\n  - name: warning_count\n    type: integer\n    description: 警告数量\ndependencies: []\n---\n\n# fixture body\n",
    expect_name: "sdd-test",
    expect_description: "Execute verification and testing for SDD workflow. Runs build, lint, and tests to validate code quality. Passive design, records but does not block. Trigger on \"run tests\", \"verify code\", \"验证代码\", \"运行测试\".",
    expect_license: None,
  },
  {
    id: "UP-031",
    skill_md: "---\nname: sdd\ndescription: >\n  规范驱动开发（Spec-Driven Development）—— 把一次功能开发固化为 research（可选）→ spec → design → tasks → code → test\n  六步流水线，每步产出文档化中间产物并落库可回放，每步之后设人在回路闸口。\n  各文档步由 SDD 专属子 agent 真实派生执行（非主 agent 自扮演），回传结果经契约校验后才被采信。\n  触发词：\"规范驱动开发\"、\"SDD\"、\"按 SDD 流程\"、\"六步开发\"、\"先写 spec 再写代码\"、\n  \"继续 SDD\"、\"接着 SDD 走\"、\"直接开始编码阶段\"、\"从任务分解继续\"、\"SDD 先跳过研究步\"、\n  \"拆分成多个子系统\"、\"多子系统 SDD\"、\"子系统目录\"、\"SPECS_INDEX\"、\"大工程拆分\"。\nlicense: MIT\nversion: \"1.2.1\"  # 2026-10-15：新增铁律 16「git 版本管理 SOP」（编译通过即提交 / 确认测试通过即纳入版本管理）\ncompatibility: >\n  需要 runtime 宿主侧能力：L3 进程隔离轨插件宿主（CordisHostManager + host.db 服务代理）、\n  子 agent 派生链路（ChangeDetector 同步 skills/*/agents/ + SkillManagementService bundledAgents + SubAgentTool 真派生）、\n  宿主 PostgreSQL（七张白名单表）。L3 进程隔离轨插件（mode=process）。\nmetadata:\n  author: UCToo Team\n  category: spec-driven-development\n  tags: [\"sdd\", \"spec-driven\", \"multi-agent\", \"human-in-the-loop\", \"规范驱动开发\"]\nallowed-tools: filesystem, cli, skill\nagents:\n  - name: sdd-researcher\n    role: 研究步执行者\n    file: agents/sdd-researcher.md\n    stage: research\n  - name: sdd-spec-writer\n    role: 需求规格撰写\n    file: agents/sdd-spec-writer.md\n    stage: spec\n  - name: sdd-design-writer\n    role: 设计方案撰写\n    file: agents/sdd-design-writer.md\n    stage: de\n---\n\n# fixture body\n",
    expect_name: "sdd",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-032",
    skill_md: "---\nname: skill-creator\ndescription: Create new skills, modify and improve existing skills, and measure skill performance. Use this skill whenever the user wants to create a skill from scratch, edit or modify an existing skill (e.g., add documentation, update examples, change settings), run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. When the user mentions \"modify skill\", \"update skill\", \"add to skill\", \"edit skill\", or similar phrases, you MUST use this skill and follow the modification workflow.\n---\n\n# fixture body\n",
    expect_name: "skill-creator",
    expect_description: "Create new skills, modify and improve existing skills, and measure skill performance. Use this skill whenever the user wants to create a skill from scratch, edit or modify an existing skill (e.g., add documentation, update examples, change settings), run evals to test a skill, benchmark skill performance with variance analysis, or optimize a skill's description for better triggering accuracy. When the user mentions \"modify skill\", \"update skill\", \"add to skill\", \"edit skill\", or similar phrases, you MUST use this skill and follow the modification workflow.",
    expect_license: None,
  },
  {
    id: "UP-033",
    skill_md: "---\nname: test-generator\nversion: 1.0.0\ndescription: 测试脚本动态生成技能，支持根据代码变更自动生成单元测试、集成测试和端到端测试，形成测试反馈闭环\ntype: orchestrator\ndependencies:\n  - cangjie-coder\nagents:\n  - agents/test-planner.md\n  - agents/test-writer.md\n  - agents/test-runner.md\nscripts:\n  - scripts/generate_unit_test.py\n  - scripts/generate_integration_test.py\n  - scripts/run_cangjie_test.py\n  - scripts/analyze_coverage.py\n  - scripts/fix_test_failures.py\n---\n\n# fixture body\n",
    expect_name: "test-generator",
    expect_description: "测试脚本动态生成技能，支持根据代码变更自动生成单元测试、集成测试和端到端测试，形成测试反馈闭环",
    expect_license: None,
  },
  {
    id: "UP-034",
    skill_md: "---\nname: tiny-robot-skill\ndescription: Guides TinyRobot Vue AI chat UI implementation, setup, and code generation. Use when the user mentions TinyRobot, OpenTiny TinyRobot, Bubble, Sender, Prompts, chat container, message list, conversation tools, or asks to build chat interfaces with TinyRobot components.\nlicense: MIT\nmetadata:\n  author: opentiny\n  version: '1.0.0'\n---\n\n# fixture body\n",
    expect_name: "tiny-robot-skill",
    expect_description: "Guides TinyRobot Vue AI chat UI implementation, setup, and code generation. Use when the user mentions TinyRobot, OpenTiny TinyRobot, Bubble, Sender, Prompts, chat container, message list, conversation tools, or asks to build chat interfaces with TinyRobot components.",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-035",
    skill_md: "---\nname: tiny-vue-skill\ndescription: 当使用 TinyVue 组件库(@opentiny/vue)进行开发时或者配置 TinyVue 工程的国际化，主题配置，表单校验说明，自动导入组件等，一定要阅读本技能。本技能提供严格的 API 文档和示例，以及如何查找流程以及代码规范。\nlicense: MIT\nmetadata:\n  author: opentiny\n  version: '3.30.0'\n---\n\n# fixture body\n",
    expect_name: "tiny-vue-skill",
    expect_description: "当使用 TinyVue 组件库(@opentiny/vue)进行开发时或者配置 TinyVue 工程的国际化，主题配置，表单校验说明，自动导入组件等，一定要阅读本技能。本技能提供严格的 API 文档和示例，以及如何查找流程以及代码规范。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-036",
    skill_md: "---\nname: uctoo-dev-manual\ndescription: 对当前运行的 agentskills-runtime（UCToo V4）框架进行二次开发时使用的开发手册技能。当用户要扩展系统功能、变更数据库表结构、开发插件、接入新大模型通道、排查开发或构建问题、编写或修改仓颉（Cangjie）代码、处理长程任务或技能提示词时参考。覆盖内置代码生成工具（crudgen/crudweb/plugingen/loaddbinfo/pluginuninstall）、V4 API 与数据库/模块/权限规范、插件三轨架构、长程任务系统、技能内置提示词机制。\n---\n\n# fixture body\n",
    expect_name: "uctoo-dev-manual",
    expect_description: "对当前运行的 agentskills-runtime（UCToo V4）框架进行二次开发时使用的开发手册技能。当用户要扩展系统功能、变更数据库表结构、开发插件、接入新大模型通道、排查开发或构建问题、编写或修改仓颉（Cangjie）代码、处理长程任务或技能提示词时参考。覆盖内置代码生成工具（crudgen/crudweb/plugingen/loaddbinfo/pluginuninstall）、V4 API 与数据库/模块/权限规范、插件三轨架构、长程任务系统、技能内置提示词机制。",
    expect_license: None,
  },
  {
    id: "UP-037",
    skill_md: "---\nname: uctoo-doc\ndescription: UCTOO AgentSkills Runtime 项目文档查询、API 规范阅读与数据库 CRUD 查询助手。帮助用户和大模型快速查找和阅读 UCTOO 项目的各类文档（API 设计规范、数据库设计、后端架构、模块开发、权限体系、AgentSkills 标准等），并告知大模型可自行组装查询条件从数据库表的标准 CRUD API 中查询所需数据。当用户提及 UCTOO 文档、API 规范、数据库设计、项目文档、技术文档、CRUD 查询、AgentSkills Runtime、智能体互联国标 等关键词时，应使用此技能。\nlicense: MIT\ncompatibility: 需要 runtime 内置文件工具支持（file_read/directory_list/file_search/web_fetch）\nversion: 2.0.0\n---\n\n# fixture body\n",
    expect_name: "uctoo-doc",
    expect_description: "UCTOO AgentSkills Runtime 项目文档查询、API 规范阅读与数据库 CRUD 查询助手。帮助用户和大模型快速查找和阅读 UCTOO 项目的各类文档（API 设计规范、数据库设计、后端架构、模块开发、权限体系、AgentSkills 标准等），并告知大模型可自行组装查询条件从数据库表的标准 CRUD API 中查询所需数据。当用户提及 UCTOO 文档、API 规范、数据库设计、项目文档、技术文档、CRUD 查询、AgentSkills Runtime、智能体互联国标 等关键词时，应使用此技能。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-038",
    skill_md: "---\nname: web-coder\ndescription: 前端代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化 Web 前端代码（Vue 3 + Vite + TypeScript + TinyVue）时使用。遵循确定性优先：先在目标工程查到确定依据（既有实现 + 官方文档技能）再写代码，禁止凭跨栈/跨版本经验臆造 API。\nversion: 1.0.0\nauthor: UCToo\n# 纯技能形态：本技能**不建 agents/ 目录、不派生编码子 agent**。\n# 依据（SDD tasks.md v3）：\"换脑子的才派生，换说明书的用技能\"——\n# 编码不需要换脑子，需要的是确定的 API 依据与工程内既有范式。\ndependencies:\n  - tiny-vue-skill          # OpenTiny TinyVue 组件库权威 API（本工程前端主用组件库）\n  - frontend-dev            # 过渡期路由：web-coder 未挂载时的降级技能\n---\n\n# fixture body\n",
    expect_name: "web-coder",
    expect_description: "前端代码编写技能（纯技能形态，不派生子 agent）。当用户需要编写、修改、重构或优化 Web 前端代码（Vue 3 + Vite + TypeScript + TinyVue）时使用。遵循确定性优先：先在目标工程查到确定依据（既有实现 + 官方文档技能）再写代码，禁止凭跨栈/跨版本经验臆造 API。",
    expect_license: None,
  },
  {
    id: "UP-039",
    skill_md: "---\nname: webmcp-cli-skill\ndescription: 面向第三方 AI Agent 的安装与执行指南：如何使用 webmcp-cli 与浏览器页面交互。包含已注入 WebMCP 工具的页面领域专用工具说明。\nlicense: MIT\nmetadata:\n  author: opentiny\n  version: '1.2.0'\n---\n\n# fixture body\n",
    expect_name: "webmcp-cli-skill",
    expect_description: "面向第三方 AI Agent 的安装与执行指南：如何使用 webmcp-cli 与浏览器页面交互。包含已注入 WebMCP 工具的页面领域专用工具说明。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-040",
    skill_md: "---\nname: webmcp-sdk-skill\ndescription: 指导如何使用 WebMCP SDK库去开发WebAgent的技能包，将前端应用快速智能化。它包含 TinyRemoter，WebMcpServer，WebMcpClient，createRemoter， AI-Extension插件开发的文档及指南。\nlicense: MIT\nmetadata:\n  author: opentiny\n  version: '1.0.0'\n---\n\n# fixture body\n",
    expect_name: "webmcp-sdk-skill",
    expect_description: "指导如何使用 WebMCP SDK库去开发WebAgent的技能包，将前端应用快速智能化。它包含 TinyRemoter，WebMcpServer，WebMcpClient，createRemoter， AI-Extension插件开发的文档及指南。",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-041",
    skill_md: "---\nname: yuanbao-policy\ndescription: >\n  L3 进程隔离轨插件（yuanbao-policy）—— 把元宝搜索（腾讯云 wsa · SearchPro）检索内核\n  编译成独立可执行文件，输出带可信度四因子标签与政策原文库交叉验证的结构化线索。\n  触发场景：需要以「不暴露脚本源码」的方式交付政策检索能力；宿主要求以进程插件形式\n  提供检索服务；脚本轨（skills/yuanbao-search）不可用时作为同规则降级通道。\n  与 skills/yuanbao-search 共用同一套判定规则与输出形态，可互为降级。\nlicense: MIT\nplugin: yuanbao-policy\nmetadata:\n  author: UCToo Team\n  version: \"1.0.0\"\n  category: search\n  track: l3-process\n---\n\n# fixture body\n",
    expect_name: "yuanbao-policy",
    expect_description: "",
    expect_license: Some("MIT"),
  },
  {
    id: "UP-042",
    skill_md: "---\nname: yuanbao-search\ndescription: 元宝搜索（腾讯云 wsa · SearchPro）检索内核 —— 提供政策/产业信息检索、可信度四因子标注与政策原文库交叉验证。当需要根据企业名称或政策主题收集可溯源的公开线索、判定信息是否可信、并在查不到可靠依据时明确说\"不知道\"时使用；配合 beichen-policy-assistant 完成画像→匹配→报告→落库→巡检闭环。\nlicense: MIT\nmetadata:\n  author: UCToo Team\n  version: \"1.0.0\"\n  category: search\n---\n\n# fixture body\n",
    expect_name: "yuanbao-search",
    expect_description: "元宝搜索（腾讯云 wsa · SearchPro）检索内核 —— 提供政策/产业信息检索、可信度四因子标注与政策原文库交叉验证。当需要根据企业名称或政策主题收集可溯源的公开线索、判定信息是否可信、并在查不到可靠依据时明确说\"不知道\"时使用；配合 beichen-policy-assistant 完成画像→匹配→报告→落库→巡检闭环。",
    expect_license: Some("MIT"),
  },
]
