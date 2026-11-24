// F05 compactor 预算诊断测试（total_chars 与 truncate_chars 同口径）

///|
fn msg(role : String, content : String) -> @compactor.Message {
  { role, content, }
}

///|
test "total_chars counts codepoints not bytes" {
  let msgs = [
    msg("system", "hello"),
    msg("user", "你好"),
    msg("assistant", "🙂🙂"),
  ]
  assert_eq(@compactor.total_chars(msgs[:]), 5 + 2 + 2)
}

///|
test "total_chars is consistent with truncate_chars" {
  let msgs = [msg("user", "abcdefghij")]
  assert_eq(@compactor.total_chars(msgs[:]), 10)
  assert_eq(@compactor.truncate_chars(msgs[0].content, 4), "abcd…")
}

///|
test "total_chars of empty input is zero" {
  let empty : Array[@compactor.Message] = []
  assert_eq(@compactor.total_chars(empty[:]), 0)
}
