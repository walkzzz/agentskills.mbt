///|
///F08 IO wrapper —— JSONL 文件持久化（薄 IO 层：编解码复用 storage 包已测纯函数核）。
///
///En: F08 IO wrapper — JSONL file persistence as a thin layer over the tested codec.
///**native-only**（@fs 属 native 目标）；本包 `supported_targets = "native"`，
///wasm/wasm-gc/js 目标由构建系统跳过（storage 包本身保持四目标）。

///|
///save_jsonl — 批量写出（encode_all 换行连接，覆盖写）。
pub async fn save_jsonl(path : String, pairs : Array[(String, String)]) -> Unit {
  @fs.write_file(path, @storage.encode_all(pairs))
}

///|
///load_jsonl — 读取并解码（空行/坏行跳过；文件不存在时由 @fs 抛出）。
pub async fn load_jsonl(path : String) -> Array[(String, String)] {
  let data = @fs.read_file(path)
  @storage.parse_all(data.text())
}
