///|
///auth 包 —— F07 认证（JWT 面，HS256 算法固定）。
///
///En: F07 authentication — JWT surface with the algorithm fixed to HS256.
///签名/校验经 mooncred 的 mooncrypt/spec 契约（不自研密码学）：HMAC-SHA256 由
///mooncrypt mac/hmac 提供。`now` 以纯值 `Clock::At(unix_seconds)` 注入（Kernel 友好），
///不读系统时钟——时钟属运行时壳职责。

///|
///sign_hs256 — 签发 HS256 JWT（claims 任意 JSON 载荷）。
pub fn sign_hs256(
  claims : Map[String, Json],
  secret : Bytes,
) -> String raise @jwt.Refused {
  let keyed = @jwt.mac(fn() {
    @hmac.Hmac::new(secret[:], fn() { @sha2.Hasher::new() })
  })
  let signer : &@spec.Signer = keyed
  @jwt.sign(claims, @jwt.Alg::of("HS256"), signer)
}

///|
///verify_hs256 — 校验 HS256 JWT 并返回 claims。
///
///now_seconds：当前 Unix 秒（由运行时壳注入）；policy 控制 exp/nbf 等时声明检查。
pub fn verify_hs256(
  token : String,
  secret : Bytes,
  now_seconds : Int64,
  policy~ : @jwt.Policy = @jwt.policy,
) -> Map[String, Json] raise @jwt.Refused {
  let keyed = @jwt.mac(fn() {
    @hmac.Hmac::new(secret[:], fn() { @sha2.Hasher::new() })
  })
  let verifier : &@spec.Verifier = keyed
  @jwt.verify(
    token[:],
    @jwt.Alg::of("HS256"),
    verifier,
    now=@jwt.At(now_seconds),
    policy~,
  )
}
