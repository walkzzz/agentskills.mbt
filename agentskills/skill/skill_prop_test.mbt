// skill 包属性测试（quickcheck，seed 固定可复现；对齐 gbz185 属性测试模式）。

///|
test "property: validate accepts every in-bound manifest" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let name_len = (n & 63) + 1
      let desc_len = ((n >> 6) & 1023) + 1
      let m : @skill.SkillManifest = {
        name: "a".repeat(name_len.to_int()),
        description: "d".repeat(desc_len.to_int()),
        license: None,
        compatibility: None,
        metadata: None,
      }
      @skill.validate(m) is Ok(_)
    },
    count=200,
    seed=2026,
  )
}

///|
test "property: validate rejects empty or oversize fields" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let kind = n & 3
      let name = if kind == 1 { "" } else { "a".repeat(65) }
      let desc = if kind == 2 { "" } else { "d".repeat(1025) }
      let m : @skill.SkillManifest = {
        name,
        description: desc,
        license: None,
        compatibility: None,
        metadata: None,
      }
      @skill.validate(m) is Err(_)
    },
    count=100,
    seed=2027,
  )
}

///|
test "property: parse roundtrips generated frontmatter" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let name = "n".repeat(((n & 15) + 1).to_int())
      let desc = "d".repeat((((n >> 4) & 255) + 1).to_int())
      let text = "---\nname: " + name + "\ndescription: " + desc + "\n---\nbody"
      match @skill.parse_skill_md(text) {
        Ok((m, body)) =>
          m.name == name && m.description == desc && body.contains("body")
        Err(_) => false
      }
    },
    count=100,
    seed=2028,
  )
}

///|
test "property: second registration always conflicts" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let reg = @skill.SkillRegistry::new()
      let m : @skill.SkillManifest = {
        name: "s".repeat(((n & 31) + 1).to_int()),
        description: "d",
        license: None,
        compatibility: None,
        metadata: None,
      }
      match reg.register(m, @skill.Metadata) {
        Ok(_) => reg.register(m, @skill.FullyLoaded) is Err(_)
        Err(_) => false
      }
    },
    count=100,
    seed=2029,
  )
}
