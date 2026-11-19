///|
///F08 JSONL IO 持久化演示（运行级验证：写 → 读 → 往返断言）。
///运行：moon run examples/storage_jsonl_demo（模块根 agentskills/）
async fn main {
  let path = "jsonl_io_demo.tmp"
  let pairs : Array[(String, String)] = [
    ("skill/demo", "{\"name\":\"demo\"}"),
    ("skill/中文", "多行\n内容\t带制表"),
  ]
  @storage.save_jsonl(path, pairs)
  let back = @storage.load_jsonl(path)
  assert_eq(back.length(), 2)
  let ok = back[0].0 == pairs[0].0 &&
    back[0].1 == pairs[0].1 &&
    back[1].0 == pairs[1].0 &&
    back[1].1 == pairs[1].1
  let status = if ok { "OK" } else { "MISMATCH" }
  println("jsonl io roundtrip: " + status)
  if !ok {
    panic()
  }
}
