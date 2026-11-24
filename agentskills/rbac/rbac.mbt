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
///Role::rank — 角色级别（Viewer=0 / Operator=1 / Admin=2；比较与展示用）。
///
///En: Role::rank exposes the numeric level of a role.
pub fn Role::rank(self : Role) -> Int32 {
  match self {
    Viewer => 0
    Operator => 1
    Admin => 2
  }
}

///|
///Sensitivity::rank — 敏感度级别（Public=0 / Internal=1 / Confidential=2）。
///
///En: Sensitivity::rank exposes the numeric level of a sensitivity class.
pub fn Sensitivity::rank(self : Sensitivity) -> Int32 {
  match self {
    Public => 0
    Internal => 1
    Confidential => 2
  }
}

///|
///Sensitivity::label — 敏感度的稳定文本标签（审计/UI 用）。
///
///En: Sensitivity::label returns a stable textual label.
pub fn Sensitivity::label(self : Sensitivity) -> String {
  match self {
    Public => "public"
    Internal => "internal"
    Confidential => "confidential"
  }
}

///|
///can_access — 授权判定：role 对 sensitivity 的访问权（纯函数，可属性测试）。
pub fn can_access(role : Role, sensitivity : Sensitivity) -> Bool {
  max_sensitivity(role).rank() >= sensitivity.rank()
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

///|
///denied_count — 被拒绝事件数（审计观测面：授权失败统计）。
///
///En: denied_count counts rejected authorization events.
pub fn Auditor::denied_count(self : Self) -> Int32 {
  let mut n = 0
  for r in self.records {
    if !r.allowed {
      n = n + 1
    }
  }
  n
}

///|
///last — 最近一条审计事件（空日志返回 None）。
///
///En: last returns the most recent audit record, if any.
pub fn Auditor::last(self : Self) -> AuditRecord? {
  let size = self.records.length()
  if size == 0 {
    None
  } else {
    Some(self.records[size - 1])
  }
}
