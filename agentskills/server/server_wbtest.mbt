///|
test {
  let router = Router::new()
  router.add("GET", "/api/health", Exact, fn(_req) { ok("healthy") })
  router.add("GET", "/api/", Prefix, fn(req) { ok("prefix:" + req.path) })
  // 精确命中
  match
    router.dispatch({ http_method: "GET", path: "/api/health", body: "", }) {
    r => {
      assert_eq(r.status, 200)
      assert_eq(r.body, "healthy")
    }
  }
  // 前缀命中
  let p = router.dispatch({ http_method: "GET", path: "/api/skills", body: "", })
  assert_eq(p.status, 200)
  assert_eq(p.body, "prefix:/api/skills")
  // 路径命中方法不符 → 405
  let m = router.dispatch({
    http_method: "POST",
    path: "/api/health",
    body: "x",
  })
  assert_eq(m.status, 405)
  // 无命中 → 404
  let n = router.dispatch({ http_method: "GET", path: "/nope", body: "", })
  assert_eq(n.status, 404)
}

///|
test {
  // SSE 编码：单行
  assert_eq(sse_event("ping", "hello"), "event: ping\ndata: hello\n\n")
  // 多行 data 逐行前缀
  let multi = sse_event("delta", "line1\nline2")
  assert_true(multi.contains("data: line1\n"))
  assert_true(multi.contains("data: line2\n"))
  assert_true(multi.has_suffix("\n\n"))
  // 空 data（split 产出单空行）——仍为合法事件块
  let empty = sse_event("tick", "")
  assert_true(empty.contains("event: tick\n"))
  assert_true(empty.has_suffix("\n\n"))
}
