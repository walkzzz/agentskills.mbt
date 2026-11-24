// F03 工具单源 MCP 视图测试（to_mcp_entry 与 to_descriptor 同源）

///|
struct SimpleTool {}

///|
impl @tooling_bridge.SkillTool for SimpleTool with fn tool_name(_self) -> String {
  "simple"
}

///|
impl @tooling_bridge.SkillTool for SimpleTool with fn tool_description(_self) -> String {
  "simple tool"
}

///|
impl @tooling_bridge.SkillTool for SimpleTool with fn tool_input_schema(_self) -> Json {
  { "type": "object" }
}

///|
impl @tooling_bridge.SkillTool for SimpleTool with fn execute(_self, _args) -> Json {
  Json::null()
}

///|
test "to_mcp_entry mirrors the descriptor single source" {
  let tool = SimpleTool::{ }
  let entry = @tooling_bridge.to_mcp_entry(tool)
  let doc = @tooling_bridge.to_descriptor(tool)
  assert_eq(entry.stringify(), doc.to_mcp_entry().stringify())
  assert_true(entry.stringify().contains("\"name\":\"simple\""))
  assert_true(entry.stringify().contains("inputSchema"))
}
