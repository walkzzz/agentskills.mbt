///|
///echo 模块（38 字节，Node 实测 echo(42)=42）：
///`(module (func (export "echo") (param i32) (result i32) local.get 0))`
fn echo_wasm() -> Bytes {
  Bytes::from_array([
    0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x06, 0x01, 0x60, 0x01,
    0x7f, 0x01, 0x7f, 0x03, 0x02, 0x01, 0x00, 0x07, 0x08, 0x01, 0x04, 0x65, 0x63,
    0x68, 0x6f, 0x00, 0x00, 0x0a, 0x06, 0x01, 0x04, 0x00, 0x20, 0x00, 0x0b,
  ])
}

///|
test {
  let sb = WasmJsSandbox::new()
  // 有效模块 + echo 调用（JSON 数字 42 → i32 42 → "42"）
  match sb.execute(echo_wasm(), "echo", Json::number(42.0), 1000L) {
    Succeeded(j) => assert_true(j.stringify() == "42")
    _ => assert_true(false)
  }
  // 无效字节 → Failed
  match
    sb.execute(Bytes::from_array([1, 2, 3]), "echo", Json::number(1.0), 10L) {
    Failed(_) => assert_true(true)
    _ => assert_true(false)
  }
  // 燃料 0 → OutOfGas
  match sb.execute(echo_wasm(), "echo", Json::number(1.0), 0L) {
    OutOfGas => assert_true(true)
    _ => assert_true(false)
  }
  // 缺导出 → Failed
  match sb.execute(echo_wasm(), "nope", Json::number(1.0), 10L) {
    Failed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
