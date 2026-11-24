///|
/// agentskills.mbt 浏览器演示导出层（JS / WasmGC 目标）。
/// Browser-demo exports for agentskills.mbt. Non-raising signatures: errors fold into
/// `{"ok":false,...}` / false / "" so the JS side needs no exception mapping.

///|
fn error_json(msg : String) -> String {
  let j : Json = { "ok": Json(false), "error": Json(msg) }
  j.stringify()
}

///|
/// 逗号分隔清单 → 去空白/去空项数组
fn split_csv(csv : String) -> Array[String] {
  let out : Array[String] = []
  for part in csv.split(",") {
    let s = part.trim(chars=" ").to_owned()
    if s.length() > 0 {
      out.push(s)
    }
  }
  out
}

///|
fn json_strings(items : Array[String]) -> Json {
  let out : Array[Json] = []
  for s in items {
    out.push(Json(s))
  }
  Json::array(out)
}

///|
/// SKILL.md 解析（F01）：frontmatter + 正文长度 + 校验结论
#export_name("skill_parse")
pub fn skill_parse(skill_md : String) -> String {
  match @skill.parse_skill_md(skill_md) {
    Ok(result) => {
      let manifest = result.0
      let body = result.1
      let compatibility = match manifest.compatibility {
        Some(items) => json_strings(items)
        None => Json::array([])
      }
      let license = match manifest.license {
        Some(text) => Json(text)
        None => Json::null()
      }
      let body_messages : Array[@compactor.Message] = [
        { role: "body", content: body, },
      ]
      let j : Json = {
        "ok": Json(true),
        "name": Json(manifest.name),
        "description": Json(manifest.description),
        "license": license,
        "compatibility": compatibility,
        "compatibility_count": Json::number(
          manifest.compatibility_count().to_double(),
        ),
        "has_license": Json(manifest.has_license()),
        "body_chars": Json::number(
          @compactor.total_chars(body_messages[:]).to_double(),
        ),
      }
      j.stringify()
    }
    Err(message) => error_json(message)
  }
}

///|
/// manifest 校验（F01）：name/description 长度契约与可选字段
#export_name("skill_validate")
pub fn skill_validate(
  name : String,
  description : String,
  license : String,
  compatibility_csv : String,
) -> String {
  let manifest : @skill.SkillManifest = {
    name,
    description,
    license: if license.trim(chars=" ").length() > 0 {
      Some(license)
    } else {
      None
    },
    compatibility: Some(split_csv(compatibility_csv)),
    metadata: None,
  }
  let result : Json = match @skill.validate(manifest) {
    Ok(_) =>
      {
        "ok": Json(true),
        "valid": Json(true),
        "name_chars": Json::number(name.length().to_double()),
        "description_chars": Json::number(description.length().to_double()),
      }
    Err(message) =>
      { "ok": Json(false), "valid": Json(false), "error": Json(message) }
  }
  result.stringify()
}

///|
/// 注册表演示（F02）：按序注册 → 升格首个 → 输出名称/级别
#export_name("registry_demo")
pub fn registry_demo(names_csv : String) -> String {
  let names = split_csv(names_csv)
  if names.length() == 0 {
    return error_json("at least one skill name required")
  }
  let registry = @skill.SkillRegistry::new()
  let rejected : Array[String] = []
  for name in names {
    let manifest : @skill.SkillManifest = {
      name,
      description: "demo skill \{name}",
      license: Some("MIT"),
      compatibility: None,
      metadata: None,
    }
    match registry.register(manifest, @skill.Metadata) {
      Ok(_) => ()
      Err(_) => rejected.push(name)
    }
  }
  let _ = registry.promote(names[0])
  let levels : Array[Json] = []
  for name in registry.names() {
    let level = match registry.level_of(name) {
      Some(@skill.FullyLoaded) => "fully-loaded"
      Some(@skill.Metadata) => "metadata"
      None => "unknown"
    }
    levels.push(Json(level))
  }
  let j : Json = {
    "ok": Json(true),
    "count": Json::number(registry.count().to_double()),
    "names": json_strings(registry.names()),
    "levels": Json::array(levels),
    "rejected": json_strings(rejected),
  }
  j.stringify()
}

///|
/// RBAC 授权矩阵（F06）：3 角色 × 3 敏感度 + 级别与标签
#export_name("rbac_matrix")
pub fn rbac_matrix() -> String {
  let roles = [@rbac.Viewer, @rbac.Operator, @rbac.Admin]
  let sensitivities = [@rbac.Public, @rbac.Internal, @rbac.Confidential]
  let role_names : Array[String] = ["viewer", "operator", "admin"]
  let role_ranks : Array[Json] = []
  for role in roles {
    role_ranks.push(Json::number(role.rank().to_double()))
  }
  let sens_labels : Array[String] = []
  let sens_ranks : Array[Json] = []
  for s in sensitivities {
    sens_labels.push(s.label())
    sens_ranks.push(Json::number(s.rank().to_double()))
  }
  let matrix : Array[Json] = []
  for role in roles {
    let row : Array[Json] = []
    for s in sensitivities {
      row.push(Json(@rbac.can_access(role, s)))
    }
    matrix.push(Json::array(row))
  }
  let j : Json = {
    "ok": Json(true),
    "roles": json_strings(role_names),
    "role_ranks": Json::array(role_ranks),
    "sensitivities": json_strings(sens_labels),
    "sensitivity_ranks": Json::array(sens_ranks),
    "matrix": Json::array(matrix),
  }
  j.stringify()
}

///|
/// RBAC 单次判定（F06）：role / sensitivity 取 "viewer|operator|admin" 与
/// "public|internal|confidential"
#export_name("rbac_check")
pub fn rbac_check(role : String, sensitivity : String) -> Bool {
  let role = match role {
    "viewer" => @rbac.Viewer
    "operator" => @rbac.Operator
    "admin" => @rbac.Admin
    _ => return false
  }
  let sensitivity = match sensitivity {
    "public" => @rbac.Public
    "internal" => @rbac.Internal
    "confidential" => @rbac.Confidential
    _ => return false
  }
  @rbac.can_access(role, sensitivity)
}

///|
/// 上下文压缩演示（F05）：messages_json = [{"role","content"}]，keep_recent + 单条预算
#export_name("compact_demo")
pub fn compact_demo(
  messages_json : String,
  keep_recent : Int32,
  max_chars : Int32,
) -> String {
  let parsed = @json.parse(messages_json) catch {
    _ => return error_json("invalid messages JSON")
  }
  let messages : Array[@compactor.Message] = []
  match parsed {
    Array(items) =>
      for item in items {
        let role = match item_field(item, "role") {
          Some(text) => text
          None => return error_json("message role must be a string")
        }
        let content = match item_field(item, "content") {
          Some(text) => text
          None => return error_json("message content must be a string")
        }
        messages.push({ role, content, })
      }
    _ => return error_json("messages must be a JSON array")
  }
  let before_chars = @compactor.total_chars(messages[:])
  let compacted = @compactor.compact(messages, keep_recent~)
  let fitted = @compactor.fit_budget(compacted, max_chars~)
  let after_chars = @compactor.total_chars(fitted[:])
  // 折叠收益判断：占位比被折叠内容更长时不应"越压越大"，直接保留原消息
  let folded = after_chars < before_chars
  let output = if folded { fitted } else { messages }
  let final_chars = if folded { after_chars } else { before_chars }
  let items : Array[Json] = []
  for m in output {
    items.push({ "role": Json(m.role), "content": Json(m.content) })
  }
  let j : Json = {
    "ok": Json(true),
    "input_chars": Json::number(before_chars.to_double()),
    "output_chars": Json::number(final_chars.to_double()),
    "saved_chars": Json::number((before_chars - final_chars).to_double()),
    "folded": Json(folded),
    "note": Json(
      if folded {
        ""
      } else {
        "折叠无收益，已跳过（保留原消息）"
      },
    ),
    "messages": Json::array(items),
  }
  j.stringify()
}

///|
fn item_field(item : Json, key : String) -> String? {
  match item {
    Object(fields) =>
      match fields.get(key) {
        Some(String(text)) => Some(text)
        _ => None
      }
    _ => None
  }
}

///|
/// Unicode 安全截断（F05）：按 codepoint 截断并追加省略号。
/// max_chars <= 0 返回空串（不再返回超出上限的 "…"）。
#export_name("truncate_text")
pub fn truncate_text(text : String, max_chars : Int32) -> String {
  if max_chars <= 0 {
    return ""
  }
  @compactor.truncate_chars(text, max_chars)
}

///|
/// RRF 融合演示（F04）：rankings_json = [["doc-a","doc-b"], ...]
#export_name("rrf_demo")
pub fn rrf_demo(rankings_json : String, k : Int32, top_n : Int32) -> String {
  if k <= 0 {
    return error_json("k must be > 0")
  }
  if top_n < 0 {
    return error_json("top_n must be >= 0")
  }
  let parsed = @json.parse(rankings_json) catch {
    _ => return error_json("invalid rankings JSON")
  }
  let rankings : Array[Array[String]] = []
  match parsed {
    Array(groups) =>
      for group in groups {
        match group {
          Array(items) => {
            let docs : Array[String] = []
            for item in items {
              match item {
                String(doc) => docs.push(doc)
                _ => return error_json("ranking entries must be strings")
              }
            }
            rankings.push(docs)
          }
          _ => return error_json("each ranking must be a string array")
        }
      }
    _ => return error_json("rankings must be a JSON array")
  }
  let hits = @rag.rrf_fuse_top(rankings, k~, top_n~)
  let items : Array[Json] = []
  for hit in hits {
    if !hit.score.is_finite() {
      return error_json("non-finite RRF score")
    }
    items.push({ "doc_id": Json(hit.doc_id), "score": Json::number(hit.score) })
  }
  let j : Json = {
    "ok": Json(true),
    "count": Json::number(hits.length().to_double()),
    "hits": Json::array(items),
  }
  j.stringify()
}

///|
/// 消息字符总数（F05 预算诊断）
#export_name("total_chars")
pub fn total_chars(messages_json : String) -> Int32 {
  let parsed = @json.parse(messages_json) catch { _ => return -1 }
  match parsed {
    Array(items) => {
      let messages : Array[@compactor.Message] = []
      for item in items {
        let content = match item_field(item, "content") {
          Some(text) => text
          None => return -1
        }
        messages.push({ role: "any", content, })
      }
      @compactor.total_chars(messages[:])
    }
    _ => -1
  }
}

///|
/// 字符统计（含错误分类）：成功 `{"ok":true,"chars":N}`；
/// JSON 语法错误 / 非数组 / content 非字符串分别返回具体原因。
#export_name("total_chars_detail")
pub fn total_chars_detail(messages_json : String) -> String {
  let parsed = @json.parse(messages_json) catch {
    _ => return error_json("invalid messages JSON")
  }
  match parsed {
    Array(items) => {
      let messages : Array[@compactor.Message] = []
      for item in items {
        let content = match item_field(item, "content") {
          Some(text) => text
          None => return error_json("message content must be a string")
        }
        messages.push({ role: "any", content, })
      }
      let j : Json = {
        "ok": Json(true),
        "chars": Json::number(@compactor.total_chars(messages[:]).to_double()),
      }
      j.stringify()
    }
    _ => error_json("messages must be a JSON array")
  }
}

///|
/// 演示工具（F03 单源映射的最小 SkillTool 实现）
priv struct DemoTool {
  name : String
  description : String
}

///|
impl @tooling_bridge.SkillTool for DemoTool with fn tool_name(self) -> String {
  self.name
}

///|
impl @tooling_bridge.SkillTool for DemoTool with fn tool_description(self) -> String {
  self.description
}

///|
impl @tooling_bridge.SkillTool for DemoTool with fn tool_input_schema(_self) -> Json {
  { "type": "object" }
}

///|
impl @tooling_bridge.SkillTool for DemoTool with fn execute(_self, args) -> Json {
  args
}

///|
/// 技能工具 → MCP tools/list 条目（F03 单源映射）。
/// 非空与长度校验：name 必填且 ≤64，description 必填（与 gbz185 tool_descriptor_check 同口径）。
#export_name("tool_mcp_entry")
pub fn tool_mcp_entry(name : String, description : String) -> String {
  let trimmed_name = name.trim(chars=" ").to_owned()
  if trimmed_name.length() == 0 {
    return error_json("tool name required")
  }
  if trimmed_name.length() > 64 {
    return error_json("tool name exceeds 64 chars")
  }
  if description.trim(chars=" ").length() == 0 {
    return error_json("tool description required")
  }
  let tool : DemoTool = { name, description, }
  @tooling_bridge.to_mcp_entry(tool).stringify()
}
