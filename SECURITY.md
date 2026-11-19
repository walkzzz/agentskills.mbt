# Security Policy

## 支持版本

| 版本 | 支持状态 |
| --- | --- |
| 0.1.x | ✅ 开发中（跟进修复） |

## 报告漏洞

请**不要**在公开 issue 中披露漏洞细节。通过以下渠道私下报告：

- GitHub Security Advisories（仓库 Security 标签页 → "Report a vulnerability"）
- 说明：受影响版本、复现步骤、影响评估（如适用，附修复建议）

我们会尽快确认并在修复后致谢（除非你要求匿名）。

## 安全设计要点（安全相关变更必须对照）

1. **防重放（GB/Z 185.6）**：AIP 信封序号严格单调——数学基础经 moon prove 机器证明（gbz185 verify：`next_seq` / `inbox_advance` / `replay_chain` / `dispatch_seq_admitted_by_peer`，20 obligations proved）。
2. **准入裁决纯函数化**：接收面 `inbox_advance` 与规格逐字对应（机器可查），接收 watermark 单调不变量已证（永不回退）。
3. **口令哈希**：依赖 `moonbitlang/x` bcrypt（官方实验库；与 `mooncrypt` 双实现交叉验证一致，冒烟实测 2026-11-18）。禁止自研密码学原语。
4. **传输安全**（gbz185 transport_async）：TLS + 对端证书 SHA-256 指纹钉扎；mTLS 双向证书受 @tls API 限制以指纹钉扎等效（GAP-2）。
5. **技能执行边界**：SKILL.md 解析为纯数据（无代码执行）；工具调用经 `ToolDescriptor` 单源契约与 `ToolRegistry` 审计日志；沙箱执行器（wasmoon）按 roadmap 集成。
6. **依赖审计**：新增依赖前跑选型冒烟（mooncakes 现状 + API 面 + 交叉验证）；依赖清单与许可证见各仓 THIRD_PARTY_NOTICES / README。