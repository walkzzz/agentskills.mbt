///|
///known_failure — 差分隔离机制（吸收 MBOpenClacky 九层测试体系层 2）。
///
///En: known_failure quarantines unresolved semantic divergences from the upstream.
///与上游 agentskills-runtime（仓颉）行为存在未修复分歧的用例在此登记编号：
///①测试内用 guard_known(id) 跳过断言 ②修复后从数组移除编号，断言自动生效。
///登记必须附原因注释与上游证据位置。
pub let known_failures : Array[String] = [
  // BUG-001（2026-11-19）：UP-019（investment-research-assistant/SKILL.md）——moonyaml
  // 拒绝其 frontmatter（decision-points 列表段形态），上游仓颉解析器接受；分歧待裁决
  // （moonyaml flavor 放宽 or F01 预处理）。修复后从本数组移除编号，断言自动生效。
  "UP-019",
]

///|
///guard_known — 编号已登记则返回 true（调用方跳过断言）。
pub fn guard_known(id : String) -> Bool {
  let mut found = false
  for f in known_failures {
    if f == id {
      found = true
    }
  }
  found
}
