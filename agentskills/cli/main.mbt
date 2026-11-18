///|
///demo_skill_md — 内嵌演示技能（最小闭环数据源；文件系统读随 async 集成接入）。
fn demo_skill_md() -> String {
  "---\nname: demo\ndescription: A demo skill that echoes a greeting\nlicense: MIT\ncompatibility:\n  - moonbit\nmetadata:\n  author: walkzzz\n---\n\n# Demo Skill\n\nEchoes a greeting."
}

///|
///F15 CLI（最小闭环演示）：F01 解析 → 校验 → F02 注册全链路。
///子命令面（skill load/run/build 与 argv 机制）随 async 文件系统集成落地。
fn main {
  println("agentskills CLI v\{@root.VERSION}")
  println("F01 parse_skill_md:")
  match @skill.parse_skill_md(demo_skill_md()) {
    Ok((manifest, body)) => {
      println("  name        = \{manifest.name}")
      println("  description = \{manifest.description}")
      match manifest.license {
        Some(l) => println("  license     = \{l}")
        None => ()
      }
      println("  body_bytes  = \{body.length()}")
      println("F02 SkillRegistry.register:")
      let reg = @skill.SkillRegistry::new()
      match reg.register(manifest, @skill.FullyLoaded) {
        Ok(_) => println("  registered   = \{reg.count()} skill(s)")
        Err(e) => println("  FAILED: \{e}")
      }
    }
    Err(e) => println("  FAILED: \{e}")
  }
}
