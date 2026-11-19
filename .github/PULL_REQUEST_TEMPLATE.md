## 变更内容

（一句话说明 + 对应 F 编号 / issue 编号）

## 验证

- [ ] `moon check --deny-warn --target all` 零警告
- [ ] `moon test --target native|js|wasm|wasm-gc` 全绿
- [ ] `moon fmt && moon info` 且 `.mbti` diff 已提交
- [ ] `bash scripts/repo_stats.sh` 绿
- [ ] 涉及公开 API：附 `.mbti` diff 说明
- [ ] 涉及协议语义 / 测试口径：roadmap 与 docs 已同步

## 说明

（破坏性变更 / 迁移指引 / 证据链）