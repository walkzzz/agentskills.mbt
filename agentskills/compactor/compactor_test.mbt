///|
test {
  let msgs : Array[@compactor.Message] = [
    { role: "system", content: "You are a skill runtime.", },
    { role: "user", content: "u1", },
    { role: "assistant", content: "a1", },
    { role: "user", content: "u2", },
    { role: "assistant", content: "a2", },
    { role: "user", content: "u3", },
    { role: "assistant", content: "a3", },
  ]
  let out = @compactor.compact(msgs, keep_recent=2)
  // system 保留 + 1 条占位 + 最近 2 条
  assert_eq(out.length(), 4)
  assert_eq(out[0].content, "You are a skill runtime.")
  assert_eq(out[1].content, "[compacted 4 earlier messages]")
  assert_eq(out[2].content, "u3")
  assert_eq(out[3].content, "a3")
}

///|
test {
  // 中文/Emoji 安全截断（不劈开多字节字符）
  let s = "智能体互联协议🦀MoonBit"
  let t = @compactor.truncate_chars(s, 5)
  assert_true(t.has_prefix("智能体互联"))
  // 精确字符数：5 个保留字 + 1 个省略号 = 6（off-by-one 变异杀手）
  let mut cnt = 0
  for _c in t {
    cnt = cnt + 1
  }
  assert_eq(cnt, 6)
  let full = @compactor.truncate_chars(s, 100)
  assert_eq(full, s)
  assert_false(t.contains("\u{FFFD}"))
}

///|
test {
  let msgs : Array[@compactor.Message] = [
    { role: "user", content: "a".repeat(20), },
    { role: "assistant", content: "b".repeat(20), },
  ]
  let fitted = @compactor.fit_budget(msgs, max_chars=10)
  assert_eq(fitted.length(), 2)
  assert_true(fitted[0].content.length() > 10) // 含省略号
  assert_true(fitted[0].content.contains("…"))
  // keep_recent=0：仅 system + 占位
  let only = @compactor.compact(msgs, keep_recent=0)
  assert_eq(only.length(), 1)
  assert_eq(only[0].content, "[compacted 2 earlier messages]")
}
