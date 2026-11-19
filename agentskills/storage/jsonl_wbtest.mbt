///|
test {
  let line = encode_line("k", "v")
  assert_eq(line, "{\"key\":\"k\",\"value\":\"v\"}")
  match parse_line(line) {
    Some((k, v)) => {
      assert_eq(k, "k")
      assert_eq(v, "v")
    }
    None => assert_true(false)
  }
}

///|
test {
  // 特殊字符往返（引号/反斜杠/换行/制表/回车/中文/emoji）
  let key = "a\"b\\c\nd\te\rf智能🦀"
  let value = "{\"nested\":\"json\"}\nEND"
  let line = encode_line(key, value)
  match parse_line(line) {
    Some((k, v)) => {
      assert_eq(k, key)
      assert_eq(v, value)
    }
    None => assert_true(false)
  }
}

///|
test {
  // 坏行容错
  assert_true(parse_line("not json") is None)
  assert_true(parse_line("{\"key\":\"a\"}") is None)
  assert_true(parse_line("{\"key\":\"a\",\"value\":\"b\"") is None)
  // 批量：空行跳过、坏行跳过
  let text = encode_all([("a", "1"), ("b", "2")]) + "\n\nnot-json\n"
  let pairs = parse_all(text)
  assert_eq(pairs.length(), 2)
  assert_eq(pairs[0].0, "a")
  assert_eq(pairs[1].1, "2")
}

///|
test {
  // 空键值往返
  let line = encode_line("", "")
  match parse_line(line) {
    Some((k, v)) => {
      assert_true(k == "")
      assert_true(v == "")
    }
    None => assert_true(false)
  }
}
