///|
///auth 包 —— F07 认证（口令哈希面）。
///
///En: F07 authentication — password hashing surface.
///密码学原语**不自研**：委托官方 `moonbitlang/x/bcrypt`（与 mooncrypt 双实现交叉验证一致，
///2026-11-18 冒烟实测）。salt 由调用方（运行时壳）提供——随机源属部署环境职责；
///本包是纯函数封装（Kernel 式），不含 IO 与全局状态。
pub const MAX_PASSWORD_BYTES : Int32 = 72

///|
///hash_password — bcrypt 口令哈希（$2b$ 格式，cost 默认 10）。
pub fn hash_password(
  password : String,
  salt : Bytes,
  cost~ : Int32 = 10,
) -> String raise @xbcrypt.BcryptError {
  @xbcrypt.hash(password=@utf8.encode(password), salt~, cost~)
}

///|
///verify_password — 校验口令与存储哈希是否匹配（恒定时间由底层实现保证）。
pub fn verify_password(
  password : String,
  hashed : String,
) -> Bool raise @xbcrypt.BcryptError {
  @xbcrypt.verify(password=@utf8.encode(password), hashed~)
}
