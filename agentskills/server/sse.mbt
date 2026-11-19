///|
///SSE 事件编码核（Server-Sent Events，EventSource 协议）。
///
///En: SSE event encoder — `event: <name>` + one `data: <line>` per line, blank-line terminated.
///多行 data 逐行加 `data: ` 前缀（事件流规范）；纯函数可测，传输由 async 层写出。
pub fn sse_event(event : String, data : String) -> String {
  let buf = StringBuilder()
  buf.write_string("event: ")
  buf.write_string(event)
  buf.write_string("\n")
  for line in data.split("\n") {
    buf.write_string("data: ")
    buf.write_string(line.to_owned())
    buf.write_string("\n")
  }
  buf.write_string("\n")
  buf.to_string()
}
