///|
///agentskills 形式化验证核（F09 燃料账本 / F05 占位计数 / F06 RBAC 授权）。
///
///En: formal verification cores for agentskills (gas ledger, compaction count, RBAC).
///契约式纯函数核（moon prove / Why3 + Z3）：与 sandbox GasMeter、compactor compact、
///rbac can_access 的语义一致——真实实现由测试对齐本核（model-based oracle），
///核本身经 SMT 机器证明（「已证明」与「已使用」两类证据在 TEST_REPORT 分别标注）。

///|
///gas_after — 燃料账本推进核（F09 GasMeter::consume 的语义核）。
pub fn gas_after(
  used : Int64,
  amount : Int64,
) -> Int64 where {
  proof_require: used >= 0,
  proof_require: amount >= 0,
  proof_ensure: res => res == used + amount,
} {
  used + amount
}

///|
///gas_after_never_exceeds — 合法消耗后账面永不超过限额（燃料安全的核心不变量）。
pub fn gas_after_never_exceeds(
  used : Int64,
  amount : Int64,
  limit : Int64,
) -> Bool where {
  proof_require: used >= 0,
  proof_require: amount >= 0,
  proof_require: used + amount <= limit,
  proof_ensure: res => res == true,
} {
  gas_after(used, amount) <= limit
}

///|
///dropped — 压缩占位计数核（F05 compact 的 total - keep 语义核）。
pub fn dropped(
  total : Int32,
  keep : Int32,
) -> Int32 where {
  proof_require: keep >= 0,
  proof_require: total > keep,
  proof_ensure: res => res == total - keep && res > 0,
} {
  total - keep
}

///|
///dropped_positive — 只要发生折叠，占位计数必为正（禁止 0/负占位消息）。
pub fn dropped_positive(
  total : Int32,
  keep : Int32,
) -> Bool where {
  proof_require: keep >= 0,
  proof_require: total > keep,
  proof_ensure: res => res == true,
} {
  dropped(total, keep) > 0
}

///|
///RBAC 三级敏感度序数核（F06 can_access 的 rank 语义核）。
pub const SENS_PUBLIC : Int32 = 0

///|
pub const SENS_INTERNAL : Int32 = 1

///|
pub const SENS_CONFIDENTIAL : Int32 = 2

///|
///角色序数核（Viewer/Operator/Admin ↔ 0/1/2）。
pub const ROLE_VIEWER : Int32 = 0

///|
pub const ROLE_OPERATOR : Int32 = 1

///|
pub const ROLE_ADMIN : Int32 = 2

///|
///allowed — 授权判定核：角色序数 >= 敏感度序数即允许（rbac can_access 语义）。
pub fn allowed(
  role_rank : Int32,
  sens_rank : Int32,
) -> Bool where {
  proof_require: role_rank >= 0,
  proof_require: sens_rank >= 0,
  proof_ensure: res => res == (role_rank >= sens_rank),
} {
  role_rank >= sens_rank
}

///|
///admin_grants_confidential — Admin 可达机密级（授权矩阵上界闭合）。
pub fn admin_grants_confidential() -> Bool where {
  proof_ensure: res => res == true,
} {
  allowed(ROLE_ADMIN, SENS_CONFIDENTIAL)
}

///|
///viewer_denied_confidential — Viewer 不可达机密级（越权拒绝）。
pub fn viewer_denied_confidential() -> Bool where {
  proof_ensure: res => res == false,
} {
  allowed(ROLE_VIEWER, SENS_CONFIDENTIAL)
}

///|
///operator_boundary_exact — Operator 恰好覆盖 Internal（边界兼具）。
pub fn operator_boundary_exact() -> Bool where {
  proof_ensure: res => res == true,
} {
  allowed(ROLE_OPERATOR, SENS_INTERNAL) &&
  !allowed(ROLE_OPERATOR, SENS_CONFIDENTIAL)
}
