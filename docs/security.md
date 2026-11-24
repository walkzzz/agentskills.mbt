# 安全说明（agentskills.mbt 0.2.0）

## 1. 威胁模型

| 威胁 | 面 | 现有防护 |
| --- | --- | --- |
| 恶意 SKILL.md（超长/畸形 frontmatter） | F01 | 长度契约（name ≤64、description ≤1024）、类型校验、解析失败即 Err |
| 技能覆盖/劫持 | F02 | 同名注册 fail-fast；覆盖需显式 unregister |
| 越权读取敏感上下文 | F06 | 三级敏感静态策略（`can_access`）；拒绝事件入审计 |
| 审计日志被篡改/断链 | F06 | 单调 `seq` 追加；`denied_count` 与 `last` 可观测 |
| 口令/令牌伪造 | F07 | bcrypt + HS256（不自研密码学；篡改 token 拒收） |
| 存储值注入 | F08 | PG 路径当前以单引号转义拼接（联测用途）；参数化准备语句列入后续（GAP-8） |
| 不可信技能工具执行 | F09 | 燃料计量契约核；js WebAssembly 执行器（gas≤0 判 OutOfGas） |
| 上下文泄露/预算爆炸 | F05 | 确定性裁剪 + 逐条预算截断；`total_chars` 诊断 |

## 2. 信任边界

- **Kernel 域**不含秘密、不做 IO；密钥、时钟、文件与网络由运行时壳注入。
- **认证**依赖 `mooncred` / `mooncrypt`，不在本仓实现密码学原语。
- **沙箱**当前 js 执行器仅提供「不可信代码隔离 + 燃料耗尽即拒」的基线，不宣称完整进程级隔离。
- **工具执行**由调用方提供实现；本库只负责单源描述、注册、分发与审计记录。

## 3. 已知安全边界（真话）

- wasmoon 逐指令计量未集成（GAP-7），js 执行器不保证精确 gas 计数。
- PG 值的 SQL 拼接未参数化（GAP-8）；生产使用前应改为准备语句。
- 审计日志为内存数组，进程退出即失；持久化属上层职责。
- CLI argv 缺失（GAP-1）导致部分高危操作只能由调用方以代码方式驱动。

## 4. 依赖与供应链

- Kernel 包零 mooncakes 依赖；运行时依赖：`moonyaml`、`MoonRetrieve`、`mooncred`、`mooncrypt`、`moonbitlang/async`、`postgres`、`gbz185.mbt`（版本在 `agentskills/moon.mod` 钉扎）。
- 第三方组件与许可证见仓库 `README.md` 与上游披露。

## 5. 漏洞报告

请按仓库 `SECURITY.md` 的私密渠道报告；附最小复现（SKILL.md 样本 / 调用序列）与影响面判断。请勿在公开 issue 披露可利用细节。