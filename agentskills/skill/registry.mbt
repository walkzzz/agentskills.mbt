///|
///LoadLevel — 渐进加载状态机（F02 锚点，ARCH §3.1）。
///
///En: LoadLevel is the progressive loading state machine of the registry.
///Metadata 仅含 frontmatter；FullyLoaded 含正文与资源（正文消费属运行时壳，见 DDD）。
#derive(Eq)
pub(all) enum LoadLevel {
  Metadata
  FullyLoaded
}

///|
///SkillRegistry — 技能注册表（F02，Kernel 式纯函数域：无 IO、无隐藏状态）。
///
///En: SkillRegistry is the skill registry as a pure functional domain (no IO).
///同名条目注册冲突即 Err（fail-fast，吸收 posoco 无 last-wins 钉扎）。
pub(all) struct SkillRegistry {
  entries : Map[String, (SkillManifest, LoadLevel)]
}

///|
pub fn SkillRegistry::new() -> SkillRegistry {
  let m : Map[String, (SkillManifest, LoadLevel)] = Map::from_array([])
  { entries: m, }
}

///|
///register — 注册技能（validate 先行；同名冲突 Err）。
pub fn SkillRegistry::register(
  self : Self,
  m : SkillManifest,
  level : LoadLevel,
) -> Result[Unit, String] {
  match validate(m) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  if self.entries.contains(m.name) {
    return Err("duplicate skill: \{m.name}")
  }
  self.entries[m.name] = (m, level)
  Ok(())
}

///|
///lookup — 按名检索；未注册返回 None。
pub fn SkillRegistry::lookup(
  self : Self,
  name : String,
) -> (SkillManifest, LoadLevel)? {
  self.entries.get(name)
}

///|
///count — 已注册条目数（观测面）。
pub fn SkillRegistry::count(self : Self) -> Int32 {
  self.entries.length()
}
