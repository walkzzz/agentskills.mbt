///|
///F08 Storage trait 抽象（ARCH §3.1：内存 / 文件 JSONL / PostgreSQL 三后端面）。
///
///En: F08 storage abstraction — key/value contract for memory / JSONL / PostgreSQL.
///Kernel 式契约：不绑定 IO；持久化后端由实现方注入（本包先落内存实现，四目标可用）。
pub(open) trait Storage {
  fn get(Self, String) -> String?
  fn put(Self, String, String) -> Unit
  fn delete(Self, String) -> Bool
  fn all_keys(Self) -> Array[String]
  fn count(Self) -> Int32
}

///|
///MemoryStorage — 内存实现（默认后端，四目标）。
pub struct MemoryStorage {
  map : Map[String, String]
}

///|
pub fn MemoryStorage::new() -> MemoryStorage {
  let m : Map[String, String] = Map::from_array([])
  { map: m, }
}

///|
impl Storage for MemoryStorage with fn get(self, key) -> String? {
  self.map.get(key)
}

///|
impl Storage for MemoryStorage with fn put(self, key, value) -> Unit {
  self.map[key] = value
}

///|
impl Storage for MemoryStorage with fn delete(self, key) -> Bool {
  if self.map.contains(key) {
    self.map.remove(key)
    true
  } else {
    false
  }
}

///|
impl Storage for MemoryStorage with fn all_keys(self) -> Array[String] {
  let out : Array[String] = []
  for pair in self.map {
    let (k, _v) = pair
    out.push(k)
  }
  out.sort()
  out
}

///|
impl Storage for MemoryStorage with fn count(self) -> Int32 {
  self.map.length()
}

///|
pub extend MemoryStorage with Storage::{get, put, delete, all_keys, count}
