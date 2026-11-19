// 断言 helper：统一 Ok/Err 判定（消除重复样板）。

///|
fn[T] assert_ok(r : Result[T, String]) -> Unit raise {
  assert_true(r is Ok(_))
}

///|
fn[T] assert_err(r : Result[T, String]) -> Unit raise {
  assert_true(r is Err(_))
}

///|
test {
  let ok : @skill.SkillManifest = {
    name: "demo",
    description: "A demo skill",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_ok(@skill.validate(ok))
  let no_name : @skill.SkillManifest = {
    name: "",
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(@skill.validate(no_name))
  let no_desc : @skill.SkillManifest = {
    name: "demo",
    description: "",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(@skill.validate(no_desc))
  let long_name : @skill.SkillManifest = {
    name: "a".repeat(65),
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(@skill.validate(long_name))
  let with_opt : @skill.SkillManifest = {
    name: "demo",
    description: "x",
    license: Some("MIT"),
    compatibility: Some(["moonbit"]),
    metadata: None,
  }
  assert_ok(@skill.validate(with_opt))
}

///|
test {
  let text = "---\nname: demo\ndescription: A demo skill\nlicense: MIT\ncompatibility:\n  - moonbit\nmetadata:\n  author: walkzzz\n---\n\n# Demo\n\nbody"
  let r = @skill.parse_skill_md(text)
  assert_ok(r)
  let (m, body) = r.unwrap()
  assert_eq(m.name, "demo")
  assert_eq(m.description, "A demo skill")
  assert_true(m.license == Some("MIT"))
  assert_true(m.compatibility == Some(["moonbit"]))
  match m.metadata {
    Some(mm) => assert_eq(mm.get("author"), Some(Json::string("walkzzz")))
    None => assert_true(false)
  }
  assert_true(body.contains("# Demo"))
}

///|
test {
  assert_err(@skill.parse_skill_md("no frontmatter at all"))
  assert_err(@skill.parse_skill_md("---\nname: x\ndescription: y\n"))
  assert_err(@skill.parse_skill_md("---\n- item\n---\nbody"))
  let minimal = "---\nname: m\ndescription: d\n---\n"
  assert_ok(@skill.parse_skill_md(minimal))
}

///|
test {
  let reg = @skill.SkillRegistry::new()
  assert_eq(reg.count(), 0)
  let m : @skill.SkillManifest = {
    name: "a",
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_ok(reg.register(m, @skill.Metadata))
  assert_eq(reg.count(), 1)
  match reg.lookup("a") {
    Some((m2, level)) => {
      assert_eq(m2.name, "a")
      assert_true(level == @skill.Metadata)
    }
    None => assert_true(false)
  }
  let dup : @skill.SkillManifest = {
    name: "a",
    description: "y",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(reg.register(dup, @skill.FullyLoaded))
  assert_eq(reg.count(), 1)
  assert_err(reg.register(dup, @skill.FullyLoaded))
  assert_true(reg.lookup("missing") is None)
}

///|
test {
  // description 长度边界（变异杀手：1024 边界宽松化）
  let long_desc : @skill.SkillManifest = {
    name: "demo",
    description: "d".repeat(1025),
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(@skill.validate(long_desc))
  let ok_desc : @skill.SkillManifest = {
    name: "demo",
    description: "d".repeat(1024),
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_ok(@skill.validate(ok_desc))
}

///|
test {
  // 非法 manifest 注册被拒（变异杀手：registry validate 先行失效）
  let reg = @skill.SkillRegistry::new()
  let bad : @skill.SkillManifest = {
    name: "",
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_err(reg.register(bad, @skill.Metadata))
  assert_eq(reg.count(), 0)
}

///|
test {
  // compatibility 字符串标量形态（变异杀手：String 分支丢值）
  let text = "---\nname: c\ndescription: d\ncompatibility: cangjie\n---\nbody"
  match @skill.parse_skill_md(text) {
    Ok((m, _)) => assert_true(m.compatibility == Some(["cangjie"]))
    Err(_) => assert_true(false)
  }
}

///|
test {
  // 块标量 description 的折叠语义锁定（moonyaml `>` folded scalar：行以空格连接）
  let text = "---\nname: b\ndescription: >\n  folded line one\n  folded line two\n---\nbody"
  match @skill.parse_skill_md(text) {
    Ok((m, _)) => {
      assert_true(m.description.contains("folded line one"))
      assert_true(m.description.contains("folded line two"))
    }
    Err(_) => assert_true(false)
  }
}

///|
test {
  // frontmatter 错误分支覆盖（类型错误的字段必须 Err）
  assert_true(
    @skill.parse_skill_md("---\nname: x\ndescription: d\nlicense: 123\n---\n")
    is Err(_),
  )
  assert_true(
    @skill.parse_skill_md(
      "---\nname: x\ndescription: d\ncompatibility: {a: b}\n---\n",
    )
    is Err(_),
  )
  assert_true(
    @skill.parse_skill_md(
      "---\nname: x\ndescription: d\ncompatibility: [1, 2]\n---\n",
    )
    is Err(_),
  )
  assert_true(
    @skill.parse_skill_md(
      "---\nname: x\ndescription: d\nmetadata: [1, 2]\n---\n",
    )
    is Err(_),
  )
  assert_true(
    @skill.parse_skill_md("---\nname: [x]\ndescription: d\n---\n") is Err(_),
  )
  assert_true(
    @skill.parse_skill_md("---\nname: x\ndescription: [d]\n---\n") is Err(_),
  )
}

///|
test {
  // 非法 YAML（重复键）→ loads 抛错 → catch 分支
  assert_true(
    @skill.parse_skill_md("---\nname: \"abc\ndescription: d\n---\n") is Err(_),
  )
}
