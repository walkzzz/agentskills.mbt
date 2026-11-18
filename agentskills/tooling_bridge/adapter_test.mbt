///|
struct EchoTool {
  prefix : String
}

///|
impl @tooling_bridge.SkillTool for EchoTool with fn tool_name(_self) -> String {
  "echo"
}

///|
impl @tooling_bridge.SkillTool for EchoTool with fn tool_description(_self) -> String {
  "Echoes the input string"
}

///|
impl @tooling_bridge.SkillTool for EchoTool with fn tool_input_schema(_self) -> Json {
  Json::object(Map::from_array([("type", Json::string("object"))]))
}

///|
impl @tooling_bridge.SkillTool for EchoTool with fn execute(self, args) -> Json {
  match args {
    String(s) => Json::string("\{self.prefix}: \{s}")
    _ => Json::string(self.prefix)
  }
}

///|
test {
  let reg = @tooling.ToolRegistry::new()
  let tool : EchoTool = { prefix: "hello", }
  @tooling_bridge.register_skill_tool(reg, tool)
  match reg.lookup("echo") {
    Some(d) => {
      assert_eq(d.name, "echo")
      assert_true(d.binding is @tooling.NativeBinding)
    }
    None => assert_true(false)
  }
  let inv : @tooling.ToolInvocation = {
    invocation_id: "i1",
    tool: "echo",
    args: Json::string("hi"),
  }
  let outcome = reg.invoke_tool(inv)
  match outcome {
    @tooling.Completed(j) => assert_true(j == Json::string("hello: hi"))
    @tooling.Failed(e) => {
      println(e)
      assert_true(false)
    }
  }
  assert_eq(reg.count(), 1)
}
