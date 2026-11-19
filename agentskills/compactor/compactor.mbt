///|
///F05 compactor —— 上下文压缩（Kernel 式纯函数域，ARCH §3.1）。
///
///En: F05 compactor — deterministic context compaction (pure functional domain).
///策略：保留全部 system 消息 + 最近 keep_recent 条 user/assistant；更早消息折叠为
///一条计数占位（真实 LLM 摘要属运行时壳——本包只做确定性裁剪与安全截断）。
pub(all) struct Message {
  role : String
  content : String
}

///|
///truncate_chars — Unicode 安全截断（按 codepoint，绝不劈开多字节字符——E7）。
pub fn truncate_chars(s : String, max_chars : Int32) -> String {
  let buf = StringBuilder()
  let mut n = 0
  for c in s {
    if n >= max_chars {
      break
    }
    buf.write_string("\{c}")
    n = n + 1
  }
  if n < max_chars {
    buf.to_string()
  } else {
    let total = s.length()
    if total > 0 && n >= max_chars && n < count_chars(s) {
      buf.write_string("…")
    }
    buf.to_string()
  }
}

///|
fn count_chars(s : String) -> Int32 {
  let mut n = 0
  for _c in s {
    n = n + 1
  }
  n
}

///|
///compact — 确定性压缩：system 全保留；user/assistant 仅保留最近 keep_recent 条，
///被折叠的旧消息数量以占位消息记入（"[compacted N earlier messages]"）。
pub fn compact(
  msgs : Array[Message],
  keep_recent~ : Int32 = 8,
) -> Array[Message] {
  let systems : Array[Message] = []
  let dialog : Array[Message] = []
  for m in msgs {
    if m.role == "system" {
      systems.push(m)
    } else {
      dialog.push(m)
    }
  }
  let total = dialog.length()
  let keep = if keep_recent < 0 { 0 } else { keep_recent }
  let dropped = if total > keep { total - keep } else { 0 }
  let out : Array[Message] = []
  for m in systems {
    out.push(m)
  }
  if dropped > 0 {
    out.push({
      role: "system",
      content: "[compacted \{dropped} earlier messages]",
    })
  }
  let start = if total > keep { total - keep } else { 0 }
  for i in start..<total {
    out.push(dialog[i])
  }
  out
}

///|
///fit_budget — 单消息字符预算裁剪（compact 后逐条安全截断）。
pub fn fit_budget(
  msgs : Array[Message],
  max_chars~ : Int32 = 800,
) -> Array[Message] {
  let out : Array[Message] = []
  for m in msgs {
    out.push({ role: m.role, content: truncate_chars(m.content, max_chars), })
  }
  out
}
