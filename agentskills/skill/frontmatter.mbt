///|
///parse_skill_md — 提取 SKILL.md 的 YAML frontmatter 并解析为 SkillManifest（F01）。
///
///En: parse_skill_md extracts the YAML frontmatter of a SKILL.md file into a SkillManifest.
///格式：`---` 起始行、YAML 正文、`---` 结束行；返回 (manifest, 正文)。缺 frontmatter 或 YAML
///非法返回 Err（fail-fast）。YAML 解析经 moonyaml（W1-D1 锁定）；metadata 各键保留原始 Json 值
///（上游真实文件含内联数组等非标量形态，如 tags: ["a", "b"]——不作扁平化收窄）。
pub fn parse_skill_md(text : String) -> Result[(SkillManifest, String), String] {
  let lines : Array[String] = []
  for v in text.split("\n").collect() {
    lines.push(v.to_owned())
  }
  if lines.length() == 0 || lines[0].trim() != "---" {
    return Err("missing frontmatter: first line must be '---'")
  }
  let end = find_closing_fence(lines)
  if end < 0 {
    return Err("unterminated frontmatter: no closing '---'")
  }
  let parts : Array[String] = []
  for i in 1..<end {
    parts.push(lines[i])
  }
  let node = @yaml.loads(parts.join("\n")[:]) catch {
    _ => return Err("invalid YAML frontmatter")
  }
  let fields = match collect_fields(Json(node)) {
    Ok(fs) => fs
    Err(e) => return Err(e)
  }
  let name = match string_field(fields, "name") {
    Ok(Some(s)) => s
    Ok(None) => ""
    Err(e) => return Err(e)
  }
  let description = match string_field(fields, "description") {
    Ok(Some(s)) => s
    Ok(None) => ""
    Err(e) => return Err(e)
  }
  let license = match string_field(fields, "license") {
    Ok(v) => v
    Err(e) => return Err(e)
  }
  let compatibility = match strings_field(fields, "compatibility") {
    Ok(v) => v
    Err(e) => return Err(e)
  }
  let metadata = match map_field(fields, "metadata") {
    Ok(v) => v
    Err(e) => return Err(e)
  }
  let manifest : SkillManifest = { name, description, license, compatibility, metadata }
  match validate(manifest) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let body_parts : Array[String] = []
  for i in (end + 1)..<lines.length() {
    body_parts.push(lines[i])
  }
  Ok((manifest, body_parts.join("\n")))
}

///|
///find_closing_fence — 定位 frontmatter 闭合行（`---`），未找到返回 -1。
fn find_closing_fence(lines : Array[String]) -> Int32 {
  for i in 1..<lines.length() {
    if lines[i].trim() == "---" {
      return i
    }
  }
  -1
}

///|
///collect_fields — 顶层对象字段映射（非对象 → Err）。
fn collect_fields(j : Json) -> Result[Map[String, Json], String] {
  match j {
    Object(fields) => Ok(fields)
    _ => Err("frontmatter must be a YAML mapping")
  }
}

///|
///field_of — 按名查字段（缺失 → None）。
fn field_of(fields : Map[String, Json], name : String) -> Json? {
  fields.get(name)
}

///|
///string_field — 文本字段（缺失 → None；类型错 → Err）。
fn string_field(
  fields : Map[String, Json],
  name : String
) -> Result[String?, String] {
  match field_of(fields, name) {
    None => Ok(None)
    Some(v) =>
      match v {
        String(s) => Ok(Some(s))
        _ => Err("field '\{name}' must be a string")
      }
  }
}

///|
///strings_field — 字符串列表字段（兼容字符串标量 → 单元素；缺失 → None）。
fn strings_field(
  fields : Map[String, Json],
  name : String
) -> Result[Array[String]?, String] {
  match field_of(fields, name) {
    None => Ok(None)
    Some(v) =>
      match v {
        String(s) => Ok(Some([s]))
        Array(items) => {
          let arr : Array[String] = []
          for it in items {
            match it {
              String(s) => arr.push(s)
              _ => return Err("field '\{name}' must be a list of strings")
            }
          }
          Ok(Some(arr))
        }
        _ => Err("field '\{name}' must be a list or string")
      }
  }
}

///|
///map_field — 映射字段（原始 Json 值保留；缺失 → None）。
fn map_field(
  fields : Map[String, Json],
  name : String
) -> Result[Map[String, Json]?, String] {
  match field_of(fields, name) {
    None => Ok(None)
    Some(v) =>
      match v {
        Object(kv) => {
          let m : Map[String, Json] = Map::from_array([])
          for p2 in kv {
            let (k2, v2) = p2
            m[k2] = v2
          }
          Ok(Some(m))
        }
        _ => Err("field '\{name}' must be a mapping")
      }
  }
}

///|
///SkillManifest::parse — parse_skill_md 的方法化入口（Type::fn 惯用形式，与函数等价）。
pub fn SkillManifest::parse(
  text : String
) -> Result[(SkillManifest, String), String] {
  parse_skill_md(text)
}