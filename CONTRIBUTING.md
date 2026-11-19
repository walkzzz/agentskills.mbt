# Contributing

感谢贡献。本仓是 MoonBit 全量移植 SKILL.md 标准技能运行时的工程现场，纪律优先于速度。

## 环境

- MoonBit 工具链 **0.1.20261117+**（`moon version` 确认）
- 平台：Windows/Linux/macOS 均可构建；形式化验证（gbz185 仓）走 WSL/CI（Windows 本地有 `\\?` mkdir 平台 bug）

## 门禁（提交前必须全过）

```bash
moon check --deny-warn --target all   # 四目标零警告
moon test                             # 全绿（seed 固定可复现）
moon fmt && moon info                 # 格式化 + 契约文件更新（mbti 入库，diff 必查）
```

## 提交规范

- [Conventional Commits](https://www.conventionalcommits.org/)：`feat:` / `fix:` / `docs:` / `refactor:` / `chore:` / `test:`
- 一个提交只做一件事；格式化与行为变更分开提交（可 rebase 保干净历史）
- 长提交消息在 git-bash 用 `git commit -F <文件>`（`-m` 长消息会静默失败）

## 测试纪律（差分层）

1. **新 fixture**：`verify/verify/fixture.mbt` 的 `fixtures` 数组；`skill_md` 冻结原文 frontmatter，**期望值必须独立生成**（人工/独立脚本核对），禁止"用被测代码产出期望"。
2. **字符级期望不可独立冻结的样本**（块标量 description 等）：`expect_description = ""` 哨兵（只断言 name/license）。
3. **上游语义分歧**：登记 `known_failures`（附 BUG 编号与原因注释）→ 测试跳过；修复后从数组移除编号，断言自动生效。禁止直接删测试迁就实现。

## 架构纪律

- **三层执行模型**：Kernel 式纯函数域（`skill/`，无 IO 无隐藏状态）→ 运行时壳（`cli/`）→ 互联协议栈（gbz185 独立仓）。
- **契约即包结构**：能力面用 `pub(open) trait` 注入（参考 `SkillTool`/`CAIVerifier`）；实现方不触碰内部字段。
- **依赖方向钉扎**：ToolDescriptor 单源（gbz185/tooling）；gbz185 网关协议能力不重复实现。
- **Int64 wire 纪律**：数字字段显式 `Json::number(x.to_double())`（防 JS 精度丢失）；JS 安全域边界 2^53 有形式化证明背书（gbz185 verify）。

## 提交 PR

- 描述变更动机与验证方式（命令+输出摘要）
- 涉及公开 API：附 `moon info` 的 `.mbti` diff 说明
- 涉及协议语义：先改 `roadmap.md`/`docs/known-gaps.md` 口径，再动实现（文档即实现）