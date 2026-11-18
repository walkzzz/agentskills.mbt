///|
///known_failure — 差分隔离机制（吸收 MBOpenClacky 九层测试体系层 2）。
///
///En: known_failure quarantines unresolved semantic divergences from the upstream.
///与上游 agentskills-runtime（仓颉）行为存在未修复分歧的用例在此登记编号：
///①测试内用 guard_known(id) 跳过断言 ②修复后从数组移除编号，断言自动生效。
///登记必须附原因注释与上游证据位置。
pub let known_failures : Array[String] = []

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
