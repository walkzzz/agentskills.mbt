///|
///差分层（MBOpenClacky 九层体系层 2 的 MoonBit 落地）：FIXTURES 驱动
///F01 解析器与冻结期望的字面量对比；guard_known 隔离未修复分歧。
test {
  for fx in @verify.fixtures {
    if @verify.guard_known(fx.id) {
      continue
    }
    match @skill.parse_skill_md(fx.skill_md) {
      Ok((m, _body)) => {
        assert_eq(m.name, fx.expect_name)
        assert_eq(m.description, fx.expect_description)
        assert_true(m.license == fx.expect_license)
      }
      Err(e) => {
        println("FIX \{fx.id} parse FAILED: \{e}")
        assert_true(false)
      }
    }
  }
}

///|
test {
  assert_eq(@verify.fixtures.length(), 3)
  assert_true(@verify.guard_known("BUG-000") == false)
}
