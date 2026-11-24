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

///|
///is_registered — 名称是否已注册（查询不改变注册表）。
///
///En: is_registered reports whether a skill name is registered.
pub fn SkillRegistry::is_registered(self : Self, name : String) -> Bool {
  self.entries.contains(name)
}

///|
///level_of — 已注册条目的加载级别；未注册返回 None。
///
///En: level_of exposes the progressive-loading level of a registered skill.
pub fn SkillRegistry::level_of(self : Self, name : String) -> LoadLevel? {
  match self.entries.get(name) {
    Some(pair) => Some(pair.1)
    None => None
  }
}

///|
///names — 已注册名称清单（shortlex 确定性顺序：MoonBit String Compare 先长度后逐字符）。
///
///En: names returns registered skill names in shortlex deterministic order.
pub fn SkillRegistry::names(self : Self) -> Array[String] {
  let out : Array[String] = []
  for name, _entry in self.entries {
    out.push(name)
  }
  out.sort()
  out
}

///|
///promote — 渐进加载升格 Metadata → FullyLoaded（幂等；未注册 Err）。
///
///En: promote upgrades a skill from Metadata to FullyLoaded (idempotent; unknown → Err).
pub fn SkillRegistry::promote(
  self : Self,
  name : String,
) -> Result[Unit, String] {
  match self.entries.get(name) {
    Some(pair) => {
      self.entries[name] = (pair.0, FullyLoaded)
      Ok(())
    }
    None => Err("unknown skill: \{name}")
  }
}

///|
///unregister — 注销技能（未注册 Err）。
///
///En: unregister removes a skill; unknown names are rejected.
pub fn SkillRegistry::unregister(
  self : Self,
  name : String,
) -> Result[Unit, String] {
  if !self.entries.contains(name) {
    return Err("unknown skill: \{name}")
  }
  let _ = self.entries.remove(name)
  Ok(())
}
