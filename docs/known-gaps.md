# 已知边界与缺口（真话台账）

> 维护者人工维护的诚实台账：记录已知缺口与平台边界，避免"宣传面与事实面漂移"。
> README 只描述能力；本文件描述边界。评审/集成前请先读此页。

## 功能边界

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-1 | CLI 无 argv（moon run 不传命令行参数——moon-cross 实测工具链限制） | F15 CLI 子命令面（skill load/run/build） | 子命令经环境变量/内嵌演示剧本过渡；argv 方案随 @process 集成裁决 |
| GAP-2 | 文件系统读未接入：@async fs 依赖链在 Windows native test 报 MSVC C1189（vcruntime C11 atomics 未启用——moonbitlang/async C runtime 工具链限制，CI ubuntu 不受影响） | F02 文件加载、CLI 读 SKILL.md | skill load 以内嵌演示剧本走通全链路；文件读随 async 集成接入 |
| GAP-3 | 差分样本 3/40（FIXTURE_TARGET） | D2 差分层覆盖度 | 沙箱内 AtomGit 克隆受阻（SSH Sandbox Error/https 不稳）；上游仓库人工下载后扩容（真实技能文件实测期望冻结） |
| GAP-4 | F02 渐进加载的 Metadata→FullyLoaded 升格路径未接文件消费 | F02 完整面 | LoadLevel 状态机已就位，升格随 GAP-2 落地 |
| GAP-5 | F03 MCP 面（to_mcp_entry 的 server 侧暴露）未实现 | F03 完整面 | W9 mcp 家族集成时落地；单源映射已通（gbz185 ToolRegistry 桥接） |

## 平台与工具链

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-6 | gbz185.mbt Windows 本地 `moon prove` 触发 moon 工具链 `\\?` mkdir bug（EACCES/EINVAL） | 国标形式化验证的本地运行 | WSL 通道复验 3 goals proved；CI 走 ubuntu runner（详见 gbz185 仓 docs/known-gaps.md GAP-1） |

## 测试口径

- 7/7 为 **native 目标**实测（2026-11-18）：skill 包 5（validate/parse/边界）+ verify 包 2（差分层驱动/guard_known）；js 目标同绿。
- 覆盖率/CRAP/变异基线：随测试矩阵扩容（目标 200+）后按 gbz185 模式出报告。
- 双智能体互联演示五环节实测输出见 README（2026-11-18）。
