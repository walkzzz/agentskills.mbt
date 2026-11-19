///|
///F06 RBAC 三级敏感模型（ARCH §3.1/§7 框架落地；级别名可随部署策略调整）。
///
///En: F06 three-level sensitivity RBAC model — pure functional domain (no IO).
pub(all) enum Sensitivity {
  Public
  Internal
  Confidential
}

///|
pub(all) enum Role {
  Viewer
  Operator
  Admin
}

///|
///max_sensitivity — 角色可访问的最大敏感度（静态策略）。
pub fn max_sensitivity(role : Role) -> Sensitivity {
  match role {
    Viewer => Public
    Operator => Internal
    Admin => Confidential
  }
}

///|
fn rank(s : Sensitivity) -> Int32 {
  match s {
    Public => 0
    Internal => 1
    Confidential => 2
  }
}

///|
///can_access — 授权判定：role 对 sensitivity 的访问权（纯函数，可属性测试）。
pub fn can_access(role : Role, sensitivity : Sensitivity) -> Bool {
  rank(max_sensitivity(role)) >= rank(sensitivity)
}

///|
///AuditRecord — 审计事件（F06 审计面）。
pub(all) struct AuditRecord {
  seq : Int64
  actor : String
  action : String
  allowed : Bool
}

///|
///Auditor — 审计日志（Kernel 式追加日志：无 IO，事件单调编号）。
pub struct Auditor {
  mut next_seq : Int64
  records : Array[AuditRecord]
}

///|
pub fn Auditor::new() -> Auditor {
  { next_seq: 1L, records: [], }
}

///|
///record — 记录一次授权判定事件（单调 seq 自增）。
pub fn Auditor::record(
  self : Self,
  actor : String,
  action : String,
  allowed : Bool,
) -> AuditRecord {
  let rec : AuditRecord = { seq: self.next_seq, actor, action, allowed, }
  self.next_seq = self.next_seq + 1L
  self.records.push(rec)
  rec
}

///|
///log — 审计事件快照。
pub fn Auditor::log(self : Self) -> Array[AuditRecord] {
  self.records
}

///|
///count — 事件数。
pub fn Auditor::count(self : Self) -> Int32 {
  self.records.length()
}
