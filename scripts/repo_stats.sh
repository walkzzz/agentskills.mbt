#!/usr/bin/env bash
# repo_stats — 数字一致性门禁（MBOpenClacky 模式，moon-cross 申报数字漂移教训的自动化防线）。
# 校验 README / CHANGELOG / docs / 测试断言中的统计口径与仓库实测一致；任何漂移即非零退出。
# 运行：在仓根 `bash scripts/repo_stats.sh`（CI 与本机同命令）。
set -u
FAIL=0

fail() { echo "DRIFT: $1"; FAIL=1; }

# ---- 实测 ----
TESTS=$(moon test 2>&1 | rg -o "Total tests: [0-9]+" | head -1 | rg -o "[0-9]+$")
if [ -z "${TESTS:-}" ]; then
  fail "无法从 moon test 输出解析测试总数"
  TESTS=0
fi

FIX=$(rg -c 'id: "UP-' verify/verify/fixture.mbt 2>/dev/null | rg -o "[0-9]+$")
if [ -z "${FIX:-}" ]; then
  fail "无法统计 fixtures 样本数（verify/verify/fixture.mbt）"
  FIX=0
fi

VERSION=$(rg -o '^version = "[0-9.]+"' agentskills/moon.mod | rg -o '[0-9]+\.[0-9]+\.[0-9]+')
PROVE_LINE=$(rg -o "[0-9]+ obligations proved" docs/known-gaps.md | head -1 | rg -o "[0-9]+")

# ---- 口径校验 ----
# 1) README 徽章 tests-N%2FN
if ! rg -q "tests-${TESTS}%2F${TESTS}" README.md; then
  fail "README 测试徽章与实测不一致（实测 ${TESTS}/${TESTS}）"
fi

# 2) CHANGELOG 测试口径 X/X（native）
if ! rg -q "${TESTS}/${TESTS}（native" CHANGELOG.md; then
  fail "CHANGELOG 测试口径与实测不一致（实测 ${TESTS}/${TESTS}）"
fi

# 3) fixture 计数断言
if ! rg -q "fixtures.length\(\), ${FIX}" verify/verify/fixture_test.mbt; then
  fail "fixture_test 长度断言与实测 fixtures 数不一致（实测 ${FIX}）"
fi

# 4) FIXTURE_TARGET 达标（实测 >= 目标）
TARGET=$(rg -o "FIXTURE_TARGET[^0-9]*[0-9]+" verify/verify/fixture.mbt | head -1 | rg -o "[0-9]+$")
if [ -z "${TARGET:-}" ]; then
  fail "无法解析 FIXTURE_TARGET"
  TARGET=0
elif [ "${FIX}" -lt "${TARGET}" ]; then
  fail "fixtures 实测 ${FIX} 低于 FIXTURE_TARGET ${TARGET}"
fi

# 5) known-gaps 中 fixtures 口径 N/TARGET
if ! rg -q "${FIX}/${TARGET}" docs/known-gaps.md; then
  fail "docs/known-gaps.md 中 fixtures 口径与实测不一致（实测 ${FIX}/${TARGET}）"
fi

# 6) moon.mod 版本在 roadmap 中出现（发布物口径）
if ! rg -q "${VERSION:-0.0.0}" README.md; then
  echo "WARN: README 未提及版本 ${VERSION:-?}（可接受，发布前补）"
fi

# ---- 汇总 ----
echo "repo_stats: tests=${TESTS} fixtures=${FIX}/${TARGET:-?} version=${VERSION:-?} prove=${PROVE_LINE:-?} obligations"
if [ "${FAIL}" -ne 0 ]; then
  echo "repo_stats FAILED — 修复上述漂移后重跑"
  exit 1
fi
echo "repo_stats OK"