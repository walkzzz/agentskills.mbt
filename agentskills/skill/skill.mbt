///|
///SkillManifest — SKILL.md frontmatter 域模型（F01 锚点，ARCH §3.1）。
///
///En: SkillManifest is the domain model of SKILL.md frontmatter.
///name/description 必填（对标上游 agentskills 与 SKILL.md 规范）；其余字段可选。
///YAML 解析（moonyaml）在 W1 选型锁定后接入；本结构为解析目标与校验契约。
pub(all) struct SkillManifest {
  name : String
  description : String
  license : String?
  compatibility : Array[String]?
  metadata : Map[String, Json]?
}

///|
///validate — manifest 必填字段与长度契约校验。
///
///En: validate checks required fields and length contracts of a manifest.
pub fn validate(m : SkillManifest) -> Result[Unit, String] {
  if m.name.is_empty() {
    Err("name is required")
  } else if m.name.length() > 64 {
    Err("name exceeds 64 chars")
  } else if m.description.is_empty() {
    Err("description is required")
  } else if m.description.length() > 1024 {
    Err("description exceeds 1024 chars")
  } else {
    Ok(())
  }
}

///|
///has_license — 是否声明 license（可选字段的谓词投影）。
///
///En: has_license projects the optional license field.
pub fn SkillManifest::has_license(self : SkillManifest) -> Bool {
  self.license is Some(_)
}

///|
///compatibility_count — 兼容性声明条目数（缺省视为 0）。
///
///En: compatibility_count reports the number of compatibility entries (absent → 0).
pub fn SkillManifest::compatibility_count(self : SkillManifest) -> Int32 {
  match self.compatibility {
    Some(items) => items.length()
    None => 0
  }
}
