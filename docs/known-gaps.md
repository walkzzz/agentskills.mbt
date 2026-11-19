# 已知边界与缺口（真话台账）

> 维护者人工维护的诚实台账：记录已知缺口与平台边界，避免"宣传面与事实面漂移"。
> README 只描述能力；本文件描述边界。评审/集成前请先读此页。

## 功能边界

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-1 | CLI 无 argv（moon run 不传命令行参数——moon-cross 实测工具链限制） | F15 CLI 子命令面（skill load/run/build） | 子命令经环境变量/内嵌演示剧本过渡；argv 方案随 @process 集成裁决 |
| GAP-2 | ~~文件系统读未接入~~ **已闭环（2026-11-19）** | F02 文件加载、CLI 读 SKILL.md | ✅ F08 JSONL IO wrapper 落地（async save/load + demo 往返 OK）；**async@0.22.9 接入后 native 37/37 全绿、无 MSVC C1189**（此前基于 .tmp-smoke 的 C1189 结论不适用于本仓依赖组合） |
| GAP-3 | 差分样本 **42/40 达成**（FIXTURE_TARGET=40，2026-11-19 冻结上游全量 42 个 SKILL.md） | D2 差分层覆盖度 | ✅ 已闭环：实测期望独立于 F01 生成；8 个块标量样本 description 用空哨兵（字符级期望不可独立冻结，只断言 name/license）；**BUG-001 登记**：UP-019（investment-research-assistant）frontmatter 被 moonyaml 拒绝、上游接受——known_failure 隔离待裁决 |
| GAP-4 | F02 渐进加载的 Metadata→FullyLoaded 升格路径未接文件消费（GAP-2 闭环后前提已具备） | F02 完整面 | LoadLevel 状态机就位；升格接 `load_jsonl`/文件读随 CLI skill load 子命令落地 |
| GAP-5 | F03 MCP 面（to_mcp_entry 的 server 侧暴露）未实现 | F03 完整面 | W9 mcp 家族集成时落地；单源映射已通（gbz185 ToolRegistry 桥接） |
| GAP-7 | F09 wasmoon 完整集成 = **编译器级依赖链**（wa​smoon + milkir + wasmoon_jit + wasm_milkir 四模块，2026-11-19 侦察确认） | F09 三执行器（wasm 沙箱实际执行） | 三执行器策略：①**js WebAssembly（零依赖，浏览器/Node 内置）优先** ②@process 进程隔离 ③wasmoon JIT 完整集成随 W10 排期（构建风险与耗时需专门窗口） |

## 平台与工具链

| 编号 | 描述 | 影响面 | 状态/规避 |
| --- | --- | --- | --- |
| GAP-6 | gbz185.mbt Windows 本地 `moon prove` 触发 moon 工具链 `\\?` mkdir bug（EACCES/EINVAL） | 国标形式化验证的本地运行 | WSL 通道 **20 obligations proved / 13 verified functions**（2026-11-19 三档扩展）；CI 走 ubuntu runner（详见 gbz185 仓 docs/known-gaps.md GAP-1） |

## 测试口径

- **45/45 为 native 目标实测**（2026-11-19）：skill/rag/auth/rbac/compactor/storage/sandbox/server 全包覆盖（含 6 个 quickcheck 属性、差分层 42 fixtures、JSONL 往返、RBAC 矩阵、HS256、沙箱燃料、HTTP 路由/SSE 编码、frontmatter 错误分支）；js / wasm / wasm-gc 与 native×3 OS 经 CI 实测绿。
- 变异测试 **24/24 KILLED**（7 功能域，scripts/mutation_test.mbtx）；覆盖率 `moon coverage analyze` 库代码仅 3 行未覆盖（WSL 通道——Windows 本地有路径拼接 bug）；**形式化验证 `verify/proof` 8 goals proved**（moon prove/WSL；契约核：燃料账本/占位计数/RBAC 授权）；数字一致性门禁 `scripts/repo_stats.sh`；本地 CI `scripts/local_ci.sh` 与 CI jobs 对齐；完整矩阵见 docs/TEST_REPORT.md。
- `examples/storage_jsonl_demo` 与 `examples/interconnect_demo` 为运行级验证（moon run 实测输出见 README）。
