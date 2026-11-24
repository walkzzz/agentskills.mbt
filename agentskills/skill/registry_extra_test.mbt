// F02 注册表查询与渐进加载测试（is_registered / level_of / names / promote / unregister）

///|
fn entry(name : String) -> @skill.SkillManifest {
  {
    name,
    description: "desc of \{name}",
    license: Some("MIT"),
    compatibility: None,
    metadata: None,
  }
}

///|
fn registry_with(names : Array[String]) -> @skill.SkillRegistry {
  let reg = @skill.SkillRegistry::new()
  for name in names {
    match reg.register(entry(name), @skill.Metadata) {
      Ok(_) => ()
      Err(_) => panic()
    }
  }
  reg
}

///|
test "is_registered and level_of follow the registry" {
  let reg = registry_with(["alpha"])
  assert_true(reg.is_registered("alpha"))
  assert_false(reg.is_registered("beta"))
  match reg.level_of("alpha") {
    Some(level) => assert_true(level == @skill.Metadata)
    None => assert_true(false)
  }
  assert_true(reg.level_of("beta") is None)
}

///|
test "names use shortlex order independent of insertion" {
  let reg = registry_with(["alpha", "zeta"])
  // MoonBit String Compare 为 shortlex（长度优先）：zeta(4) 先于 alpha(5)
  assert_eq(reg.names(), ["zeta", "alpha"])
}

///|
test "promote upgrades to FullyLoaded and is idempotent" {
  let reg = registry_with(["alpha"])
  assert_ok(reg.promote("alpha"))
  match reg.level_of("alpha") {
    Some(level) => assert_true(level == @skill.FullyLoaded)
    None => assert_true(false)
  }
  assert_ok(reg.promote("alpha"))
  match reg.level_of("alpha") {
    Some(level) => assert_true(level == @skill.FullyLoaded)
    None => assert_true(false)
  }
  assert_err(reg.promote("missing"))
  assert_eq(reg.count(), 1)
}

///|
test "unregister removes and rejects unknown" {
  let reg = registry_with(["alpha", "beta"])
  assert_ok(reg.unregister("alpha"))
  assert_false(reg.is_registered("alpha"))
  assert_eq(reg.count(), 1)
  assert_eq(reg.names(), ["beta"])
  assert_err(reg.unregister("alpha"))
}
