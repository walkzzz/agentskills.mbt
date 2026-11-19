///|
///F08 存储后端 —— JSONL 行式编解码核（纯函数，无 IO）。
///
///En: F08 storage backend — JSONL line codec core (pure functions, no IO).
///行形状：`{"key":"<esc>","value":"<esc>"}`；编码器保证转义对称，解码器接受
///任意 encode_line 产出（往返契约）。坏行返回 None（容错：损坏行不污染其它行）。
fn to_chars(s : String) -> Array[Char] {
  let out : Array[Char] = []
  for c in s {
    out.push(c)
  }
  out
}

///|
fn escape_json(s : String) -> String {
  let buf = StringBuilder()
  for c in s {
    if c == '"' {
      buf.write_string("\\\"")
    } else if c == '\\' {
      buf.write_string("\\\\")
    } else if c == '\n' {
      buf.write_string("\\n")
    } else if c == '\t' {
      buf.write_string("\\t")
    } else if c == '\r' {
      buf.write_string("\\r")
    } else {
      buf.write_string("\{c}")
    }
  }
  buf.to_string()
}

///|
fn unescape_json(chars : Array[Char], start : Int32, end : Int32) -> String {
  let buf = StringBuilder()
  let mut i = start
  while i < end {
    let c = chars[i]
    if c == '\\' && i + 1 < end {
      let n = chars[i + 1]
      if n == '"' {
        buf.write_string("\"")
      } else if n == '\\' {
        buf.write_string("\\")
      } else if n == 'n' {
        buf.write_string("\n")
      } else if n == 't' {
        buf.write_string("\t")
      } else if n == 'r' {
        buf.write_string("\r")
      } else {
        buf.write_string("\{n}")
      }
      i = i + 2
    } else {
      buf.write_string("\{c}")
      i = i + 1
    }
  }
  buf.to_string()
}

///|
fn literal_at(chars : Array[Char], pos : Int32, lit : String) -> Bool {
  let lc = to_chars(lit)
  if pos + lc.length() > chars.length() {
    return false
  }
  let mut i = 0
  while i < lc.length() {
    if chars[pos + i] != lc[i] {
      return false
    }
    i = i + 1
  }
  true
}

///|
fn find_literal(chars : Array[Char], from : Int32, lit : String) -> Int32 {
  let lc = to_chars(lit)
  let mut pos = from
  while pos + lc.length() <= chars.length() {
    if literal_at(chars, pos, lit) {
      return pos
    }
    pos = pos + 1
  }
  -1
}

///|
///encode_line — 编码单条记录为 JSONL 行。
pub fn encode_line(key : String, value : String) -> String {
  "{\"key\":\"" +
  escape_json(key) +
  "\",\"value\":\"" +
  escape_json(value) +
  "\"}"
}

///|
///parse_line — 解码单条 JSONL 行；形状不符返回 None。
pub fn parse_line(line : String) -> (String, String)? {
  let chars = to_chars(line)
  let head = "{\"key\":\""
  let sep = "\",\"value\":\""
  if !literal_at(chars, 0, head) {
    return None
  }
  let key_start = to_chars(head).length()
  let sep_pos = find_literal(chars, key_start, sep)
  if sep_pos < 0 {
    return None
  }
  let value_start = sep_pos + to_chars(sep).length()
  if chars.length() < value_start + 2 {
    return None
  }
  if chars[chars.length() - 1] != '}' || chars[chars.length() - 2] != '"' {
    return None
  }
  let key = unescape_json(chars, key_start, sep_pos)
  let value = unescape_json(chars, value_start, chars.length() - 2)
  Some((key, value))
}

///|
///encode_all — 批量编码（换行连接）。
pub fn encode_all(pairs : Array[(String, String)]) -> String {
  let buf = StringBuilder()
  for pair in pairs {
    let (k, v) = pair
    buf.write_string(encode_line(k, v))
    buf.write_string("\n")
  }
  buf.to_string()
}

///|
///parse_all — 批量解码（空行与坏行跳过——容错持久化恢复）。
pub fn parse_all(text : String) -> Array[(String, String)] {
  let out : Array[(String, String)] = []
  for line in text.split("\n") {
    let s = line.to_owned()
    if s.trim() == "" {
      continue
    }
    match parse_line(s) {
      Some(pair) => out.push(pair)
      None => ()
    }
  }
  out
}
