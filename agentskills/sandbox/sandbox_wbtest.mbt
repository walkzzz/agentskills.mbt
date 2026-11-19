///|
test {
  let g = GasMeter::new(100L)
  assert_eq(g.remaining(), 100L)
  assert_false(g.exhausted())
  assert_true(g.consume(30L))
  assert_eq(g.remaining(), 70L)
  assert_true(g.consume(70L))
  assert_true(g.exhausted())
  // 超限拒绝且 used 不变
  assert_false(g.consume(1L))
  assert_eq(g.remaining(), 0L)
}

///|
test {
  // 负额拒绝
  let g = GasMeter::new(10L)
  assert_false(g.consume(-1L))
  assert_eq(g.remaining(), 10L)
}

///|
test {
  let sb = StubSandbox::new()
  // 空模块拒绝
  let empty = Bytes::from_array([])
  match sb.execute(empty, "main", Json::string("x"), 10L) {
    Failed(_) => assert_true(true)
    _ => assert_true(false)
  }
  // 燃料 0 → OutOfGas
  let one = Bytes::from_array([1])
  match sb.execute(one, "main", Json::string("x"), 0L) {
    OutOfGas => assert_true(true)
    _ => assert_true(false)
  }
  // 正常回显
  match sb.execute(one, "main", Json::string("hello"), 10L) {
    Succeeded(j) => assert_true(j == Json::string("hello"))
    _ => assert_true(false)
  }
  assert_eq(sb.call_count(), 3)
}

///|
test {
  // 缺入口 → 失败分型
  let sb = StubSandbox::new()
  let one = Bytes::from_array([1])
  match sb.execute(one, "", Json::string("x"), 10L) {
    Failed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
