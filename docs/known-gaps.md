# 已知边界与缺口（真话台账）

> 维护者人工维护的诚实台账：记录已知缺口与平台边界，避免"宣传面与事实面漂移"。
> README 只描述能力；本文件描述边界。评审/集成前请先读此页。

## 功能边界

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-1 | CLI 无 argv（moon run 不传命令行参数——moon-cross 实测工具链限制） | F15 CLI 子命令面（skill load/run/build） | 子命令经环境变量/内嵌演示剧本过渡；argv 方案随 @process 集成裁决 |
| GAP-2 | 文件系统读未接入：@async fs 依赖链在 Windows native test 报 MSVC C1189（vcruntime C11 atomics 未启用——moonbitlang/async C runtime 工具链限制，CI ubuntu 不受影响） | F02 文件加载、CLI 读 SKILL.md | skill load 以内嵌演示剧本走通全链路；文件读随 async 集成接入 |
| GAP-3 | 差分样本 **42/40 达成**（FIXTURE_TARGET=40，2026-11-19 冻结上游全量 42 个 SKILL.md） | D2 差分层覆盖度 | ✅ 已闭环：实测期望独立于 F01 生成；8 个块标量样本 description 用空哨兵（字符级期望不可独立冻结，只断言 name/license）；**BUG-001 登记**：UP-019（investment-research-assistant）frontmatter 被 moonyaml 拒绝、上游接受——known_failure 隔离待裁决 |
| GAP-4 | F02 渐进加载的 Metadata→FullyLoaded 升格路径未接文件消费 | F02 完整面 | LoadLevel 状态机已就位，升格随 GAP-2 落地 |
| GAP-5 | F03 MCP 面（to_mcp_entry 的 server 侧暴露）未实现 | F03 完整面 | W9 mcp 家族集成时落地；单源映射已通（gbz185 ToolRegistry 桥接） |

## 平台与工具链

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-6 | gbz185.mbt Windows 本地 `moon prove` 触发 moon 工具链 `\\?` mkdir bug（EACCES/EINVAL） | 国标形式化验证的本地运行 | WSL 通道 **20 obligations proved / 13 verified functions**（2026-11-19 三档扩展）；CI 走 ubuntu runner（详见 gbz185 仓 docs/known-gaps.md GAP-1） |

## 测试口径

- 7/7 为 **native 目标**实测（2026-11-18）：skill 包 5（validate/parse/边界）+ verify 包 2（差分层驱动/guard_known）；js 目标同绿。
- 覆盖率/CRAP/变异基线：随测试矩阵扩容（目标 200+）后按 gbz185 模式出报告。
- 双智能体互联演示五环节实测输出见 README（2026-11-18）。
