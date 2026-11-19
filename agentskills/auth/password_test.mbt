///|
test {
  let salt = Bytes::from_array(Array::makei(16, i => (i * 7 + 3).to_byte()))
  let h = @auth.hash_password("secret-pw", salt, cost=6)
  assert_true(h.contains("$2b$"))
  assert_true(@auth.verify_password("secret-pw", h))
  assert_false(@auth.verify_password("wrong-pw", h))
}

///|
test {
  // 不同 salt → 不同哈希（bcrypt 语义）
  let salt_a = Bytes::from_array(Array::makei(16, i => (i * 7 + 3).to_byte()))
  let salt_b = Bytes::from_array(Array::makei(16, i => (i * 5 + 11).to_byte()))
  let ha = @auth.hash_password("pw", salt_a, cost=6)
  let hb = @auth.hash_password("pw", salt_b, cost=6)
  assert_true(ha != hb)
  assert_true(@auth.verify_password("pw", ha))
  assert_true(@auth.verify_password("pw", hb))
}
