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
