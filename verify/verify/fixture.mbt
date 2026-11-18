///|
///verify 模块：fixture 资产 + 差分验证 + mockgen（原 testkit 并入，ARCH §2.5 钉扎 2）。
///上游 fixture ≥40 例是 M0 验收门（Charter §4）；FIXTURE_TARGET 为目标数，
///FIXTURES 为已冻结实测期望的样本清单（每例带 id/输入/期望输出三元组）。
pub const FIXTURE_TARGET : Int32 = 40

///|
///Fixture — 冻结的差分样本：SKILL.md 输入 + 期望的 frontmatter 解析结果。
pub(all) struct Fixture {
  id : String
  skill_md : String
  expect_name : String
  expect_description : String
  expect_license : String?
}

///|
///fixtures — 差分样本清单（M0 起步 3 例；逐步扩至 FIXTURE_TARGET）。
pub let fixtures : Array[Fixture] = [
  {
    id: "FIX-001",
    skill_md: "---\nname: demo\ndescription: A demo skill\nlicense: MIT\n---\n\n# Demo\n\nbody",
    expect_name: "demo",
    expect_description: "A demo skill",
    expect_license: Some("MIT"),
  },
  {
    id: "FIX-002",
    skill_md: "---\nname: minimal\ndescription: Only required fields\n---\nbody",
    expect_name: "minimal",
    expect_description: "Only required fields",
    expect_license: None,
  },
  {
    id: "FIX-003",
    skill_md: "---\nname: probe\ndescription: Frozen upstream expectation probe\nlicense: Apache-2.0\n---\n\n# Probe\n\nline one\nline two",
    expect_name: "probe",
    expect_description: "Frozen upstream expectation probe",
    expect_license: Some("Apache-2.0"),
  },
]
