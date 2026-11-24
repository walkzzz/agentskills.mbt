///|
///SkillTool — 技能侧工具契约（F03；ARCH §2.5 钉扎 1：ToolDescriptor 单源模型）。
///
///En: SkillTool is the skill-side tool contract bridged to GB/Z 185.7 descriptors.
///技能作者以原生 Json 契约声明工具；经 to_descriptor 映射为 GB/Z 185.7 ToolDescriptor
///（NativeBinding），再经 register_skill_tool 桥入国标 ToolRegistry 统一调用与审计。
pub(open) trait SkillTool {
  fn tool_name(Self) -> String
  fn tool_description(Self) -> String
  fn tool_input_schema(Self) -> Json
  fn execute(Self, Json) -> Json
}

///|
///to_descriptor — SKILL 工具 → GB/Z 185.7 ToolDescriptor 单源映射（NativeBinding）。
pub fn[T : SkillTool] to_descriptor(t : T) -> @tooling.ToolDescriptor {
  let d : @tooling.ToolDescriptor = {
    name: t.tool_name(),
    description: t.tool_description(),
    input_schema: t.tool_input_schema(),
    binding: @tooling.NativeBinding,
  }
  d
}

///|
///to_mcp_entry — 技能工具 → MCP tools/list 条目（GB/Z 185.7 单源映射的 MCP 视图）。
///
///En: to_mcp_entry maps a SkillTool to the MCP tools/list entry (single-source view).
pub fn[T : SkillTool] to_mcp_entry(t : T) -> Json {
  to_descriptor(t).to_mcp_entry()
}

///|
///register_skill_tool — 将技能工具桥入国标 ToolRegistry（闭包 handler 翻译
///Json → ToolOutcome：execute 结果包 Completed；失败语义由技能实现内嵌 Json 表达）。
pub fn[T : SkillTool] register_skill_tool(
  reg : @tooling.ToolRegistry,
  t : T,
) -> Unit raise @tooling.ToolingError {
  reg.register(to_descriptor(t), fn(inv) {
    @tooling.Completed(t.execute(inv.args))
  })
}
