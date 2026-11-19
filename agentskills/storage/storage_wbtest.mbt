///|
test {
  let s = MemoryStorage::new()
  assert_eq(s.count(), 0)
  s.put("a", "1")
  s.put("b", "2")
  assert_eq(s.get("a"), Some("1"))
  assert_eq(s.count(), 2)
  // 覆盖写不增计数
  s.put("a", "9")
  assert_eq(s.get("a"), Some("9"))
  assert_eq(s.count(), 2)
  // delete 存在/不存在语义
  assert_true(s.delete("a"))
  assert_false(s.delete("a"))
  assert_eq(s.get("a"), None)
  assert_eq(s.count(), 1)
  // keys 排序确定性
  s.put("c", "3")
  let ks = s.all_keys()
  assert_eq(ks.length(), 2)
  assert_eq(ks[0], "b")
  assert_eq(ks[1], "c")
}
