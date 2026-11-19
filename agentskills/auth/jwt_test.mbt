///|
test {
  let secret = Bytes::from_array(Array::makei(32, i => (i * 11 + 5).to_byte()))
  let claims : Map[String, Json] = Map::from_array([
    ("sub", Json::string("alice")),
    ("role", Json::string("admin")),
  ])
  let token = @auth.sign_hs256(claims, secret)
  assert_true(token.length() > 20)
  let back = @auth.verify_hs256(token, secret, 1700000000L)
  assert_eq(back.get("sub"), Some(Json::string("alice")))
  assert_eq(back.get("role"), Some(Json::string("admin")))
}

///|
test {
  let secret = Bytes::from_array(Array::makei(32, i => (i * 11 + 5).to_byte()))
  let other = Bytes::from_array(Array::makei(32, i => (i * 3 + 7).to_byte()))
  let claims : Map[String, Json] = Map::from_array([("k", Json::string("v"))])
  let token = @auth.sign_hs256(claims, secret)
  // 错误密钥拒收
  let bad_key = try {
    let _ = @auth.verify_hs256(token, other, 1700000000L)
    false
  } catch {
    _ => true
  }
  assert_true(bad_key)
  // 篡改载荷拒收
  let tampered = token + "x"
  let bad_tamper = try {
    let _ = @auth.verify_hs256(tampered, secret, 1700000000L)
    false
  } catch {
    _ => true
  }
  assert_true(bad_tamper)
}
