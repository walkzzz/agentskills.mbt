// F06 RBAC 级别与审计观测测试（rank / label / 3×3 授权矩阵 / denied_count / last）

///|
test "role and sensitivity ranks are ordered" {
  assert_eq(@rbac.Viewer.rank(), 0)
  assert_eq(@rbac.Operator.rank(), 1)
  assert_eq(@rbac.Admin.rank(), 2)
  assert_eq(@rbac.Public.rank(), 0)
  assert_eq(@rbac.Internal.rank(), 1)
  assert_eq(@rbac.Confidential.rank(), 2)
}

///|
test "sensitivity labels are stable" {
  assert_eq(@rbac.Public.label(), "public")
  assert_eq(@rbac.Internal.label(), "internal")
  assert_eq(@rbac.Confidential.label(), "confidential")
}

///|
test "can_access matches the 3x3 policy matrix" {
  let roles = [@rbac.Viewer, @rbac.Operator, @rbac.Admin]
  let sens = [@rbac.Public, @rbac.Internal, @rbac.Confidential]
  let expected = [[true, false, false], [true, true, false], [true, true, true]]
  for i in 0..<3 {
    for j in 0..<3 {
      assert_eq(@rbac.can_access(roles[i], sens[j]), expected[i][j])
    }
  }
}

///|
test "auditor tracks denials and last record" {
  let auditor = @rbac.Auditor::new()
  assert_true(auditor.last() is None)
  assert_eq(auditor.denied_count(), 0)
  let first = auditor.record("agent-a", "read", true)
  assert_eq(first.seq, 1L)
  let second = auditor.record("agent-b", "write", false)
  assert_eq(second.seq, 2L)
  let _ = auditor.record("agent-c", "delete", false)
  assert_eq(auditor.count(), 3)
  assert_eq(auditor.denied_count(), 2)
  match auditor.last() {
    Some(rec) => {
      assert_eq(rec.seq, 3L)
      assert_eq(rec.actor, "agent-c")
      assert_false(rec.allowed)
    }
    None => panic()
  }
}
