///|
///parse_skill_md — 提取 SKILL.md 的 YAML frontmatter 并解析为 SkillManifest（F01）。
///
///En: parse_skill_md extracts the YAML frontmatter of a SKILL.md file into a SkillManifest.
///格式：`---` 起始行、YAML 正文、`---` 结束行；返回 (manifest, 正文)。缺 frontmatter 或 YAML
///非法返回 Err（fail-fast）。YAML 解析经 moonyaml（W1-D1 锁定）；metadata 映射限定一层扁平 KV。
pub fn parse_skill_md(text : String) -> Result[(SkillManifest, String), String] {
  let view_lines = text.split("\n").collect()
  let lines : Array[String] = []
  for v in view_lines {
    lines.push(v.to_owned())
  }
  if lines.length() == 0 || lines[0].trim() != "---" {
    return Err("missing frontmatter: first line must be '---'")
  }
  let mut end : Int32 = -1
  for i in 1..<lines.length() {
    if lines[i].trim() == "---" {
      end = i
      break
    }
  }
  if end < 0 {
    return Err("unterminated frontmatter: no closing '---'")
  }
  let parts : Array[String] = []
  for i in 1..<end {
    parts.push(lines[i].to_string())
  }
  let fm = parts.join("\n")
  let node = @yaml.loads(fm[:]) catch {
    _ => return Err("invalid YAML frontmatter")
  }
  let j = Json(node)
  let mut name = ""
  let mut description = ""
  let mut license : String? = None
  let mut compatibility : Array[String]? = None
  let mut metadata : Map[String, String]? = None
  match j {
    Object(fields) =>
      for pair in fields {
        let (k, v) = pair
        match k {
          "name" =>
            match v {
              String(s) => name = s
              _ => return Err("field 'name' must be a string")
            }
          "description" =>
            match v {
              String(s) => description = s
              _ => return Err("field 'description' must be a string")
            }
          "license" =>
            match v {
              String(s) => license = Some(s)
              _ => return Err("field 'license' must be a string")
            }
          "compatibility" =>
            match v {
              Array(items) => {
                let arr : Array[String] = []
                for it in items {
                  match it {
                    String(s) => arr.push(s)
                    _ =>
                      return Err(
                        "field 'compatibility' must be a list of strings",
                      )
                  }
                }
                compatibility = Some(arr)
              }
              _ => return Err("field 'compatibility' must be a list")
            }
          "metadata" =>
            match v {
              Object(kv) => {
                let m : Map[String, String] = Map::from_array([])
                for p2 in kv {
                  let (k2, v2) = p2
                  match v2 {
                    String(s) => m[k2] = s
                    _ => return Err("metadata values must be strings")
                  }
                }
                metadata = Some(m)
              }
              _ => return Err("field 'metadata' must be a mapping")
            }
          _ => ()
        }
      }
    _ => return Err("frontmatter must be a YAML mapping")
  }
  let manifest : SkillManifest = {
    name,
    description,
    license,
    compatibility,
    metadata,
  }
  match validate(manifest) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let body_parts : Array[String] = []
  for i in (end + 1)..<lines.length() {
    body_parts.push(lines[i].to_string())
  }
  Ok((manifest, body_parts.join("\n")))
}
