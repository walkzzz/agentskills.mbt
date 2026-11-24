// F01 manifest 谓词测试（可选字段投影：license / compatibility）

///|
fn manifest(name : String, description : String) -> @skill.SkillManifest {
  { name, description, license: None, compatibility: None, metadata: None, }
}

///|
test "has_license projects optional license" {
  let bare = manifest("demo", "demo skill")
  let licensed = { ..bare, license: Some("MIT"), }
  assert_false(bare.has_license())
  assert_true(licensed.has_license())
}

///|
test "compatibility_count treats absence as zero" {
  let bare = manifest("demo", "demo skill")
  assert_eq(bare.compatibility_count(), 0)
  assert_eq(
    { ..bare, compatibility: Some(["claude", "gpt"]), }.compatibility_count(),
    2,
  )
  assert_eq({ ..bare, compatibility: Some([]), }.compatibility_count(), 0)
}
