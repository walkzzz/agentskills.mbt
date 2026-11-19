///|
test {
  let ok : @skill.SkillManifest = {
    name: "demo",
    description: "A demo skill",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_true(@skill.validate(ok) is Ok(_))
  let no_name : @skill.SkillManifest = {
    name: "",
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_true(@skill.validate(no_name) is Err(_))
  let no_desc : @skill.SkillManifest = {
    name: "demo",
    description: "",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_true(@skill.validate(no_desc) is Err(_))
  let long_name : @skill.SkillManifest = {
    name: "a".repeat(65),
    description: "x",
    license: None,
    compatibility: None,
    metadata: None,
  }
  assert_true(@skill.validate(long_name) is Err(_))
  let with_opt : @skill.SkillManifest = {
    name: "demo",
    description: "x",
    license: Some("MIT"),
    compatibility: Some(["moonbit"]),
    metadata: None,
  }
  assert_true(@skill.validate(with_opt) is Ok(_))
}

///|
test {
  let text = "---\nname: demo\ndescription: A demo skill\nlicense: MIT\ncompatibility:\n  - moonbit\nmetadata:\n  author: walkzzz\n---\n\n# Demo\n\nbody"
  let r = @skill.parse_skill_md(text)
  assert_true(r is Ok(_))
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
  assert_true(@skill.parse_skill_md("no frontmatter at all") is Err(_))
  assert_true(@skill.parse_skill_md("---\nname: x\ndescription: y\n") is Err(_))
  assert_true(@skill.parse_skill_md("---\n- item\n---\nbody") is Err(_))
  let minimal = "---\nname: m\ndescription: d\n---\n"
  assert_true(@skill.parse_skill_md(minimal) is Ok(_))
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
  assert_true(reg.register(m, @skill.Metadata) is Ok(_))
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
  assert_true(reg.register(dup, @skill.FullyLoaded) is Err(_))
  assert_eq(reg.count(), 1)
  assert_true(reg.register(dup, @skill.FullyLoaded) is Err(_))
  assert_true(reg.lookup("missing") is None)
}
