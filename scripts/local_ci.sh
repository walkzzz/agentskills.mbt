#!/usr/bin/env bash
# local_ci.sh — 本地 CI（与 .github/workflows/ci.yml 的 jobs 对齐）
# 用法：bash scripts/local_ci.sh [--quick]
#   --quick  跳过变异矩阵与覆盖率提示（慢项），其余与 CI 相同
# 环境：git-bash / WSL bash；moon 已在 PATH
set -u
FAIL=0
cd "$(dirname "$0")/.." || exit 1   # 仓根（workspace 根）

step() { echo ""; echo "=== $1 ==="; }
run()  { echo "> $*"; "$@" || { echo "FAILED: $*"; FAIL=1; }; }

step "check --deny-warn --target all（workspace 双成员）"
run moon check --deny-warn --target all

step "test 四目标（native / js / wasm / wasm-gc）"
for t in native js wasm wasm-gc; do
  run moon test --target $t
done

step "contract：mbti 漂移检查（对齐 CI contract job）"
(cd agentskills && moon info) >/dev/null 2>&1
git diff --exit-code --stat || { echo "FAILED: mbti drift（运行 moon info 并提交）"; FAIL=1; }

step "repo_stats：数字一致性门禁"
run bash scripts/repo_stats.sh

if [ "${1:-}" != "--quick" ]; then
  step "coverage：moon coverage analyze（WSL 通道——Windows 本地有路径拼接 bug）"
  WSL_DIR="${WSL_DIR:-/mnt/e/AA_WP/forMoonHankson/agentskills.mbt/agentskills}"
  if command -v wsl >/dev/null 2>&1; then
    echo "> wsl -e bash -c \"cd $WSL_DIR && ~/.moon/bin/moon coverage analyze\""
    wsl -e bash -c "cd '$WSL_DIR' && ~/.moon/bin/moon coverage analyze 2>&1 | grep -E 'Total|uncovered' | head -8" || echo "WARN: coverage 步骤失败（WSL 不可用或索引未更新）"
  else
    echo "WARN: 未检测到 wsl——跳过 coverage（可用 WSL_DIR 指定）"
  fi

  step "mutation：24 变异点矩阵（慢，--quick 跳过）"
  run moon run scripts/mutation_test.mbtx
fi

echo ""
if [ "$FAIL" -ne 0 ]; then
  echo "LOCAL CI FAILED"
  exit 1
fi
echo "LOCAL CI OK"