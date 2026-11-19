///|
test {
  // 授权矩阵：Viewer≤Public、Operator≤Internal、Admin≤Confidential
  assert_true(@rbac.can_access(@rbac.Viewer, @rbac.Public))
  assert_false(@rbac.can_access(@rbac.Viewer, @rbac.Internal))
  assert_false(@rbac.can_access(@rbac.Viewer, @rbac.Confidential))
  assert_true(@rbac.can_access(@rbac.Operator, @rbac.Public))
  assert_true(@rbac.can_access(@rbac.Operator, @rbac.Internal))
  assert_false(@rbac.can_access(@rbac.Operator, @rbac.Confidential))
  assert_true(@rbac.can_access(@rbac.Admin, @rbac.Public))
  assert_true(@rbac.can_access(@rbac.Admin, @rbac.Internal))
  assert_true(@rbac.can_access(@rbac.Admin, @rbac.Confidential))
}

///|
test {
  let aud = @rbac.Auditor::new()
  assert_eq(aud.count(), 0)
  let r1 = aud.record("alice", "skill.run", true)
  assert_eq(r1.seq, 1L)
  let r2 = aud.record("bob", "skill.read", false)
  assert_eq(r2.seq, 2L)
  assert_eq(aud.count(), 2)
  let events = aud.log()
  assert_eq(events[0].actor, "alice")
  assert_true(events[0].allowed == true)
  assert_true(events[1].allowed == false)
  assert_eq(events[1].action, "skill.read")
}
